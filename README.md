# Pravah AI — Autonomous Vendor Onboarding Employee
### Supervity AutoPilot Hackathon: Ahmedabad Edition — Domain B: Track B1 (Vendor & Procurement Lifecycle)

[![Supervity Auto](https://img.shields.io/badge/Platform-Supervity%20Auto-blue.svg)](https://auto.supervity.ai/)
[![Database](https://img.shields.io/badge/Database-Supabase%20PostgreSQL-3ECF8E.svg)](https://supabase.com)
[![Channel](https://img.shields.io/badge/Channel-Microsoft%20Outlook-0078D4.svg)](https://outlook.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📌 Executive Summary
**Pravah AI** ("Pravah" meaning *continuous, uninterrupted stream*) is an autonomous enterprise AI Employee engineered for **Ashvaka Industries Group** in Ahmedabad. It transforms manual, latency-ridden vendor onboarding into a high-velocity, zero-friction ("operational antigravity") digital workflow running live on the **Supervity Auto** platform.

Operating across Ashvaka Group companies (**AI10** Infrastructure, **AC20** Cement, **AE30** Energy, and **AL40** Logistics), Pravah AI handles incoming vendor registration packets from the moment they arrive via email to final SAP-ready verified record creation, autonomously detecting document discrepancies, executing multi-turn vendor chases, and escalating true compliance exceptions to human authorities.

---

## 🏗️ Architecture: Hybrid Agent Paradigm

Pravah AI bridges unstructured real-world communication with deterministic enterprise ERP governance using a two-layer architecture:
1. **Agentic Cognitive Layer (Supervity Auto + Multimodal LLM):** Parses incoming emails, handles thread continuity, extracts key fields via Agentic OCR from heterogeneous PDFs (GST REG-06, PAN cards, Bank Letters, Cancelled Cheques, ISO 45001, Insurance).
2. **Deterministic Compliance Micro-Service:** Strictly enforces 21 business verification rules, currency & unit normalizations, format checksums, and master duplicate checks with mathematical precision.

```
                    ┌──────────────────────────────────────────────┐
                    │            MICROSOFT OUTLOOK.COM             │
                    │   Mailbox 1 (The Desk)    Mailbox 2 (The World)
                    └───────────────▲──────────────────▲───────────┘
                                    │                  │
                         Inbound / Outbound      Contact Map / Redirect
                                    │                  │
                    ┌───────────────▼──────────────────▼───────────┐
                    │               SUPERVITY AUTO                 │
                    │            (auto.supervity.ai)               │
                    │                                              │
                    │  [Trigger] ──> [Parser / OCR]                │
                    │                      │                       │
                    │           [Deterministic Rules]              │
                    │                      │                       │
                    │           [Decision & Gateways]              │
                    │           ├── Clean ──> Auto Handover        │
                    │           ├── Gap ───> Auto Chase Email      │
                    │           └── Exception ──> Human Task Modal │
                    └──────────────────────┬───────────────────────┘
                                           │
                                    Read / Write Records
                                           │
                    ┌──────────────────────▼───────────────────────┐
                    │               SUPABASE CLOUD                 │
                    │  - onboarding_request  - chase_log           │
                    │  - document_requirement - vendor_master      │
                    │  - verification_rule   - verification_audit  │
                    │  - contact_map         - review_tasks        │
                    └──────────────────────────────────────────────┘
```

---

## 📋 Compliance & Verification Rule Engine

Pravah AI implements the full Ashvaka Industries verification rulebook:
- **Presence Rules:**
  - `PRS-01`: All mandatory documents received for vendor category (e.g. `EQUIP_RENTAL`, `CIVIL_WORKS`).
  - `PRS-02`: Udyam registration certificate validated if MSME status declared.
- **Validity & Cryptographic Structure:**
  - `VAL-01`: 15-character GSTIN structure, state code, and check character.
  - `VAL-02`: 10-character PAN structure; 4th character ('C' for Company, 'F' for Firm/LLP, 'P' for Proprietorship) strictly matching declared constitution.
  - `VAL-03`: 11-character IFSC format (`^[A-Z]{4}0[A-Z0-9]{6}$`).
  - `VAL-04`: GSTIN state code matching principal place of business and declared state.
  - `VAL-05`: Bank proof validation (Account number, IFSC, Account holder name).
- **Temporal Validity (Expiry):**
  - `EXP-01`: Zero expired documents against reference business date (**09 Oct 2026, 18:00 IST**).
  - `EXP-02`: Documents lapsing within 30 days flagged for proactive renewal chase.
  - `EXP-03`: Lapsed documents with renewal receipts accepted only if filed <= expiry date, receipt <= 60 days old, and flagged for human sign-off.
- **Cross-Document Consistency:**
  - `XDC-01`: Legal name identity across GST, PAN, Certificate of Incorporation, and Udyam.
  - `XDC-02`: PAN embedded in GSTIN (characters 3–12) exactly matching PAN document.
  - `XDC-03`: Account holder name on bank proof matching legal entity name under flexible name-matching rules (treating `Pvt Ltd` == `Private Limited`, dropping `M/s` prefix, but flagging extra words like `Industries`).
- **Master Data Duplicate Checks:**
  - `DUP-01`: Search SAP `vendor_master` by PAN, GSTIN, and Bank Account Number. Any match halts automation and triggers a Human Review Task. Never matches on name alone.
  - `DUP-02`: State extension detection for existing PAN holders.
- **Chase Cadence & Working Days:**
  - `CHS-00`: Calculates working days excluding weekends and official 2026 Ashvaka group holidays (Independence Day, Raksha Bandhan, Janmashtami, Gandhi Jayanti, Dussehra, Diwali, etc.).
  - `CHS-01` & `CHS-02`: Chase Round 1 (+2 working days) and Chase Round 2 (+3 working days).

---

## 🚀 Enterprise Operations Console & REST API Operator

Pravah AI includes a production-grade **Enterprise Operations Console** (`console/index.html`) and dual-mode REST API operator (`tools/api_operator.py`):

```bash
# Launch Console & API Operator in one command:
python tools/api_operator.py
```
Open **[http://localhost:8080](http://localhost:8080)** in any browser (or open `console/index.html` directly):
- 📊 **Executive KPI Telemetry:** Real-time run rate (105 req/mo), manual labor saved (62.5 hrs/mo), and autonomous clean pass rate (87.4%).
- 📋 **Live Intake Directory:** Filter and search all 130 requests by ID, vendor name, buyer, or purchase category (`EQUIP_RENTAL`, `CIVIL_WORKS`, etc.).
- ⚖️ **Decoupled Verification Matrix:** Complete table of all 24 Ashvaka business rules changeable by non-technical function owners.
- 🛡️ **Human Review Queue (HITL):** Live exception workbench for Rule `DUP-01` (Probable Duplicate PAN) allowing approvers to merge, extend, or reject duplicates with audit logging.
- 🧪 **Evaluator Testing Sandbox:** Interactive payload test environment where evaluators can test any JSON record against the deterministic engine and see instant rule evaluations.

---

## 🚀 Repository Structure

```
├── README.md                           # Master Project Documentation
├── EVALUATOR_GUIDE.md                  # Step-by-Step Evaluator & Jury Testing Guide
├── ROUND1_SUBMISSION_BRIEF.md          # Form-ready Round 1 Submission Brief
├── DEMO_SCRIPT.md                      # 5-minute Pitch & Screen-Recording Script
├── SUPERVITY_AUTO_SPEC.md              # Node-by-Node Supervity Auto Technical Canvas Spec
├── LICENSE                             # MIT License
├── .gitignore                          # Git configuration
├── console/                            # Enterprise Operations Console
│   └── index.html                      # Interactive Glassmorphism Dashboard & Evaluator Sandbox
├── staged_reply_0002/                  # Staged Reply 0002 Test Artifacts
│   ├── body.txt                        # Reply body with virtual sender mapping
│   └── cancel cheque.pdf               # Corrected Cheque Leaf for VOR-26-0567
├── pack_B1/                            # Official Hackathon Pack
│   ├── 00_START_HERE.md                # Official track narrative & walkthrough
│   ├── problem_statement/              # Official problem statement PDF
│   ├── setup_kit/                      # Ready-to-import CSVs & SQL schemas
│   │   ├── Column_Guide.md             # Data dictionary
│   │   ├── supabase_seed.sql           # Initial 6-table database schema
│   │   └── supabase_pravah_extensions.sql # Contact map, audit, and review queue
│   └── dataset/                        # Benchmark documents, mailbox, and rules
├── tools/                              # Execution & Testing Suite
│   ├── api_operator.py                 # REST API & Console HTTP Server (port 8080)
│   ├── build_console.py                # Standalone Operations Console generator
│   ├── pravah_engine.py                # Core deterministic verification engine (24 rules)
│   ├── test_pravah_engine.py           # Automated unit test suite (100% passing)
│   ├── eml_helper.py                   # EML inspection and extraction utility
│   ├── simulate_vor_0567.py            # End-to-end run: VOR-26-0567 + Staged Reply 0002
│   └── simulate_exception_duplicate.py # Declared Exception run: DUP-01 + Human Approver
└── pravah_ai_master_blueprint.md       # Master Blueprint, Architecture & RTM
```

---

## 🧪 Local Simulation & Test Verification

You can reproduce the exact hackathon benchmark runs locally in seconds:

### 1. Launch Operations Console & REST API
```bash
python tools/api_operator.py
```
*Serves the web console at `http://localhost:8080` with `/health`, `/verify`, and `/resolve_task` endpoints.*

### 2. Run Core Rule Engine Unit Tests
```bash
python tools/test_pravah_engine.py
```
*Validates name normalization, PAN 4th character check, GSTIN checksums, IFSC verification, and working-day holiday scheduling.*

### 3. Run End-to-End Test Case (`VOR-26-0567`)
```bash
python tools/simulate_vor_0567.py
```
*Simulates intake of Sankalp Equipment Hire Pvt Ltd, detection of extra word 'Industries' in bank certificate (XDC-03 failure), auto-generation of Chase 1 email, receipt of staged reply 0002 with corrected cancelled cheque, rule normalization, and emission of verified SAP handover pack.*

### 4. Run Declared Exception Test Case (`DUP-01: Probable Duplicate`)
```bash
python tools/simulate_exception_duplicate.py
```
*Simulates arrival of a vendor request whose PAN already exists in SAP Vendor Master under a different spelling. Demonstrates how automation halts, packages evidence, and requests a recorded human decision.*

---

## 🔗 Live System Links

- **Supervity Auto Live Canvas:** [https://auto.supervity.ai/u/alpha/agent/01a12a32-3e3d-702c-9c5f-dc55476b8ef0](https://auto.supervity.ai/u/alpha/agent/01a12a32-3e3d-702c-9c5f-dc55476b8ef0) (Organization: `NexAura`)
- **Supabase Cloud System of Record:** [https://nacjwuajfopkxgmkpipw.supabase.co](https://nacjwuajfopkxgmkpipw.supabase.co)
- **GitHub Repository:** [https://github.com/fenilpatel-Builds/pravah-ai](https://github.com/fenilpatel-Builds/pravah-ai)

---

## 👥 Hackathon Team & Author Attribution
- **Team Name:** Team NexAura
- **Developer & Presenter:** Fenil Patel (`fenil8918@gmail.com`)
- **Domain:** Domain B — Vendor & Procurement Lifecycle (Track B1: Vendor Onboarding)
- **Edition:** Supervity AutoPilot Hackathon — Ahmedabad Edition (October 2026)
