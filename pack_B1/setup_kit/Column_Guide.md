# B1 column guide

Every table and column in the pack, with the plain name used in `csv_plain/` and `supabase_seed.sql`. The pack keeps the enterprise names because that is what you meet on the job.

## document_requirement (`Document_Requirements`)

One document a vendor must (or may) send, and which kinds of vendor it applies to.

| Plain name | In the pack | Meaning |
|---|---|---|
| requirement_id | requirement_id | Requirement code, DR-01 to DR-19. |
| applies_to | applies_to | Which vendors the requirement covers: by GST status, constitution (company, LLP, partnership, proprietorship), purchase category code, or an MSME declaration. |
| document_name | document | The document the vendor must send, for example GST registration certificate (Form GST REG-06) or ISO 45001 certificate. |
| is_mandatory | mandatory | Yes if the document must be received; No for optional papers such as a company profile, which are not verified. |
| accepted_forms | accepted_forms | Which versions of the document are accepted in its place, for example a cancelled cheque or a signed and stamped bank letter; blank when only one form exists. |
| validity_check | validity_check | What makes the document acceptable on its own, for example the GSTIN structure, the PAN fourth character, or not lapsed on the verification date. |
| fields_cross_checked | fields_cross_checked | Values on this document that must agree with the other documents, for example legal name, PAN or account holder; blank when nothing is compared. |

## verification_rule (`Verification_Rules`)

One rule the desk applies to a document set, the chase timing or the handover.

| Plain name | In the pack | Meaning |
|---|---|---|
| rule_id | rule_id | Rule code. PRS = presence, LEG = legibility, VAL = validity, EXP = expiry, XDC = cross-document, DUP = master check, CHS = chase cadence, HND = handover. |
| rule_area | area | The group the rule belongs to, in words: Presence, Legibility, Validity, Expiry, Cross-document, Master check, Chase cadence or Handover. |
| rule_text | rule | The rule itself in one or two sentences, as the desk applies it. |
| applies_to | applies_to | Which requests or documents the rule covers, for example every vendor, GST-registered vendors, or msme_declared = Y. |
| evidence | evidence | Which documents or tables the rule reads to decide, for example the GST certificate and the PAN document, or Vendor_Master_Extract. |
| if_not_met | if_not_met | What the desk does when the rule fails, usually a chase for a named document or a stop for human review; blank for chase cadence and handover rows. |

## onboarding_request (`Onboarding_Requests`)

One buyer's request to register one new vendor, with what the vendor declared on the registration form.

| Plain name | In the pack | Meaning |
|---|---|---|
| request_id | request_id | Onboarding request number, VOR-26- followed by four digits; quoted in the subject of every email about the request. |
| raised_on | raised_on | Date the buyer raised the request. Formats vary (25-09-2026, 25.09.2026, 30/09/2026, 2026-09-29, 30 Sep 2026, Oct 1, 2026, 22-09-26); numeric dates that do not start with the year put the day first. |
| buyer_name | raised_by | Name of the buyer at Ashvaka who wants this vendor. |
| buyer_email | raised_by_email | The buyer's email address at ashvakagroup.in. |
| company_code | company_code | SAP code of the group company that will buy: AI10 Ashvaka Infrastructure, AC20 Ashvaka Cement and Building Materials, AE30 Ashvaka Energy, AL40 Ashvaka Logistics and Warehousing. |
| plant_code | plant | SAP plant code of the site, for example 1002 = Sanand Industrial Park Project, 2002 = Rajkot RMC Plant, 4001 = Bhiwandi Distribution Centre (full list in 00_INDEX). |
| purchase_category | category | Purchase category code, such as EQUIP_RENTAL, CIVIL_WORKS, MANPOWER, SECURITY or TRANSPORT; it decides which extra documents the vendor must send. |
| business_need | business_need | The buyer's free-text reason, for example Crane and DG set hire for Rajkot RMC Plant. |
| vendor_name_as_typed | vendor_name_as_typed | The vendor's name as the buyer typed it. It can be informal, with an M/s prefix or a short suffix, so it is not the legal name. |
| vendor_contact_name | vendor_contact_name | Person at the vendor the buyer gave as the contact; chases go to this person. |
| vendor_contact_email | vendor_contact_email | The contact's email address; capitalisation varies. |
| vendor_contact_phone | vendor_contact_phone | The contact's mobile number, written +91 followed by ten digits. |
| constitution_declared | constitution_declared | Legal form the vendor declared: private or public limited company, LLP, partnership or proprietorship, written several ways (Pvt Ltd Company, Private Ltd, Sole Proprietor, Partnership Firm). |
| state_declared | state_declared | State the vendor says it supplies from, written in full, for example Gujarat or Maharashtra. |
| city_declared | city_declared | City the vendor declared, for example Anand or Bhiwandi. |
| msme_declared | msme_declared | Y if the vendor says it is a registered MSME (it must then send a Udyam certificate), N if not. |
| gst_registered_declared | gst_registered_declared | Y if the vendor says it is registered under GST; N means a signed non-registration declaration replaces the GST certificate. |
| estimated_annual_spend_inr | estimated_annual_spend_inr | Buyer's estimate of yearly spend with the vendor in rupees. Formats vary: 66,00,000.00, ₹ 66,00,000.00, INR 66,00,000.00, Rs. 66,00,000/-, plain digits, and western comma grouping. |
| portal_registration_id | slp_registration_id | Reference on the supplier registration portal, SR- followed by seven digits. |
| request_status | status | Desk status: Documents awaited (nothing received yet) or Documents received. |

