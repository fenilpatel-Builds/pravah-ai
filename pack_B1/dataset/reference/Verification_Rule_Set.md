# Vendor onboarding: verification rule set

Ashvaka Industries Group, Vendor Onboarding Desk. Applies to every vendor onboarding request for company codes AI10, AC20, AE30 and AL40. Version 3.2, effective 01 Jul 2026.

## 1. What the desk does

The desk sends each new vendor a document checklist, verifies every document that comes back, chases what is missing or wrong by email, and hands the master data team a verified record. The master data team creates the vendor in SAP. Nothing is created on the master by the desk.

## 2. Documents required

The full list is in the Document_Requirements sheet. In short: every vendor sends a GST registration certificate (or a signed non-registration declaration), the PAN of the vendor entity, and a bank proof. Companies add the certificate of incorporation, LLPs the LLP certificate, partnership firms the partnership deed and proprietors a shop and establishment registration. A vendor that declares MSME status sends the Udyam registration certificate. Manpower, security and housekeeping vendors add the contract labour licence, EPF and ESIC registrations and an employees' compensation policy; security agencies add the PSARA licence. Laboratories add NABL accreditation. Transporters add the GTA declaration for the current financial year. Works and equipment vendors add ISO 45001 and insurance; manufacturers of the listed materials add ISO 9001.

## 3. Rules

**PRS-01 (Presence).** Every mandatory document for the vendor's constitution and category is received. If not met: chase for the missing document.

**PRS-02 (Presence).** A vendor that declares MSME status has sent a Udyam registration certificate. If not met: chase for the certificate or a written confirmation that the vendor is not an MSME.

**LEG-01 (Legibility).** Every document can be read in full: names, numbers and dates. If not met: chase for a clear copy of the document.

**VAL-01 (Validity).** The GSTIN on the GST certificate has 15 characters and a valid check character. If not met: chase for the certificate downloaded from the GST portal.

**VAL-02 (Validity).** The PAN has the standard structure and its fourth character matches the constitution. If not met: chase for the PAN of the vendor entity.

**VAL-03 (Validity).** The IFSC on the bank proof has the standard structure. If not met: chase for a cheque or bank letter with the right IFSC.

**VAL-04 (Validity).** The GSTIN state code matches the principal place of business on the certificate and the state the vendor declared. If not met: chase for the GST certificate of the state the vendor supplies from.

**VAL-05 (Validity).** The bank proof is a cheque leaf with the account holder's name printed, or a bank letter signed and stamped by the bank. If not met: chase for an acceptable bank proof.

**VAL-06 (Validity).** Declarations are on the vendor's letterhead, signed, and for the current financial year where they are annual. If not met: chase for a signed, current declaration.

**EXP-01 (Expiry).** No document with an expiry date has lapsed on the verification date. If not met: chase for the renewed document unless EXP-03 applies.

**EXP-02 (Expiry).** A document that lapses within 30 days of verification is flagged and its renewal is requested. If not met: not a blocker. Ask for the renewed document or renewal receipt and flag the record for approval.

**EXP-03 (Expiry).** A lapsed document is accepted with a renewal receipt only if the renewal was filed on or before the expiry date, the receipt is less than 60 days old, and it names the same licence and legal entity. Needs human sign-off. If not met: if all conditions hold, accept with human sign-off; otherwise treat as EXP-01.

**XDC-01 (Cross-document).** The legal name is identical across the GST certificate, PAN, incorporation document and Udyam certificate, and licences carry the legal or trade name. If not met: chase for a document in the legal name, or the fresh certificate after a change of name.

**XDC-02 (Cross-document).** The PAN inside the GSTIN (characters 3 to 12) equals the PAN on the PAN document and on the EPF certificate. If not met: chase for the PAN of the entity that holds the GSTIN.

