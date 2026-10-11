# Start here: B1

**Vendor onboarding: collecting the documents, verifying them, and chasing what is missing**

## The story

At Ashvaka Industries Group in Ahmedabad, the Vendor Onboarding Desk registers every new supplier a buyer wants to use, from crane hire firms to labour contractors. For each request the desk emails the vendor a checklist, and the vendor replies with PDFs: a GST certificate, a PAN, a cancelled cheque or bank letter, and licences or certificates for its line of work. Each paper can look fine on its own, yet the bank account may be in a name one word different from the GST certificate, or the insurance may have lapsed last month. Some vendors go quiet after the first reminder, and some are already on the company's vendor list under a different spelling. The AI Employee reads each set, checks it against the rule set, emails the vendor about the exact gap, and hands a verified record to the master data team, leaving duplicates and open exceptions for a human to approve.

## Open these three files first

1. `dataset/reference/Verification_Rule_Set.md`: All the rules in one place: what each check means, how names are compared, the chase timing and who approves what.
2. `dataset/csv/Document_Requirements.csv`: Tells you which documents each vendor owes, based on its legal form, category and MSME claim.
3. `dataset/mailbox/mailbox_index.csv`: Links every email to its request and thread, and says when each staged vendor reply is released.

## Words you will meet

| Term | Meaning |
|---|---|
| GSTIN | The 15-character GST registration number of a business. Characters 1 and 2 are the state code (24 = Gujarat, 27 = Maharashtra), characters 3 to 12 are the business's PAN, and the last character is a check character, so a GSTIN can be tested for typing errors. |
| PAN | The 10-character income tax number of a person or business. Its fourth character shows the type of holder (C = company, F = firm or LLP, P = individual or proprietor), and it must match the PAN inside the GSTIN. |
| Udyam (MSME) registration | The government registration of a micro, small or medium enterprise, proved by a Udyam certificate with a number like UDYAM-GJ-09-4740105. MSMEs get legal protection on payment terms, so a vendor that claims MSME status must send the certificate; an older Udyog Aadhaar memorandum is not accepted. |
| Cancelled cheque and bank letter | A cancelled cheque is a blank cheque leaf with CANCELLED written across it, sent to prove the vendor's account number, IFSC and account holder name. A letter on the bank's letterhead, signed and stamped, is accepted instead. |
| IFSC | The 11-character code of a bank branch, used for electronic payments: four letters for the bank, a zero, then six characters for the branch (for example IDFB0305764). A wrong IFSC means payments bounce. |
| Vendor master | The list of approved vendors held in SAP, one record per vendor with a vendor number (LIFNR), PAN, GSTIN and bank details. Before a new vendor is created, the desk checks it is not already on this list. |
| Legal name and trade name | The legal name is the name the business is registered under, shown on its GST certificate; the trade name is the name it trades as, which can differ. The legal name must be the same on every document, ignoring only harmless variations such as Pvt Ltd versus Private Limited or an M/s prefix. |
| Expiry and validity | Validity means a document is genuine and well formed, for example a GSTIN with the right check character. Expiry is the date a licence, certificate or insurance policy stops being in force; a lapsed document is treated as missing, and one lapsing within 30 days is flagged. |
| Probable duplicate and extension | A probable duplicate is a new request whose PAN, GSTIN or bank account already appears on the vendor master, whatever the name says; a human decides on the merge. An extension is the same company registering a GSTIN in a new state, which updates the existing vendor instead of creating a new one. |

## One record, end to end

**Request VOR-26-0567: a bank letter one word off the legal name, chased and fixed**

1. Open Onboarding_Requests row VOR-26-0567: buyer Farhan Shah (AC20, plant 2002 Rajkot RMC Plant) wants Sankalp Equipment Hire Private Limited, a private limited company in Gujarat, for crane and DG set hire (EQUIP_RENTAL), MSME N.
2. Use Document_Requirements to list what this vendor owes: GST certificate (DR-01), PAN (DR-03), bank proof (DR-04), certificate of incorporation (DR-05), ISO 45001 (DR-16) and insurance (DR-18); the checklist went out on 05 Oct 2026 (Onboarding_Chase_Log CL-00119).
3. Read mailbox/inbox/0122__20261005_1753.eml and the six PDFs filed under documents/VOR-26-0567/ in Received_Documents: every required document is present (PRS-01), ISO 45001 runs to 20 Aug 2027 and insurance to 14 Dec 2026 (EXP-01).
4. Compare identifiers: SEH GST.pdf gives legal name SANKALP EQUIPMENT HIRE PRIVATE LIMITED and GSTIN 24NLOCS1237Y1ZE, and PAN.pdf shows NLOCS1237Y, the same as GSTIN characters 3 to 12 (XDC-02 passes).
5. Read Bank certificate.pdf, an IDFC FIRST Bank letter: the account holder is M/s Sankalp Equipment Hire Industries Private Limited; dropping M/s still leaves the extra word Industries, so XDC-03 fails.
6. Search Vendor_Master_Extract for PAN NLOCS1237Y, GSTIN 24NLOCS1237Y1ZE and account 58769288966: no match, so DUP-01 passes, and chase round 1 goes to Meera Amin naming the bank letter, the name it shows and the legal name it must match.
7. Release mailbox/staged_replies/0002__20261012_1142.eml: its cancel cheque.pdf is in the name SANKALP EQUIPMENT HIRE PVT. LTD., which equals the legal name under the name-matching rules, so every rule passes and the verified pack goes to vendor.master@ashvakagroup.in.

**Outcome.** Chase round 1 to the vendor contact Meera Amin about the bank letter's account holder name. Once her cancelled cheque in the legal name arrives, the request is a verified pack handed to the master data team (vendor.master@ashvakagroup.in), with no human approval needed.

**Why.** XDC-03 requires the account holder on the bank proof to equal the legal name, and the name-matching section counts an added word as a mismatch while treating Pvt. Ltd. and Private Limited as the same. No human is involved because CHS-01 makes the chase routine and, after the fix, no exception or duplicate is left for HND-02 approval.

## What the Round 1 minimum needs

- Tables: `onboarding_request` (Onboarding_Requests), `document_requirement` (Document_Requirements), `received_document` (Received_Documents), `vendor_master` (Vendor_Master_Extract)
- Staged replies: One staged reply: 0002, the corrected cheque for the record traced above. 0004 and 0016 are optional extras inside the same two vendor types.
- Watch for: Match a possible duplicate on PAN, GSTIN or bank account only, never on the name.
- Ready-made tables: `setup_kit/` in this folder.
- Not needed: the rest of the pack.

## What the job costs by hand

130 onboarding requests were raised between 03 Sep and 09 Oct 2026, about 105 a month. Do one by hand with a stopwatch before you build. Minutes per record times records per month is what your AI Employee gives back.
