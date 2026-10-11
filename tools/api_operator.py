#!/usr/bin/env python3
"""
api_operator.py - REST API Operator for Supervity Auto Integration
Provides HTTP endpoints for Supervity Auto to invoke Pravah AI's deterministic rule engine.
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__)))
from pravah_engine import (
    names_match,
    validate_pan,
    validate_gstin,
    validate_ifsc,
    check_expiry,
    calculate_working_days,
    REFERENCE_DATE
)

class PravahOperatorHandler(BaseHTTPRequestHandler):
    def _send_response(self, status_code, data):
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

    def do_OPTIONS(self):
        self._send_response(200, {"status": "ok"})

    def do_GET(self):
        if self.path == "/health":
            self._send_response(200, {
                "status": "HEALTHY",
                "service": "Pravah AI Deterministic Operator",
                "reference_date": str(REFERENCE_DATE)
            })
        else:
            self._send_response(404, {"error": "Not Found"})

    def do_POST(self):
        if self.path == "/verify":
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            try:
                payload = json.loads(post_data.decode('utf-8'))
            except Exception as e:
                self._send_response(400, {"error": f"Invalid JSON payload: {e}"})
                return

            # Extract fields
            legal_name = payload.get("legal_name", "")
            pan = payload.get("pan", "")
            gstin = payload.get("gstin", "")
            constitution = payload.get("constitution", "")
            state = payload.get("state", "")
            bank_holder = payload.get("bank_account_holder", "")
            ifsc = payload.get("ifsc", "")
            expiries = payload.get("expiries", {}) # dict of doc_name -> date_str

            # Run deterministic evaluations
            rule_results = {}
            gaps = []

            # 1. PAN
            pan_ok, pan_msg = validate_pan(pan, constitution=constitution)
            rule_results["VAL-02"] = {"pass": pan_ok, "msg": pan_msg}
            if not pan_ok:
                gaps.append(f"PAN Validation (VAL-02): {pan_msg}")

            # 2. GSTIN
            gst_ok, gst_msg = validate_gstin(gstin, pan=pan, state_code=state)
            rule_results["VAL-01"] = {"pass": gst_ok, "msg": gst_msg}
            if not gst_ok:
                gaps.append(f"GSTIN Validation (VAL-01): {gst_msg}")

            # 3. IFSC
            ifsc_ok, ifsc_msg = validate_ifsc(ifsc)
            rule_results["VAL-03"] = {"pass": ifsc_ok, "msg": ifsc_msg}
            if not ifsc_ok:
                gaps.append(f"IFSC Validation (VAL-03): {ifsc_msg}")

            # 4. Bank Account Holder Name Match (XDC-03)
            holder_match = names_match(legal_name, bank_holder)
            rule_results["XDC-03"] = {
                "pass": holder_match,
                "msg": "Matches legal entity name" if holder_match else f"Account holder '{bank_holder}' does not match legal name '{legal_name}'"
            }
            if not holder_match:
                gaps.append(f"Bank Account Holder Mismatch (XDC-03): Bank proof shows '{bank_holder}', but legal name is '{legal_name}'")

            # 5. Expiries
            for doc, exp_str in expiries.items():
                exp_stat, exp_msg = check_expiry(exp_str)
                rule_results[f"EXP-{doc}"] = {"status": exp_stat, "msg": exp_msg}
                if exp_stat == "EXPIRED":
                    gaps.append(f"Document Expired: {doc} lapsed ({exp_msg})")

            # Determine Outcome
            if len(gaps) == 0:
                outcome = "VERIFIED_PASS"
                action = "DISPATCH_HANDOVER_TO_MASTER_DATA"
                chase_body = None
            else:
                outcome = "GAP_DETECTED"
                action = "GENERATE_AUTONOMOUS_CHASE"
                chase_body = f"Please resolve the following discrepancy:\n" + "\n".join(f"- {g}" for g in gaps)

            response_data = {
                "outcome": outcome,
                "action": action,
                "rules_evaluated": rule_results,
                "open_gaps": gaps,
                "chase_body": chase_body,
                "reference_date": str(REFERENCE_DATE)
            }
            self._send_response(200, response_data)
        else:
            self._send_response(404, {"error": "Endpoint not found"})

def run_server(port=8080):
    server_address = ('', port)
    httpd = HTTPServer(server_address, PravahOperatorHandler)
    print(f"Pravah AI Operator Server listening on port {port}...")
    print(f"Endpoints available: GET /health | POST /verify")
    httpd.serve_forever()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    run_server(port)