**XDC-03 (Cross-document).** The account holder on the bank proof equals the legal name (for a proprietorship, the proprietor's name or the trade name). If not met: chase for bank proof of an account in the legal name.

**DUP-01 (Master check).** No existing vendor on the master has the same PAN, GSTIN or bank account. If not met: stop. Route to a human as a probable duplicate with the matching vendor number.

**DUP-02 (Master check).** A vendor whose PAN is already on the master with a GSTIN of another state is an extension of the existing vendor. If not met: hand over as an extension of the existing vendor with the new GSTIN and address, for human approval.

### Name matching

Names are compared after ignoring capitalisation, punctuation, extra spaces and an M/s prefix, and after treating these as the same: Private Limited, Pvt Ltd, Pvt. Ltd., (P) Ltd and P. Ltd.; Limited and Ltd; LLP and L.L.P.; & and and. Any other difference, including one added, dropped or changed word, is a mismatch. For a proprietorship the GST legal name is the proprietor's own name; the bank account, Udyam certificate and shop registration may carry either the proprietor's name or the trade name on the GST certificate.

### Renewal receipts

A lapsed licence or certificate can be accepted on the strength of a renewal receipt only when all of these hold: the renewal was filed on or before the expiry date; the receipt (or the certification body's recertification letter) is dated less than 60 days before the verification date; and it names the same licence or certificate number and the same legal entity. The record then needs human sign-off, and the desk asks for the renewed document when it is issued. Otherwise the lapsed document is treated as missing.

### Master check

Before a record is handed over, the desk searches the vendor master for the same PAN, the same GSTIN or the same bank account number. Any one match makes the request a probable duplicate of that vendor, whatever the names say; the desk stops and a human decides on the merge. A blocked vendor that matches is reported with the block. The one exception is a vendor whose PAN is on the master with a GSTIN of another state and whose new GSTIN is not on the master: that is the same legal entity registering a new state, and the existing vendor is extended. A similar name with no identifier in common is not a match.

## 4. Chase cadence

Working days are Monday to Friday, excluding these group holidays: 15 Aug 2026 (Independence Day), 28 Aug 2026 (Raksha Bandhan), 04 Sep 2026 (Janmashtami), 02 Oct 2026 (Gandhi Jayanti), 20 Oct 2026 (Dussehra), 09 Nov 2026 (Diwali), 10 Nov 2026 (Gujarati New Year), 11 Nov 2026 (Bhai Bij).

- Round 1: as soon as a received set has been verified and anything is open, send one email naming every open item. If nothing has arrived, round 1 is due 2 working days after the checklist.
- Round 2: when a reply to round 1 leaves anything open, or 3 working days after round 1 with no reply, whichever comes first. Name what is still open, including anything new found in the reply.
- Escalation: when a reply to round 2 still leaves items open, or 3 working days pass after round 2 with no reply, stop chasing. Escalate to the buyer who raised the request and the procurement lead for the company code, listing the open items.
- An automatic out-of-office reply is not a reply. A question from the vendor is answered in the thread and does not close anything.
- Every chase names the document and the exact problem, for example the name that does not match and the name it should match.

## 5. Handover and approvals

A verified pack goes to the master data team at vendor.master@ashvakagroup.in with every document, every rule result and the values to key in: legal name, trade name, constitution, PAN, GSTIN, address, bank account, IFSC, account holder, MSME status and Udyam number.

A human approves: any vendor that still carries an unresolved exception (including a renewal accepted under EXP-03 and a document that lapses within 30 days), every probable duplicate and merge, and every extension of an existing vendor.

## 6. Contacts

- Vendor Onboarding Desk: vendor.onboarding@ashvakagroup.in
- Master data team: vendor.master@ashvakagroup.in
- Procurement lead, AC20 Ashvaka Cement and Building Materials Limited: Foram Shukla (foram.shukla@ashvakagroup.in)
- Procurement lead, AE30 Ashvaka Energy Limited: Manan Kothari (manan.kothari@ashvakagroup.in)
- Procurement lead, AI10 Ashvaka Infrastructure Limited: Ronak Trivedi (ronak.trivedi@ashvakagroup.in)
- Procurement lead, AL40 Ashvaka Logistics and Warehousing Limited: Priyanka Sheikh (priyanka.sheikh@ashvakagroup.in)
