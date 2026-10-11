# Pravah AI — 5-Minute Hackathon Demo Script
### Supervity AutoPilot Hackathon: Ahmedabad Edition (Round 1)

**Target Duration:** Exactly 4:45 – 5:00 Minutes  
**Presenter:** Fenil Patel (Team NexAura)  
**Tone:** Confident, enterprise-focused, professional, and clear.

---

### [0:00 – 0:45] Introduction & The Enterprise Problem
- **Visual:** Show Supervity Auto dashboard ([auto.supervity.ai](https://auto.supervity.ai/)) with the **Pravah AI** workflow open.
- **Voiceover:**
  > *"Hello judges. I'm Fenil Patel from **Team NexAura**, presenting **Pravah AI** — our autonomous enterprise AI Employee built on Supervity Auto for Domain B: Vendor Onboarding at Ashvaka Industries Group in Ahmedabad.*
  > *In heavy industrial conglomerates like Ashvaka — spanning cement, infrastructure, energy, and logistics — vendor onboarding is traditionally burdened by severe operational drag. Between September 3rd and October 9th alone, 130 vendor registration requests were filed — roughly 105 per month. Processing a single vendor manually takes 35 minutes of tedious cross-checking, back-and-forth emails, and duplicate searching. That’s over 60 hours of high-cost human labour wasted every single month.*
  > *Pravah AI delivers true operational antigravity. It autonomously ingests registration packets via Outlook, runs 21 deterministic compliance checks, executes multi-turn vendor chases, updates Supabase in real-time, and routes true exceptions to human decision-makers."*

---

### [0:45 – 2:00] Live Scenario 1: Intake, OCR & Autonomous Chase
- **Visual:** Switch to **Outlook Web App** (Mailbox 1 / Desk). Show the incoming email for `VOR-26-0567` (Sankalp Equipment Hire Pvt Ltd) arriving with 6 PDF attachments.
- **Voiceover:**
  > *"Let's watch Pravah AI execute live. An email arrives from vendor contact Meera Amin for equipment rental request VOR-26-0567, containing six PDF attachments: GST REG-06, PAN card, bank certificate, Certificate of Incorporation, ISO 45001, and insurance.*
  > *Pravah AI’s Outlook trigger immediately fires. It resolves the sender identity, reads the request metadata from our connected Supabase database, and applies agentic OCR.*
  > *Now notice what happens: all individual documents look authentic. But our deterministic compliance engine runs Rule XDC-03 — Cross-Document Bank Alignment. The IDFC FIRST Bank letter has account holder name 'M/s Sankalp Equipment Hire Industries Private Limited'. The registered legal entity is 'Sankalp Equipment Hire Private Limited'. The extra word 'Industries' is an instant compliance blocker."*
- **Visual:** Switch to **Outlook Mailbox 2** (The World). Show the automated Chase Round 1 email that Pravah AI just dispatched.
- **Voiceover:**
  > *"Instead of guessing or crashing, Pravah AI autonomously generates Chase Round 1 directly to the vendor contact, explicitly naming Rule XDC-03 and highlighting the exact mismatch on the bank proof. Everything is recorded in our Supabase chase log with a 2-working-day deadline calculated using Ashvaka's holiday calendar."*

---

### [2:00 – 3:15] Multi-Turn Staged Reply & Autonomous Handover
- **Visual:** Show Mailbox 2 replying with the staged reply (0002) containing `cancel cheque.pdf`.
- **Voiceover:**
  > *"Now the vendor replies. Meera Amin sends a corrected cancelled cheque leaf where the account holder reads 'SANKALP EQUIPMENT HIRE PVT. LTD.'*
  > *Pravah AI ingests this reply in the same thread. It applies Ashvaka's name normalization engine — recognizing that 'Pvt. Ltd.' equals 'Private Limited'. Rule XDC-03 now PASSES!*
  > *Next, it performs Rule DUP-01: querying SAP Vendor Master by PAN, GSTIN, and Bank Account number. No duplicate exists. All 21 checks are green.*
  > *Because the pack is 100% compliant, Pravah AI autonomously generates the Verified Handover Pack and transmits it to vendor.master@ashvakagroup.in for SAP creation — requiring ZERO manual intervention from our team."*
- **Visual:** Switch to Supabase Table View. Show `onboarding_request` updated to `VERIFIED_PACK_HANDED_OVER`.

---

### [3:15 – 4:15] Declared Exception: Duplicate PAN & Human-in-the-Loop (DUP-01)
- **Visual:** Trigger request `VOR-26-0999` (Vendor with differing name but existing PAN). Show Supervity Auto's Human Review Modal.
- **Voiceover:**
  > *"Now let's demonstrate our declared exception: Rule DUP-01 — Probable Duplicate in SAP Vendor Master.*
  > *A new request arrives under the name 'M/S RADHE RMC & CO CONTRACTORS'. But when Pravah AI scans the master, it discovers that this PAN and GSTIN already belong to an active SAP vendor (LIFNR 200100) registered as 'RADHE RMC & CO'.*
  > *Governance is strictly enforced: an AI must NEVER automatically merge financial entities or create duplicate vendor master records. Pravah AI halts automated processing immediately, flags the severity as HIGH, and presents a structured Context Package to Procurement Lead Foram Shukla.*
  > *As the human approver, I am presented with 4 clear choices: Merge into Existing Vendor, Extend State GSTIN, Reject Duplicate, or Override.*
  > *I click 'MERGE'. The decision, approver identity, and timestamp are immediately locked into the immutable Supabase audit log."*

---

### [4:15 – 5:00] Governance, Architecture & Conclusion
- **Visual:** Show Supabase `verification_audit` and `contact_map` tables, followed by the GitHub repository [`https://github.com/fenilpatel-Builds/pravah-ai`](https://github.com/fenilpatel-Builds/pravah-ai).
- **Voiceover:**
  > *"To summarize our build:
  > 1. We run live on Supervity Auto with zero Google integrations, connected to Outlook and Supabase PostgreSQL.
  > 2. Business rules, approver matrices, and contact routing are completely decoupled from prompts inside Supabase tables, allowing non-technical function owners to adjust policies instantly.
  > 3. An immutable audit trail captures every rule evaluation, evidence snippet, and human decision.
  > 4. Pravah AI saves Ashvaka Group over 60 hours per month, cuts onboarding turnaround from 45 days down to minutes, and guarantees zero bad master data enters SAP.
  > Thank you!"*
