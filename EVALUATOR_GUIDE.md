# Pravah AI — Evaluator & Judge Testing Guide
### Supervity AutoPilot Hackathon: Ahmedabad Edition (Round 1)

Dear Evaluators and Judges,

Welcome to the **Pravah AI** live testing portal. Pravah AI runs autonomously on the **Supervity Auto** platform, connected to live **Microsoft Outlook** (Channel) and **Supabase PostgreSQL** (System of Record).

---

## 🚀 Live Trigger Instructions for Evaluators

You can test Pravah AI by sending a live email to the intake mailbox with an onboarding packet. Pravah AI will autonomously process the email, parse the documents, execute all 21 verification rules, update Supabase, and either:
1. Dispatch a verified handover packet to `vendor.master@ashvakagroup.in`.
2. Generate an autonomous chase email naming the exact document discrepancy.
3. Halt and route to the **Human Review Modal** if an exception is detected.

---

### Step 1: Send a Test Email
- **To:** `ashvaka.desk.pravah@outlook.com` *(Configured Desk Mailbox)*
- **Subject:** `Vendor registration | VOR-26-0567 | Sankalp Equipment Hire Private Limited`
- **First Line of Body (Crucial for Virtual Identity):**
  ```text
  On behalf of: Meera Amin <meera.amin@sankalpequipmenthi.co.in>
  ```
- **Body Content:**
  ```text
  Dear Onboarding Desk,

  Please find attached our registration documents for request VOR-26-0567.

  Regards,
  Meera Amin
  Accounts Manager, Sankalp Equipment Hire Private Limited
  ```
- **Attachments:** Attach the 6 documents located in [`pack_B1/dataset/documents/VOR-26-0567/`](file:///c:/Users/Harshit/Desktop/vendor_%20procurement_lifecycle/pack_B1/dataset/documents/VOR-26-0567/) (`SEH GST.pdf`, `PAN.pdf`, `Bank certificate.pdf`, `SEH COI.pdf`, `ISO Certificate.pdf`, `Policy Certificate.pdf`).

---

### Step 2: What Pravah AI Does Live (No Builder Intervention)
1. **Intake & OCR:** Ingests email and runs agentic OCR across all 6 PDFs.
2. **Deterministic Verification:** 
   - Detects that `Bank certificate.pdf` lists the account holder as `M/s Sankalp Equipment Hire Industries Private Limited`.
   - Flags **Rule XDC-03 FAILURE** due to the extra word **'Industries'** not matching the legal name (`SANKALP EQUIPMENT HIRE PRIVATE LIMITED`).
3. **Autonomous Chase 1:** Immediately dispatches an automated Chase Round 1 email to `meera.amin@sankalpequipmenthi.co.in` (redirected to Mailbox 2) explaining the exact discrepancy.
4. **Audit Logging:** Inserts execution trail into Supabase table `verification_audit`.

---

### Step 3: Test Multi-Turn Reply (Releasing Staged Reply 0002)
- From your mailbox, reply to the chase email (or send a new email in the same thread):
- **Subject:** `RE: Vendor registration | VOR-26-0567 | Sankalp Equipment Hire Private Limited`
- **First Line:** `On behalf of: Meera Amin <meera.amin@sankalpequipmenthi.co.in>`
- **Attachment:** Attach `cancel cheque.pdf` (from [`pack_B1/mailbox/staged_replies/0002__20261012_1142.eml`](file:///c:/Users/Harshit/Desktop/vendor_%20procurement_lifecycle/pack_B1/mailbox/staged_replies/0002__20261012_1142.eml) or tools folder).
- **Outcome:** Pravah AI applies Ashvaka Name Normalization (`Pvt. Ltd.` == `Private Limited`), confirms **ALL RULES PASS**, and dispatches the verified handover packet to `vendor.master@ashvakagroup.in` with zero human intervention!

---

## 🛡️ Testing the Declared Exception (Duplicate PAN: Rule DUP-01)

To test Pravah AI's exception handling and Human-in-the-Loop decision enforcement:
1. Send an email with a new request ID (e.g. `VOR-26-9999`) with a vendor claiming legal name `M/S RADHE RMC & CO CONTRACTORS`.
2. Include PAN `DHTFR7891Z` or GSTIN `33DHTFR7891Z1ZY` (which already exists in SAP `vendor_master` under vendor `200100`).
3. **Observed Behavior:**
   - Pravah AI detects the match on PAN/GSTIN in SAP Master Data.
   - Automation is **HALTED**. Pravah AI refuses to auto-create or overwrite.
   - Creates a pending record in `review_tasks` and presents the **Human Review Decision Modal** to the Procurement Approver.
   - The decision (`MERGE` / `EXTEND` / `REJECT`) is recorded in the immutable audit log.

---

## 📊 Live System of Record Verification (Supabase)
Evaluators can view live table updates at:
- **Supabase Project URL:** `https://nacjwuajfopkxgmkpipw.supabase.co`
- Tables to inspect:
  - `onboarding_request`: Real-time status progression.
  - `verification_audit`: Immutable rule evaluation logs with timestamps.
  - `chase_log`: Record of autonomous outbound chase emails.
  - `review_tasks`: Human-in-the-Loop exception approvals.
