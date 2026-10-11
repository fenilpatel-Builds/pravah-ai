# Pravah AI — Round 1 Submission Brief
### Supervity AutoPilot Hackathon: Ahmedabad Edition
**Domain B: Vendor & Procurement Lifecycle | Track B1: Vendor Onboarding**  
**Team Name:** Team NexAura  
**Team Member:** Fenil Patel (`fenil8918@gmail.com`)  
**Repository:** [https://github.com/fenilpatel-Builds/pravah-ai](https://github.com/fenilpatel-Builds/pravah-ai)  
**Supervity Auto Workspace:** `[INSERT_YOUR_SUPERVITY_WORKSPACE_URL]`  

---

### 1. The Job
Pravah AI is an autonomous enterprise AI Employee engineered for **Ashvaka Industries Group** in Ahmedabad. It takes vendor onboarding registration packets from the moment they arrive via email, parses all compliance documents, evaluates 21 deterministic business verification rules, autonomously chases missing or inconsistent details by email, and hands a verified vendor pack to the SAP master data team with zero manual intervention for clean records.

### 2. The Trigger
- **Channel:** Microsoft Outlook (Personal Outlook.com account).
- **Event:** Inbound email received by Mailbox 1 (The Desk: standing in for `vendor.onboarding@ashvakagroup.in`) with subject matching `Vendor registration` or `VOR-` and PDF attachments.
- **Header Parsing:** Automatically resolves sender identity from `On behalf of: [Name] <[Email]>` when sent from simulator mailboxes.

### 3. The Rules & Verification Engine
- **Presence:** `PRS-01` (Mandatory documents by category), `PRS-02` (Udyam certificate for declared MSMEs).
- **Structure & Validity:** `VAL-01` (15-character GSTIN & checksum), `VAL-02` (10-character PAN structure with 4th character strictly matching company/LLP/proprietor constitution), `VAL-03` (IFSC format).
- **Temporal Validity:** `EXP-01` (Zero lapsed documents as of fixed date **09 Oct 2026, 18:00 IST**), `EXP-02` (Warning flag for documents expiring <= 30 days).
- **Cross-Document Consistency:** `XDC-01` (Legal name identical across GST, PAN, COI), `XDC-02` (Embedded PAN in GSTIN matches PAN card), `XDC-03` (Bank proof account holder matches legal entity name, applying normalization where `Pvt Ltd` == `Private Limited`, but failing extra words).
- **Cadence & Working Days:** `CHS-00` (Calculates chase deadlines excluding weekends & 8 Ashvaka 2026 group holidays), `CHS-01` (Chase Round 1 at +2 working days).

### 4. The Connected Systems
1. **Trigger & Communication Channel:** Microsoft Outlook (Personal Outlook.com account).
2. **System of Record:** Supabase Cloud PostgreSQL (`pravah-vendorflow`) housing `onboarding_request`, `document_requirement`, `verification_rule`, `vendor_master`, `chase_log`, `received_document`, `contact_map`, and `verification_audit`.
3. **Execution Platform:** Supervity Auto ([auto.supervity.ai](https://auto.supervity.ai/)).
4. **Zero Google Ecosystem:** No Gmail, Google Sheets, or Google Drive used.

### 5. Declared Exception Handled Live
- **Rule DUP-01: Probable Duplicate in SAP Vendor Master.**
- When a vendor request arrives whose legal name differs (e.g. `M/S RADHE RMC & CO CONTRACTORS`), but its PAN or GSTIN matches an existing record in SAP `vendor_master` (LIFNR `200100`), Pravah AI halts automation immediately.
- It generates a structured Context Package with matching LIFNR and evidence, and triggers a live **Human Review Task Modal** in Supervity Auto.

### 6. What a Human Still Approves
1. **Master Data Duplicate Merges & State Extensions:** Deciding whether to merge a matching PAN into an existing SAP vendor or create an extension.
2. **Lapsed Documents with Renewal Receipts (`EXP-03`):** Accepting an expired licence accompanied by a renewal receipt filed on or before expiry.
3. **Unresolved Two-Round Chase Escalations (`CHS-03`):** Reviewing vendors who fail to resolve document discrepancies after two chase rounds.

### 7. Level Reached
- **Round 1 Minimum:** 100% Complete (`EQUIP_RENTAL` & `CIVIL_WORKS` end-to-end, live trigger, Supabase read/write, Chase 1, handover).
- **Strong Scope:** 100% Complete (Format & checksum validations, name normalization engine, Ashvaka working-day holiday calendar, multi-turn staged reply ingestion).

### 8. How an Evaluator Sends Your Auto a New Record
1. Send an email to the Desk Mailbox: `ashvaka.desk.pravah@outlook.com`
2. **Subject:** `Vendor registration | VOR-26-0567 | Sankalp Equipment Hire Private Limited`
3. **First Line of Body:** `On behalf of: Meera Amin <meera.amin@sankalpequipmenthi.co.in>`
4. **Attachments:** Attach the 6 sample PDFs from [`pack_B1/dataset/documents/VOR-26-0567/`](https://github.com/fenilpatel-Builds/pravah-ai/tree/main/pack_B1/dataset/documents/VOR-26-0567).
5. Watch Pravah AI flag the bank certificate mismatch, issue Chase 1, ingest staged reply 0002, and transmit the final verified pack!
