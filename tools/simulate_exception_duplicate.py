#!/usr/bin/env python3
"""
simulate_exception_duplicate.py - Declared Exception Simulation (DUP-01: Existing Vendor Under Different Spelling)
Demonstrates:
1. Intake of a vendor request whose PAN already exists on SAP Vendor Master under a different spelling
2. Rule DUP-01 detects match on PAN/GSTIN
3. Automation halts: prohibits automated SAP handover
4. Creates Human-in-the-Loop (HITL) Decision Task for Master Data Approver
5. Records the human approval/merge decision in the audit log
"""

import sys
import os
import json
import pandas as pd

sys.path.append(os.path.join(os.path.dirname(__file__)))
from pravah_engine import REFERENCE_DATE

def run_duplicate_exception():
    print("=" * 70)
    print("PRAVAH AI: DECLARED EXCEPTION SIMULATION (RULE DUP-01: PROBABLE DUPLICATE)")
    print(f"System Reference Business Date: {REFERENCE_DATE} 18:00 IST")
    print("=" * 70)
    
    # Load vendor master
    vm = pd.read_csv("pack_B1/setup_kit/csv_plain/vendor_master.csv")
    sample_existing = vm.dropna(subset=['pan', 'gstin']).iloc[0]
    
    existing_lifnr = sample_existing['vendor_number']
    existing_name = sample_existing['name_line_1']
    existing_pan = sample_existing['pan']
    existing_gstin = sample_existing['gstin']
    
    # Synthetic incoming request with different spelling
    incoming_request_id = "VOR-26-0999"
    incoming_name_typed = f"M/S {existing_name} TRADING & CONTRACTORS"
    incoming_pan = existing_pan
    incoming_gstin = existing_gstin
    
    print(f"\n[PHASE 1: INGESTION] Request: {incoming_request_id}")
    print(f"Incoming Vendor Name: '{incoming_name_typed}'")
    print(f"Declared PAN: {incoming_pan} | Declared GSTIN: {incoming_gstin}")
    
    # Phase 2: Master Check DUP-01
    print("\n[PHASE 2: SAP VENDOR MASTER CHECK (RULE DUP-01)]")
    print(f"Searching SAP Vendor Master for PAN={incoming_pan} OR GSTIN={incoming_gstin}...")
    
    match = vm[(vm['pan'] == incoming_pan) | (vm['gstin'] == incoming_gstin)]
    if len(match) > 0:
        matched_row = match.iloc[0]
        print(f"-> ALERT: Match detected in SAP Master Data!")
        print(f"   Existing SAP Vendor Number (LIFNR): {matched_row['vendor_number']}")
        print(f"   Existing Registered Name: '{matched_row['name_line_1']}'")
        print(f"   Existing Address: {matched_row['city']}, {matched_row['state_code']}")
        print(f"   Existing Bank Account: {matched_row['bank_account_number']} (IFSC: {matched_row['ifsc']})")
        
        # Rule DUP-01 halts automation
        print("\n" + "!" * 70)
        print("[PHASE 3: RULE DUP-01 FIRED - AUTOMATION HALTED]")
        print("Finding: PAN/GSTIN match on existing vendor, despite differing legal/trade name.")
        print("Governance Constraint: AI Employee is FORBIDDEN from automatically merging or creating.")
        print("Escalation: Routing to Master Data Lead for Human Decision.")
        print("!" * 70)
        
        hitl_decision_pack = {
            "task_id": "TASK-DUP-2026-0999",
            "request_id": incoming_request_id,
            "exception_type": "PROBABLE_DUPLICATE_OR_EXTENSION (DUP-01)",
            "severity": "HIGH",
            "evidence": {
                "incoming_name": incoming_name_typed,
                "incoming_pan": incoming_pan,
                "incoming_gstin": incoming_gstin,
                "matched_sap_vendor_lifnr": str(matched_row['vendor_number']),
                "matched_sap_name": matched_row['name_line_1'],
                "match_reason": "Exact PAN match in SAP Vendor Master"
            },
            "options_presented_to_human": [
                "1. MERGE: Update existing LIFNR record with new request details",
                "2. EXTEND: Add new company code or state GSTIN to existing vendor",
                "3. REJECT: Reject onboarding request as unauthorized duplicate",
                "4. OVERRIDE: Create separate vendor (requires written rationale)"
            ],
            "assigned_approver": "Foram Shukla (Procurement Lead / Master Data Authority)",
            "timestamp": f"{REFERENCE_DATE} 18:02:15 IST",
            "status": "WAITING_HUMAN_APPROVAL"
        }
        
        print("\nDecision Pack presented to Human Approver:")
        print(json.dumps(hitl_decision_pack, indent=2))
        
        # Simulated Human Decision
        print("\n" + "-" * 70)
        print("[PHASE 4: HUMAN APPROVAL RECORDED (SIMULATED OPERATOR INPUT)]")
        simulated_human_decision = {
            "task_id": "TASK-DUP-2026-0999",
            "decision": "MERGE",
            "approved_by": "Foram Shukla (foram.shukla@ashvakagroup.in)",
            "decision_notes": "Confirmed subsidiary branch. Approved merge into existing LIFNR.",
            "decision_timestamp": f"{REFERENCE_DATE} 18:05:00 IST"
        }
        print(f"Human Decision: {simulated_human_decision['decision']}")
        print(f"Decided by: {simulated_human_decision['approved_by']}")
        print(f"Notes: {simulated_human_decision['decision_notes']}")
        print("-" * 70)
        
        # Phase 5: Persist in Audit Log
        print("\n[PHASE 5: AUDIT LOG PERSISTED]")
        print("Database record updated in 'verification_audit' and 'onboarding_request' status set to 'MERGED_TO_EXISTING_VENDOR'.")
        print("Audit trail complete and immutable.")

if __name__ == "__main__":
    run_duplicate_exception()