## chase_log (`Onboarding_Chase_Log`)

One email the desk has already sent to a vendor: the first checklist or a chase.

| Plain name | In the pack | Meaning |
|---|---|---|
| log_id | log_id | Row number of the log, CL- followed by five digits. |
| request_id | request_id | The onboarding request the email belongs to. |
| action | action | What was sent: Document checklist sent (the first email listing every document), Chase 1 or Chase 2. |
| chase_round | round | 0 = document checklist, 1 = first chase, 2 = second chase. |
| sent_at | sent_at | When the email went out. Mostly 2026-09-07 10:17:00 in IST; some rows use 28-09-2026 17:13, and some are UTC with a Z or carry a +05:30 offset. |
| sent_by | sent_by | Desk staff member who sent it. |
| sent_to | sent_to | Vendor address the email went to. |
| cc | cc | Address copied, normally the buyer who raised the request. |
| email_body | items_requested | The full text of the email, listing each document asked for or each problem found. |
| thread_id | thread_id | Mailbox thread reference, B1-T followed by four digits, shared by every message about the request. |
| message_id | message_id | Email Message-ID of this outgoing mail; vendor replies quote it in their In-Reply-To header. |

## received_document (`Received_Documents`)

One attachment that arrived by email and was filed against a request.

| Plain name | In the pack | Meaning |
|---|---|---|
| request_id | request_id | The onboarding request the attachment was filed against. |
| received_at | received_at | When the email carrying the file arrived, IST, as 2026-09-07 17:41:00. |
| from_address | from_address | Address the email came from: usually the vendor contact, sometimes another vendor address, a personal mailbox, or a buyer forwarding the papers. |
| mailbox_file | mailbox_file | Path of the .eml file in mailbox/inbox/ that carried the attachment. |
| attachment_name | attachment_name | File name as the vendor sent it, for example pan copy.pdf or IMG_20260909_169381.pdf; the name does not reliably say what the file is. |
| stored_path | stored_as | Where the file is saved under documents/<request_id>/, renamed with a number only when a name repeats. |
| page_count | pages | Number of pages, 1 to 4; a file with several pages can hold more than one document. |
| size_kb | size_kb | File size in kilobytes. |

## vendor_master (`Vendor_Master_Extract`)

One vendor that already exists in SAP, with its PAN, GSTIN and bank details.

| Plain name | In the pack | Meaning |
|---|---|---|
| vendor_number | LIFNR | SAP vendor number, six digits, for example 200100. |
| name_line_1 | NAME1 | Vendor name as stored on the master, first 35 characters; capitalisation and suffix style vary. |
| name_line_2 | NAME2 | Rest of the name when it runs past 35 characters, for example Ltd; usually blank. |
| search_term | SORTL | Short search key, the first ten letters of the name in capitals without spaces. |
| street | STRAS | Street address. |
| city | ORT01 | City. |
| state_code | REGIO | Two-letter state code, for example GJ = Gujarat, MH = Maharashtra, RJ = Rajasthan (not the two-digit GST state code). |
| pin_code | PSTLZ | Six-digit postal PIN code. |
| country | LAND1 | Country code, IN for India. |
| phone | TELF1 | Phone number, +91 followed by ten digits. |
| email | SMTP_ADDR | Vendor email address on file. |
| pan | J_1IPANNO | Vendor PAN, ten characters; blank on some older records. |
| gstin | STCD3 | Vendor GSTIN, fifteen characters; blank on some older records. |
| bank_country | BANKS | Country of the bank account, IN. |
| ifsc | BANKL | IFSC of the vendor's bank branch, eleven characters. |
| bank_account_number | BANKN | Bank account number the vendor is paid into. |
| account_holder | KOINH | Name of the bank account holder. |
| msme_flag | MSME_FLAG | Y if the vendor is recorded as an MSME, N if not. |
| udyam_number | UDYAM_NO | Udyam registration number, in the form UDYAM-GJ-09-4740105; blank for non-MSME vendors. |
| account_group | KTOKK | SAP account group: ZDOM = domestic vendor, ZMSE = domestic MSME vendor. |
| purchase_category | CATEGORY | Main purchase category the vendor supplies, using the same codes as the onboarding requests. |
| created_on | ERDAT | Date the vendor was created on the master, dd.mm.yyyy, between 2014 and 2025. |
| posting_block | SPERR | X = blocked for posting (payments and invoices stopped); blank = active. |
| deletion_flag | LOEVM | X = marked for deletion; blank otherwise. |
| company_codes_extended | BUKRS_EXTENDED | Group company codes the vendor is already set up for, separated by semicolons, for example AE30;AI10. |
