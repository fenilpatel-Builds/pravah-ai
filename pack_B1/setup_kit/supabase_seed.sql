-- Autopilot Ahmedabad Round 1, statement B1: create and fill every table in Supabase.
-- Paste into the Supabase SQL editor and run. Every value is text, exactly as in the pack:
-- dates and amounts come in mixed formats on purpose. Rerunning drops and recreates the tables.
-- Fully synthetic data, for this hackathon only.

drop table if exists public."document_requirement";
create table public."document_requirement" (
  row_id bigint generated always as identity primary key,
  "requirement_id" text,
  "applies_to" text,
  "document_name" text,
  "is_mandatory" text,
  "accepted_forms" text,
  "validity_check" text,
  "fields_cross_checked" text
);
comment on table public."document_requirement" is 'One document a vendor must (or may) send, and which kinds of vendor it applies to.';
insert into public."document_requirement" ("requirement_id", "applies_to", "document_name", "is_mandatory", "accepted_forms", "validity_check", "fields_cross_checked") values
('DR-01', 'Every vendor registered under GST', 'GST registration certificate (Form GST REG-06)', 'Yes', 'Certificate downloaded from the GST portal', 'GSTIN structure and check character; state code agrees with the principal place of business and with the declared state; validity dates for casual or non-resident registrations', 'Legal name, trade name, PAN inside GSTIN, constitution, address'),
('DR-02', 'Vendor not registered under GST (declared N)', 'Declaration of non-registration under GST', 'Yes', 'Signed declaration on the vendor''s letterhead', 'Signed; names the reason and carries the PAN', 'Name, PAN'),
('DR-03', 'Every vendor', 'PAN of the vendor entity', 'Yes', 'PAN card copy, e-PAN, or PAN details printout', 'PAN structure; fourth character C for a company, F for a firm or LLP, P for a proprietor', 'PAN, name'),
('DR-04', 'Every vendor', 'Bank proof', 'Yes', 'Cancelled cheque leaf with the account holder''s name printed, or a bank letter on the bank''s letterhead signed and stamped', 'IFSC structure; holder name printed or letter signed and stamped', 'Account holder, account number, IFSC'),
('DR-05', 'Private or public limited company', 'Certificate of incorporation', 'Yes', 'Also the fresh certificate of incorporation when the company name has changed', 'Issued by the Registrar of Companies', 'Legal name, CIN, PAN where printed'),
('DR-06', 'Limited liability partnership', 'LLP certificate of incorporation (Form 16)', 'Yes', NULL, 'Issued by the Registrar', 'Legal name, LLPIN'),
('DR-07', 'Partnership firm', 'Partnership deed', 'Yes', 'First pages naming the firm and partners and the signature page', 'Signed by the partners', 'Firm name, partners'),
('DR-08', 'Proprietorship', 'Shop and establishment registration certificate', 'Yes', 'Registration certificate or intimation receipt', 'Issued by the local authority', 'Trade name, proprietor name'),
('DR-09', 'Vendor declares MSME status', 'Udyam registration certificate', 'Yes', 'Udyam certificate only; an Udyog Aadhaar memorandum is not accepted', 'Udyam number structure', 'Enterprise name (legal name, or trade name for a proprietorship)'),
('DR-10', 'Categories MANPOWER, SECURITY, HOUSEKEEPING', 'Contract labour licence', 'Yes', NULL, 'Not lapsed; see expiry rules', 'Name'),
('DR-11', 'Categories MANPOWER, SECURITY, HOUSEKEEPING', 'EPF registration certificate', 'Yes', NULL, 'Establishment code', 'Name, PAN'),
('DR-12', 'Categories MANPOWER, SECURITY, HOUSEKEEPING', 'ESIC registration certificate', 'Yes', NULL, 'Employer code', 'Name'),
('DR-13', 'Category SECURITY', 'PSARA licence', 'Yes', NULL, 'Not lapsed; covers the state of operation', 'Name'),
('DR-14', 'Category LAB_TESTING', 'NABL accreditation certificate', 'Yes', NULL, 'Not lapsed; discipline covers the tests bought', 'Name'),
('DR-15', 'Category TRANSPORT', 'GTA declaration for FY 2026-27', 'Yes', 'Annexure V on the vendor''s letterhead', 'For the current financial year and signed', 'Name, GSTIN'),
('DR-16', 'Categories CIVIL_WORKS, EQUIP_RENTAL, SCAFFOLDING', 'ISO 45001 certificate', 'Yes', NULL, 'Not lapsed', 'Name'),
('DR-17', 'Categories RMC, CABLE, ELECTRICAL, SOLAR, SAFETY_PPE', 'ISO 9001 certificate', 'Yes', NULL, 'Not lapsed', 'Name'),
('DR-18', 'Categories MANPOWER, SECURITY, HOUSEKEEPING, CIVIL_WORKS, EQUIP_RENTAL, SCAFFOLDING', 'Insurance certificate', 'Yes', 'Employees'' compensation policy for labour categories; contractor''s all risk or plant and machinery cover for works', 'Period of insurance covers the verification date', 'Insured name'),
('DR-19', 'Any vendor', 'Company profile, brochures, other papers', 'No', NULL, 'Not verified', NULL);

drop table if exists public."verification_rule";
create table public."verification_rule" (
  row_id bigint generated always as identity primary key,
  "rule_id" text,
  "rule_area" text,
  "rule_text" text,
  "applies_to" text,
  "evidence" text,
  "if_not_met" text
);
comment on table public."verification_rule" is 'One rule the desk applies to a document set, the chase timing or the handover.';
insert into public."verification_rule" ("rule_id", "rule_area", "rule_text", "applies_to", "evidence", "if_not_met") values
('PRS-01', 'Presence', 'Every mandatory document for the vendor''s constitution and category is received.', 'Every request', 'Document_Requirements; all attachments', 'Chase for the missing document'),
('PRS-02', 'Presence', 'A vendor that declares MSME status has sent a Udyam registration certificate.', 'msme_declared = Y', 'Udyam registration certificate', 'Chase for the certificate or a written confirmation that the vendor is not an MSME'),
('LEG-01', 'Legibility', 'Every document can be read in full: names, numbers and dates.', 'Every document', 'Every attachment, including scans', 'Chase for a clear copy of the document'),
('VAL-01', 'Validity', 'The GSTIN on the GST certificate has 15 characters and a valid check character.', 'GST-registered vendors', 'GST certificate', 'Chase for the certificate downloaded from the GST portal'),
('VAL-02', 'Validity', 'The PAN has the standard structure and its fourth character matches the constitution.', 'Every vendor', 'PAN document', 'Chase for the PAN of the vendor entity'),
('VAL-03', 'Validity', 'The IFSC on the bank proof has the standard structure.', 'Every vendor', 'Cancelled cheque or bank letter', 'Chase for a cheque or bank letter with the right IFSC'),
('VAL-04', 'Validity', 'The GSTIN state code matches the principal place of business on the certificate and the state the vendor declared.', 'GST-registered vendors', 'GST certificate; registration form (state_declared)', 'Chase for the GST certificate of the state the vendor supplies from'),
('VAL-05', 'Validity', 'The bank proof is a cheque leaf with the account holder''s name printed, or a bank letter signed and stamped by the bank.', 'Every vendor', 'Cancelled cheque or bank letter', 'Chase for an acceptable bank proof'),
('VAL-06', 'Validity', 'Declarations are on the vendor''s letterhead, signed, and for the current financial year where they are annual.', 'Transport vendors; vendors not registered under GST', 'GTA declaration; non-registration declaration', 'Chase for a signed, current declaration'),
('EXP-01', 'Expiry', 'No document with an expiry date has lapsed on the verification date.', 'Documents with an expiry date', 'Licences, certificates, insurance, GTA declaration', 'Chase for the renewed document unless EXP-03 applies'),
('EXP-02', 'Expiry', 'A document that lapses within 30 days of verification is flagged and its renewal is requested.', 'Documents with an expiry date', 'Same as EXP-01', 'Not a blocker. Ask for the renewed document or renewal receipt and flag the record for approval'),
('EXP-03', 'Expiry', 'A lapsed document is accepted with a renewal receipt only if the renewal was filed on or before the expiry date, the receipt is less than 60 days old, and it names the same licence and legal entity. Needs human sign-off.', 'A lapsed document sent with a renewal receipt', 'The lapsed document and the receipt', 'If all conditions hold, accept with human sign-off; otherwise treat as EXP-01'),
('XDC-01', 'Cross-document', 'The legal name is identical across the GST certificate, PAN, incorporation document and Udyam certificate, and licences carry the legal or trade name.', 'Every vendor', 'GST, PAN, incorporation document, Udyam, licences', 'Chase for a document in the legal name, or the fresh certificate after a change of name'),
('XDC-02', 'Cross-document', 'The PAN inside the GSTIN (characters 3 to 12) equals the PAN on the PAN document and on the EPF certificate.', 'GST-registered vendors', 'GST certificate, PAN document, EPF certificate', 'Chase for the PAN of the entity that holds the GSTIN'),
('XDC-03', 'Cross-document', 'The account holder on the bank proof equals the legal name (for a proprietorship, the proprietor''s name or the trade name).', 'Every vendor', 'Cancelled cheque or bank letter', 'Chase for bank proof of an account in the legal name'),
('DUP-01', 'Master check', 'No existing vendor on the master has the same PAN, GSTIN or bank account.', 'Every request, before anything is created', 'Vendor_Master_Extract', 'Stop. Route to a human as a probable duplicate with the matching vendor number'),
('DUP-02', 'Master check', 'A vendor whose PAN is already on the master with a GSTIN of another state is an extension of the existing vendor.', 'PAN already on the master', 'Vendor_Master_Extract; GST certificate', 'Hand over as an extension of the existing vendor with the new GSTIN and address, for human approval'),
('CHS-00', 'Chase cadence', 'Working days are Monday to Friday excluding group holidays: 15 Aug 2026 Independence Day; 28 Aug 2026 Raksha Bandhan; 04 Sep 2026 Janmashtami; 02 Oct 2026 Gandhi Jayanti; 20 Oct 2026 Dussehra; 09 Nov 2026 Diwali; 10 Nov 2026 Gujarati New Year; 11 Nov 2026 Bhai Bij.', 'All timing rules', 'Onboarding_Chase_Log; mailbox', NULL),
('CHS-01', 'Chase cadence', 'When a document set is verified and anything is open, send chase round 1 naming every open item. If nothing at all has arrived, chase round 1 is due 2 working days after the document checklist was sent.', 'Open requests', 'Onboarding_Chase_Log; mailbox', NULL),
('CHS-02', 'Chase cadence', 'Send chase round 2 naming what is still open when a reply to round 1 leaves anything open, or when 3 working days pass after round 1 with no reply, whichever comes first. New problems found in a reply are added to round 2.', 'Open requests', 'Onboarding_Chase_Log; mailbox', NULL),
('CHS-03', 'Chase cadence', 'After two unresolved rounds, stop chasing and escalate to the buyer who raised the request and the procurement lead for the company code, listing what is still open. Two unresolved rounds means a reply to round 2 still leaves items open, or 3 working days pass after round 2 with no reply.', 'Open requests', 'Onboarding_Chase_Log; mailbox', NULL),
('CHS-04', 'Chase cadence', 'An automatic out-of-office reply is not a reply. A reply that only asks a question or promises documents does not close any item. Reply to the question in the same thread.', 'Open requests', 'mailbox', NULL),
('HND-01', 'Handover', 'A verified pack lists every document with its file, every rule with its result, and the values the master data team will key in: legal name, trade name, constitution, PAN, GSTIN, address, bank account, IFSC, account holder, MSME status and Udyam number.', 'Every request that is ready', NULL, NULL),
('HND-02', 'Handover', 'A human approves any vendor that still carries an unresolved exception (including a renewal accepted under EXP-03 or a document expiring within 30 days), every probable duplicate, and every extension of an existing vendor.', 'Every request', NULL, NULL);

drop table if exists public."onboarding_request";
create table public."onboarding_request" (
  row_id bigint generated always as identity primary key,
  "request_id" text,
  "raised_on" text,
  "buyer_name" text,
  "buyer_email" text,
  "company_code" text,
  "plant_code" text,
  "purchase_category" text,
  "business_need" text,
  "vendor_name_as_typed" text,
  "vendor_contact_name" text,
  "vendor_contact_email" text,
  "vendor_contact_phone" text,
  "constitution_declared" text,
  "state_declared" text,
  "city_declared" text,
  "msme_declared" text,
  "gst_registered_declared" text,
  "estimated_annual_spend_inr" text,
  "portal_registration_id" text,
  "request_status" text
);
comment on table public."onboarding_request" is 'One buyer''s request to register one new vendor, with what the vendor declared on the registration form.';
insert into public."onboarding_request" ("request_id", "raised_on", "buyer_name", "buyer_email", "company_code", "plant_code", "purchase_category", "business_need", "vendor_name_as_typed", "vendor_contact_name", "vendor_contact_email", "vendor_contact_phone", "constitution_declared", "state_declared", "city_declared", "msme_declared", "gst_registered_declared", "estimated_annual_spend_inr", "portal_registration_id", "request_status") values
('VOR-26-0514', '25-09-2026', 'Kavya D''Souza', 'kavya.dsouza@ashvakagroup.in', 'AI10', '1002', 'CEMENT', 'OPC 53 and PPC cement for Sanand Industrial Park Project', 'M/s Zenith Cement & Co', 'Deepa Thakkar', 'deepa.thakkar@zenithcement.in', '+91 6846557706', 'Partnership', 'Gujarat', 'Surat', 'N', 'Y', '₹ 66,00,000.00', 'SR-2947552', 'Documents received'),
('VOR-26-0495', '24-09-2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AC20', '2002', 'EQUIP_RENTAL', 'Crane and DG set hire for Rajkot RMC Plant', 'Kaveri Earthmovers Private Limited', 'Hardik Kothari', 'hardik.kothari@kaveriearthmovers.in', '+91 7452920942', 'Pvt Ltd Company', 'Gujarat', 'Sanand', 'Y', 'Y', '₹85,00,000.00', 'SR-2911835', 'Documents received'),
('VOR-26-0427', '07-09-2026', 'Devang Menon', 'devang.menon@ashvakagroup.in', 'AC20', '2002', 'HOUSEKEEPING', 'Housekeeping staff for Rajkot RMC Plant site offices and labour camp', 'Crestline Facility Service Private Limited', 'Karan Sheikh', 'KARAN.SHEIKH@CRESTLINEFACILITYS.COM', '+91 8932120439', 'Private Ltd', 'Gujarat', 'Surat', 'Y', 'Y', '23,00,000.00', 'SR-6688106', 'Documents received'),
('VOR-26-0454', '11-09-2026', 'Yash Amin', 'yash.amin@ashvakagroup.in', 'AI10', '1001', 'IT_SVC', 'Managed network support for Ahmedabad Head Office', 'bansi it solutions', 'Kruti Pandya', 'kruti.pandya@bansiitsolutions.in', '+91 7994907034', 'Proprietorship Firm', 'Rajasthan', 'Bhilwara', 'Y', 'Y', '₹32,00,000.00', 'SR-7101257', 'Documents received'),
('VOR-26-0445', '11-09-2026', 'Kavya D''Souza', 'kavya.dsouza@ashvakagroup.in', 'AI10', '1002', 'CABLE', 'LT and DC solar cables for Sanand Industrial Park Project', 'Bhagyoday Cable Industries', 'Meera Dave', 'meera.dave@bhagyodaycableindu.in', '+91 6609328436', 'Partnership Firm', 'Gujarat', 'Gandhinagar', 'N', 'Y', '1,88,00,000.00', 'SR-1851669', 'Documents received'),
('VOR-26-0466', '16-09-2026', 'Sameer Patel', 'sameer.patel@ashvakagroup.in', 'AL40', '4001', 'TRANSPORT', 'Trailer and tipper freight for Bhiwandi Distribution Centre', 'Sahjanand Transport Co ', 'Urvashi Shukla', 'urvashi.shukla@sahjanandtransport.co.in', '+91 9274972362', 'Sole Proprietor', 'Haryana', 'Gurugram', 'Y', 'Y', '1,16,00,000.00', 'SR-6445716', 'Documents received'),
('VOR-26-0533', '28-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AI10', '1004', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Vadodara Ring Road Package 3', 'Orbit Safety Solutions Private Limited', 'Kruti Gill', 'kruti.gill@orbitsafetysolutio.in', '+91 6236049200', 'Private Limited Company', 'Gujarat', 'Gandhinagar', 'N', 'Y', '19,00,000.00', 'SR-8192374', 'Documents received'),
('VOR-26-0538', '2026-09-30', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AL40', '4001', 'TRANSPORT', 'Trailer and tipper freight for Bhiwandi Distribution Centre', 'M/s Chitra Logistics Pvt. Ltd.', 'Imran Chauhan', 'imran.chauhan@chitralogistics.com', '+91 6792559915', 'Private Ltd', 'Gujarat', 'Ahmedabad', 'Y', 'Y', 'INR 36,00,000.00', 'SR-7339145', 'Documents received'),
('VOR-26-0522', '29-09-2026', 'Maria Solanki', 'maria.solanki@ashvakagroup.in', 'AE30', '3001', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Bhuj Solar Park Phase 2', 'Deccan Industrial Safety Pvt. Ltd. ', 'Vivek Reddy', 'vivek.reddy@deccanindustrialsa.co.in', '+91 6732621879', 'Pvt Ltd Company', 'Gujarat', 'Bhuj', 'Y', 'Y', '6,00,000.00', 'SR-9576573', 'Documents received'),
('VOR-26-0431', '09-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AL40', '4001', 'TRANSPORT', 'Trailer and tipper freight for Bhiwandi Distribution Centre', 'Deccan Roadlines ', 'Nisha Shah', 'nisha.shah@deccanroadlines.com', '+91 9149802999', 'Proprietorship', 'Gujarat', 'Mehsana', 'N', 'Y', '59,00,000.00', 'SR-8754054', 'Documents received'),
('VOR-26-0570', '2026-10-05', 'Aarav Dave', 'aarav.dave@ashvakagroup.in', 'AC20', '2001', 'MANPOWER', 'Skilled and semi-skilled manpower for Vadodara Grinding Unit, about 40 workers from next month', 'Mahalaxmi Labour Contractors Private Limited', 'Jignesh Rao', 'jignesh.rao@mahalaxmilabourcon.in', '+91 6996442322', 'Private Limited Company', 'Gujarat', 'Surat', 'Y', 'Y', '1,48,00,000.00', 'SR-3910228', 'Documents received'),
('VOR-26-0418', '07-09-2026', 'Yash Amin', 'yash.amin@ashvakagroup.in', 'AI10', '1002', 'HOUSEKEEPING', 'Housekeeping staff for Sanand Industrial Park Project site offices and labour camp', 'M/s Jay Ambe Housekeeping Services Pvt. Limited', 'Meera Pathan', 'meera.pathan@jayambehousekeepin.co.in', '+91 6154269579', 'Private Ltd', 'Gujarat', 'Surat', 'N', 'Y', '16,00,000.00', 'SR-9207246', 'Documents received'),
('VOR-26-0437', 'Sep 9, 2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AE30', '3001', 'CABLE', 'LT and DC solar cables for Bhuj Solar Park Phase 2', 'Horizon Cables Pvt Ltd', 'Joseph Shah', 'JOSEPH.SHAH@HORIZONCABLES.CO.IN', '+91 6448182753', 'Pvt Ltd Company', 'Gujarat', 'Anand', 'N', 'Y', '4600000.00', 'SR-9249977', 'Documents received'),
('VOR-26-0601', '05-10-2026', 'Sana Singh', 'sana.singh@ashvakagroup.in', 'AL40', '4001', 'MANPOWER', 'Skilled and semi-skilled manpower for Bhiwandi Distribution Centre, about 120 workers from next month', 'Aashirwad Workforce Solutions Pvt Ltd', 'Vivek Chauhan', 'vivek.chauhan@aashirwadworkforce.in', '+91 6471327624', 'Private Ltd', 'Gujarat', 'Anand', 'Y', 'Y', '1,32,00,000.00', 'SR-5459522', 'Documents received'),
('VOR-26-0486', '22 Sep 2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AI10', '1004', 'ELECTRICAL', 'LT switchgear and DBs for Vadodara Ring Road Package 3', 'Arihant Electricals LLP', 'Amit Shah', 'amit.shah@arihantelectricals.com', '+91 6864425805', 'Limited Liability Partnership', 'Gujarat', 'Ahmedabad', 'N', 'Y', '53,00,000.00', 'SR-4703166', 'Documents received'),
('VOR-26-0441', '10-09-2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AI10', '1004', 'AGGREGATE', 'Aggregates and M-sand for Vadodara Ring Road Package 3', 'Garuda Minerals ', 'Zoya Solanki', 'zoya.solanki@garudaminerals.in', '+91 9679230109', 'Partnership', 'Gujarat', 'Rajkot', 'Y', 'Y', '1,22,00,000.00', 'SR-9421720', 'Documents received'),
('VOR-26-0509', '24.09.2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AI10', '1002', 'SCAFFOLDING', 'Cuplock scaffolding hire for Sanand Industrial Park Project', 'dhara access systems', 'Rohit Bhatt', 'rohit.bhatt@dharaaccesssystems.com', '+91 6849515683', 'Proprietorship', 'Gujarat', 'Ahmedabad', 'Y', 'Y', '42,00,000.00', 'SR-8038352', 'Documents received'),
('VOR-26-0590', '06-10-2026', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AC20', '2001', 'EQUIP_RENTAL', 'Crane and DG set hire for Vadodara Grinding Unit', 'Keystone Equipment Hire LLP', 'Krunal Pandya', 'krunal.pandya@keystoneequipmenth.com', '+91 8782882357', 'Limited Liability Partnership', 'Gujarat', 'Ahmedabad', 'N', 'Y', '34,00,000.00', 'SR-2052449', 'Documents received'),
('VOR-26-0477', '22-09-26', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AE30', '3001', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Bhuj Solar Park Phase 2', 'Mahi Builders', 'Nirav Vyas', 'nirav.vyas@mahibuilders.in', '+91 9559293809', 'Proprietorship Firm', 'Gujarat', 'Anand', 'N', 'Y', '1,52,00,000.00', 'SR-4016572', 'Documents received'),
('VOR-26-0560', '05.10.2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AC20', '2002', 'RMC', 'Ready-mix concrete M25 to M40 for Rajkot RMC Plant', 'Omkar RMC Limited', 'Vivek Solanki', 'vivek.solanki@omkarrmc.co.in', '+91 8976336909', 'Public Limited Company', 'Gujarat', 'Anand', 'N', 'Y', '2,75,00,000.00', 'SR-1910948', 'Documents received'),
('VOR-26-0469', '21-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AI10', '1001', 'IT_SVC', 'Managed network support for Ahmedabad Head Office', 'Bansi Technologies', 'Manan Jadeja', 'manan.jadeja@bansitechnologies.co.in', '+91 7349587691', 'Partnership', 'Gujarat', 'Bharuch', 'N', 'Y', '17,00,000.00', 'SR-7510548', 'Documents received'),
('VOR-26-0526', '29-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AC20', '2001', 'AMC', 'DG set and HVAC AMC for Vadodara Grinding Unit', 'Shivam Maintenance Services', 'Krunal Parikh', 'krunal.parikh@shivammaintenances.co.in', '+91 6912334005', 'Proprietorship', 'Rajasthan', 'Udaipur', 'N', 'Y', '14,00,000.00', 'SR-2901916', 'Documents received'),
('VOR-26-0482', '22/09/2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AI10', '1002', 'MANPOWER', 'Skilled and semi-skilled manpower for Sanand Industrial Park Project, about 80 workers from next month', 'Aravalli Manpower Services', 'Arjun Menon', 'arjun.menon@aravallimanpowerse.com', '+91 6394675350', 'Proprietorship Firm', 'Madhya Pradesh', 'Indore', 'Y', 'Y', 'Rs. 74,00,000/-', 'SR-5382445', 'Documents awaited'),
('VOR-26-0578', '05-10-2026', 'Kavya D''Souza', 'kavya.dsouza@ashvakagroup.in', 'AC20', '2002', 'RMC', 'Ready-mix concrete M25 to M40 for Rajkot RMC Plant', 'Dhara RMC LLP', 'Nikhil Bhatt', 'nikhil.bhatt@dhararmc.co.in', '+91 8803617688', 'LLP', 'Gujarat', 'Vadodara', 'N', 'Y', '1,27,00,000.00', 'SR-1194970', 'Documents awaited'),
('VOR-26-0609', '07-10-2026', 'Maria Solanki', 'maria.solanki@ashvakagroup.in', 'AI10', '1001', 'HOUSEKEEPING', 'Housekeeping staff for Ahmedabad Head Office site offices and labour camp', 'Pragati Housekeeping Services', 'Mitesh D''Souza', 'mitesh.dsouza@pragatihousekeepin.in', '+91 7476787814', 'Public Ltd Company', 'Gujarat', 'Rajkot', 'Y', 'Y', '21,00,000.00', 'SR-9782840', 'Documents received'),
('VOR-26-0588', '06-10-2026', 'Sameer Patel', 'sameer.patel@ashvakagroup.in', 'AI10', '1003', 'TRANSPORT', 'Trailer and tipper freight for Dahej Terminal Expansion Project', 'Aashirwad Carriers', 'Hetal Sanghvi', 'hetal.sanghvi@aashirwadcarriers.in', '+91 6221268219', 'LLP', 'Haryana', 'Faridabad', 'Y', 'Y', 'Rs. 49,00,000/-', 'SR-6803097', 'Documents received'),
('VOR-26-0603', '05-10-2026', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AL40', '4001', 'MANPOWER', 'Skilled and semi-skilled manpower for Bhiwandi Distribution Centre, about 120 workers from next month', 'Mahalaxmi Workforce Solutions', 'Dhruv Parikh', 'dhruv.parikh@mahalaxmiworkforce.in', '+91 6847041084', 'Proprietorship Firm', 'Maharashtra', 'Aurangabad', 'N', 'Y', '90,00,000.00', 'SR-3711156', 'Documents received'),
('VOR-26-0567', '05-10-2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AC20', '2002', 'EQUIP_RENTAL', 'Crane and DG set hire for Rajkot RMC Plant', 'Sankalp Equipment Hire Private Limited', 'Meera Amin', 'meera.amin@sankalpequipmenthi.co.in', '+91 8584371614', 'Private Limited Company', 'Gujarat', 'Anand', 'N', 'Y', '57,00,000.00', 'SR-8399646', 'Documents received'),
('VOR-26-0576', '01-10-2026', 'Manan Brahmbhatt', 'manan.brahmbhatt@ashvakagroup.in', 'AL40', '4001', 'AMC', 'DG set and HVAC AMC for Bhiwandi Distribution Centre', 'Bhagyoday Engineering Services', 'Ishaan Sheikh', 'ishaan.sheikh@bhagyodayengineeri.in', '+91 8249687080', 'Sole Proprietor', 'Maharashtra', 'Bhiwandi', 'N', 'N', '6,00,000.00', 'SR-8369245', 'Documents received'),
('VOR-26-0517', '25-09-2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AL40', '4001', 'TRANSPORT', 'Trailer and tipper freight for Bhiwandi Distribution Centre', 'Parshva Roadlines Pvt Ltd', 'Sneha Menon', 'sneha.menon@parshvaroadlines.co.in', '+91 6500315197', 'Pvt Ltd Company', 'Gujarat', 'Ahmedabad', 'N', 'Y', '50,00,000.00', 'SR-3388085', 'Documents received'),
('VOR-26-0608', 'Oct 7, 2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AI10', '1001', 'HOUSEKEEPING', 'Housekeeping staff for Ahmedabad Head Office site offices and labour camp', 'Dhara Facility Services Pvt Ltd', 'Hardik Rathod', 'hardik.rathod@dharafacilityservi.in', '+91 6453967691', 'Private Ltd', 'Maharashtra', 'Pune', 'Y', 'Y', '15,00,000.00', 'SR-5133071', 'Documents received'),
('VOR-26-0499', '23-09-2026', 'Maria Solanki', 'maria.solanki@ashvakagroup.in', 'AL40', '4001', 'MANPOWER', 'Skilled and semi-skilled manpower for Bhiwandi Distribution Centre, about 120 workers from next month', 'Lotus Labour Contractors', 'Vivek Rao', 'vivek.rao@lotuslabourcontrac.co.in', '+91 7698588166', 'Proprietorship Firm', 'Gujarat', 'Anand', 'N', 'Y', '1,09,00,000.00', 'SR-4110358', 'Documents received'),
('VOR-26-0456', '11-09-2026', 'Neha Amin', 'neha.amin@ashvakagroup.in', 'AI10', '1004', 'ELECTRICAL', 'LT switchgear and DBs for Vadodara Ring Road Package 3', 'Sahjanand Switchgear L.L.P.', 'Heena Mistry', 'heena.mistry@sahjanandswitchgea.in', '+91 7682016257', 'LLP', 'Madhya Pradesh', 'Bhopal', 'N', 'Y', '24,00,000.00', 'SR-6915692', 'Documents received'),
('VOR-26-0426', '07-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AC20', '2002', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Rajkot RMC Plant', 'siddhivinayak industrial safety ', 'Kruti Bhatt', 'kruti.bhatt@siddhivinayakindus.in', '+91 8758699671', 'Partnership Firm', 'Gujarat', 'Sanand', 'N', 'Y', '9,00,000.00', 'SR-6070122', 'Documents received'),
('VOR-26-0488', '22-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AC20', '2001', 'TRANSPORT', 'Trailer and tipper freight for Vadodara Grinding Unit', 'Bhumi Carriers', 'Aarav Bhatt', 'aarav.bhatt@bhumicarriers.in', '+91 6303639526', 'Sole Proprietor', 'Gujarat', 'Gandhinagar', 'N', 'Y', '1,41,00,000.00', 'SR-8900822', 'Documents received'),
('VOR-26-0546', '30-09-2026', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AC20', '2002', 'ELECTRICAL', 'LT switchgear and DBs for Rajkot RMC Plant', 'avadh electric co', 'Suresh Kapadia', 'suresh.kapadia@avadhelectricco.com', '+91 8284906059', 'Proprietorship Firm', 'Madhya Pradesh', 'Indore', 'Y', 'Y', '32,00,000.00', 'SR-6432324', 'Documents received'),
('VOR-26-0438', '10-09-2026', 'Yash Amin', 'yash.amin@ashvakagroup.in', 'AC20', '2001', 'SECURITY', 'Security guards and a supervisor for Vadodara Grinding Unit, round the clock', 'Kesar Protection Force ', 'Riya Parikh', 'riya.parikh@kesarprotectionfor.in', '+91 7410152183', 'LLP', 'Gujarat', 'Vadodara', 'N', 'Y', 'INR 55,00,000.00', 'SR-5294071', 'Documents received'),
('VOR-26-0558', 'Oct 1, 2026', 'Aarav Rao', 'aarav.rao@ashvakagroup.in', 'AC20', '2001', 'MANPOWER', 'Skilled and semi-skilled manpower for Vadodara Grinding Unit, about 120 workers from next month', 'M/s Vishwakarma Manpower Services & Co', 'Aakash Oza', 'aakash.oza@vishwakarmamanpowe.co.in', '+91 9288209712', 'Partnership Firm', 'Gujarat', 'Bhuj', 'Y', 'Y', '1,49,00,000.00', 'SR-3555603', 'Documents received'),
('VOR-26-0577', '05-10-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AI10', '1001', 'STEEL', 'TMT bars Fe550D for Ahmedabad Head Office', 'Mahi Ispat', 'Jinal D''Souza', 'jinal.dsouza@mahiispat.in', '+91 9730532460', 'Public Limited Company', 'Madhya Pradesh', 'Pithampur', 'Y', 'Y', '₹ 1,25,00,000.00', 'SR-2520509', 'Documents received'),
('VOR-26-0429', '07-09-2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AI10', '1001', 'CONSULTING', 'Environmental monitoring study for Ahmedabad Head Office', 'Suryoday Engineering Consultants Private Limited', 'Vikram Gill', 'vikram.gill@suryodayengineerin.co.in', '+91 7233988757', 'Private Ltd', 'Gujarat', 'Mehsana', 'N', 'Y', 'INR 10,00,000.00', 'SR-1138507', 'Documents received'),
('VOR-26-0587', '06-10-2026', 'Heena Solanki', 'heena.solanki@ashvakagroup.in', 'AC20', '2002', 'EQUIP_RENTAL', 'Crane and DG set hire for Rajkot RMC Plant', 'sabar earthmovers private limited', 'Zoya Amin', 'zoya.amin@sabarearthmovers.in', '+91 6413988741', 'Private Ltd', 'Gujarat', 'Mehsana', 'Y', 'Y', '6,200,000.00', 'SR-9383985', 'Documents received'),
('VOR-26-0506', '25-09-2026', 'Aarav Dave', 'aarav.dave@ashvakagroup.in', 'AI10', '1002', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Sanand Industrial Park Project', 'Jyoti Industrial Safety', 'Sagar Vaghela', 'sagar.vaghela@jyotiindustrialsaf.com', '+91 7922457072', 'Proprietorship', 'Maharashtra', 'Mumbai', 'Y', 'Y', '20,00,000.00', 'SR-1119788', 'Documents received'),
('VOR-26-0604', '07-10-2026', 'Sana Singh', 'sana.singh@ashvakagroup.in', 'AC20', '2002', 'AGGREGATE', 'Aggregates and M-sand for Rajkot RMC Plant', 'suryoday minerals', 'Maria Rao', 'MARIA.RAO@SURYODAYMINERALS.COM', '+91 7526347475', 'Sole Proprietor', 'Maharashtra', 'Bhiwandi', 'Y', 'Y', '1,16,00,000.00', 'SR-8445710', 'Documents received'),
('VOR-26-0545', '29-09-2026', 'Kavya D''Souza', 'kavya.dsouza@ashvakagroup.in', 'AC20', '2001', 'EQUIP_RENTAL', 'Crane and DG set hire for Vadodara Grinding Unit', 'kesar earthmovers', 'Parth Chauhan', 'parth.chauhan@kesarearthmovers.in', '+91 8598001391', 'Proprietorship', 'Gujarat', 'Ahmedabad', 'Y', 'Y', '3,000,000.00', 'SR-6943647', 'Documents received'),
('VOR-26-0423', '07-09-2026', 'Neha Amin', 'neha.amin@ashvakagroup.in', 'AL40', '4001', 'AMC', 'DG set and HVAC AMC for Bhiwandi Distribution Centre', 'Shree Umiya Engineering Services & Co', 'Sameer Sharma', 'sameer.sharma@shreeumiyaengineer.in', '+91 8540046934', 'Partnership Firm', 'Gujarat', 'Bhuj', 'Y', 'Y', '8,00,000.00', 'SR-6073929', 'Documents received'),
('VOR-26-0512', '25-09-2026', 'Sana Singh', 'sana.singh@ashvakagroup.in', 'AI10', '1001', 'SECURITY', 'Security guards and a supervisor for Ahmedabad Head Office, round the clock', 'Narmada Guarding Services', 'Nisha Sanghvi', 'nisha.sanghvi@narmadaguardingser.co.in', '+91 9646582006', 'LLP', 'Gujarat', 'Bhuj', 'Y', 'Y', '45,00,000.00', 'SR-7786341', 'Documents received'),
('VOR-26-0542', '30-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AI10', '1002', 'STEEL', 'TMT bars Fe550D for Sanand Industrial Park Project', 'Keystone Steel Traders', 'Maria Nair', 'maria.nair@keystonesteeltrade.com', '+91 7458023250', 'Partnership Firm', 'Gujarat', 'Sanand', 'Y', 'Y', 'Rs. 8,59,00,000/-', 'SR-7676352', 'Documents awaited'),
('VOR-26-0564', '05-10-2026', 'Maria Solanki', 'maria.solanki@ashvakagroup.in', 'AL40', '4001', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Bhiwandi Distribution Centre', 'Gokul Safety Solutions', 'Arjun Nair', 'arjun.nair@gokulsafetysolutio.in', '+91 8718974898', 'Partnership Firm', 'Rajasthan', 'Bhilwara', 'N', 'Y', '1,000,000.00', 'SR-6469027', 'Documents received'),
('VOR-26-0515', '25.09.2026', 'Aarav Dave', 'aarav.dave@ashvakagroup.in', 'AI10', '1001', 'IT_SVC', 'Managed network support for Ahmedabad Head Office', 'pinnacle digital services', 'Rohit Brahmbhatt', 'rohit.brahmbhatt@pinnacledigitalser.in', '+91 8875184424', 'Proprietorship Firm', 'Madhya Pradesh', 'Bhopal', 'N', 'Y', '24,00,000.00', 'SR-1605329', 'Documents received'),
('VOR-26-0554', '01-10-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AC20', '2002', 'SCAFFOLDING', 'Cuplock scaffolding hire for Rajkot RMC Plant', 'Unnati Formwork Systems', 'Riya Bhatt', 'riya.bhatt@unnatiformworksyst.in', '+91 7784289775', 'Partnership Firm', 'Gujarat', 'Bharuch', 'Y', 'Y', '31,00,000.00', 'SR-2926378', 'Documents received'),
('VOR-26-0553', '01-10-2026', 'Kavya D''Souza', 'kavya.dsouza@ashvakagroup.in', 'AI10', '1004', 'STEEL', 'TMT bars Fe550D for Vadodara Ring Road Package 3', 'Kaveri Steel Private Limited ', 'Pooja Amin', 'pooja.amin@kaveristeel.co.in', '+91 7996035952', 'Pvt Ltd Company', 'Gujarat', 'Rajkot', 'Y', 'Y', '1,28,00,000.00', 'SR-7609033', 'Documents received'),
('VOR-26-0475', '21/09/2026', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AL40', '4001', 'SECURITY', 'Security guards and a supervisor for Bhiwandi Distribution Centre, round the clock', 'Jyoti Guarding Services', 'Manan Reddy', 'manan.reddy@jyotiguardingservi.co.in', '+91 8339942158', 'LLP', 'Madhya Pradesh', 'Indore', 'Y', 'Y', '18,00,000.00', 'SR-3708551', 'Documents received'),
('VOR-26-0596', '05-10-2026', 'Sana Singh', 'sana.singh@ashvakagroup.in', 'AI10', '1003', 'AGGREGATE', 'Aggregates and M-sand for Dahej Terminal Expansion Project', 'Trikam Aggregates Pvt Ltd', 'Vivek Jadeja', 'vivek.jadeja@trikamaggregates.in', '+91 9263076768', 'Private Limited Company', 'Gujarat', 'Ahmedabad', 'N', 'Y', '1,47,00,000.00', 'SR-5302895', 'Documents received'),
('VOR-26-0413', '07-09-2026', 'Kavya D''Souza', 'kavya.dsouza@ashvakagroup.in', 'AI10', '1002', 'CEMENT', 'OPC 53 and PPC cement for Sanand Industrial Park Project', 'M/s Darshan Cement & Co', 'Heena Fernandes', 'heena.fernandes@darshancement.in', '+91 8647674702', 'Partnership Firm', 'Gujarat', 'Surat', 'N', 'Y', '3,60,00,000.00', 'SR-1437361', 'Documents received'),
('VOR-26-0496', '24-09-2026', 'Heena Solanki', 'heena.solanki@ashvakagroup.in', 'AI10', '1002', 'CEMENT', 'OPC 53 and PPC cement for Sanand Industrial Park Project', 'Vihaan Building Materials', 'Vivek Verma', 'vivek.verma@vihaanbuildingmate.in', '+91 7671521218', 'Limited Liability Partnership', 'Maharashtra', 'Mumbai', 'Y', 'Y', '3,85,00,000.00', 'SR-3364228', 'Documents received'),
('VOR-26-0417', '03-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AL40', '4001', 'EQUIP_RENTAL', 'Crane and DG set hire for Bhiwandi Distribution Centre', 'Narmada Equipment Hire', 'Nikhil Reddy', 'NIKHIL.REDDY@NARMADAEQUIPMENTHI.IN', '+91 8930096184', 'Sole Proprietor', 'Gujarat', 'Ahmedabad', 'N', 'Y', 'Rs. 74,00,000/-', 'SR-5276274', 'Documents received'),
('VOR-26-0508', '24-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AI10', '1003', 'MANPOWER', 'Skilled and semi-skilled manpower for Dahej Terminal Expansion Project, about 80 workers from next month', 'Gokul Labour Contractors Pvt Ltd', 'Rutvik Sharma', 'rutvik.sharma@gokullabourcontrac.in', '+91 9527186567', 'Private Ltd', 'Gujarat', 'Vadodara', 'N', 'Y', '1,04,00,000.00', 'SR-2739602', 'Documents received'),
('VOR-26-0543', '30 Sep 2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AE30', '3001', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Bhuj Solar Park Phase 2', 'Eshan Constructions Pvt ', 'Sneha Rathod', 'sneha.rathod@eshanconstruction.in', '+91 6557811194', 'Pvt Ltd Company', 'Haryana', 'Faridabad', 'N', 'Y', '33200000.00', 'SR-3723245', 'Documents received'),
('VOR-26-0513', '24-09-2026', 'Sana Singh', 'sana.singh@ashvakagroup.in', 'AI10', '1003', 'TRANSPORT', 'Trailer and tipper freight for Dahej Terminal Expansion Project', 'Shree Umiya Carriers Private Limited', 'Hetal D''Souza', 'hetal.dsouza@shreeumiyacarriers.com', '+91 8723287240', 'Pvt Ltd Company', 'Gujarat', 'Rajkot', 'N', 'Y', '1,34,00,000.00', 'SR-7522828', 'Documents received'),
('VOR-26-0552', 'Sep 30, 2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AE30', '3001', 'SOLAR', 'Module mounting structures and BOS for Bhuj Solar Park Phase 2', 'Lotus Solar Private Limited', 'Hetal Nair', 'HETAL.NAIR@LOTUSSOLAR.COM', '+91 6729809395', 'Private Limited Company', 'Rajasthan', 'Jaipur', 'N', 'Y', '10,42,00,000.00', 'SR-9637652', 'Documents received'),
('VOR-26-0602', '05-10-2026', 'Neha Amin', 'neha.amin@ashvakagroup.in', 'AI10', '1003', 'EQUIP_RENTAL', 'Crane and DG set hire for Dahej Terminal Expansion Project', 'Kesar Crane Services Pvt Ltd', 'Harsh Trivedi', 'harsh.trivedi@kesarcraneservices.co.in', '+91 7702895448', 'Private Ltd', 'Gujarat', 'Sanand', 'Y', 'Y', '33,00,000.00', 'SR-2956202', 'Documents received'),
('VOR-26-0580', '05-10-2026', 'Devang Menon', 'devang.menon@ashvakagroup.in', 'AI10', '1004', 'LAB_TESTING', 'Third party material testing (cubes, steel, aggregates) for Vadodara Ring Road Package 3', 'Sankalp Testing Laboratory Private Limited ', 'Suresh Sheikh', 'suresh.sheikh@sankalptestinglabo.co.in', '+91 9179673303', 'Private Ltd', 'Karnataka', 'Hubballi', 'N', 'Y', '11,00,000.00', 'SR-1110470', 'Documents received'),
('VOR-26-0434', '10-09-2026', 'Sameer Patel', 'sameer.patel@ashvakagroup.in', 'AI10', '1001', 'MANPOWER', 'Skilled and semi-skilled manpower for Ahmedabad Head Office, about 80 workers from next month', 'Pragati Labour Contractors', 'Kinjal Shukla', 'kinjal.shukla@pragatilabourcontr.com', '+91 8253111762', 'Proprietorship', 'Gujarat', 'Surat', 'Y', 'Y', 'Rs. 50,00,000/-', 'SR-6454981', 'Documents received'),
('VOR-26-0483', '22-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AI10', '1004', 'STEEL', 'TMT bars Fe550D for Vadodara Ring Road Package 3', 'Indus Steel Private Limited', 'Riya Joshi', 'riya.joshi@indussteel.co.in', '+91 7155561271', 'Private Limited Company', 'Gujarat', 'Rajkot', 'Y', 'Y', '₹ 8,35,00,000.00', 'SR-7225103', 'Documents received'),
('VOR-26-0549', '30-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AC20', '2002', 'SECURITY', 'Security guards and a supervisor for Rajkot RMC Plant, round the clock', 'kesar guarding services private limited', 'Gurpreet Reddy', 'gurpreet.reddy@kesarguardingservi.com', '+91 8164354580', 'Private Limited Company', 'Gujarat', 'Anand', 'Y', 'Y', '30,00,000.00', 'SR-1806326', 'Documents received'),
('VOR-26-0593', '06 Oct 2026', 'Kavya Bhatt', 'kavya.bhatt@ashvakagroup.in', 'AI10', '1002', 'CEMENT', 'OPC 53 and PPC cement for Sanand Industrial Park Project', 'Crestline Cement Traders', 'Aakash Mistry', 'AAKASH.MISTRY@CRESTLINECEMENTTRA.IN', '+91 9157137549', 'Proprietorship', 'Haryana', 'Faridabad', 'N', 'Y', '2,15,00,000.00', 'SR-9959160', 'Documents received'),
('VOR-26-0547', '30/09/2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AC20', '2002', 'EQUIP_RENTAL', 'Crane and DG set hire for Rajkot RMC Plant', 'Arihant Earthmovers', 'Harsh Patel', 'harsh.patel@arihantearthmovers.in', '+91 6302033023', 'Partnership', 'Karnataka', 'Hubballi', 'N', 'Y', '26,00,000.00', 'SR-1050184', 'Documents received'),
('VOR-26-0493', '23-09-2026', 'Maria Solanki', 'maria.solanki@ashvakagroup.in', 'AI10', '1004', 'AGGREGATE', 'Aggregates and M-sand for Vadodara Ring Road Package 3', 'Sabar Stone Crusher Private Limited', 'Simran Bhatt', 'simran.bhatt@sabarstonecrusher.in', '+91 9902785272', 'Pvt Ltd Company', 'Maharashtra', 'Bhiwandi', 'Y', 'Y', '23,00,000.00', 'SR-1761480', 'Documents received'),
('VOR-26-0467', '16-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AE30', '3001', 'STEEL', 'TMT bars Fe550D for Bhuj Solar Park Phase 2', 'Keystone Ispat Private Limited', 'Meera Thakkar', 'meera.thakkar@keystoneispat.in', '+91 7121884140', 'Private Ltd', 'Gujarat', 'Gandhinagar', 'Y', 'Y', '26,300,000.00', 'SR-3866561', 'Documents received'),
('VOR-26-0447', '10-09-2026', 'Heena Solanki', 'heena.solanki@ashvakagroup.in', 'AE30', '3001', 'SOLAR', 'Module mounting structures and BOS for Bhuj Solar Park Phase 2', 'Tirth Renewables Pvt Ltd', 'Imran Sheikh', 'imran.sheikh@tirthrenewables.in', '+91 9542514565', 'Private Limited Company', 'Rajasthan', 'Jaipur', 'Y', 'Y', '₹ 10,47,00,000.00', 'SR-4021342', 'Documents received'),
('VOR-26-0614', '09-10-2026', 'Aarav Rao', 'aarav.rao@ashvakagroup.in', 'AL40', '4001', 'STEEL', 'TMT bars Fe550D for Bhiwandi Distribution Centre', 'Jay Ambe Ispat ', 'Neha Sharma', 'neha.sharma@jayambeispat.com', '+91 9120683451', 'Partnership', 'Gujarat', 'Bhuj', 'Y', 'Y', '1,26,00,000.00', 'SR-7438540', 'Documents awaited'),
('VOR-26-0478', '22-09-2026', 'Yash Amin', 'yash.amin@ashvakagroup.in', 'AC20', '2001', 'CEMENT', 'OPC 53 and PPC cement for Vadodara Grinding Unit', 'Radhe and Sons', 'Priyanka Bhatt', 'priyanka.bhatt@radhecement.co.in', '+91 6117819606', 'Partnership Firm', 'Gujarat', 'Ahmedabad', 'Y', 'Y', '33200000.00', 'SR-9592040', 'Documents received'),
('VOR-26-0439', '09 Sep 2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AL40', '4001', 'STEEL', 'TMT bars Fe550D for Bhiwandi Distribution Centre', 'Jyoti Steel Traders', 'Tanvi Joshi', 'tanvi.joshi@jyotisteeltraders.in', '+91 6600261971', 'Limited Liability Partnership', 'Gujarat', 'Gandhinagar', 'N', 'Y', '7,10,00,000.00', 'SR-7583578', 'Documents received'),
('VOR-26-0541', 'Sep 30, 2026', 'Neha Amin', 'neha.amin@ashvakagroup.in', 'AI10', '1002', 'RMC', 'Ready-mix concrete M25 to M40 for Sanand Industrial Park Project', 'Rudra Concrete Pvt Ltd', 'Neha Panchal', 'neha.panchal@rudraconcrete.co.in', '+91 9738276824', 'Private Limited Company', 'Gujarat', 'Sanand', 'N', 'Y', '4,38,00,000.00', 'SR-1897771', 'Documents received'),
('VOR-26-0518', '28-09-26', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AI10', '1004', 'LAB_TESTING', 'Third party material testing (cubes, steel, aggregates) for Vadodara Ring Road Package 3', 'Prayag Quality Labs', 'Urvashi Pandya', 'urvashi.pandya@prayagqualitylabs.co.in', '+91 8179485937', 'Sole Proprietor', 'Gujarat', 'Sanand', 'Y', 'Y', '4,00,000.00', 'SR-8761040', 'Documents received'),
('VOR-26-0461', '15-09-26', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AC20', '2002', 'HOUSEKEEPING', 'Housekeeping staff for Rajkot RMC Plant site offices and labour camp', 'Arihant Facility Services Ltd. ', 'Venkat Joshi', 'venkat.joshi@arihantfacilityser.in', '+91 6731634273', 'Public Limited Company', 'Gujarat', 'Ahmedabad', 'N', 'Y', '16,00,000.00', 'SR-1581092', 'Documents received'),
('VOR-26-0607', '07/10/2026', 'Sana Singh', 'sana.singh@ashvakagroup.in', 'AI10', '1002', 'SECURITY', 'Security guards and a supervisor for Sanand Industrial Park Project, round the clock', 'navjivan guarding services', 'Rakesh Thakkar', 'rakesh.thakkar@navjivanguardingse.in', '+91 8790625468', 'Proprietorship Firm', 'Gujarat', 'Bhuj', 'Y', 'Y', '42,00,000.00', 'SR-4444843', 'Documents received'),
('VOR-26-0422', '08-09-26', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AC20', '2001', 'TRANSPORT', 'Trailer and tipper freight for Vadodara Grinding Unit', 'Girnar Carriers & Co', 'Hardik Iyer', 'HARDIK.IYER@GIRNARCARRIERS.CO.IN', '+91 7765905598', 'Partnership Firm', 'Karnataka', 'Mysuru', 'Y', 'Y', '40,00,000.00', 'SR-3259018', 'Documents received'),
('VOR-26-0582', '01 Oct 2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AE30', '3001', 'MANPOWER', 'Skilled and semi-skilled manpower for Bhuj Solar Park Phase 2, about 120 workers from next month', 'Deccan Labour Contractors', 'Farhan Oza', 'farhan.oza@deccanlabourcontra.in', '+91 9794377280', 'Proprietorship', 'Gujarat', 'Anand', 'N', 'Y', '84,00,000.00', 'SR-7561463', 'Documents received'),
('VOR-26-0449', '11-09-2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AL40', '4001', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Bhiwandi Distribution Centre', 'Eshan Infra Private Limited', 'Krunal Oza', 'krunal.oza@eshaninfra.in', '+91 8616408746', 'Private Ltd', 'Gujarat', 'Gandhinagar', 'N', 'Y', '1,52,00,000.00', 'SR-7638200', 'Documents received'),
('VOR-26-0458', '14-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AL40', '4001', 'AMC', 'DG set and HVAC AMC for Bhiwandi Distribution Centre', 'Garuda Maintenance Services', 'Chirag Sharma', 'chirag.sharma@garudamaintenances.com', '+91 8150220098', 'Partnership Firm', 'Gujarat', 'Bhuj', 'Y', 'Y', '9,00,000.00', 'SR-7980627', 'Documents received'),
('VOR-26-0420', '07-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AC20', '2001', 'SCAFFOLDING', 'Cuplock scaffolding hire for Vadodara Grinding Unit', 'Sthapatya Scaffolding L.L.P. ', 'Meera Shah', 'meera.shah@sthapatyascaffoldi.com', '+91 8903540924', 'LLP', 'Gujarat', 'Gandhinagar', 'N', 'Y', '10,00,000.00', 'SR-8291599', 'Documents received'),
('VOR-26-0490', '22-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AC20', '2002', 'HOUSEKEEPING', 'Housekeeping staff for Rajkot RMC Plant site offices and labour camp', 'avadh housekeeping services ', 'Sneha Pandya', 'sneha.pandya@avadhhousekeepings.co.in', '+91 7897189628', 'Private Limited Company', 'Gujarat', 'Ahmedabad', 'Y', 'Y', '18,00,000.00', 'SR-1696523', 'Documents received'),
('VOR-26-0452', '14-09-2026', 'Manan Brahmbhatt', 'manan.brahmbhatt@ashvakagroup.in', 'AE30', '3001', 'CABLE', 'LT and DC solar cables for Bhuj Solar Park Phase 2', 'Pinnacle Cable Industries', 'Sagar Trivedi', 'sagar.trivedi@pinnaclecableindus.com', '+91 8314237498', 'Private Ltd', 'Gujarat', 'Vadodara', 'N', 'Y', '5,300,000.00', 'SR-4981876', 'Documents received'),
('VOR-26-0468', '17-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AE30', '3001', 'CABLE', 'LT and DC solar cables for Bhuj Solar Park Phase 2', 'Indus Wires and Cables ', 'Shreya Nair', 'shreya.nair@induswiresandcable.co.in', '+91 6871843298', 'Proprietorship', 'Maharashtra', 'Mumbai', 'N', 'Y', '1,34,00,000.00', 'SR-9784442', 'Documents received'),
('VOR-26-0563', '05-10-2026', 'Neha Amin', 'neha.amin@ashvakagroup.in', 'AL40', '4001', 'TRANSPORT', 'Trailer and tipper freight for Bhiwandi Distribution Centre', 'Darshan Transport Co', 'Joseph Thakkar', 'joseph.thakkar@darshantransportco.in', '+91 9664963045', 'Private Limited Company', 'Maharashtra', 'Bhiwandi', 'Y', 'Y', '25,00,000.00', 'SR-9088986', 'Documents received'),
('VOR-26-0539', '29-09-2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AI10', '1003', 'SECURITY', 'Security guards and a supervisor for Dahej Terminal Expansion Project, round the clock', 'keystone protection force', 'Aakash Panchal', 'aakash.panchal@keystoneprotection.in', '+91 6717733778', 'Private Limited Company', 'Gujarat', 'Sanand', 'N', 'Y', '42,00,000.00', 'SR-4629375', 'Documents received'),
('VOR-26-0498', '24-09-2026', 'Sana Singh', 'sana.singh@ashvakagroup.in', 'AI10', '1002', 'RMC', 'Ready-mix concrete M25 to M40 for Sanand Industrial Park Project', 'Tapti Concrete', 'Suresh Iyer', 'suresh.iyer@tapticoncrete.co.in', '+91 8818572278', 'Pvt Ltd Company', 'Gujarat', 'Bharuch', 'Y', 'Y', 'INR 2,55,00,000.00', 'SR-6197643', 'Documents received'),
('VOR-26-0520', '25-09-2026', 'Kavya Bhatt', 'kavya.bhatt@ashvakagroup.in', 'AL40', '4001', 'TRANSPORT', 'Trailer and tipper freight for Bhiwandi Distribution Centre', 'Riddhi Roadways Private Limited', 'Mitesh Reddy', 'MITESH.REDDY@RIDDHIROADWAYS.CO.IN', '+91 8616941060', 'Private Limited Company', 'Gujarat', 'Mehsana', 'Y', 'Y', '7600000.00', 'SR-6643125', 'Documents received'),
('VOR-26-0516', '28-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AI10', '1003', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Dahej Terminal Expansion Project', 'uday infra', 'Ankit Jadeja', 'ankit.jadeja@udayinfra.in', '+91 9258345860', 'Partnership Firm', 'Gujarat', 'Anand', 'N', 'Y', '37,800,000.00', 'SR-4096420', 'Documents received'),
('VOR-26-0598', '06.10.2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AI10', '1002', 'MANPOWER', 'Skilled and semi-skilled manpower for Sanand Industrial Park Project, about 120 workers from next month', 'Suryoday Manpower Services', 'Jignesh Amin', 'JIGNESH.AMIN@SURYODAYMANPOWERSE.CO.IN', '+91 8268724469', 'Sole Proprietor', 'Gujarat', 'Bhuj', 'Y', 'Y', '₹ 85,00,000.00', 'SR-2668831', 'Documents received'),
('VOR-26-0500', '25.09.2026', 'Aarav Dave', 'aarav.dave@ashvakagroup.in', 'AI10', '1004', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Vadodara Ring Road Package 3', 'Pragati Infraprojects P. Ltd.', 'Ronak Kapadia', 'ronak.kapadia@pragatiinfraprojec.in', '+91 8419863467', 'Private Limited Company', 'Haryana', 'Faridabad', 'Y', 'Y', '1,34,00,000.00', 'SR-1007934', 'Documents received'),
('VOR-26-0583', '05-10-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AC20', '2001', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Vadodara Grinding Unit', 'prayag industrial safety private limited', 'Ishaan Brahmbhatt', 'ishaan.brahmbhatt@prayagindustrialsa.co.in', '+91 8849216868', 'Pvt Ltd Company', 'Gujarat', 'Bharuch', 'Y', 'Y', '₹ 17,00,000.00', 'SR-6569863', 'Documents awaited'),
('VOR-26-0471', '21-09-2026', 'Yash Amin', 'yash.amin@ashvakagroup.in', 'AI10', '1004', 'SECURITY', 'Security guards and a supervisor for Vadodara Ring Road Package 3, round the clock', 'Yamuna Security Services', 'Nirav Parmar', 'nirav.parmar@yamunasecurityserv.in', '+91 6820211927', 'Private Ltd', 'Haryana', 'Faridabad', 'Y', 'Y', '36,00,000.00', 'SR-8603218', 'Documents received'),
('VOR-26-0451', '11-09-2026', 'Maria Solanki', 'maria.solanki@ashvakagroup.in', 'AC20', '2001', 'MANPOWER', 'Skilled and semi-skilled manpower for Vadodara Grinding Unit, about 80 workers from next month', 'Vihaan Manpower Services ', 'Aakash Verma', 'aakash.verma@vihaanmanpowerserv.co.in', '+91 7394236535', 'LLP', 'Gujarat', 'Surat', 'N', 'Y', '3,300,000.00', 'SR-3738968', 'Documents received'),
('VOR-26-0494', '23-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AI10', '1003', 'EQUIP_RENTAL', 'Crane and DG set hire for Dahej Terminal Expansion Project', 'M/s Narmada Earthmovers', 'Mahesh Joshi', 'mahesh.joshi@narmadaearthmovers.in', '+91 9744949634', 'Proprietorship', 'Delhi', 'New Delhi', 'N', 'Y', '43,00,000.00', 'SR-2885591', 'Documents received'),
('VOR-26-0479', '21-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AI10', '1001', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Ahmedabad Head Office', 'Neelkanth Infraprojects', 'Nisha Menon', 'nisha.menon@neelkanthinfraproj.in', '+91 9488164614', 'Proprietorship Firm', 'Maharashtra', 'Bhiwandi', 'N', 'Y', 'Rs. 1,59,00,000/-', 'SR-4769915', 'Documents received'),
('VOR-26-0473', '21-09-2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AC20', '2001', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Vadodara Grinding Unit', 'M/s Girnar Safety Solutions', 'Arjun Rathod', 'arjun.rathod@girnarsafetysoluti.co.in', '+91 8618463325', 'Pvt Ltd Company', 'Maharashtra', 'Mumbai', 'Y', 'Y', '11,00,000.00', 'SR-8421281', 'Documents received'),
('VOR-26-0557', '01 Oct 2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AL40', '4001', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Bhiwandi Distribution Centre', 'Horizon Builders', 'Amit Kapadia', 'amit.kapadia@horizonbuilders.co.in', '+91 8560543382', 'Proprietorship Firm', 'Gujarat', 'Ahmedabad', 'N', 'Y', '2,53,00,000.00', 'SR-2280263', 'Documents received'),
('VOR-26-0535', '29-09-2026', 'Yash Amin', 'yash.amin@ashvakagroup.in', 'AC20', '2001', 'TRANSPORT', 'Trailer and tipper freight for Vadodara Grinding Unit', 'M/s Mahalaxmi Roadlines ', 'Foram Singh', 'foram.singh@mahalaxmiroadlines.in', '+91 6131169743', 'Sole Proprietor', 'Gujarat', 'Bhuj', 'N', 'Y', '1,21,00,000.00', 'SR-7977134', 'Documents received'),
('VOR-26-0472', '21-09-2026', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AI10', '1003', 'HOUSEKEEPING', 'Housekeeping staff for Dahej Terminal Expansion Project site offices and labour camp', 'Shree Umiya Facility Services', 'Kinjal Parmar', 'kinjal.parmar@shreeumiyafacility.co.in', '+91 8878667621', 'Pvt Ltd Company', 'Gujarat', 'Bhuj', 'Y', 'Y', '13,00,000.00', 'SR-7666211', 'Documents received'),
('VOR-26-0414', '03-09-2026', 'Aarav Rao', 'aarav.rao@ashvakagroup.in', 'AI10', '1004', 'HOUSEKEEPING', 'Housekeeping staff for Vadodara Ring Road Package 3 site offices and labour camp', 'STHAPATYA FACILITY SERVICES', 'Sameer Raval', 'sameer.raval@sthapatyafacility.in', '+91 7879547503', 'Limited Liability Partnership', 'Gujarat', 'Surat', 'Y', 'Y', '13,00,000.00', 'SR-8501995', 'Documents received'),
('VOR-26-0525', '29-09-2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AC20', '2001', 'TRANSPORT', 'Trailer and tipper freight for Vadodara Grinding Unit', 'yamuna logistics', 'Urvashi Shah', 'urvashi.shah@yamunalogistics.in', '+91 9558248626', 'Proprietorship Firm', 'Gujarat', 'Bharuch', 'N', 'Y', '1,09,00,000.00', 'SR-2524325', 'Documents received'),
('VOR-26-0485', '22-09-26', 'Kavya Bhatt', 'kavya.bhatt@ashvakagroup.in', 'AI10', '1003', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Dahej Terminal Expansion Project', 'Harsiddhi Infra & Co', 'Ronak Reddy', 'ronak.reddy@harsiddhiinfra.com', '+91 7331978265', 'Partnership Firm', 'Maharashtra', 'Mumbai', 'Y', 'Y', 'INR 3,39,00,000.00', 'SR-1304467', 'Documents received'),
('VOR-26-0536', '30-09-2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AI10', '1001', 'EQUIP_RENTAL', 'Crane and DG set hire for Ahmedabad Head Office', 'orbit earthmovers private limited', 'Parth Pathan', 'parth.pathan@orbitearthmovers.in', '+91 6913576653', 'Private Limited Company', 'Maharashtra', 'Pune', 'Y', 'Y', '23,00,000.00', 'SR-9020342', 'Documents received'),
('VOR-26-0457', '15-09-2026', 'Devang Menon', 'devang.menon@ashvakagroup.in', 'AC20', '2001', 'SAFETY_PPE', 'Helmets, harnesses and safety shoes for Vadodara Grinding Unit', 'Samarth Industrial Safety Pvt. Limited', 'Gurpreet Sanghvi', 'gurpreet.sanghvi@samarthindustrials.in', '+91 8301289197', 'Pvt Ltd Company', 'Gujarat', 'Bhuj', 'N', 'Y', '13,00,000.00', 'SR-3138214', 'Documents received'),
('VOR-26-0507', '24-09-2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AL40', '4001', 'EQUIP_RENTAL', 'Crane and DG set hire for Bhiwandi Distribution Centre', 'Bansi Equipment Hire LLP ', 'Mitesh Pathan', 'mitesh.pathan@bansiequipmenthire.com', '+91 7697797896', 'LLP', 'Gujarat', 'Vadodara', 'Y', 'Y', '35,00,000.00', 'SR-7068705', 'Documents received'),
('VOR-26-0544', '29-09-2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AI10', '1003', 'CONSULTING', 'Environmental monitoring study for Dahej Terminal Expansion Project', 'Chitra Consultants', 'Pooja Vaghela', 'pooja.vaghela@chitraconsultants.co.in', '+91 6226928446', 'Proprietorship', 'Gujarat', 'Anand', 'N', 'N', '10,00,000.00', 'SR-3865817', 'Documents received'),
('VOR-26-0463', '16-09-2026', 'Maria Solanki', 'maria.solanki@ashvakagroup.in', 'AC20', '2002', 'AGGREGATE', 'Aggregates and M-sand for Rajkot RMC Plant', 'M/s Zenith Aggregates Private Limited', 'Priyanka Kapadia', 'priyanka.kapadia@zenithaggregates.in', '+91 7532443226', 'Private Limited Company', 'Gujarat', 'Sanand', 'N', 'Y', '71,00,000.00', 'SR-9064222', 'Documents received'),
('VOR-26-0574', '01/10/2026', 'Devang Menon', 'devang.menon@ashvakagroup.in', 'AC20', '2002', 'CIVIL_WORKS', 'Civil works subcontract for boundary wall and drains at Rajkot RMC Plant', 'M/s Quartz Infra Private Limited', 'Manan Parikh', 'manan.parikh@quartzinfra.com', '+91 7763091371', 'Pvt Ltd Company', 'Gujarat', 'Rajkot', 'N', 'Y', 'INR 1,71,00,000.00', 'SR-5110358', 'Documents received'),
('VOR-26-0521', '25-09-2026', 'Heena Solanki', 'heena.solanki@ashvakagroup.in', 'AI10', '1001', 'CONSULTING', 'Environmental monitoring study for Ahmedabad Head Office', 'M/s Sabar Consultants L.L.P. ', 'Zoya Sharma', 'zoya.sharma@sabarconsultants.in', '+91 9530136785', 'Limited Liability Partnership', 'Gujarat', 'Mehsana', 'N', 'Y', '2100000.00', 'SR-5696053', 'Documents received'),
('VOR-26-0613', '07-10-2026', 'Sameer Patel', 'sameer.patel@ashvakagroup.in', 'AI10', '1001', 'IT_SVC', 'Managed network support for Ahmedabad Head Office', 'keystone it solutions ', 'Vikram Gill', 'vikram.gill@keystoneitsolution.in', '+91 9342291338', 'Sole Proprietor', 'Madhya Pradesh', 'Bhopal', 'N', 'Y', '3,200,000.00', 'SR-8187723', 'Documents awaited'),
('VOR-26-0571', '05-10-2026', 'Manan Brahmbhatt', 'manan.brahmbhatt@ashvakagroup.in', 'AI10', '1001', 'IT_SVC', 'Managed network support for Ahmedabad Head Office', 'Sthapatya IT Solutions Private Limited', 'Riya Qureshi', 'riya.qureshi@sthapatyaitsolutio.co.in', '+91 6443051976', 'Private Ltd', 'Gujarat', 'Ahmedabad', 'N', 'Y', '21,00,000.00', 'SR-8689599', 'Documents received'),
('VOR-26-0555', '01 Oct 2026', 'Rutvik Chauhan', 'rutvik.chauhan@ashvakagroup.in', 'AI10', '1004', 'CEMENT', 'OPC 53 and PPC cement for Vadodara Ring Road Package 3', 'crestline cement private limited', 'Sameer Trivedi', 'sameer.trivedi@crestlinecement.com', '+91 9242841303', 'Private Limited Company', 'Madhya Pradesh', 'Pithampur', 'Y', 'Y', '1,95,00,000.00', 'SR-9360964', 'Documents received'),
('VOR-26-0453', '11-09-2026', 'Heena Solanki', 'heena.solanki@ashvakagroup.in', 'AL40', '4001', 'TRANSPORT', 'Trailer and tipper freight for Bhiwandi Distribution Centre', 'Radhe Roadlines', 'Amit Sanghvi', 'amit.sanghvi@radheroadlines.in', '+91 8783772758', 'Pvt Ltd Company', 'Gujarat', 'Mehsana', 'N', 'Y', 'INR 84,00,000.00', 'SR-4034670', 'Documents received'),
('VOR-26-0487', '23-09-2026', 'Pooja Trivedi', 'pooja.trivedi@ashvakagroup.in', 'AI10', '1001', 'CONSULTING', 'Environmental monitoring study for Ahmedabad Head Office', 'Girnar Advisory Pvt Ltd', 'Ishaan Bhatt', 'ishaan.bhatt@girnaradvisory.in', '+91 7569848075', 'Pvt Ltd Company', 'Gujarat', 'Mehsana', 'Y', 'Y', '9,00,000.00', 'SR-3944102', 'Documents received'),
('VOR-26-0459', '15-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AL40', '4001', 'EQUIP_RENTAL', 'Crane and DG set hire for Bhiwandi Distribution Centre', 'Uday Earthmovers', 'Ankit Panchal', 'ankit.panchal@udayearthmovers.com', '+91 8928074878', 'Public Limited Company', 'Gujarat', 'Bharuch', 'N', 'Y', '29,00,000.00', 'SR-6241982', 'Documents received'),
('VOR-26-0448', '11-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AL40', '4001', 'AMC', 'DG set and HVAC AMC for Bhiwandi Distribution Centre', 'Lotus Engineering Services (P) Ltd ', 'Rohit D''Souza', 'rohit.dsouza@lotusengineering.in', '+91 7358802580', 'Private Limited Company', 'Gujarat', 'Anand', 'Y', 'Y', '6,00,000.00', 'SR-3496004', 'Documents received'),
('VOR-26-0497', '24-09-2026', 'Aarav Dave', 'aarav.dave@ashvakagroup.in', 'AI10', '1003', 'ELECTRICAL', 'LT switchgear and DBs for Dahej Terminal Expansion Project', 'Keystone Switchgear', 'Simran Pathan', 'simran.pathan@keystoneswitchgear.in', '+91 8270157642', 'Private Limited Company', 'Gujarat', 'Bhuj', 'N', 'Y', '23,00,000.00', 'SR-2194997', 'Documents received'),
('VOR-26-0528', '29-09-2026', 'Kruti Vaghela', 'kruti.vaghela@ashvakagroup.in', 'AC20', '2002', 'SCAFFOLDING', 'Cuplock scaffolding hire for Rajkot RMC Plant', 'Darshan Access Systems Private Limited', 'Sana Trivedi', 'sana.trivedi@darshanaccesssyste.in', '+91 6734799791', 'Pvt Ltd Company', 'Madhya Pradesh', 'Bhopal', 'N', 'Y', '₹12,00,000.00', 'SR-4903958', 'Documents received'),
('VOR-26-0428', '07-09-2026', 'Kavya D''Souza', 'kavya.dsouza@ashvakagroup.in', 'AC20', '2001', 'CEMENT', 'OPC 53 and PPC cement for Vadodara Grinding Unit', 'unnati cement', 'Venkat Gill', 'venkat.gill@unnaticement.in', '+91 8289763199', 'Limited Liability Partnership', 'Gujarat', 'Ahmedabad', 'N', 'Y', '3,68,00,000.00', 'SR-6026022', 'Documents received'),
('VOR-26-0440', '09-09-2026', 'Devang Menon', 'devang.menon@ashvakagroup.in', 'AI10', '1001', 'IT_HW', 'Laptops and monitors for new joiners at Ahmedabad Head Office', 'Aravalli Systems & Co', 'Hardik Gill', 'hardik.gill@aravallisystems.in', '+91 6145033918', 'Partnership Firm', 'Gujarat', 'Bharuch', 'Y', 'Y', '52,00,000.00', 'SR-5689469', 'Documents received'),
('VOR-26-0586', '05-10-2026', 'Sneha Parmar', 'sneha.parmar@ashvakagroup.in', 'AC20', '2002', 'AGGREGATE', 'Aggregates and M-sand for Rajkot RMC Plant', 'Bhagyoday Aggregates', 'Sagar Parmar', 'sagar.parmar@bhagyodayaggregate.in', '+91 7385637237', 'Sole Proprietor', 'Rajasthan', 'Jaipur', 'N', 'Y', '93,00,000.00', 'SR-9550245', 'Documents received'),
('VOR-26-0476', '22-09-2026', 'Farhan Shah', 'farhan.shah@ashvakagroup.in', 'AI10', '1002', 'MANPOWER', 'Skilled and semi-skilled manpower for Sanand Industrial Park Project, about 120 workers from next month', 'Radhe Workforce Solutions', 'Mahesh Gill', 'mahesh.gill@radheworkforcesolu.co.in', '+91 8643409044', 'Partnership Firm', 'Gujarat', 'Mehsana', 'Y', 'Y', '₹ 1,59,00,000.00', 'SR-3861910', 'Documents received'),
('VOR-26-0503', '24-09-2026', 'Neha Amin', 'neha.amin@ashvakagroup.in', 'AE30', '3001', 'SCAFFOLDING', 'Cuplock scaffolding hire for Bhuj Solar Park Phase 2', 'Rudra Access Systems ', 'Mitesh Sheikh', 'mitesh.sheikh@rudraaccesssystems.in', '+91 9661729701', 'Private Limited Company', 'Madhya Pradesh', 'Pithampur', 'N', 'Y', 'INR 35,00,000.00', 'SR-9479312', 'Documents received'),
('VOR-26-0529', '29-09-2026', 'Priyanka Trivedi', 'priyanka.trivedi@ashvakagroup.in', 'AE30', '3001', 'SECURITY', 'Security guards and a supervisor for Bhuj Solar Park Phase 2, round the clock', 'Anand Guarding Services ', 'Dhaval Brahmbhatt', 'dhaval.brahmbhatt@anandguardingservi.in', '+91 6570534262', 'Partnership', 'Gujarat', 'Surat', 'Y', 'Y', '35,00,000.00', 'SR-9884159', 'Documents received'),
('VOR-26-0559', '05-10-2026', 'Manan Brahmbhatt', 'manan.brahmbhatt@ashvakagroup.in', 'AC20', '2002', 'SCAFFOLDING', 'Cuplock scaffolding hire for Rajkot RMC Plant', 'Chitra Access Systems Pvt Ltd', 'Zoya Nair', 'zoya.nair@chitraaccesssystem.co.in', '+91 9947753829', 'Pvt Ltd Company', 'Gujarat', 'Gandhinagar', 'Y', 'Y', '11,00,000.00', 'SR-9444190', 'Documents received'),
('VOR-26-0612', '08-10-2026', 'Neha Amin', 'neha.amin@ashvakagroup.in', 'AE30', '3001', 'SECURITY', 'Security guards and a supervisor for Bhuj Solar Park Phase 2, round the clock', 'lotus guarding services llp ', 'Aditi Pandya', 'aditi.pandya@lotusguardingservi.co.in', '+91 9244454843', 'LLP', 'Gujarat', 'Gandhinagar', 'N', 'Y', '24,00,000.00', 'SR-7912772', 'Documents awaited'),
('VOR-26-0443', '11-09-2026', 'Devang Menon', 'devang.menon@ashvakagroup.in', 'AC20', '2002', 'MANPOWER', 'Skilled and semi-skilled manpower for Rajkot RMC Plant, about 40 workers from next month', 'Nandan Workforce Solutions LLP', 'Harsh Kothari', 'harsh.kothari@nandanworkforcesol.in', '+91 7455847436', 'LLP', 'Gujarat', 'Surat', 'Y', 'Y', '1,76,00,000.00', 'SR-6033896', 'Documents received'),
('VOR-26-0532', '2026-09-29', 'Aarav Dave', 'aarav.dave@ashvakagroup.in', 'AI10', '1001', 'IT_SVC', 'Managed network support for Ahmedabad Head Office', 'vishwakarma technologies private limited ', 'Imran Shukla', 'imran.shukla@vishwakarmatechnol.com', '+91 8751178657', 'Private Limited Company', 'Gujarat', 'Surat', 'N', 'Y', '17,00,000.00', 'SR-9099443', 'Documents received');

drop table if exists public."chase_log";
create table public."chase_log" (
  row_id bigint generated always as identity primary key,
  "log_id" text,
  "request_id" text,
  "action" text,
  "chase_round" text,
  "sent_at" text,
  "sent_by" text,
  "sent_to" text,
  "cc" text,
  "email_body" text,
  "thread_id" text,
  "message_id" text
);
comment on table public."chase_log" is 'One email the desk has already sent to a vendor: the first checklist or a chase.';
insert into public."chase_log" ("log_id", "request_id", "action", "chase_round", "sent_at", "sent_by", "sent_to", "cc", "email_body", "thread_id", "message_id") values
('CL-00001', 'VOR-26-0413', 'Document checklist sent', '0', '2026-09-07 10:17:00', 'Pooja Pandya', 'heena.fernandes@darshancement.in', 'kavya.dsouza@ashvakagroup.in', 'Dear Heena Fernandes,

Kavya D''Souza has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for cement. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0001', '<PN3P849MB6690FWOZAB@PN3P629MB.INDP737.PROD.OUTLOOK.COM>'),
('CL-00002', 'VOR-26-0414', 'Document checklist sent', '0', '2026-09-07 10:33:00', 'Riya Pandya', 'sameer.raval@sthapatyafacility.in', 'aarav.rao@ashvakagroup.in', 'Dear Sameer Raval,

Aarav Rao has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0002', '<PN2P751MB9226MNABNI@PN2P756MB.INDP502.PROD.OUTLOOK.COM>'),
('CL-00003', 'VOR-26-0417', 'Document checklist sent', '0', '2026-09-07 11:59:00', 'Pooja Pandya', 'nikhil.reddy@narmadaequipmenthi.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Nikhil Reddy,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0003', '<7ccf497561c18536ff83255f@ashvakagroup.in>'),
('CL-00004', 'VOR-26-0418', 'Document checklist sent', '0', '2026-09-07 14:01:00', 'Meera Kapadia', 'meera.pathan@jayambehousekeepin.co.in', 'yash.amin@ashvakagroup.in', 'Dear Meera Pathan,

Yash Amin has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0005', '<81259832a98894919fdaab0e@ashvakagroup.in>'),
('CL-00005', 'VOR-26-0420', 'Document checklist sent', '0', '2026-09-07 17:56:00', 'Meera Kapadia', 'meera.shah@sthapatyascaffoldi.com', 'kruti.vaghela@ashvakagroup.in', 'Dear Meera Shah,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for scaffolding and formwork hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0006', '<3699d2c0252bd9c0c449e94a@ashvakagroup.in>'),
('CL-00006', 'VOR-26-0422', 'Document checklist sent', '0', '2026-09-08 10:31:00', 'Pooja Pandya', 'hardik.iyer@girnarcarriers.co.in', 'farhan.shah@ashvakagroup.in', 'Dear Hardik Iyer,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)
6. GTA declaration for FY 2026-27 on your letterhead

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0007', '<PN3P205MB2209GXJNYZ@PN3P742MB.INDP192.PROD.OUTLOOK.COM>'),
('CL-00007', 'VOR-26-0423', 'Document checklist sent', '0', '2026-09-08 11:22:00', 'Riya Pandya', 'sameer.sharma@shreeumiyaengineer.in', 'neha.amin@ashvakagroup.in', 'Dear Sameer Sharma,

Neha Amin has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for maintenance contracts (amc). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0008', '<415770655581.5097@ashvakagroup.in>'),
('CL-00008', 'VOR-26-0426', 'Document checklist sent', '0', '2026-09-08 11:26:00', 'Riya Pandya', 'kruti.bhatt@siddhivinayakindus.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Kruti Bhatt,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0010', '<278268529144.2131@ashvakagroup.in>'),
('CL-00009', 'VOR-26-0427', 'Document checklist sent', '0', '2026-09-08 11:44:00', 'Pooja Pandya', 'karan.sheikh@crestlinefacilitys.com', 'devang.menon@ashvakagroup.in', 'Dear Karan Sheikh,

Devang Menon has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0011', '<cebceac3f12985e86d012e13@ashvakagroup.in>'),
('CL-00010', 'VOR-26-0428', 'Document checklist sent', '0', '2026-09-08 13:30:00', 'Pooja Pandya', 'venkat.gill@unnaticement.in', 'kavya.dsouza@ashvakagroup.in', 'Dear Venkat Gill,

Kavya D''Souza has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for cement. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0012', '<970562230990.2000@ashvakagroup.in>'),
('CL-00011', 'VOR-26-0429', 'Document checklist sent', '0', '2026-09-08 13:35:00', 'Pooja Pandya', 'vikram.gill@suryodayengineerin.co.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Vikram Gill,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for professional and consulting. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0013', '<PN2P409MB3881FFYXBJ@PN3P353MB.INDP463.PROD.OUTLOOK.COM>'),
('CL-00012', 'VOR-26-0431', 'Document checklist sent', '0', '2026-09-09 12:06:00', 'Riya Pandya', 'nisha.shah@deccanroadlines.com', 'kruti.vaghela@ashvakagroup.in', 'Dear Nisha Shah,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. GTA declaration for FY 2026-27 on your letterhead

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0014', '<654189790073.5319@ashvakagroup.in>'),
('CL-00013', 'VOR-26-0434', 'Document checklist sent', '0', '2026-09-10 12:02:00', 'Pooja Pandya', 'kinjal.shukla@pragatilabourcontr.com', 'sameer.patel@ashvakagroup.in', 'Dear Kinjal Shukla,

Sameer Patel has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0015', '<e8ae242e771e7ea037c8b32a@ashvakagroup.in>'),
('CL-00014', 'VOR-26-0437', 'Document checklist sent', '0', '2026-09-10 12:39:00', 'Pooja Pandya', 'joseph.shah@horizoncables.co.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Joseph Shah,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Energy Limited for cables. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0016', '<b0922987c17539d29aa67f46@ashvakagroup.in>'),
('CL-00015', 'VOR-26-0438', 'Document checklist sent', '0', '2026-09-10 15:05:00', 'Riya Pandya', 'riya.parikh@kesarprotectionfor.in', 'yash.amin@ashvakagroup.in', 'Dear Riya Parikh,

Yash Amin has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. PSARA licence
9. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0017', '<PN2P413MB7909UVCPDM@PN1P985MB.INDP998.PROD.OUTLOOK.COM>'),
('CL-00016', 'VOR-26-0439', 'Document checklist sent', '0', '2026-09-10 15:42:00', 'Riya Pandya', 'tanvi.joshi@jyotisteeltraders.in', 'farhan.shah@ashvakagroup.in', 'Dear Tanvi Joshi,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for reinforcement steel. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0019', '<d74e0b69baff6e6451142481@ashvakagroup.in>'),
('CL-00017', 'VOR-26-0440', 'Document checklist sent', '0', '2026-09-10 16:55:00', 'Meera Kapadia', 'hardik.gill@aravallisystems.in', 'devang.menon@ashvakagroup.in', 'Dear Hardik Gill,

Devang Menon has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for it hardware. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0020', '<6b77e78ac1b34060bb2dba94@ashvakagroup.in>'),
('CL-00018', 'VOR-26-0441', 'Document checklist sent', '0', '2026-09-10 16:59:00', 'Pooja Pandya', 'zoya.solanki@garudaminerals.in', 'farhan.shah@ashvakagroup.in', 'Dear Zoya Solanki,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for aggregates and sand. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0021', '<PN2P265MB7324GZJXNS@PN3P744MB.INDP675.PROD.OUTLOOK.COM>'),
('CL-00019', 'VOR-26-0443', 'Document checklist sent', '0', '2026-09-11 10:36:00', 'Riya Pandya', 'harsh.kothari@nandanworkforcesol.in', 'devang.menon@ashvakagroup.in', 'Dear Harsh Kothari,

Devang Menon has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0022', '<834582873801.8644@ashvakagroup.in>'),
('CL-00020', 'VOR-26-0445', 'Document checklist sent', '0', '2026-09-11 12:48:00', 'Pooja Pandya', 'meera.dave@bhagyodaycableindu.in', 'kavya.dsouza@ashvakagroup.in', 'Dear Meera Dave,

Kavya D''Souza has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for cables. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0023', '<PN2P246MB2091OKFFON@PN3P836MB.INDP343.PROD.OUTLOOK.COM>'),
('CL-00021', 'VOR-26-0447', 'Document checklist sent', '0', '11-09-2026 13:14', 'Meera Kapadia', 'imran.sheikh@tirthrenewables.in', 'heena.solanki@ashvakagroup.in', 'Dear Imran Sheikh,

Heena Solanki has asked us to register your firm as a supplier to Ashvaka Energy Limited for solar modules and bos. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 9001 certificate

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0024', '<PN1P371MB5300WSUNPZ@PN3P516MB.INDP600.PROD.OUTLOOK.COM>'),
('CL-00022', 'VOR-26-0448', 'Document checklist sent', '0', '2026-09-11 15:33:00', 'Riya Pandya', 'rohit.dsouza@lotusengineering.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Rohit D''Souza,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for maintenance contracts (amc). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0025', '<883147379973.2289@ashvakagroup.in>'),
('CL-00023', 'VOR-26-0449', 'Document checklist sent', '0', '2026-09-11 16:39:00', 'Riya Pandya', 'krunal.oza@eshaninfra.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Krunal Oza,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0026', '<PN2P840MB3493BKZFZE@PN3P180MB.INDP626.PROD.OUTLOOK.COM>'),
('CL-00024', 'VOR-26-0451', 'Document checklist sent', '0', '2026-09-14 11:24:00', 'Riya Pandya', 'aakash.verma@vihaanmanpowerserv.co.in', 'maria.solanki@ashvakagroup.in', 'Dear Aakash Verma,

Maria Solanki has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0027', '<b7babc23d5d15af891c86b84@ashvakagroup.in>'),
('CL-00025', 'VOR-26-0452', 'Document checklist sent', '0', '2026-09-14 14:37:00', 'Meera Kapadia', 'sagar.trivedi@pinnaclecableindus.com', 'manan.brahmbhatt@ashvakagroup.in', 'Dear Sagar Trivedi,

Manan Brahmbhatt has asked us to register your firm as a supplier to Ashvaka Energy Limited for cables. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0028', '<PN2P724MB7578HYIFUC@PN1P878MB.INDP929.PROD.OUTLOOK.COM>'),
('CL-00026', 'VOR-26-0453', 'Document checklist sent', '0', '2026-09-14 15:08:00', 'Meera Kapadia', 'amit.sanghvi@radheroadlines.in', 'heena.solanki@ashvakagroup.in', 'Dear Amit Sanghvi,

Heena Solanki has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. GTA declaration for FY 2026-27 on your letterhead

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0029', '<PN3P375MB3631RGANNA@PN1P139MB.INDP752.PROD.OUTLOOK.COM>'),
('CL-00027', 'VOR-26-0454', 'Document checklist sent', '0', '2026-09-14 16:41:00', 'Pooja Pandya', 'kruti.pandya@bansiitsolutions.in', 'yash.amin@ashvakagroup.in', 'Dear Kruti Pandya,

Yash Amin has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for it services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0031', '<407868950213d895360396b3@ashvakagroup.in>'),
('CL-00028', 'VOR-26-0456', 'Document checklist sent', '0', '2026-09-14 17:34:00', 'Meera Kapadia', 'heena.mistry@sahjanandswitchgea.in', 'neha.amin@ashvakagroup.in', 'Dear Heena Mistry,

Neha Amin has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for electrical items. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0032', '<446438487596.3506@ashvakagroup.in>'),
('CL-00029', 'VOR-26-0449', 'Chase 1', '1', '2026-09-15 12:05:00', 'Riya Pandya', 'krunal.oza@eshaninfra.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Krunal Oza,

Thank you for the documents. We still need the following before we can complete your registration:

1. PAN: the copy received (scan_0045.pdf) cannot be read. Please send a clear copy.

Please reply to this email with the documents.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0026', '<ef3614c5daccda1861d35431@ashvakagroup.in>'),
('CL-00030', 'VOR-26-0457', 'Document checklist sent', '0', '2026-09-15 12:45:00', 'Riya Pandya', 'gurpreet.sanghvi@samarthindustrials.in', 'devang.menon@ashvakagroup.in', 'Dear Gurpreet Sanghvi,

Devang Menon has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0033', '<PN1P112MB4729GVDAWD@PN2P954MB.INDP125.PROD.OUTLOOK.COM>'),
('CL-00031', 'VOR-26-0447', 'Chase 1', '1', '2026-09-15 14:15:00', 'Meera Kapadia', 'imran.sheikh@tirthrenewables.in', 'heena.solanki@ashvakagroup.in', 'Dear Imran Sheikh,

Thank you for the documents. We still need the following before we can complete your registration:

1. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.

Please reply to this email with the documents.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0024', '<PN3P138MB3512GWDSTO@PN1P655MB.INDP183.PROD.OUTLOOK.COM>'),
('CL-00032', 'VOR-26-0458', 'Document checklist sent', '0', '2026-09-15T09:18:00Z', 'Riya Pandya', 'chirag.sharma@garudamaintenances.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Chirag Sharma,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for maintenance contracts (amc). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0034', '<bd649ebd557eb1c71e3b5e71@ashvakagroup.in>'),
('CL-00033', 'VOR-26-0459', 'Document checklist sent', '0', '2026-09-15 15:36:00', 'Riya Pandya', 'ankit.panchal@udayearthmovers.com', 'kruti.vaghela@ashvakagroup.in', 'Dear Ankit Panchal,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0036', '<612341840170.1432@ashvakagroup.in>'),
('CL-00034', 'VOR-26-0461', 'Document checklist sent', '0', '2026-09-16 10:21:00', 'Riya Pandya', 'venkat.joshi@arihantfacilityser.in', 'sneha.parmar@ashvakagroup.in', 'Dear Venkat Joshi,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0037', '<742520580931.7586@ashvakagroup.in>'),
('CL-00035', 'VOR-26-0463', 'Document checklist sent', '0', '2026-09-16 17:41:00', 'Riya Pandya', 'priyanka.kapadia@zenithaggregates.in', 'maria.solanki@ashvakagroup.in', 'Dear Priyanka Kapadia,

Maria Solanki has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for aggregates and sand. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0038', '<312813121497.4006@ashvakagroup.in>'),
('CL-00036', 'VOR-26-0466', 'Document checklist sent', '0', '2026-09-17 10:13:00', 'Meera Kapadia', 'urvashi.shukla@sahjanandtransport.co.in', 'sameer.patel@ashvakagroup.in', 'Dear Urvashi Shukla,

Sameer Patel has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. GTA declaration for FY 2026-27 on your letterhead

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0039', '<PN2P313MB2550OPFWCN@PN3P991MB.INDP215.PROD.OUTLOOK.COM>'),
('CL-00037', 'VOR-26-0467', 'Document checklist sent', '0', '2026-09-17 11:13:00', 'Meera Kapadia', 'meera.thakkar@keystoneispat.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Meera Thakkar,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Energy Limited for reinforcement steel. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0040', '<4d31fa5defb3e0332d199960@ashvakagroup.in>'),
('CL-00038', 'VOR-26-0468', 'Document checklist sent', '0', '2026-09-18 11:36:00', 'Pooja Pandya', 'shreya.nair@induswiresandcable.co.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Shreya Nair,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Energy Limited for cables. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0041', '<d94571250118716aa5bca72a@ashvakagroup.in>'),
('CL-00039', 'VOR-26-0469', 'Document checklist sent', '0', '2026-09-21 15:46:00', 'Riya Pandya', 'manan.jadeja@bansitechnologies.co.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Manan Jadeja,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for it services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0042', '<94de4cc3690fc3499ef70de8@ashvakagroup.in>'),
('CL-00040', 'VOR-26-0471', 'Document checklist sent', '0', '2026-09-21 16:19:00', 'Pooja Pandya', 'nirav.parmar@yamunasecurityserv.in', 'yash.amin@ashvakagroup.in', 'Dear Nirav Parmar,

Yash Amin has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. PSARA licence
10. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0043', '<3abcc863f6a02d0b9c31011a@ashvakagroup.in>'),
('CL-00041', 'VOR-26-0472', 'Document checklist sent', '0', '2026-09-21 16:51:00', 'Meera Kapadia', 'kinjal.parmar@shreeumiyafacility.co.in', 'sneha.parmar@ashvakagroup.in', 'Dear Kinjal Parmar,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0044', '<82544c5fd22a7867abc7eebb@ashvakagroup.in>'),
('CL-00042', 'VOR-26-0473', 'Document checklist sent', '0', '2026-09-21 16:54:00', 'Riya Pandya', 'arjun.rathod@girnarsafetysoluti.co.in', 'farhan.shah@ashvakagroup.in', 'Dear Arjun Rathod,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 9001 certificate

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0045', '<PN1P298MB2665EMOKMA@PN2P306MB.INDP882.PROD.OUTLOOK.COM>'),
('CL-00043', 'VOR-26-0475', 'Document checklist sent', '0', '2026-09-22T05:30:00Z', 'Meera Kapadia', 'manan.reddy@jyotiguardingservi.co.in', 'sneha.parmar@ashvakagroup.in', 'Dear Manan Reddy,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. PSARA licence
10. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0046', '<c023cc319784d6cd190835e3@ashvakagroup.in>'),
('CL-00044', 'VOR-26-0476', 'Document checklist sent', '0', '2026-09-22 12:14:00', 'Riya Pandya', 'mahesh.gill@radheworkforcesolu.co.in', 'farhan.shah@ashvakagroup.in', 'Dear Mahesh Gill,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0047', '<a00ddd7d4ac2afd1c9940727@ashvakagroup.in>'),
('CL-00045', 'VOR-26-0477', 'Document checklist sent', '0', '2026-09-22 12:35:00', 'Meera Kapadia', 'nirav.vyas@mahibuilders.in', 'sneha.parmar@ashvakagroup.in', 'Dear Nirav Vyas,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Energy Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0048', '<914166503233.7387@ashvakagroup.in>'),
('CL-00046', 'VOR-26-0478', 'Document checklist sent', '0', '2026-09-22 13:04:00', 'Riya Pandya', 'priyanka.bhatt@radhecement.co.in', 'yash.amin@ashvakagroup.in', 'Dear Priyanka Bhatt,

Yash Amin has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for cement. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0049', '<PN2P243MB7672KOEVHG@PN3P193MB.INDP624.PROD.OUTLOOK.COM>'),
('CL-00047', 'VOR-26-0479', 'Document checklist sent', '0', '2026-09-22 13:24:00', 'Riya Pandya', 'nisha.menon@neelkanthinfraproj.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Nisha Menon,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0050', '<a3697428ed7a7d332766c50d@ashvakagroup.in>'),
('CL-00048', 'VOR-26-0482', 'Document checklist sent', '0', '2026-09-22 14:13:00', 'Pooja Pandya', 'arjun.menon@aravallimanpowerse.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Arjun Menon,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0051', '<235751632085.4951@ashvakagroup.in>'),
('CL-00049', 'VOR-26-0483', 'Document checklist sent', '0', '2026-09-22 15:00:00', 'Pooja Pandya', 'riya.joshi@indussteel.co.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Riya Joshi,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for reinforcement steel. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0052', '<PN1P512MB3933EUHOZC@PN3P482MB.INDP605.PROD.OUTLOOK.COM>'),
('CL-00050', 'VOR-26-0485', 'Document checklist sent', '0', '2026-09-22 15:16:00', 'Riya Pandya', 'ronak.reddy@harsiddhiinfra.com', 'kavya.bhatt@ashvakagroup.in', 'Dear Ronak Reddy,

Kavya Bhatt has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0053', '<753401592425.1718@ashvakagroup.in>'),
('CL-00051', 'VOR-26-0486', 'Document checklist sent', '0', '2026-09-22 17:28:00', 'Meera Kapadia', 'amit.shah@arihantelectricals.com', 'pooja.trivedi@ashvakagroup.in', 'Dear Amit Shah,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for electrical items. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0054', '<856583759391.4915@ashvakagroup.in>'),
('CL-00052', 'VOR-26-0487', 'Document checklist sent', '0', '2026-09-23T05:06:00Z', 'Meera Kapadia', 'ishaan.bhatt@girnaradvisory.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Ishaan Bhatt,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for professional and consulting. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0055', '<15e95125433c8599d0e36a2b@ashvakagroup.in>'),
('CL-00053', 'VOR-26-0488', 'Document checklist sent', '0', '2026-09-23 10:53:00', 'Riya Pandya', 'aarav.bhatt@bhumicarriers.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Aarav Bhatt,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. GTA declaration for FY 2026-27 on your letterhead

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0056', '<7f2c38397894c389254f0a93@ashvakagroup.in>'),
('CL-00054', 'VOR-26-0490', 'Document checklist sent', '0', '2026-09-23 15:40:00', 'Pooja Pandya', 'sneha.pandya@avadhhousekeepings.co.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Sneha Pandya,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0057', '<PN1P653MB6846OTZEFZ@PN3P962MB.INDP192.PROD.OUTLOOK.COM>'),
('CL-00055', 'VOR-26-0493', 'Document checklist sent', '0', '2026-09-23 16:50:00', 'Meera Kapadia', 'simran.bhatt@sabarstonecrusher.in', 'maria.solanki@ashvakagroup.in', 'Dear Simran Bhatt,

Maria Solanki has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for aggregates and sand. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0058', '<3ea602ce030f18a70860c803@ashvakagroup.in>'),
('CL-00056', 'VOR-26-0494', 'Document checklist sent', '0', '2026-09-23 17:55:00', 'Pooja Pandya', 'mahesh.joshi@narmadaearthmovers.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Mahesh Joshi,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0059', '<647d854035e072c036e16904@ashvakagroup.in>'),
('CL-00057', 'VOR-26-0495', 'Document checklist sent', '0', '2026-09-24 10:20:00', 'Meera Kapadia', 'hardik.kothari@kaveriearthmovers.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Hardik Kothari,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0060', '<197394660845.8792@ashvakagroup.in>'),
('CL-00058', 'VOR-26-0496', 'Document checklist sent', '0', '2026-09-24T06:30:00Z', 'Riya Pandya', 'vivek.verma@vihaanbuildingmate.in', 'heena.solanki@ashvakagroup.in', 'Dear Vivek Verma,

Heena Solanki has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for cement. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0061', '<PN2P317MB5291MMABRX@PN1P519MB.INDP721.PROD.OUTLOOK.COM>'),
('CL-00059', 'VOR-26-0497', 'Document checklist sent', '0', '2026-09-24 14:09:00', 'Riya Pandya', 'simran.pathan@keystoneswitchgear.in', 'aarav.dave@ashvakagroup.in', 'Dear Simran Pathan,

Aarav Dave has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for electrical items. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0062', '<197435034692.4432@ashvakagroup.in>'),
('CL-00060', 'VOR-26-0498', 'Document checklist sent', '0', '2026-09-24T09:15:00Z', 'Riya Pandya', 'suresh.iyer@tapticoncrete.co.in', 'sana.singh@ashvakagroup.in', 'Dear Suresh Iyer,

Sana Singh has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for ready-mix concrete. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 9001 certificate

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0063', '<441259922193.5375@ashvakagroup.in>'),
('CL-00061', 'VOR-26-0482', 'Chase 1', '1', '2026-09-24 17:10:00', 'Pooja Pandya', 'arjun.menon@aravallimanpowerse.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Arjun Menon,

We have not yet received your documents for vendor registration. Please send the following:

1. GST registration certificate: not received.
2. PAN: not received.
3. Cancelled cheque or bank letter: not received.
4. Shop and establishment registration: not received.
5. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.
6. Contract labour licence: not received.
7. EPF registration certificate: not received.
8. ESIC registration certificate: not received.
9. Insurance certificate: not received.

Please reply to this email with the documents.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0051', '<40c486510a30041a8ec88187@ashvakagroup.in>'),
('CL-00062', 'VOR-26-0499', 'Document checklist sent', '0', '2026-09-24 17:13:00', 'Riya Pandya', 'vivek.rao@lotuslabourcontrac.co.in', 'maria.solanki@ashvakagroup.in', 'Dear Vivek Rao,

Maria Solanki has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0064', '<PN3P321MB9730CWWEBZ@PN3P993MB.INDP427.PROD.OUTLOOK.COM>'),
('CL-00063', 'VOR-26-0479', 'Chase 1', '1', '2026-09-25 10:11:00', 'Riya Pandya', 'nisha.menon@neelkanthinfraproj.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Nisha Menon,

Thank you for the documents. We still need the following before we can complete your registration:

1. Insurance certificate: not received.
2. GST registration certificate: GSTIN 27GAFPM4081P1Z7 on the certificate is not a valid GSTIN. Please send the registration certificate downloaded from the GST portal.

Please reply to this email with the documents.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0050', '<339912833186.5588@ashvakagroup.in>'),
('CL-00064', 'VOR-26-0500', 'Document checklist sent', '0', '2026-09-25 10:36:00', 'Pooja Pandya', 'ronak.kapadia@pragatiinfraprojec.in', 'aarav.dave@ashvakagroup.in', 'Dear Ronak Kapadia,

Aarav Dave has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0065', '<PN3P652MB4749IACIBE@PN3P238MB.INDP888.PROD.OUTLOOK.COM>'),
('CL-00065', 'VOR-26-0503', 'Document checklist sent', '0', '2026-09-25 10:40:00', 'Meera Kapadia', 'mitesh.sheikh@rudraaccesssystems.in', 'neha.amin@ashvakagroup.in', 'Dear Mitesh Sheikh,

Neha Amin has asked us to register your firm as a supplier to Ashvaka Energy Limited for scaffolding and formwork hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0066', '<816b80ff598c784582a81235@ashvakagroup.in>'),
('CL-00066', 'VOR-26-0506', 'Document checklist sent', '0', '25-09-2026 10:56', 'Pooja Pandya', 'sagar.vaghela@jyotiindustrialsaf.com', 'aarav.dave@ashvakagroup.in', 'Dear Sagar Vaghela,

Aarav Dave has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. ISO 9001 certificate

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0067', '<PN3P378MB6985BIESKB@PN1P496MB.INDP949.PROD.OUTLOOK.COM>'),
('CL-00067', 'VOR-26-0483', 'Chase 1', '1', '2026-09-25 11:53:00', 'Pooja Pandya', 'riya.joshi@indussteel.co.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Riya Joshi,

Thank you for the documents. We still need the following before we can complete your registration:

1. Cancelled cheque: the account holder name (INDUS STEEL INDUSTRIES PRIVATE LIMITED) does not match the legal name on your GST certificate (INDUS STEEL PRIVATE LIMITED). Please send a cancelled cheque or bank letter for an account in the legal name.

Please reply to this email with the documents.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0052', '<PN1P664MB1043EUCMDO@PN3P935MB.INDP616.PROD.OUTLOOK.COM>'),
('CL-00068', 'VOR-26-0507', 'Document checklist sent', '0', '2026-09-25 12:29:00', 'Riya Pandya', 'mitesh.pathan@bansiequipmenthire.com', 'pooja.trivedi@ashvakagroup.in', 'Dear Mitesh Pathan,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0068', '<820295528654.6465@ashvakagroup.in>'),
('CL-00069', 'VOR-26-0508', 'Document checklist sent', '0', '2026-09-25 14:06:00', 'Riya Pandya', 'rutvik.sharma@gokullabourcontrac.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Rutvik Sharma,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0069', '<263524687547.5464@ashvakagroup.in>'),
('CL-00070', 'VOR-26-0509', 'Document checklist sent', '0', '2026-09-25 14:48:00', 'Meera Kapadia', 'rohit.bhatt@dharaaccesssystems.com', 'farhan.shah@ashvakagroup.in', 'Dear Rohit Bhatt,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for scaffolding and formwork hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0070', '<PN2P965MB9740GHOJOX@PN2P593MB.INDP525.PROD.OUTLOOK.COM>'),
('CL-00071', 'VOR-26-0512', 'Document checklist sent', '0', '2026-09-25 15:42:00', 'Pooja Pandya', 'nisha.sanghvi@narmadaguardingser.co.in', 'sana.singh@ashvakagroup.in', 'Dear Nisha Sanghvi,

Sana Singh has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. PSARA licence
10. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0071', '<47fef11f023e648b05b456b6@ashvakagroup.in>'),
('CL-00072', 'VOR-26-0513', 'Document checklist sent', '0', '25-09-2026 16:34', 'Riya Pandya', 'hetal.dsouza@shreeumiyacarriers.com', 'sana.singh@ashvakagroup.in', 'Dear Hetal D''Souza,

Sana Singh has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. GTA declaration for FY 2026-27 on your letterhead

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0072', '<9c9e4bfd3686583188bbab78@ashvakagroup.in>'),
('CL-00073', 'VOR-26-0475', 'Chase 1', '1', '2026-09-25T17:42:00+05:30', 'Meera Kapadia', 'manan.reddy@jyotiguardingservi.co.in', 'sneha.parmar@ashvakagroup.in', 'Dear Manan Reddy,

Thank you for the documents. We still need the following before we can complete your registration:

1. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.
2. Insurance certificate: not received.

Please reply to this email with the documents.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0046', '<PN3P560MB6783SWRNYL@PN1P585MB.INDP210.PROD.OUTLOOK.COM>'),
('CL-00074', 'VOR-26-0514', 'Document checklist sent', '0', '2026-09-28 10:10:00', 'Pooja Pandya', 'deepa.thakkar@zenithcement.in', 'kavya.dsouza@ashvakagroup.in', 'Dear Deepa Thakkar,

Kavya D''Souza has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for cement. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0073', '<PN2P861MB8630RGHMUV@PN1P336MB.INDP779.PROD.OUTLOOK.COM>'),
('CL-00075', 'VOR-26-0515', 'Document checklist sent', '0', '2026-09-28 11:04:00', 'Pooja Pandya', 'rohit.brahmbhatt@pinnacledigitalser.in', 'aarav.dave@ashvakagroup.in', 'Dear Rohit Brahmbhatt,

Aarav Dave has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for it services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0075', '<c62cae5c3a5a2dd5e5e2a794@ashvakagroup.in>'),
('CL-00076', 'VOR-26-0516', 'Document checklist sent', '0', '2026-09-28 13:03:00', 'Riya Pandya', 'ankit.jadeja@udayinfra.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Ankit Jadeja,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0076', '<9381ad7bf8a69aacbb2f02ab@ashvakagroup.in>'),
('CL-00077', 'VOR-26-0517', 'Document checklist sent', '0', '2026-09-28 13:37:00', 'Meera Kapadia', 'sneha.menon@parshvaroadlines.co.in', 'farhan.shah@ashvakagroup.in', 'Dear Sneha Menon,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. GTA declaration for FY 2026-27 on your letterhead

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0077', '<63ed10d1d36348c6ad10653e@ashvakagroup.in>'),
('CL-00078', 'VOR-26-0518', 'Document checklist sent', '0', '2026-09-28 15:14:00', 'Pooja Pandya', 'urvashi.pandya@prayagqualitylabs.co.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Urvashi Pandya,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for material testing laboratory. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. NABL accreditation certificate with scope

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0078', '<1ed10783c79697453d2dd11b@ashvakagroup.in>'),
('CL-00079', 'VOR-26-0520', 'Document checklist sent', '0', '2026-09-28T09:46:00Z', 'Riya Pandya', 'mitesh.reddy@riddhiroadways.co.in', 'kavya.bhatt@ashvakagroup.in', 'Dear Mitesh Reddy,

Kavya Bhatt has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. GTA declaration for FY 2026-27 on your letterhead

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0079', '<PN2P631MB2527XLBDUS@PN3P382MB.INDP551.PROD.OUTLOOK.COM>'),
('CL-00080', 'VOR-26-0521', 'Document checklist sent', '0', '28-09-2026 17:13', 'Pooja Pandya', 'zoya.sharma@sabarconsultants.in', 'heena.solanki@ashvakagroup.in', 'Dear Zoya Sharma,

Heena Solanki has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for professional and consulting. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0080', '<bb7bd5a377c76a01fa625d6b@ashvakagroup.in>'),
('CL-00081', 'VOR-26-0522', 'Document checklist sent', '0', '2026-09-29 10:08:00', 'Meera Kapadia', 'vivek.reddy@deccanindustrialsa.co.in', 'maria.solanki@ashvakagroup.in', 'Dear Vivek Reddy,

Maria Solanki has asked us to register your firm as a supplier to Ashvaka Energy Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 9001 certificate

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0081', '<PN2P172MB2309IZWVDH@PN1P397MB.INDP342.PROD.OUTLOOK.COM>'),
('CL-00082', 'VOR-26-0525', 'Document checklist sent', '0', '2026-09-29 10:23:00', 'Riya Pandya', 'urvashi.shah@yamunalogistics.in', 'farhan.shah@ashvakagroup.in', 'Dear Urvashi Shah,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. GTA declaration for FY 2026-27 on your letterhead

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0082', '<PN1P947MB9203AUJLGZ@PN1P109MB.INDP933.PROD.OUTLOOK.COM>'),
('CL-00083', 'VOR-26-0526', 'Document checklist sent', '0', '2026-09-29 12:51:00', 'Riya Pandya', 'krunal.parikh@shivammaintenances.co.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Krunal Parikh,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for maintenance contracts (amc). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0084', '<791781705116.8914@ashvakagroup.in>'),
('CL-00084', 'VOR-26-0528', 'Document checklist sent', '0', '2026-09-29 13:14:00', 'Pooja Pandya', 'sana.trivedi@darshanaccesssyste.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Sana Trivedi,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for scaffolding and formwork hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0085', '<PN3P890MB4940BHTDOP@PN1P983MB.INDP955.PROD.OUTLOOK.COM>'),
('CL-00085', 'VOR-26-0529', 'Document checklist sent', '0', '2026-09-29 13:35:00', 'Pooja Pandya', 'dhaval.brahmbhatt@anandguardingservi.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Dhaval Brahmbhatt,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Energy Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. PSARA licence
10. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0086', '<9f6a0feb77777990b14dcabf@ashvakagroup.in>'),
('CL-00086', 'VOR-26-0482', 'Chase 2', '2', '2026-09-29 16:20:00', 'Pooja Pandya', 'arjun.menon@aravallimanpowerse.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Arjun Menon,

This is our second reminder. The following items are still open on your registration:

1. GST registration certificate: not received.
2. PAN: not received.
3. Cancelled cheque or bank letter: not received.
4. Shop and establishment registration: not received.
5. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.
6. Contract labour licence: not received.
7. EPF registration certificate: not received.
8. ESIC registration certificate: not received.
9. Insurance certificate: not received.

Once we receive them we will complete the registration. If we do not hear from you, we will refer the request back to Rutvik Chauhan.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0051', '<940070422679.2732@ashvakagroup.in>'),
('CL-00087', 'VOR-26-0532', 'Document checklist sent', '0', '2026-09-29 16:25:00', 'Riya Pandya', 'imran.shukla@vishwakarmatechnol.com', 'aarav.dave@ashvakagroup.in', 'Dear Imran Shukla,

Aarav Dave has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for it services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0087', '<7ddea579c64a57255beb98a7@ashvakagroup.in>'),
('CL-00088', 'VOR-26-0485', 'Chase 1', '1', '2026-09-29T16:59:00+05:30', 'Riya Pandya', 'ronak.reddy@harsiddhiinfra.com', 'kavya.bhatt@ashvakagroup.in', 'Dear Ronak Reddy,

Thank you for the documents. We still need the following before we can complete your registration:

1. Insurance certificate: VGI/10/2026/91967130 expired on 09 Sep 2026. Please send the renewed insurance certificate.

Please reply to this email with the documents.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0053', '<PN2P512MB5225LVQKBY@PN1P749MB.INDP789.PROD.OUTLOOK.COM>'),
('CL-00089', 'VOR-26-0533', 'Document checklist sent', '0', '2026-09-29 17:15:00', 'Riya Pandya', 'kruti.gill@orbitsafetysolutio.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Kruti Gill,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0088', '<PN1P123MB1618EKPPNU@PN3P282MB.INDP212.PROD.OUTLOOK.COM>'),
('CL-00090', 'VOR-26-0535', 'Document checklist sent', '0', '2026-09-29 17:17:00', 'Riya Pandya', 'foram.singh@mahalaxmiroadlines.in', 'yash.amin@ashvakagroup.in', 'Dear Foram Singh,

Yash Amin has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. GTA declaration for FY 2026-27 on your letterhead

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0089', '<0ea52d9d0a39571af7ddeaab@ashvakagroup.in>'),
('CL-00091', 'VOR-26-0508', 'Chase 1', '1', '2026-09-29 17:51:00', 'Riya Pandya', 'rutvik.sharma@gokullabourcontrac.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Rutvik Sharma,

Thank you for the documents. We still need the following before we can complete your registration:

1. Cancelled cheque or bank letter: not received.
2. EPF registration certificate: not received.
3. ESIC registration certificate: not received.

Please reply to this email with the documents.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0069', '<e455265d24dedf17333c7465@ashvakagroup.in>'),
('CL-00092', 'VOR-26-0536', 'Document checklist sent', '0', '2026-09-30 10:19:00', 'Meera Kapadia', 'parth.pathan@orbitearthmovers.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Parth Pathan,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0090', '<PN3P451MB9451IUNEDR@PN3P752MB.INDP211.PROD.OUTLOOK.COM>'),
('CL-00093', 'VOR-26-0512', 'Chase 1', '1', '30-09-2026 10:24', 'Pooja Pandya', 'nisha.sanghvi@narmadaguardingser.co.in', 'sana.singh@ashvakagroup.in', 'Dear Nisha Sanghvi,

Thank you for the documents. We still need the following before we can complete your registration:

1. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.
2. Contract labour licence: not received.

Please reply to this email with the documents.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0071', '<PN3P742MB5261EEHAMK@PN1P991MB.INDP858.PROD.OUTLOOK.COM>'),
('CL-00094', 'VOR-26-0538', 'Document checklist sent', '0', '30-09-2026 10:39', 'Meera Kapadia', 'imran.chauhan@chitralogistics.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Imran Chauhan,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. GTA declaration for FY 2026-27 on your letterhead

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0091', '<PN2P252MB3598JSMOYY@PN1P334MB.INDP832.PROD.OUTLOOK.COM>'),
('CL-00095', 'VOR-26-0539', 'Document checklist sent', '0', '2026-09-30 10:54:00', 'Meera Kapadia', 'aakash.panchal@keystoneprotection.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Aakash Panchal,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. PSARA licence
9. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0092', '<115963983850.9332@ashvakagroup.in>'),
('CL-00096', 'VOR-26-0541', 'Document checklist sent', '0', '2026-09-30 11:25:00', 'Riya Pandya', 'neha.panchal@rudraconcrete.co.in', 'neha.amin@ashvakagroup.in', 'Dear Neha Panchal,

Neha Amin has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for ready-mix concrete. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0093', '<PN2P181MB9916OOIYDY@PN2P562MB.INDP726.PROD.OUTLOOK.COM>'),
('CL-00097', 'VOR-26-0542', 'Document checklist sent', '0', '2026-09-30 11:31:00', 'Pooja Pandya', 'maria.nair@keystonesteeltrade.com', 'priyanka.trivedi@ashvakagroup.in', 'Dear Maria Nair,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for reinforcement steel. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0094', '<PN1P336MB9934QXTCWL@PN3P474MB.INDP212.PROD.OUTLOOK.COM>'),
('CL-00098', 'VOR-26-0499', 'Chase 1', '1', '2026-09-30 14:09:00', 'Riya Pandya', 'vivek.rao@lotuslabourcontrac.co.in', 'maria.solanki@ashvakagroup.in', 'Dear Vivek Rao,

Thank you for the documents. We still need the following before we can complete your registration:

1. EPF registration certificate: not received.

Please reply to this email with the documents.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0064', '<28d48dfd158037002cdb0b62@ashvakagroup.in>'),
('CL-00099', 'VOR-26-0479', 'Chase 2', '2', '2026-09-30 15:36:00', 'Riya Pandya', 'nisha.menon@neelkanthinfraproj.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Nisha Menon,

This is our second reminder. The following items are still open on your registration:

1. GST registration certificate: GSTIN 27GAFPM4081P1Z7 on the certificate is not a valid GSTIN. Please send the registration certificate downloaded from the GST portal.

Once we receive them we will complete the registration. If we do not hear from you, we will refer the request back to Rutvik Chauhan.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0050', '<PN1P890MB4744ZLOYMA@PN3P375MB.INDP741.PROD.OUTLOOK.COM>'),
('CL-00100', 'VOR-26-0543', 'Document checklist sent', '0', '2026-09-30 16:27:00', 'Meera Kapadia', 'sneha.rathod@eshanconstruction.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Sneha Rathod,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Energy Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0095', '<799099055385.9317@ashvakagroup.in>'),
('CL-00101', 'VOR-26-0544', 'Document checklist sent', '0', '2026-09-30 16:30:00', 'Riya Pandya', 'pooja.vaghela@chitraconsultants.co.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Pooja Vaghela,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for professional and consulting. Please reply to this email with the following documents:

1. Declaration of non-registration under GST on your letterhead, signed
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0096', '<764308315118.6111@ashvakagroup.in>'),
('CL-00102', 'VOR-26-0545', 'Document checklist sent', '0', '2026-09-30 17:33:00', 'Pooja Pandya', 'parth.chauhan@kesarearthmovers.in', 'kavya.dsouza@ashvakagroup.in', 'Dear Parth Chauhan,

Kavya D''Souza has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0097', '<5deb7310a9cc0bd03458ea59@ashvakagroup.in>'),
('CL-00103', 'VOR-26-0546', 'Document checklist sent', '0', '2026-10-01 10:13:00', 'Riya Pandya', 'suresh.kapadia@avadhelectricco.com', 'sneha.parmar@ashvakagroup.in', 'Dear Suresh Kapadia,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for electrical items. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. ISO 9001 certificate

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0098', '<PN3P939MB1804WJGNEB@PN2P327MB.INDP154.PROD.OUTLOOK.COM>'),
('CL-00104', 'VOR-26-0475', 'Chase 2', '2', '01-10-2026 10:29', 'Meera Kapadia', 'manan.reddy@jyotiguardingservi.co.in', 'sneha.parmar@ashvakagroup.in', 'Dear Manan Reddy,

This is our second reminder. The following items are still open on your registration:

1. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.
2. Insurance certificate: not received.

Once we receive them we will complete the registration. If we do not hear from you, we will refer the request back to Sneha Parmar.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0046', '<602816261865.3589@ashvakagroup.in>'),
('CL-00105', 'VOR-26-0547', 'Document checklist sent', '0', '2026-10-01 11:19:00', 'Riya Pandya', 'harsh.patel@arihantearthmovers.in', 'pooja.trivedi@ashvakagroup.in', 'Dear Harsh Patel,

Pooja Trivedi has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0099', '<PN1P604MB5012YKSHFZ@PN1P648MB.INDP682.PROD.OUTLOOK.COM>'),
('CL-00106', 'VOR-26-0549', 'Document checklist sent', '0', '2026-10-01 11:43:00', 'Riya Pandya', 'gurpreet.reddy@kesarguardingservi.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Gurpreet Reddy,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. PSARA licence
10. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0101', '<332356173706.6451@ashvakagroup.in>'),
('CL-00107', 'VOR-26-0508', 'Chase 2', '2', '2026-10-01 12:49:00', 'Riya Pandya', 'rutvik.sharma@gokullabourcontrac.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Rutvik Sharma,

This is our second reminder. The following items are still open on your registration:

1. ESIC registration certificate: not received.

Once we receive them we will complete the registration. If we do not hear from you, we will refer the request back to Priyanka Trivedi.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0069', '<PN1P706MB4413JEKCNH@PN3P712MB.INDP664.PROD.OUTLOOK.COM>'),
('CL-00108', 'VOR-26-0552', 'Document checklist sent', '0', '2026-10-01 13:09:00', 'Pooja Pandya', 'hetal.nair@lotussolar.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Hetal Nair,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Energy Limited for solar modules and bos. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0102', '<PN3P131MB5540XVXFBC@PN1P425MB.INDP831.PROD.OUTLOOK.COM>'),
('CL-00109', 'VOR-26-0553', 'Document checklist sent', '0', '2026-10-01 13:32:00', 'Pooja Pandya', 'pooja.amin@kaveristeel.co.in', 'kavya.dsouza@ashvakagroup.in', 'Dear Pooja Amin,

Kavya D''Souza has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for reinforcement steel. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0103', '<02c1cdbbbdf9845bc9beec6f@ashvakagroup.in>'),
('CL-00110', 'VOR-26-0554', 'Document checklist sent', '0', '2026-10-01 14:38:00', 'Pooja Pandya', 'riya.bhatt@unnatiformworksyst.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Riya Bhatt,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for scaffolding and formwork hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0104', '<582498957634.2781@ashvakagroup.in>'),
('CL-00111', 'VOR-26-0555', 'Document checklist sent', '0', '2026-10-01 15:45:00', 'Pooja Pandya', 'sameer.trivedi@crestlinecement.com', 'rutvik.chauhan@ashvakagroup.in', 'Dear Sameer Trivedi,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for cement. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0105', '<4cef2fc2a2fbe9ff9f17a21a@ashvakagroup.in>'),
('CL-00112', 'VOR-26-0557', 'Document checklist sent', '0', '2026-10-01T11:19:00Z', 'Riya Pandya', 'amit.kapadia@horizonbuilders.co.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Amit Kapadia,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0106', '<464487688105.4549@ashvakagroup.in>'),
('CL-00113', 'VOR-26-0558', 'Document checklist sent', '0', '2026-10-01 17:03:00', 'Pooja Pandya', 'aakash.oza@vishwakarmamanpowe.co.in', 'aarav.rao@ashvakagroup.in', 'Dear Aakash Oza,

Aarav Rao has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0107', '<2c982608a85c18c94728fbd2@ashvakagroup.in>'),
('CL-00114', 'VOR-26-0559', 'Document checklist sent', '0', '2026-10-05 10:32:00', 'Meera Kapadia', 'zoya.nair@chitraaccesssystem.co.in', 'manan.brahmbhatt@ashvakagroup.in', 'Dear Zoya Nair,

Manan Brahmbhatt has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for scaffolding and formwork hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0108', '<PN2P996MB6513ZAUGAA@PN3P592MB.INDP820.PROD.OUTLOOK.COM>'),
('CL-00115', 'VOR-26-0560', 'Document checklist sent', '0', '2026-10-05 11:43:00', 'Pooja Pandya', 'vivek.solanki@omkarrmc.co.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Vivek Solanki,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for ready-mix concrete. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0109', '<728581975352.8442@ashvakagroup.in>'),
('CL-00116', 'VOR-26-0563', 'Document checklist sent', '0', '2026-10-05 11:50:00', 'Pooja Pandya', 'joseph.thakkar@darshantransportco.in', 'neha.amin@ashvakagroup.in', 'Dear Joseph Thakkar,

Neha Amin has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. GTA declaration for FY 2026-27 on your letterhead

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0110', '<PN2P826MB8567AZNHLN@PN2P332MB.INDP730.PROD.OUTLOOK.COM>'),
('CL-00117', 'VOR-26-0564', 'Document checklist sent', '0', '2026-10-05 12:15:00', 'Riya Pandya', 'arjun.nair@gokulsafetysolutio.in', 'maria.solanki@ashvakagroup.in', 'Dear Arjun Nair,

Maria Solanki has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0111', '<ec7dba24df540adbdde3aa3a@ashvakagroup.in>'),
('CL-00118', 'VOR-26-0506', 'Chase 1', '1', '2026-10-05 12:16:00', 'Pooja Pandya', 'sagar.vaghela@jyotiindustrialsaf.com', 'aarav.dave@ashvakagroup.in', 'Dear Sagar Vaghela,

Thank you for the documents. We still need the following before we can complete your registration:

1. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.

Please reply to this email with the documents.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0067', '<663776564547.7175@ashvakagroup.in>'),
('CL-00119', 'VOR-26-0567', 'Document checklist sent', '0', '2026-10-05 12:53:00', 'Riya Pandya', 'meera.amin@sankalpequipmenthi.co.in', 'farhan.shah@ashvakagroup.in', 'Dear Meera Amin,

Farhan Shah has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0112', '<f249ca101eef0459ee47dc3a@ashvakagroup.in>'),
('CL-00120', 'VOR-26-0570', 'Document checklist sent', '0', '2026-10-05 13:07:00', 'Meera Kapadia', 'jignesh.rao@mahalaxmilabourcon.in', 'aarav.dave@ashvakagroup.in', 'Dear Jignesh Rao,

Aarav Dave has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0113', '<PN3P646MB7864PHJELQ@PN3P605MB.INDP989.PROD.OUTLOOK.COM>'),
('CL-00121', 'VOR-26-0571', 'Document checklist sent', '0', '2026-10-05 13:54:00', 'Riya Pandya', 'riya.qureshi@sthapatyaitsolutio.co.in', 'manan.brahmbhatt@ashvakagroup.in', 'Dear Riya Qureshi,

Manan Brahmbhatt has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for it services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0114', '<PN2P131MB4715KKSDIG@PN1P388MB.INDP624.PROD.OUTLOOK.COM>'),
('CL-00122', 'VOR-26-0574', 'Document checklist sent', '0', '2026-10-05 14:24:00', 'Meera Kapadia', 'manan.parikh@quartzinfra.com', 'devang.menon@ashvakagroup.in', 'Dear Manan Parikh,

Devang Menon has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for civil works subcontract. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0115', '<PN2P201MB5837QSSYIX@PN3P403MB.INDP620.PROD.OUTLOOK.COM>'),
('CL-00123', 'VOR-26-0576', 'Document checklist sent', '0', '2026-10-05 15:57:00', 'Meera Kapadia', 'ishaan.sheikh@bhagyodayengineeri.in', 'manan.brahmbhatt@ashvakagroup.in', 'Dear Ishaan Sheikh,

Manan Brahmbhatt has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for maintenance contracts (amc). Please reply to this email with the following documents:

1. Declaration of non-registration under GST on your letterhead, signed
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0117', '<PN3P974MB2604HRIMMZ@PN1P572MB.INDP340.PROD.OUTLOOK.COM>'),
('CL-00124', 'VOR-26-0577', 'Document checklist sent', '0', '2026-10-05 16:12:00', 'Pooja Pandya', 'jinal.dsouza@mahiispat.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Jinal D''Souza,

Priyanka Trivedi has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for reinforcement steel. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0118', '<325075009559.6633@ashvakagroup.in>'),
('CL-00125', 'VOR-26-0578', 'Document checklist sent', '0', '2026-10-05 16:29:00', 'Riya Pandya', 'nikhil.bhatt@dhararmc.co.in', 'kavya.dsouza@ashvakagroup.in', 'Dear Nikhil Bhatt,

Kavya D''Souza has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for ready-mix concrete. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. ISO 9001 certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0119', '<PN2P994MB3681ZJJRZK@PN2P728MB.INDP893.PROD.OUTLOOK.COM>'),
('CL-00126', 'VOR-26-0580', 'Document checklist sent', '0', '2026-10-05T11:29:00Z', 'Pooja Pandya', 'suresh.sheikh@sankalptestinglabo.co.in', 'devang.menon@ashvakagroup.in', 'Dear Suresh Sheikh,

Devang Menon has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for material testing laboratory. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. NABL accreditation certificate with scope

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0120', '<cc4140b58ef547bf2b2b5f1a@ashvakagroup.in>'),
('CL-00127', 'VOR-26-0517', 'Chase 1', '1', '2026-10-05 17:39:00', 'Meera Kapadia', 'sneha.menon@parshvaroadlines.co.in', 'farhan.shah@ashvakagroup.in', 'Dear Sneha Menon,

Thank you for the documents. We still need the following before we can complete your registration:

1. Cancelled cheque or bank letter: not received.
2. Certificate of incorporation: not received.

Please reply to this email with the documents.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0077', '<7af2c6ed0c88fba4ca533451@ashvakagroup.in>'),
('CL-00128', 'VOR-26-0582', 'Document checklist sent', '0', '2026-10-05 17:46:00', 'Riya Pandya', 'farhan.oza@deccanlabourcontra.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Farhan Oza,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Energy Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0121', '<PN2P837MB1691GSCLPB@PN2P865MB.INDP570.PROD.OUTLOOK.COM>'),
('CL-00129', 'VOR-26-0583', 'Document checklist sent', '0', '2026-10-06 12:09:00', 'Meera Kapadia', 'ishaan.brahmbhatt@prayagindustrialsa.co.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Ishaan Brahmbhatt,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for safety and ppe. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 9001 certificate

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0122', '<8a82709a73fef7d789131ef3@ashvakagroup.in>'),
('CL-00130', 'VOR-26-0586', 'Document checklist sent', '0', '06-10-2026 12:43', 'Pooja Pandya', 'sagar.parmar@bhagyodayaggregate.in', 'sneha.parmar@ashvakagroup.in', 'Dear Sagar Parmar,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for aggregates and sand. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0123', '<320263191284.7617@ashvakagroup.in>'),
('CL-00131', 'VOR-26-0587', 'Document checklist sent', '0', '2026-10-06 13:21:00', 'Meera Kapadia', 'zoya.amin@sabarearthmovers.in', 'heena.solanki@ashvakagroup.in', 'Dear Zoya Amin,

Heena Solanki has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0124', '<PN2P687MB1266FNGJEV@PN3P621MB.INDP649.PROD.OUTLOOK.COM>'),
('CL-00132', 'VOR-26-0588', 'Document checklist sent', '0', '2026-10-06 13:26:00', 'Pooja Pandya', 'hetal.sanghvi@aashirwadcarriers.in', 'sameer.patel@ashvakagroup.in', 'Dear Hetal Sanghvi,

Sameer Patel has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for transport and freight (gta). Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Udyam registration certificate (you have declared MSME status)
6. GTA declaration for FY 2026-27 on your letterhead

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0125', '<PN3P487MB8930VZSLPC@PN1P179MB.INDP637.PROD.OUTLOOK.COM>'),
('CL-00133', 'VOR-26-0590', 'Document checklist sent', '0', '2026-10-06 14:49:00', 'Meera Kapadia', 'krunal.pandya@keystoneequipmenth.com', 'sneha.parmar@ashvakagroup.in', 'Dear Krunal Pandya,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. ISO 45001 certificate
6. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0126', '<PN2P599MB3853RHICNZ@PN2P265MB.INDP980.PROD.OUTLOOK.COM>'),
('CL-00134', 'VOR-26-0593', 'Document checklist sent', '0', '2026-10-06 14:50:00', 'Meera Kapadia', 'aakash.mistry@crestlinecementtra.in', 'kavya.bhatt@ashvakagroup.in', 'Dear Aakash Mistry,

Kavya Bhatt has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for cement. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0127', '<PN2P802MB5946QTUUWO@PN2P135MB.INDP435.PROD.OUTLOOK.COM>'),
('CL-00135', 'VOR-26-0596', 'Document checklist sent', '0', '2026-10-06 15:16:00', 'Meera Kapadia', 'vivek.jadeja@trikamaggregates.in', 'sana.singh@ashvakagroup.in', 'Dear Vivek Jadeja,

Sana Singh has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for aggregates and sand. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0128', '<cf99f968f36fa9a68e4bdc6e@ashvakagroup.in>'),
('CL-00136', 'VOR-26-0598', 'Document checklist sent', '0', '06-10-2026 15:38', 'Pooja Pandya', 'jignesh.amin@suryodaymanpowerse.co.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Jignesh Amin,

Rutvik Chauhan has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0129', '<358a34ae173a8f4940df4bd8@ashvakagroup.in>'),
('CL-00137', 'VOR-26-0601', 'Document checklist sent', '0', '2026-10-06 15:49:00', 'Meera Kapadia', 'vivek.chauhan@aashirwadworkforce.in', 'sana.singh@ashvakagroup.in', 'Dear Vivek Chauhan,

Sana Singh has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0131', '<343695603703.5188@ashvakagroup.in>'),
('CL-00138', 'VOR-26-0602', 'Document checklist sent', '0', '2026-10-06 15:58:00', 'Pooja Pandya', 'harsh.trivedi@kesarcraneservices.co.in', 'neha.amin@ashvakagroup.in', 'Dear Harsh Trivedi,

Neha Amin has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for equipment hire. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. ISO 45001 certificate
7. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0132', '<741402082620.2213@ashvakagroup.in>'),
('CL-00139', 'VOR-26-0603', 'Document checklist sent', '0', '2026-10-06 17:46:00', 'Pooja Pandya', 'dhruv.parikh@mahalaxmiworkforce.in', 'sneha.parmar@ashvakagroup.in', 'Dear Dhruv Parikh,

Sneha Parmar has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for manpower supply. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0133', '<1c060f716a91662543d76d53@ashvakagroup.in>'),
('CL-00140', 'VOR-26-0554', 'Chase 1', '1', '2026-10-07 10:02:00', 'Pooja Pandya', 'riya.bhatt@unnatiformworksyst.in', 'rutvik.chauhan@ashvakagroup.in', 'Dear Riya Bhatt,

Thank you for the documents. We still need the following before we can complete your registration:

1. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.

Please reply to this email with the documents.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0104', '<155173858875.2490@ashvakagroup.in>'),
('CL-00141', 'VOR-26-0604', 'Document checklist sent', '0', '2026-10-07 11:15:00', 'Meera Kapadia', 'maria.rao@suryodayminerals.com', 'sana.singh@ashvakagroup.in', 'Dear Maria Rao,

Sana Singh has asked us to register your firm as a supplier to Ashvaka Cement and Building Materials Limited for aggregates and sand. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0134', '<PN1P335MB4222OQXKGT@PN3P137MB.INDP827.PROD.OUTLOOK.COM>'),
('CL-00142', 'VOR-26-0607', 'Document checklist sent', '0', '2026-10-07 12:39:00', 'Meera Kapadia', 'rakesh.thakkar@navjivanguardingse.in', 'sana.singh@ashvakagroup.in', 'Dear Rakesh Thakkar,

Sana Singh has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. PSARA licence
10. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0135', '<720615174068.4441@ashvakagroup.in>'),
('CL-00143', 'VOR-26-0608', 'Document checklist sent', '0', '2026-10-07 12:49:00', 'Riya Pandya', 'hardik.rathod@dharafacilityservi.in', 'kruti.vaghela@ashvakagroup.in', 'Dear Hardik Rathod,

Kruti Vaghela has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Riya Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0136', '<PN2P934MB6306AURCGR@PN1P404MB.INDP224.PROD.OUTLOOK.COM>'),
('CL-00144', 'VOR-26-0609', 'Document checklist sent', '0', '2026-10-07 13:55:00', 'Pooja Pandya', 'mitesh.dsouza@pragatihousekeepin.in', 'maria.solanki@ashvakagroup.in', 'Dear Mitesh D''Souza,

Maria Solanki has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for housekeeping and facility. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Certificate of incorporation (and the fresh certificate if the company name has changed)
5. Udyam registration certificate (you have declared MSME status)
6. Contract labour licence
7. EPF registration certificate
8. ESIC registration certificate
9. Insurance certificate (employees'' compensation or contractor''s cover)

Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0137', '<85e97c16194f334f7574df8a@ashvakagroup.in>'),
('CL-00145', 'VOR-26-0577', 'Chase 1', '1', '2026-10-08 13:30:00', 'Pooja Pandya', 'jinal.dsouza@mahiispat.in', 'priyanka.trivedi@ashvakagroup.in', 'Dear Jinal D''Souza,

Thank you for the documents. We still need the following before we can complete your registration:

1. Udyam registration certificate: you declared MSME status but the certificate has not been received. Please send it, or confirm in writing that you are not registered as an MSME.

Please reply to this email with the documents.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0118', '<PN1P353MB3701UPMWCI@PN1P401MB.INDP711.PROD.OUTLOOK.COM>'),
('CL-00146', 'VOR-26-0612', 'Document checklist sent', '0', '2026-10-08 14:12:00', 'Meera Kapadia', 'aditi.pandya@lotusguardingservi.co.in', 'neha.amin@ashvakagroup.in', 'Dear Aditi Pandya,

Neha Amin has asked us to register your firm as a supplier to Ashvaka Energy Limited for security services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. LLP certificate of incorporation (Form 16)
5. Contract labour licence
6. EPF registration certificate
7. ESIC registration certificate
8. PSARA licence
9. Insurance certificate (employees'' compensation or contractor''s cover)

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0138', '<PN3P776MB7180GERMMB@PN1P152MB.INDP476.PROD.OUTLOOK.COM>'),
('CL-00147', 'VOR-26-0613', 'Document checklist sent', '0', '2026-10-08 15:08:00', 'Pooja Pandya', 'vikram.gill@keystoneitsolution.in', 'sameer.patel@ashvakagroup.in', 'Dear Vikram Gill,

Sameer Patel has asked us to register your firm as a supplier to Ashvaka Infrastructure Limited for it services. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Shop and establishment registration certificate

If you are registered as an MSME, please include your Udyam registration certificate. Copies must be clear and complete.

Regards,
Pooja Pandya
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0139', '<954529713548.7053@ashvakagroup.in>'),
('CL-00148', 'VOR-26-0614', 'Document checklist sent', '0', '2026-10-09 10:31:00', 'Meera Kapadia', 'neha.sharma@jayambeispat.com', 'aarav.rao@ashvakagroup.in', 'Dear Neha Sharma,

Aarav Rao has asked us to register your firm as a supplier to Ashvaka Logistics and Warehousing Limited for reinforcement steel. Please reply to this email with the following documents:

1. GST registration certificate (Form GST REG-06) for the state you will supply from
2. PAN of the vendor entity
3. Cancelled cheque with the account holder''s name printed, or a bank letter signed and stamped by the bank
4. Partnership deed (first pages and signature page)
5. Udyam registration certificate (you have declared MSME status)

Copies must be clear and complete.

Regards,
Meera Kapadia
Vendor Onboarding Desk
Ashvaka Industries Group', 'B1-T0140', '<692073500035.2456@ashvakagroup.in>');

drop table if exists public."received_document";
create table public."received_document" (
  row_id bigint generated always as identity primary key,
  "request_id" text,
  "received_at" text,
  "from_address" text,
  "mailbox_file" text,
  "attachment_name" text,
  "stored_path" text,
  "page_count" text,
  "size_kb" text
);
comment on table public."received_document" is 'One attachment that arrived by email and was filed against a request.';
insert into public."received_document" ("request_id", "received_at", "from_address", "mailbox_file", "attachment_name", "stored_path", "page_count", "size_kb") values
('VOR-26-0417', '2026-09-07 17:41:00', 'nikhil.reddy@narmadaequipmenthi.in', 'mailbox/inbox/0001__20260907_1741.eml', 'pan copy.pdf', 'documents/VOR-26-0417/pan copy.pdf', '1', '2.5'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0414/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0414/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'ESI Code.pdf', 'documents/VOR-26-0414/ESI Code.pdf', '1', '2.5'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'Form 16 LLP.pdf', 'documents/VOR-26-0414/Form 16 LLP.pdf', '1', '3.1'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0414/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0414/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'Labour License.pdf', 'documents/VOR-26-0414/Labour License.pdf', '1', '3.8'),
('VOR-26-0414', '2026-09-08 11:41:00', 'sameer.raval@sthapatyafacility.in', 'mailbox/inbox/0002__20260908_1141.eml', 'pan copy.pdf', 'documents/VOR-26-0414/pan copy.pdf', '1', '2.5'),
('VOR-26-0423', '2026-09-08 21:37:00', 'shreeumiyaengi19@gmail.com', 'mailbox/inbox/0003__20260908_2137.eml', 'Deed extract.pdf', 'documents/VOR-26-0423/Deed extract.pdf', '1', '3.5'),
('VOR-26-0423', '2026-09-08 21:37:00', 'shreeumiyaengi19@gmail.com', 'mailbox/inbox/0003__20260908_2137.eml', 'SUE KYC.pdf', 'documents/VOR-26-0423/SUE KYC.pdf', '4', '8.6'),
('VOR-26-0420', '2026-09-09 10:27:00', 'meera.shah@sthapatyascaffoldi.com', 'mailbox/inbox/0004__20260909_1027.eml', 'All documents.pdf', 'documents/VOR-26-0420/All documents.pdf', '4', '8.7'),
('VOR-26-0420', '2026-09-09 10:27:00', 'meera.shah@sthapatyascaffoldi.com', 'mailbox/inbox/0004__20260909_1027.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0420/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0420', '2026-09-09 10:27:00', 'meera.shah@sthapatyascaffoldi.com', 'mailbox/inbox/0004__20260909_1027.eml', 'scan_0033.pdf', 'documents/VOR-26-0420/scan_0033.pdf', '1', '45.7'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0418/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'Company PAN.pdf', 'documents/VOR-26-0418/Company PAN.pdf', '1', '2.5'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'Company Profile.pdf', 'documents/VOR-26-0418/Company Profile.pdf', '1', '2.7'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0418/ESIC Registration.pdf', '1', '2.6'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'JAH COI.pdf', 'documents/VOR-26-0418/JAH COI.pdf', '1', '3.1'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'JAH GST.pdf', 'documents/VOR-26-0418/JAH GST.pdf', '1', '3.5'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'Labour License.pdf', 'documents/VOR-26-0418/Labour License.pdf', '1', '3.9'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'PF Registration.pdf', 'documents/VOR-26-0418/PF Registration.pdf', '1', '2.6'),
('VOR-26-0418', '2026-09-09 11:19:00', 'meera.pathan@jayambehousekeepin.co.in', 'mailbox/inbox/0005__20260909_1119.eml', 'WC Policy.pdf', 'documents/VOR-26-0418/WC Policy.pdf', '1', '3.0'),
('VOR-26-0428', '2026-09-09 15:15:00', 'venkat.gill@unnaticement.in', 'mailbox/inbox/0006__20260909_1515.eml', 'Company PAN.pdf', 'documents/VOR-26-0428/Company PAN.pdf', '1', '2.5'),
('VOR-26-0428', '2026-09-09 15:15:00', 'venkat.gill@unnaticement.in', 'mailbox/inbox/0006__20260909_1515.eml', 'GST REG-06.pdf', 'documents/VOR-26-0428/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0428', '2026-09-09 15:15:00', 'venkat.gill@unnaticement.in', 'mailbox/inbox/0006__20260909_1515.eml', 'IMG_20260909_169381.pdf', 'documents/VOR-26-0428/IMG_20260909_169381.pdf', '1', '22.3'),
('VOR-26-0428', '2026-09-09 15:15:00', 'venkat.gill@unnaticement.in', 'mailbox/inbox/0006__20260909_1515.eml', 'LLP Incorporation.pdf', 'documents/VOR-26-0428/LLP Incorporation.pdf', '1', '3.2'),
('VOR-26-0426', '2026-09-09 15:54:00', 'kruti.bhatt@siddhivinayakindus.in', 'mailbox/inbox/0007__20260909_1554.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0426/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0426', '2026-09-09 15:54:00', 'kruti.bhatt@siddhivinayakindus.in', 'mailbox/inbox/0007__20260909_1554.eml', 'GST REG-06.pdf', 'documents/VOR-26-0426/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0426', '2026-09-09 15:54:00', 'kruti.bhatt@siddhivinayakindus.in', 'mailbox/inbox/0007__20260909_1554.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0426/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0426', '2026-09-09 15:54:00', 'kruti.bhatt@siddhivinayakindus.in', 'mailbox/inbox/0007__20260909_1554.eml', 'Partnership deed copy.pdf', 'documents/VOR-26-0426/Partnership deed copy.pdf', '1', '3.6'),
('VOR-26-0426', '2026-09-09 15:54:00', 'kruti.bhatt@siddhivinayakindus.in', 'mailbox/inbox/0007__20260909_1554.eml', 'pan copy.pdf', 'documents/VOR-26-0426/pan copy.pdf', '1', '2.5'),
('VOR-26-0417', '2026-09-09 19:44:00', 'nikhil.reddy@narmadaequipmenthi.in', 'mailbox/inbox/0008__20260909_1944.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0417/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0417', '2026-09-09 19:44:00', 'nikhil.reddy@narmadaequipmenthi.in', 'mailbox/inbox/0008__20260909_1944.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0417/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0417', '2026-09-09 19:44:00', 'nikhil.reddy@narmadaequipmenthi.in', 'mailbox/inbox/0008__20260909_1944.eml', 'NEH GST.pdf', 'documents/VOR-26-0417/NEH GST.pdf', '1', '3.4'),
('VOR-26-0417', '2026-09-09 19:44:00', 'nikhil.reddy@narmadaequipmenthi.in', 'mailbox/inbox/0008__20260909_1944.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0417/Shop Establishment Certificate.pdf', '1', '3.2'),
('VOR-26-0417', '2026-09-09 19:44:00', 'nikhil.reddy@narmadaequipmenthi.in', 'mailbox/inbox/0008__20260909_1944.eml', 'WC Policy.pdf', 'documents/VOR-26-0417/WC Policy.pdf', '1', '2.9'),
('VOR-26-0413', '2026-09-10 14:32:00', 'heena.fernandes@darshancement.in', 'mailbox/inbox/0009__20260910_1432.eml', 'Cheque.pdf', 'documents/VOR-26-0413/Cheque.pdf', '1', '2.4'),
('VOR-26-0413', '2026-09-10 14:32:00', 'heena.fernandes@darshancement.in', 'mailbox/inbox/0009__20260910_1432.eml', 'GST Registration.pdf', 'documents/VOR-26-0413/GST Registration.pdf', '1', '3.5'),
('VOR-26-0413', '2026-09-10 14:32:00', 'heena.fernandes@darshancement.in', 'mailbox/inbox/0009__20260910_1432.eml', 'KYC Documents.pdf', 'documents/VOR-26-0413/KYC Documents.pdf', '2', '4.6'),
('VOR-26-0439', '2026-09-10 21:40:00', 'tanvi.joshi@jyotisteeltraders.in', 'mailbox/inbox/0010__20260910_2140.eml', 'PAN.pdf', 'documents/VOR-26-0439/PAN.pdf', '1', '2.5'),
('VOR-26-0439', '2026-09-10 21:40:00', 'tanvi.joshi@jyotisteeltraders.in', 'mailbox/inbox/0010__20260910_2140.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0439/Vendor Registration Documents.pdf', '4', '9.0'),
('VOR-26-0422', '2026-09-11 10:38:00', 'hardik.iyer@girnarcarriers.co.in', 'mailbox/inbox/0011__20260911_1038.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0422/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0422', '2026-09-11 10:38:00', 'hardik.iyer@girnarcarriers.co.in', 'mailbox/inbox/0011__20260911_1038.eml', 'GST Registration.pdf', 'documents/VOR-26-0422/GST Registration.pdf', '1', '3.4'),
('VOR-26-0422', '2026-09-11 10:38:00', 'hardik.iyer@girnarcarriers.co.in', 'mailbox/inbox/0011__20260911_1038.eml', 'GTA declaration FY.pdf', 'documents/VOR-26-0422/GTA declaration FY.pdf', '1', '3.2'),
('VOR-26-0422', '2026-09-11 10:38:00', 'hardik.iyer@girnarcarriers.co.in', 'mailbox/inbox/0011__20260911_1038.eml', 'MSME.pdf', 'documents/VOR-26-0422/MSME.pdf', '1', '3.3'),
('VOR-26-0422', '2026-09-11 10:38:00', 'hardik.iyer@girnarcarriers.co.in', 'mailbox/inbox/0011__20260911_1038.eml', 'Partnership Deed.pdf', 'documents/VOR-26-0422/Partnership Deed.pdf', '1', '3.5'),
('VOR-26-0422', '2026-09-11 10:38:00', 'hardik.iyer@girnarcarriers.co.in', 'mailbox/inbox/0011__20260911_1038.eml', 'pan copy.pdf', 'documents/VOR-26-0422/pan copy.pdf', '1', '2.5'),
('VOR-26-0431', '2026-09-11 13:22:00', 'nisha.shah@deccanroadlines.com', 'mailbox/inbox/0012__20260911_1322.eml', 'Annexure V.pdf', 'documents/VOR-26-0431/Annexure V.pdf', '1', '3.2'),
('VOR-26-0431', '2026-09-11 13:22:00', 'nisha.shah@deccanroadlines.com', 'mailbox/inbox/0012__20260911_1322.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0431/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0431', '2026-09-11 13:22:00', 'nisha.shah@deccanroadlines.com', 'mailbox/inbox/0012__20260911_1322.eml', 'GST Certificate.pdf', 'documents/VOR-26-0431/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0431', '2026-09-11 13:22:00', 'nisha.shah@deccanroadlines.com', 'mailbox/inbox/0012__20260911_1322.eml', 'PAN.pdf', 'documents/VOR-26-0431/PAN.pdf', '1', '2.5'),
('VOR-26-0431', '2026-09-11 13:22:00', 'nisha.shah@deccanroadlines.com', 'mailbox/inbox/0012__20260911_1322.eml', 'scan_0039.pdf', 'documents/VOR-26-0431/scan_0039.pdf', '1', '77.4'),
('VOR-26-0440', '2026-09-11 14:45:00', 'hardik.gill@aravallisystems.in', 'mailbox/inbox/0013__20260911_1445.eml', 'AS GST.pdf', 'documents/VOR-26-0440/AS GST.pdf', '1', '3.4'),
('VOR-26-0440', '2026-09-11 14:45:00', 'hardik.gill@aravallisystems.in', 'mailbox/inbox/0013__20260911_1445.eml', 'AS KYC.pdf', 'documents/VOR-26-0440/AS KYC.pdf', '2', '4.3'),
('VOR-26-0440', '2026-09-11 14:45:00', 'hardik.gill@aravallisystems.in', 'mailbox/inbox/0013__20260911_1445.eml', 'Cheque.pdf', 'documents/VOR-26-0440/Cheque.pdf', '1', '2.4'),
('VOR-26-0440', '2026-09-11 14:45:00', 'hardik.gill@aravallisystems.in', 'mailbox/inbox/0013__20260911_1445.eml', 'Partnership Deed.pdf', 'documents/VOR-26-0440/Partnership Deed.pdf', '1', '3.4'),
('VOR-26-0429', '2026-09-11 15:51:00', 'vikram.gill@suryodayengineerin.co.in', 'mailbox/inbox/0014__20260911_1551.eml', 'Bank Confirmation Letter.pdf', 'documents/VOR-26-0429/Bank Confirmation Letter.pdf', '1', '3.6'),
('VOR-26-0429', '2026-09-11 15:51:00', 'vikram.gill@suryodayengineerin.co.in', 'mailbox/inbox/0014__20260911_1551.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0429/Incorporation Certificate.pdf', '1', '3.4'),
('VOR-26-0429', '2026-09-11 15:51:00', 'vikram.gill@suryodayengineerin.co.in', 'mailbox/inbox/0014__20260911_1551.eml', 'SEC GST.pdf', 'documents/VOR-26-0429/SEC GST.pdf', '1', '3.5'),
('VOR-26-0429', '2026-09-11 15:51:00', 'vikram.gill@suryodayengineerin.co.in', 'mailbox/inbox/0014__20260911_1551.eml', 'SEC PAN.pdf', 'documents/VOR-26-0429/SEC PAN.pdf', '1', '2.5'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'CFS GST.pdf', 'documents/VOR-26-0427/CFS GST.pdf', '1', '3.5'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0427/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'COI.pdf', 'documents/VOR-26-0427/COI.pdf', '1', '3.1'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'Cheque.pdf', 'documents/VOR-26-0427/Cheque.pdf', '1', '2.4'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0427/ESIC Registration.pdf', '1', '2.6'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0427/Insurance Policy.pdf', '1', '2.9'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'MSME.pdf', 'documents/VOR-26-0427/MSME.pdf', '1', '3.3'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'PAN Card.pdf', 'documents/VOR-26-0427/PAN Card.pdf', '1', '2.5'),
('VOR-26-0427', '2026-09-11 21:53:00', 'karan.sheikh@crestlinefacilitys.com', 'mailbox/inbox/0015__20260911_2153.eml', 'PF Registration.pdf', 'documents/VOR-26-0427/PF Registration.pdf', '1', '2.6'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0443/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0443/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'NWS KYC.pdf', 'documents/VOR-26-0443/NWS KYC.pdf', '3', '7.3'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'PAN Card.pdf', 'documents/VOR-26-0443/PAN Card.pdf', '1', '2.5'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0443/Udyam Registration.pdf', '1', '3.2'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'WC Policy.pdf', 'documents/VOR-26-0443/WC Policy.pdf', '1', '2.9'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'cancel cheque.pdf', 'documents/VOR-26-0443/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0443', '2026-09-12 10:48:00', 'harsh.kothari@nandanworkforcesol.in', 'mailbox/inbox/0016__20260912_1048.eml', 'scan_0041.pdf', 'documents/VOR-26-0443/scan_0041.pdf', '1', '50.7'),
('VOR-26-0445', '2026-09-12 11:11:00', 'meera.dave@bhagyodaycableindu.in', 'mailbox/inbox/0017__20260912_1111.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0445/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0445', '2026-09-12 11:11:00', 'meera.dave@bhagyodaycableindu.in', 'mailbox/inbox/0017__20260912_1111.eml', 'Company PAN.pdf', 'documents/VOR-26-0445/Company PAN.pdf', '1', '2.5'),
('VOR-26-0445', '2026-09-12 11:11:00', 'meera.dave@bhagyodaycableindu.in', 'mailbox/inbox/0017__20260912_1111.eml', 'GST Certificate.pdf', 'documents/VOR-26-0445/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0445', '2026-09-12 11:11:00', 'meera.dave@bhagyodaycableindu.in', 'mailbox/inbox/0017__20260912_1111.eml', 'ISO 9001.pdf', 'documents/VOR-26-0445/ISO 9001.pdf', '1', '3.0'),
('VOR-26-0445', '2026-09-12 11:11:00', 'meera.dave@bhagyodaycableindu.in', 'mailbox/inbox/0017__20260912_1111.eml', 'Partnership Deed.pdf', 'documents/VOR-26-0445/Partnership Deed.pdf', '1', '3.5'),
('VOR-26-0449', '2026-09-12 16:39:00', 'krunal.oza@eshaninfra.in', 'mailbox/inbox/0018__20260912_1639.eml', 'EI GST.pdf', 'documents/VOR-26-0449/EI GST.pdf', '1', '3.4'),
('VOR-26-0449', '2026-09-12 16:39:00', 'krunal.oza@eshaninfra.in', 'mailbox/inbox/0018__20260912_1639.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0449/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0449', '2026-09-12 16:39:00', 'krunal.oza@eshaninfra.in', 'mailbox/inbox/0018__20260912_1639.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0449/Incorporation Certificate.pdf', '1', '3.1'),
('VOR-26-0449', '2026-09-12 16:39:00', 'krunal.oza@eshaninfra.in', 'mailbox/inbox/0018__20260912_1639.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0449/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0449', '2026-09-12 16:39:00', 'krunal.oza@eshaninfra.in', 'mailbox/inbox/0018__20260912_1639.eml', 'cancel cheque.pdf', 'documents/VOR-26-0449/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0449', '2026-09-12 16:39:00', 'krunal.oza@eshaninfra.in', 'mailbox/inbox/0018__20260912_1639.eml', 'scan_0045.pdf', 'documents/VOR-26-0449/scan_0045.pdf', '1', '12.1'),
('VOR-26-0434', '2026-09-12 18:25:00', 'kinjal.shukla@pragatilabourcontr.com', 'mailbox/inbox/0019__20260912_1825.eml', 'All documents.pdf', 'documents/VOR-26-0434/All documents.pdf', '4', '8.1'),
('VOR-26-0434', '2026-09-12 18:25:00', 'kinjal.shukla@pragatilabourcontr.com', 'mailbox/inbox/0019__20260912_1825.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0434/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0434', '2026-09-12 18:25:00', 'kinjal.shukla@pragatilabourcontr.com', 'mailbox/inbox/0019__20260912_1825.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0434/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0434', '2026-09-12 18:25:00', 'kinjal.shukla@pragatilabourcontr.com', 'mailbox/inbox/0019__20260912_1825.eml', 'Gumasta.pdf', 'documents/VOR-26-0434/Gumasta.pdf', '1', '3.2'),
('VOR-26-0434', '2026-09-12 18:25:00', 'kinjal.shukla@pragatilabourcontr.com', 'mailbox/inbox/0019__20260912_1825.eml', 'Labour Licence.pdf', 'documents/VOR-26-0434/Labour Licence.pdf', '1', '3.8'),
('VOR-26-0434', '2026-09-12 18:25:00', 'kinjal.shukla@pragatilabourcontr.com', 'mailbox/inbox/0019__20260912_1825.eml', 'pan copy.pdf', 'documents/VOR-26-0434/pan copy.pdf', '1', '2.5'),
('VOR-26-0441', '2026-09-12 18:40:00', 'zoya.solanki@garudaminerals.in', 'mailbox/inbox/0020__20260912_1840.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0441/Udyam Registration.pdf', '1', '3.2'),
('VOR-26-0441', '2026-09-12 18:40:00', 'zoya.solanki@garudaminerals.in', 'mailbox/inbox/0020__20260912_1840.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0441/Vendor Registration Documents.pdf', '4', '9.7'),
('VOR-26-0447', '2026-09-13 00:14:00', 'imran.sheikh@tirthrenewables.in', 'mailbox/inbox/0021__20260913_0014.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0447/Certificate of Incorporation.pdf', '1', '3.3'),
('VOR-26-0447', '2026-09-13 00:14:00', 'imran.sheikh@tirthrenewables.in', 'mailbox/inbox/0021__20260913_0014.eml', 'Cheque.pdf', 'documents/VOR-26-0447/Cheque.pdf', '1', '2.4'),
('VOR-26-0447', '2026-09-13 00:14:00', 'imran.sheikh@tirthrenewables.in', 'mailbox/inbox/0021__20260913_0014.eml', 'ISO 9001.pdf', 'documents/VOR-26-0447/ISO 9001.pdf', '1', '3.1'),
('VOR-26-0447', '2026-09-13 00:14:00', 'imran.sheikh@tirthrenewables.in', 'mailbox/inbox/0021__20260913_0014.eml', 'PAN Card.pdf', 'documents/VOR-26-0447/PAN Card.pdf', '1', '2.5'),
('VOR-26-0447', '2026-09-13 00:14:00', 'imran.sheikh@tirthrenewables.in', 'mailbox/inbox/0021__20260913_0014.eml', 'TR GST.pdf', 'documents/VOR-26-0447/TR GST.pdf', '1', '3.5'),
('VOR-26-0437', '2026-09-13 09:24:00', 'joseph.shah@horizoncables.co.in', 'mailbox/inbox/0022__20260913_0924.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0437/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0437', '2026-09-13 09:24:00', 'joseph.shah@horizoncables.co.in', 'mailbox/inbox/0022__20260913_0924.eml', 'HC COI.pdf', 'documents/VOR-26-0437/HC COI.pdf', '1', '3.1'),
('VOR-26-0437', '2026-09-13 09:24:00', 'joseph.shah@horizoncables.co.in', 'mailbox/inbox/0022__20260913_0924.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0437/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0437', '2026-09-13 09:24:00', 'joseph.shah@horizoncables.co.in', 'mailbox/inbox/0022__20260913_0924.eml', 'gst.pdf', 'documents/VOR-26-0437/gst.pdf', '1', '3.4'),
('VOR-26-0437', '2026-09-13 09:24:00', 'joseph.shah@horizoncables.co.in', 'mailbox/inbox/0022__20260913_0924.eml', 'pan copy.pdf', 'documents/VOR-26-0437/pan copy.pdf', '1', '2.5'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0438/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0438/ESIC Registration.pdf', '1', '2.5'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'Form 16 LLP.pdf', 'documents/VOR-26-0438/Form 16 LLP.pdf', '1', '3.1'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'GST REG-06.pdf', 'documents/VOR-26-0438/GST REG-06.pdf', '1', '3.4'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'KPF PAN.pdf', 'documents/VOR-26-0438/KPF PAN.pdf', '1', '2.5'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'PF Certificate.pdf', 'documents/VOR-26-0438/PF Certificate.pdf', '1', '2.6'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'PSARA Licence.pdf', 'documents/VOR-26-0438/PSARA Licence.pdf', '1', '3.5'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0438/Policy Certificate.pdf', '1', '2.9'),
('VOR-26-0438', '2026-09-13 18:43:00', 'yash.amin@ashvakagroup.in', 'mailbox/inbox/0023__20260913_1843.eml', 'cancelled chq.pdf', 'documents/VOR-26-0438/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0448', '2026-09-14 12:36:00', 'rohit.dsouza@lotusengineering.in', 'mailbox/inbox/0025__20260914_1236.eml', 'COI.pdf', 'documents/VOR-26-0448/COI.pdf', '1', '3.1'),
('VOR-26-0448', '2026-09-14 12:36:00', 'rohit.dsouza@lotusengineering.in', 'mailbox/inbox/0025__20260914_1236.eml', 'Cheque.pdf', 'documents/VOR-26-0448/Cheque.pdf', '1', '2.5'),
('VOR-26-0448', '2026-09-14 12:36:00', 'rohit.dsouza@lotusengineering.in', 'mailbox/inbox/0025__20260914_1236.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0448/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0448', '2026-09-14 12:36:00', 'rohit.dsouza@lotusengineering.in', 'mailbox/inbox/0025__20260914_1236.eml', 'LES PAN.pdf', 'documents/VOR-26-0448/LES PAN.pdf', '1', '2.5'),
('VOR-26-0448', '2026-09-14 12:36:00', 'rohit.dsouza@lotusengineering.in', 'mailbox/inbox/0025__20260914_1236.eml', 'MSME.pdf', 'documents/VOR-26-0448/MSME.pdf', '1', '3.3'),
('VOR-26-0456', '2026-09-14 22:41:00', 'heena.mistry@sahjanandswitchgea.in', 'mailbox/inbox/0026__20260914_2241.eml', 'ISO 9001.pdf', 'documents/VOR-26-0456/ISO 9001.pdf', '1', '3.3'),
('VOR-26-0456', '2026-09-14 22:41:00', 'heena.mistry@sahjanandswitchgea.in', 'mailbox/inbox/0026__20260914_2241.eml', 'KYC Documents.pdf', 'documents/VOR-26-0456/KYC Documents.pdf', '4', '8.5'),
('VOR-26-0457', '2026-09-16 10:22:00', 'gurpreet.sanghvi@samarthindustrials.in', 'mailbox/inbox/0027__20260916_1022.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0457/Certificate of Incorporation.pdf', '1', '3.1'),
('VOR-26-0457', '2026-09-16 10:22:00', 'gurpreet.sanghvi@samarthindustrials.in', 'mailbox/inbox/0027__20260916_1022.eml', 'Company Profile.pdf', 'documents/VOR-26-0457/Company Profile.pdf', '1', '2.7'),
('VOR-26-0457', '2026-09-16 10:22:00', 'gurpreet.sanghvi@samarthindustrials.in', 'mailbox/inbox/0027__20260916_1022.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0457/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0457', '2026-09-16 10:22:00', 'gurpreet.sanghvi@samarthindustrials.in', 'mailbox/inbox/0027__20260916_1022.eml', 'ISO 9001 2015.pdf', 'documents/VOR-26-0457/ISO 9001 2015.pdf', '1', '3.2'),
('VOR-26-0457', '2026-09-16 10:22:00', 'gurpreet.sanghvi@samarthindustrials.in', 'mailbox/inbox/0027__20260916_1022.eml', 'PAN.pdf', 'documents/VOR-26-0457/PAN.pdf', '1', '2.5'),
('VOR-26-0457', '2026-09-16 10:22:00', 'gurpreet.sanghvi@samarthindustrials.in', 'mailbox/inbox/0027__20260916_1022.eml', 'cancelled chq.pdf', 'documents/VOR-26-0457/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0452', '2026-09-16 11:26:00', 'sagar.trivedi@pinnaclecableindus.com', 'mailbox/inbox/0028__20260916_1126.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0452/Certificate of Incorporation.pdf', '1', '3.2'),
('VOR-26-0452', '2026-09-16 11:26:00', 'sagar.trivedi@pinnaclecableindus.com', 'mailbox/inbox/0028__20260916_1126.eml', 'GST REG-06.pdf', 'documents/VOR-26-0452/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0452', '2026-09-16 11:26:00', 'sagar.trivedi@pinnaclecableindus.com', 'mailbox/inbox/0028__20260916_1126.eml', 'ISO 9001 2015.pdf', 'documents/VOR-26-0452/ISO 9001 2015.pdf', '1', '3.0'),
('VOR-26-0452', '2026-09-16 11:26:00', 'sagar.trivedi@pinnaclecableindus.com', 'mailbox/inbox/0028__20260916_1126.eml', 'PAN.pdf', 'documents/VOR-26-0452/PAN.pdf', '1', '2.5'),
('VOR-26-0452', '2026-09-16 11:26:00', 'sagar.trivedi@pinnaclecableindus.com', 'mailbox/inbox/0028__20260916_1126.eml', 'cancelled chq.pdf', 'documents/VOR-26-0452/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0449', '2026-09-16 11:27:00', 'krunal.oza@eshaninfra.in', 'mailbox/inbox/0029__20260916_1127.eml', 'Company PAN.pdf', 'documents/VOR-26-0449/Company PAN.pdf', '1', '2.5'),
('VOR-26-0451', '2026-09-16 11:38:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0030__20260916_1138.eml', 'Cheque.pdf', 'documents/VOR-26-0451/Cheque.pdf', '1', '2.5'),
('VOR-26-0451', '2026-09-16 11:38:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0030__20260916_1138.eml', 'Form 16 LLP.pdf', 'documents/VOR-26-0451/Form 16 LLP.pdf', '1', '3.1'),
('VOR-26-0451', '2026-09-16 11:38:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0030__20260916_1138.eml', 'PAN Card.pdf', 'documents/VOR-26-0451/PAN Card.pdf', '1', '2.5'),
('VOR-26-0458', '2026-09-16 12:55:00', 'garudamaintena36@gmail.com', 'mailbox/inbox/0031__20260916_1255.eml', 'GMS PAN.pdf', 'documents/VOR-26-0458/GMS PAN.pdf', '1', '2.5'),
('VOR-26-0458', '2026-09-16 12:55:00', 'garudamaintena36@gmail.com', 'mailbox/inbox/0031__20260916_1255.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0458/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0458', '2026-09-16 12:55:00', 'garudamaintena36@gmail.com', 'mailbox/inbox/0031__20260916_1255.eml', 'Partnership Deed.pdf', 'documents/VOR-26-0458/Partnership Deed.pdf', '1', '3.6'),
('VOR-26-0458', '2026-09-16 12:55:00', 'garudamaintena36@gmail.com', 'mailbox/inbox/0031__20260916_1255.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0458/Udyam Registration.pdf', '1', '3.2'),
('VOR-26-0458', '2026-09-16 12:55:00', 'garudamaintena36@gmail.com', 'mailbox/inbox/0031__20260916_1255.eml', 'cancelled chq.pdf', 'documents/VOR-26-0458/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0459', '2026-09-16 20:33:00', 'ankit.panchal@udayearthmovers.com', 'mailbox/inbox/0032__20260916_2033.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0459/Incorporation Certificate.pdf', '1', '3.2'),
('VOR-26-0459', '2026-09-16 20:33:00', 'ankit.panchal@udayearthmovers.com', 'mailbox/inbox/0032__20260916_2033.eml', 'Insurance.pdf', 'documents/VOR-26-0459/Insurance.pdf', '1', '3.0'),
('VOR-26-0459', '2026-09-16 20:33:00', 'ankit.panchal@udayearthmovers.com', 'mailbox/inbox/0032__20260916_2033.eml', 'KYC Documents.pdf', 'documents/VOR-26-0459/KYC Documents.pdf', '4', '8.4'),
('VOR-26-0459', '2026-09-16 20:33:00', 'ankit.panchal@udayearthmovers.com', 'mailbox/inbox/0032__20260916_2033.eml', 'UE Profile.pdf', 'documents/VOR-26-0459/UE Profile.pdf', '1', '2.9'),
('VOR-26-0451', '2026-09-17 10:33:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0033__20260917_1033.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0451/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0451', '2026-09-17 10:33:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0033__20260917_1033.eml', 'ESI Code.pdf', 'documents/VOR-26-0451/ESI Code.pdf', '1', '2.6'),
('VOR-26-0451', '2026-09-17 10:33:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0033__20260917_1033.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0451/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0451', '2026-09-17 10:33:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0033__20260917_1033.eml', 'Insurance.pdf', 'documents/VOR-26-0451/Insurance.pdf', '1', '3.0'),
('VOR-26-0451', '2026-09-17 10:33:00', 'aakash.verma@vihaanmanpowerserv.co.in', 'mailbox/inbox/0033__20260917_1033.eml', 'PF Certificate.pdf', 'documents/VOR-26-0451/PF Certificate.pdf', '1', '2.6'),
('VOR-26-0454', '2026-09-17 14:33:00', 'kruti.pandya@bansiitsolutions.in', 'mailbox/inbox/0034__20260917_1433.eml', 'All documents.pdf', 'documents/VOR-26-0454/All documents.pdf', '2', '4.6'),
('VOR-26-0454', '2026-09-17 14:33:00', 'kruti.pandya@bansiitsolutions.in', 'mailbox/inbox/0034__20260917_1433.eml', 'Bank certificate.pdf', 'documents/VOR-26-0454/Bank certificate.pdf', '1', '3.5'),
('VOR-26-0454', '2026-09-17 14:33:00', 'kruti.pandya@bansiitsolutions.in', 'mailbox/inbox/0034__20260917_1433.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0454/MSME Certificate.pdf', '1', '3.2'),
('VOR-26-0454', '2026-09-17 14:33:00', 'kruti.pandya@bansiitsolutions.in', 'mailbox/inbox/0034__20260917_1433.eml', 'scan_0047.pdf', 'documents/VOR-26-0454/scan_0047.pdf', '1', '75.2'),
('VOR-26-0461', '2026-09-17 16:16:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0035__20260917_1616.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0461/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0461', '2026-09-17 16:16:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0035__20260917_1616.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0461/Certificate of Incorporation.pdf', '1', '3.3'),
('VOR-26-0461', '2026-09-17 16:16:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0035__20260917_1616.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0461/ESIC Registration.pdf', '1', '2.6'),
('VOR-26-0461', '2026-09-17 16:16:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0035__20260917_1616.eml', 'PAN Card.pdf', 'documents/VOR-26-0461/PAN Card.pdf', '1', '2.5'),
('VOR-26-0461', '2026-09-17 16:16:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0035__20260917_1616.eml', 'cancel cheque.pdf', 'documents/VOR-26-0461/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0453', '2026-09-17 18:09:00', 'heena.solanki@ashvakagroup.in', 'mailbox/inbox/0036__20260917_1809.eml', 'GTA Declaration.pdf', 'documents/VOR-26-0453/GTA Declaration.pdf', '1', '3.4'),
('VOR-26-0453', '2026-09-17 18:09:00', 'heena.solanki@ashvakagroup.in', 'mailbox/inbox/0036__20260917_1809.eml', 'KYC Documents.pdf', 'documents/VOR-26-0453/KYC Documents.pdf', '4', '177.0'),
('VOR-26-0463', '2026-09-18 11:14:00', 'priyanka.kapadia@zenithaggregates.in', 'mailbox/inbox/0037__20260918_1114.eml', 'COI.pdf', 'documents/VOR-26-0463/COI.pdf', '1', '3.1'),
('VOR-26-0463', '2026-09-18 11:14:00', 'priyanka.kapadia@zenithaggregates.in', 'mailbox/inbox/0037__20260918_1114.eml', 'Company PAN.pdf', 'documents/VOR-26-0463/Company PAN.pdf', '1', '2.5'),
('VOR-26-0463', '2026-09-18 11:14:00', 'priyanka.kapadia@zenithaggregates.in', 'mailbox/inbox/0037__20260918_1114.eml', 'GST Registration.pdf', 'documents/VOR-26-0463/GST Registration.pdf', '1', '3.4'),
('VOR-26-0463', '2026-09-18 11:14:00', 'priyanka.kapadia@zenithaggregates.in', 'mailbox/inbox/0037__20260918_1114.eml', 'cancel cheque.pdf', 'documents/VOR-26-0463/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0447', '2026-09-18 17:05:00', 'imran.sheikh@tirthrenewables.in', 'mailbox/inbox/0038__20260918_1705.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0447/Udyam Certificate.pdf', '1', '3.3'),
('VOR-26-0468', '2026-09-19 12:26:00', 'shreya.nair@induswiresandcable.co.in', 'mailbox/inbox/0039__20260919_1226.eml', 'Documents.pdf', 'documents/VOR-26-0468/Documents.pdf', '2', '3.6'),
('VOR-26-0468', '2026-09-19 12:26:00', 'shreya.nair@induswiresandcable.co.in', 'mailbox/inbox/0039__20260919_1226.eml', 'IMG_20260919_162658.pdf', 'documents/VOR-26-0468/IMG_20260919_162658.pdf', '1', '55.7'),
('VOR-26-0468', '2026-09-19 12:26:00', 'shreya.nair@induswiresandcable.co.in', 'mailbox/inbox/0039__20260919_1226.eml', 'ISO 9001.pdf', 'documents/VOR-26-0468/ISO 9001.pdf', '1', '3.3'),
('VOR-26-0468', '2026-09-19 12:26:00', 'shreya.nair@induswiresandcable.co.in', 'mailbox/inbox/0039__20260919_1226.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0468/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0466', '2026-09-19 13:10:00', 'urvashi.shukla@sahjanandtransport.co.in', 'mailbox/inbox/0040__20260919_1310.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0466/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0466', '2026-09-19 13:10:00', 'urvashi.shukla@sahjanandtransport.co.in', 'mailbox/inbox/0040__20260919_1310.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0466/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0466', '2026-09-19 13:10:00', 'urvashi.shukla@sahjanandtransport.co.in', 'mailbox/inbox/0040__20260919_1310.eml', 'GTA declaration FY.pdf', 'documents/VOR-26-0466/GTA declaration FY.pdf', '1', '3.3'),
('VOR-26-0466', '2026-09-19 13:10:00', 'urvashi.shukla@sahjanandtransport.co.in', 'mailbox/inbox/0040__20260919_1310.eml', 'MSME.pdf', 'documents/VOR-26-0466/MSME.pdf', '1', '3.3'),
('VOR-26-0466', '2026-09-19 13:10:00', 'urvashi.shukla@sahjanandtransport.co.in', 'mailbox/inbox/0040__20260919_1310.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0466/Vendor Registration Documents.pdf', '2', '4.3'),
('VOR-26-0461', '2026-09-19 14:34:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0041__20260919_1434.eml', 'Insurance.pdf', 'documents/VOR-26-0461/Insurance.pdf', '1', '2.9'),
('VOR-26-0467', '2026-09-20 17:56:00', 'meera.thakkar@keystoneispat.in', 'mailbox/inbox/0042__20260920_1756.eml', 'KI COI.pdf', 'documents/VOR-26-0467/KI COI.pdf', '1', '3.3'),
('VOR-26-0467', '2026-09-20 17:56:00', 'meera.thakkar@keystoneispat.in', 'mailbox/inbox/0042__20260920_1756.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0467/Vendor Registration Documents.pdf', '4', '8.6'),
('VOR-26-0461', '2026-09-21 17:08:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0044__20260921_1708.eml', 'GST Certificate.pdf', 'documents/VOR-26-0461/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0461', '2026-09-21 17:08:00', 'venkat.joshi@arihantfacilityser.in', 'mailbox/inbox/0044__20260921_1708.eml', 'PF Certificate.pdf', 'documents/VOR-26-0461/PF Certificate.pdf', '1', '2.6'),
('VOR-26-0469', '2026-09-21 19:35:00', 'manan.jadeja@bansitechnologies.co.in', 'mailbox/inbox/0045__20260921_1935.eml', 'CamScanner 21-09-2026 19.37.pdf', 'documents/VOR-26-0469/CamScanner 21-09-2026 19.37.pdf', '1', '58.7'),
('VOR-26-0469', '2026-09-21 19:35:00', 'manan.jadeja@bansitechnologies.co.in', 'mailbox/inbox/0045__20260921_1935.eml', 'CamScanner 21-09-2026 19.49.pdf', 'documents/VOR-26-0469/CamScanner 21-09-2026 19.49.pdf', '1', '21.6'),
('VOR-26-0469', '2026-09-21 19:35:00', 'manan.jadeja@bansitechnologies.co.in', 'mailbox/inbox/0045__20260921_1935.eml', 'IMG_20260921_119924.pdf', 'documents/VOR-26-0469/IMG_20260921_119924.pdf', '1', '47.1'),
('VOR-26-0469', '2026-09-21 19:35:00', 'manan.jadeja@bansitechnologies.co.in', 'mailbox/inbox/0045__20260921_1935.eml', 'Partnership deed copy.pdf', 'documents/VOR-26-0469/Partnership deed copy.pdf', '1', '3.5'),
('VOR-26-0473', '2026-09-22 11:42:00', 'arjun.rathod@girnarsafetysoluti.co.in', 'mailbox/inbox/0046__20260922_1142.eml', 'GSS COI.pdf', 'documents/VOR-26-0473/GSS COI.pdf', '1', '3.1'),
('VOR-26-0473', '2026-09-22 11:42:00', 'arjun.rathod@girnarsafetysoluti.co.in', 'mailbox/inbox/0046__20260922_1142.eml', 'GSS PAN.pdf', 'documents/VOR-26-0473/GSS PAN.pdf', '1', '2.5'),
('VOR-26-0473', '2026-09-22 11:42:00', 'arjun.rathod@girnarsafetysoluti.co.in', 'mailbox/inbox/0046__20260922_1142.eml', 'GST REG-06.pdf', 'documents/VOR-26-0473/GST REG-06.pdf', '1', '3.4'),
('VOR-26-0473', '2026-09-22 11:42:00', 'arjun.rathod@girnarsafetysoluti.co.in', 'mailbox/inbox/0046__20260922_1142.eml', 'ISO 9001.pdf', 'documents/VOR-26-0473/ISO 9001.pdf', '1', '3.0'),
('VOR-26-0473', '2026-09-22 11:42:00', 'arjun.rathod@girnarsafetysoluti.co.in', 'mailbox/inbox/0046__20260922_1142.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0473/Udyam Certificate.pdf', '1', '3.3'),
('VOR-26-0473', '2026-09-22 11:42:00', 'arjun.rathod@girnarsafetysoluti.co.in', 'mailbox/inbox/0046__20260922_1142.eml', 'cancel cheque.pdf', 'documents/VOR-26-0473/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0475', '2026-09-23 09:50:00', 'manan.reddy@jyotiguardingservi.co.in', 'mailbox/inbox/0047__20260923_0950.eml', 'Cheque.pdf', 'documents/VOR-26-0475/Cheque.pdf', '1', '2.4'),
('VOR-26-0475', '2026-09-23 09:50:00', 'manan.reddy@jyotiguardingservi.co.in', 'mailbox/inbox/0047__20260923_0950.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0475/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0475', '2026-09-23 09:50:00', 'manan.reddy@jyotiguardingservi.co.in', 'mailbox/inbox/0047__20260923_0950.eml', 'ESIC Certificate.pdf', 'documents/VOR-26-0475/ESIC Certificate.pdf', '1', '2.5'),
('VOR-26-0475', '2026-09-23 09:50:00', 'manan.reddy@jyotiguardingservi.co.in', 'mailbox/inbox/0047__20260923_0950.eml', 'Form 16 LLP.pdf', 'documents/VOR-26-0475/Form 16 LLP.pdf', '1', '3.2'),
('VOR-26-0475', '2026-09-23 09:50:00', 'manan.reddy@jyotiguardingservi.co.in', 'mailbox/inbox/0047__20260923_0950.eml', 'JGS PAN.pdf', 'documents/VOR-26-0475/JGS PAN.pdf', '1', '2.5'),
('VOR-26-0475', '2026-09-23 09:50:00', 'manan.reddy@jyotiguardingservi.co.in', 'mailbox/inbox/0047__20260923_0950.eml', 'Labour License.pdf', 'documents/VOR-26-0475/Labour License.pdf', '1', '3.8'),
('VOR-26-0475', '2026-09-23 09:50:00', 'manan.reddy@jyotiguardingservi.co.in', 'mailbox/inbox/0047__20260923_0950.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0475/Vendor Registration Documents.pdf', '2', '5.6'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'COI.pdf', 'documents/VOR-26-0472/COI.pdf', '1', '3.1');
insert into public."received_document" ("request_id", "received_at", "from_address", "mailbox_file", "attachment_name", "stored_path", "page_count", "size_kb") values
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'CamScanner 23-09-2026 15.45.pdf', 'documents/VOR-26-0472/CamScanner 23-09-2026 15.45.pdf', '1', '21.9'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'CamScanner 23-09-2026 18.04.pdf', 'documents/VOR-26-0472/CamScanner 23-09-2026 18.04.pdf', '1', '59.6'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'ESIC Certificate.pdf', 'documents/VOR-26-0472/ESIC Certificate.pdf', '1', '2.6'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'IMG_20260923_178980.pdf', 'documents/VOR-26-0472/IMG_20260923_178980.pdf', '1', '46.9'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'Labour License.pdf', 'documents/VOR-26-0472/Labour License.pdf', '1', '3.8'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0472/MSME Certificate.pdf', '1', '3.2'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'PF Certificate.pdf', 'documents/VOR-26-0472/PF Certificate.pdf', '1', '2.6'),
('VOR-26-0472', '2026-09-23 16:11:00', 'kinjal.parmar@shreeumiyafacility.co.in', 'mailbox/inbox/0048__20260923_1611.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0472/Policy Certificate.pdf', '1', '2.9'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0490/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'Cheque.pdf', 'documents/VOR-26-0490/Cheque.pdf', '1', '2.4'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'Company PAN.pdf', 'documents/VOR-26-0490/Company PAN.pdf', '1', '2.5'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'GST Registration.pdf', 'documents/VOR-26-0490/GST Registration.pdf', '1', '3.4'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'IMG_20260924_182510.pdf', 'documents/VOR-26-0490/IMG_20260924_182510.pdf', '1', '74.0'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0490/Incorporation Certificate.pdf', '1', '3.3'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0490/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'PF Registration.pdf', 'documents/VOR-26-0490/PF Registration.pdf', '1', '2.6'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'Renewal.pdf', 'documents/VOR-26-0490/Renewal.pdf', '1', '2.6'),
('VOR-26-0490', '2026-09-24 03:40:00', 'sneha.pandya@avadhhousekeepings.co.in', 'mailbox/inbox/0049__20260924_0340.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0490/Udyam Certificate.pdf', '1', '3.3'),
('VOR-26-0487', '2026-09-24 05:36:00', 'ishaan.bhatt@girnaradvisory.in', 'mailbox/inbox/0050__20260924_0536.eml', 'Documents.pdf', 'documents/VOR-26-0487/Documents.pdf', '4', '8.7'),
('VOR-26-0486', '2026-09-24 12:41:00', 'amit.shah@arihantelectricals.com', 'mailbox/inbox/0051__20260924_1241.eml', 'GST Certificate.pdf', 'documents/VOR-26-0486/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0486', '2026-09-24 12:41:00', 'amit.shah@arihantelectricals.com', 'mailbox/inbox/0051__20260924_1241.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0486/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0486', '2026-09-24 12:41:00', 'amit.shah@arihantelectricals.com', 'mailbox/inbox/0051__20260924_1241.eml', 'LLP Incorporation.pdf', 'documents/VOR-26-0486/LLP Incorporation.pdf', '1', '3.2'),
('VOR-26-0486', '2026-09-24 12:41:00', 'amit.shah@arihantelectricals.com', 'mailbox/inbox/0051__20260924_1241.eml', 'PAN Card.pdf', 'documents/VOR-26-0486/PAN Card.pdf', '1', '2.5'),
('VOR-26-0486', '2026-09-24 12:41:00', 'amit.shah@arihantelectricals.com', 'mailbox/inbox/0051__20260924_1241.eml', 'cancel cheque.pdf', 'documents/VOR-26-0486/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0483', '2026-09-24 13:00:00', 'riya.joshi@indussteel.co.in', 'mailbox/inbox/0052__20260924_1300.eml', 'Cheque.pdf', 'documents/VOR-26-0483/Cheque.pdf', '1', '2.4'),
('VOR-26-0483', '2026-09-24 13:00:00', 'riya.joshi@indussteel.co.in', 'mailbox/inbox/0052__20260924_1300.eml', 'GST Registration.pdf', 'documents/VOR-26-0483/GST Registration.pdf', '1', '3.5'),
('VOR-26-0483', '2026-09-24 13:00:00', 'riya.joshi@indussteel.co.in', 'mailbox/inbox/0052__20260924_1300.eml', 'IS COI.pdf', 'documents/VOR-26-0483/IS COI.pdf', '1', '3.1'),
('VOR-26-0483', '2026-09-24 13:00:00', 'riya.joshi@indussteel.co.in', 'mailbox/inbox/0052__20260924_1300.eml', 'PAN Card.pdf', 'documents/VOR-26-0483/PAN Card.pdf', '1', '2.5'),
('VOR-26-0483', '2026-09-24 13:00:00', 'riya.joshi@indussteel.co.in', 'mailbox/inbox/0052__20260924_1300.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0483/Udyam Registration.pdf', '1', '3.2'),
('VOR-26-0471', '2026-09-24 13:48:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0053__20260924_1348.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0471/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0471', '2026-09-24 13:48:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0053__20260924_1348.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0471/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0471', '2026-09-24 13:48:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0053__20260924_1348.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0471/Incorporation Certificate.pdf', '1', '3.3'),
('VOR-26-0471', '2026-09-24 13:48:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0053__20260924_1348.eml', 'Labour Licence.pdf', 'documents/VOR-26-0471/Labour Licence.pdf', '1', '3.8'),
('VOR-26-0471', '2026-09-24 13:48:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0053__20260924_1348.eml', 'PF Certificate.pdf', 'documents/VOR-26-0471/PF Certificate.pdf', '1', '2.6'),
('VOR-26-0471', '2026-09-24 13:48:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0053__20260924_1348.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0471/Udyam Registration.pdf', '1', '3.3'),
('VOR-26-0471', '2026-09-24 13:48:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0053__20260924_1348.eml', 'WC Policy.pdf', 'documents/VOR-26-0471/WC Policy.pdf', '1', '3.0'),
('VOR-26-0479', '2026-09-24 13:57:00', 'nisha.menon@neelkanthinfraproj.in', 'mailbox/inbox/0054__20260924_1357.eml', 'GST Certificate.pdf', 'documents/VOR-26-0479/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0479', '2026-09-24 13:57:00', 'nisha.menon@neelkanthinfraproj.in', 'mailbox/inbox/0054__20260924_1357.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0479/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0479', '2026-09-24 13:57:00', 'nisha.menon@neelkanthinfraproj.in', 'mailbox/inbox/0054__20260924_1357.eml', 'NI PAN.pdf', 'documents/VOR-26-0479/NI PAN.pdf', '1', '2.5'),
('VOR-26-0479', '2026-09-24 13:57:00', 'nisha.menon@neelkanthinfraproj.in', 'mailbox/inbox/0054__20260924_1357.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0479/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0479', '2026-09-24 13:57:00', 'nisha.menon@neelkanthinfraproj.in', 'mailbox/inbox/0054__20260924_1357.eml', 'cancelled chq.pdf', 'documents/VOR-26-0479/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0471', '2026-09-24 14:29:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0055__20260924_1429.eml', 'ESI Code.pdf', 'documents/VOR-26-0471/ESI Code.pdf', '1', '2.5'),
('VOR-26-0471', '2026-09-24 14:29:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0055__20260924_1429.eml', 'PAN Card.pdf', 'documents/VOR-26-0471/PAN Card.pdf', '1', '2.5'),
('VOR-26-0471', '2026-09-24 14:29:00', 'nirav.parmar@yamunasecurityserv.in', 'mailbox/inbox/0055__20260924_1429.eml', 'PSARA.pdf', 'documents/VOR-26-0471/PSARA.pdf', '1', '3.5'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0476/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'Company Profile.pdf', 'documents/VOR-26-0476/Company Profile.pdf', '1', '2.7'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'Deed extract.pdf', 'documents/VOR-26-0476/Deed extract.pdf', '1', '3.6'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'GST REG-06.pdf', 'documents/VOR-26-0476/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'Insurance.pdf', 'documents/VOR-26-0476/Insurance.pdf', '1', '2.9'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'Labour License.pdf', 'documents/VOR-26-0476/Labour License.pdf', '1', '3.8'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'MSME.pdf', 'documents/VOR-26-0476/MSME.pdf', '1', '3.3'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'PAN Card.pdf', 'documents/VOR-26-0476/PAN Card.pdf', '1', '2.5'),
('VOR-26-0476', '2026-09-24 19:37:00', 'mahesh.gill@radheworkforcesolu.co.in', 'mailbox/inbox/0057__20260924_1937.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0476/Vendor Registration Documents.pdf', '2', '3.8'),
('VOR-26-0493', '2026-09-24 22:50:00', 'simran.bhatt@sabarstonecrusher.in', 'mailbox/inbox/0058__20260924_2250.eml', 'CamScanner 24-09-2026 14.22.pdf', 'documents/VOR-26-0493/CamScanner 24-09-2026 14.22.pdf', '1', '37.1'),
('VOR-26-0493', '2026-09-24 22:50:00', 'simran.bhatt@sabarstonecrusher.in', 'mailbox/inbox/0058__20260924_2250.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0493/Certificate of Incorporation.pdf', '1', '3.1'),
('VOR-26-0493', '2026-09-24 22:50:00', 'simran.bhatt@sabarstonecrusher.in', 'mailbox/inbox/0058__20260924_2250.eml', 'Documents.pdf', 'documents/VOR-26-0493/Documents.pdf', '2', '4.7'),
('VOR-26-0494', '2026-09-25 10:02:00', 'mahesh.joshi@narmadaearthmovers.in', 'mailbox/inbox/0059__20260925_1002.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0494/GSTIN Certificate.pdf', '1', '3.3'),
('VOR-26-0494', '2026-09-25 10:02:00', 'mahesh.joshi@narmadaearthmovers.in', 'mailbox/inbox/0059__20260925_1002.eml', 'ISO 45001.pdf', 'documents/VOR-26-0494/ISO 45001.pdf', '1', '3.0'),
('VOR-26-0494', '2026-09-25 10:02:00', 'mahesh.joshi@narmadaearthmovers.in', 'mailbox/inbox/0059__20260925_1002.eml', 'Policy Certificate (2).pdf', 'documents/VOR-26-0494/Policy Certificate (2).pdf', '1', '3.0'),
('VOR-26-0494', '2026-09-25 10:02:00', 'mahesh.joshi@narmadaearthmovers.in', 'mailbox/inbox/0059__20260925_1002.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0494/Policy Certificate.pdf', '1', '3.0'),
('VOR-26-0494', '2026-09-25 10:02:00', 'mahesh.joshi@narmadaearthmovers.in', 'mailbox/inbox/0059__20260925_1002.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0494/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0494', '2026-09-25 10:02:00', 'mahesh.joshi@narmadaearthmovers.in', 'mailbox/inbox/0059__20260925_1002.eml', 'cancelled chq.pdf', 'documents/VOR-26-0494/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0494', '2026-09-25 10:02:00', 'mahesh.joshi@narmadaearthmovers.in', 'mailbox/inbox/0059__20260925_1002.eml', 'pan copy.pdf', 'documents/VOR-26-0494/pan copy.pdf', '1', '2.5'),
('VOR-26-0477', '2026-09-25 10:04:00', 'nirav.vyas@mahibuilders.in', 'mailbox/inbox/0060__20260925_1004.eml', 'GST Certificate.pdf', 'documents/VOR-26-0477/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0477', '2026-09-25 10:04:00', 'nirav.vyas@mahibuilders.in', 'mailbox/inbox/0060__20260925_1004.eml', 'IMG_20260925_094698.pdf', 'documents/VOR-26-0477/IMG_20260925_094698.pdf', '1', '46.5'),
('VOR-26-0477', '2026-09-25 10:04:00', 'nirav.vyas@mahibuilders.in', 'mailbox/inbox/0060__20260925_1004.eml', 'KYC Documents.pdf', 'documents/VOR-26-0477/KYC Documents.pdf', '3', '150.3'),
('VOR-26-0477', '2026-09-25 10:04:00', 'nirav.vyas@mahibuilders.in', 'mailbox/inbox/0060__20260925_1004.eml', 'cancelled chq.pdf', 'documents/VOR-26-0477/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0478', '2026-09-25 10:06:00', 'priyanka.bhatt@radhecement.co.in', 'mailbox/inbox/0061__20260925_1006.eml', 'KYC Documents.pdf', 'documents/VOR-26-0478/KYC Documents.pdf', '3', '7.1'),
('VOR-26-0478', '2026-09-25 10:06:00', 'priyanka.bhatt@radhecement.co.in', 'mailbox/inbox/0061__20260925_1006.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0478/MSME Certificate.pdf', '1', '3.2'),
('VOR-26-0478', '2026-09-25 10:06:00', 'priyanka.bhatt@radhecement.co.in', 'mailbox/inbox/0061__20260925_1006.eml', 'PAN Card.pdf', 'documents/VOR-26-0478/PAN Card.pdf', '1', '2.5'),
('VOR-26-0499', '2026-09-25 12:15:00', 'vivek.rao@lotuslabourcontrac.co.in', 'mailbox/inbox/0062__20260925_1215.eml', 'All documents.pdf', 'documents/VOR-26-0499/All documents.pdf', '4', '9.8'),
('VOR-26-0499', '2026-09-25 12:15:00', 'vivek.rao@lotuslabourcontrac.co.in', 'mailbox/inbox/0062__20260925_1215.eml', 'Cheque.pdf', 'documents/VOR-26-0499/Cheque.pdf', '1', '2.4'),
('VOR-26-0499', '2026-09-25 12:15:00', 'vivek.rao@lotuslabourcontrac.co.in', 'mailbox/inbox/0062__20260925_1215.eml', 'WC Policy.pdf', 'documents/VOR-26-0499/WC Policy.pdf', '1', '2.9'),
('VOR-26-0499', '2026-09-25 12:15:00', 'vivek.rao@lotuslabourcontrac.co.in', 'mailbox/inbox/0062__20260925_1215.eml', 'pan copy.pdf', 'documents/VOR-26-0499/pan copy.pdf', '1', '2.5'),
('VOR-26-0485', '2026-09-25 13:16:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0063__20260925_1316.eml', 'GST Certificate.pdf', 'documents/VOR-26-0485/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0485', '2026-09-25 13:16:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0063__20260925_1316.eml', 'HI PAN.pdf', 'documents/VOR-26-0485/HI PAN.pdf', '1', '2.5'),
('VOR-26-0485', '2026-09-25 13:16:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0063__20260925_1316.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0485/ISO Certificate.pdf', '1', '3.0'),
('VOR-26-0485', '2026-09-25 13:16:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0063__20260925_1316.eml', 'Insurance.pdf', 'documents/VOR-26-0485/Insurance.pdf', '1', '3.0'),
('VOR-26-0485', '2026-09-25 13:16:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0063__20260925_1316.eml', 'Partnership Deed.pdf', 'documents/VOR-26-0485/Partnership Deed.pdf', '1', '3.5'),
('VOR-26-0485', '2026-09-25 13:16:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0063__20260925_1316.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0485/Udyam Registration.pdf', '1', '3.2'),
('VOR-26-0485', '2026-09-25 13:16:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0063__20260925_1316.eml', 'cancel cheque.pdf', 'documents/VOR-26-0485/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0497', '2026-09-25 15:20:00', 'simran.pathan@keystoneswitchgear.in', 'mailbox/inbox/0064__20260925_1520.eml', 'Cheque.pdf', 'documents/VOR-26-0497/Cheque.pdf', '1', '2.4'),
('VOR-26-0497', '2026-09-25 15:20:00', 'simran.pathan@keystoneswitchgear.in', 'mailbox/inbox/0064__20260925_1520.eml', 'ISO 9001 2015.pdf', 'documents/VOR-26-0497/ISO 9001 2015.pdf', '1', '3.3'),
('VOR-26-0497', '2026-09-25 15:20:00', 'simran.pathan@keystoneswitchgear.in', 'mailbox/inbox/0064__20260925_1520.eml', 'KS GST.pdf', 'documents/VOR-26-0497/KS GST.pdf', '1', '3.5'),
('VOR-26-0497', '2026-09-25 15:20:00', 'simran.pathan@keystoneswitchgear.in', 'mailbox/inbox/0064__20260925_1520.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0497/Vendor Registration Documents.pdf', '2', '4.4'),
('VOR-26-0507', '2026-09-25 18:27:00', 'mitesh.pathan@bansiequipmenthire.com', 'mailbox/inbox/0065__20260925_1827.eml', 'Form 16 LLP.pdf', 'documents/VOR-26-0507/Form 16 LLP.pdf', '1', '3.1'),
('VOR-26-0507', '2026-09-25 18:27:00', 'mitesh.pathan@bansiequipmenthire.com', 'mailbox/inbox/0065__20260925_1827.eml', 'WC Policy.pdf', 'documents/VOR-26-0507/WC Policy.pdf', '1', '2.9'),
('VOR-26-0507', '2026-09-25 18:27:00', 'mitesh.pathan@bansiequipmenthire.com', 'mailbox/inbox/0065__20260925_1827.eml', 'cancel cheque.pdf', 'documents/VOR-26-0507/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0488', '2026-09-25 19:38:00', 'aarav.bhatt@bhumicarriers.in', 'mailbox/inbox/0066__20260925_1938.eml', 'BC PAN.pdf', 'documents/VOR-26-0488/BC PAN.pdf', '1', '2.5'),
('VOR-26-0488', '2026-09-25 19:38:00', 'aarav.bhatt@bhumicarriers.in', 'mailbox/inbox/0066__20260925_1938.eml', 'GST Certificate.pdf', 'documents/VOR-26-0488/GST Certificate.pdf', '1', '3.3'),
('VOR-26-0488', '2026-09-25 19:38:00', 'aarav.bhatt@bhumicarriers.in', 'mailbox/inbox/0066__20260925_1938.eml', 'GTA Declaration.pdf', 'documents/VOR-26-0488/GTA Declaration.pdf', '1', '3.3'),
('VOR-26-0488', '2026-09-25 19:38:00', 'aarav.bhatt@bhumicarriers.in', 'mailbox/inbox/0066__20260925_1938.eml', 'Shop Act.pdf', 'documents/VOR-26-0488/Shop Act.pdf', '1', '3.2'),
('VOR-26-0488', '2026-09-25 19:38:00', 'aarav.bhatt@bhumicarriers.in', 'mailbox/inbox/0066__20260925_1938.eml', 'cancel cheque.pdf', 'documents/VOR-26-0488/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0513', '2026-09-26 03:34:00', 'hetal.dsouza@shreeumiyacarriers.com', 'mailbox/inbox/0067__20260926_0334.eml', 'GST Certificate.pdf', 'documents/VOR-26-0513/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0513', '2026-09-26 03:34:00', 'hetal.dsouza@shreeumiyacarriers.com', 'mailbox/inbox/0067__20260926_0334.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0513/Vendor Registration Documents.pdf', '3', '7.0'),
('VOR-26-0513', '2026-09-26 03:34:00', 'hetal.dsouza@shreeumiyacarriers.com', 'mailbox/inbox/0067__20260926_0334.eml', 'pan copy.pdf', 'documents/VOR-26-0513/pan copy.pdf', '1', '2.5'),
('VOR-26-0495', '2026-09-26 06:20:00', 'hardik.kothari@kaveriearthmovers.in', 'mailbox/inbox/0068__20260926_0620.eml', 'Bank Letter.pdf', 'documents/VOR-26-0495/Bank Letter.pdf', '1', '3.3'),
('VOR-26-0495', '2026-09-26 06:20:00', 'hardik.kothari@kaveriearthmovers.in', 'mailbox/inbox/0068__20260926_0620.eml', 'COI.pdf', 'documents/VOR-26-0495/COI.pdf', '1', '3.4'),
('VOR-26-0495', '2026-09-26 06:20:00', 'hardik.kothari@kaveriearthmovers.in', 'mailbox/inbox/0068__20260926_0620.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0495/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0495', '2026-09-26 06:20:00', 'hardik.kothari@kaveriearthmovers.in', 'mailbox/inbox/0068__20260926_0620.eml', 'ISO 45001 2018.pdf', 'documents/VOR-26-0495/ISO 45001 2018.pdf', '1', '3.0'),
('VOR-26-0495', '2026-09-26 06:20:00', 'hardik.kothari@kaveriearthmovers.in', 'mailbox/inbox/0068__20260926_0620.eml', 'KE PAN.pdf', 'documents/VOR-26-0495/KE PAN.pdf', '1', '2.5'),
('VOR-26-0495', '2026-09-26 06:20:00', 'hardik.kothari@kaveriearthmovers.in', 'mailbox/inbox/0068__20260926_0620.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0495/Udyam Registration.pdf', '1', '3.2'),
('VOR-26-0495', '2026-09-26 06:20:00', 'hardik.kothari@kaveriearthmovers.in', 'mailbox/inbox/0068__20260926_0620.eml', 'WC Policy.pdf', 'documents/VOR-26-0495/WC Policy.pdf', '1', '3.0'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0500/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'ISO 45001 2018.pdf', 'documents/VOR-26-0500/ISO 45001 2018.pdf', '1', '3.1'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0500/Incorporation Certificate.pdf', '1', '3.3'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'Insurance.pdf', 'documents/VOR-26-0500/Insurance.pdf', '1', '3.0'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'Name Change Certificate.pdf', 'documents/VOR-26-0500/Name Change Certificate.pdf', '1', '3.1'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'PI GST.pdf', 'documents/VOR-26-0500/PI GST.pdf', '1', '3.5'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'PI PAN.pdf', 'documents/VOR-26-0500/PI PAN.pdf', '1', '2.5'),
('VOR-26-0500', '2026-09-26 09:43:00', 'ronak.kapadia@pragatiinfraprojec.in', 'mailbox/inbox/0069__20260926_0943.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0500/Udyam Certificate.pdf', '1', '3.3'),
('VOR-26-0507', '2026-09-26 11:49:00', 'mitesh.pathan@bansiequipmenthire.com', 'mailbox/inbox/0070__20260926_1149.eml', 'GST Certificate.pdf', 'documents/VOR-26-0507/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0507', '2026-09-26 11:49:00', 'mitesh.pathan@bansiequipmenthire.com', 'mailbox/inbox/0070__20260926_1149.eml', 'ISO 45001.pdf', 'documents/VOR-26-0507/ISO 45001.pdf', '1', '3.3'),
('VOR-26-0507', '2026-09-26 11:49:00', 'mitesh.pathan@bansiequipmenthire.com', 'mailbox/inbox/0070__20260926_1149.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0507/MSME Certificate.pdf', '1', '3.2'),
('VOR-26-0498', '2026-09-26 18:43:00', 'suresh.iyer@tapticoncrete.co.in', 'mailbox/inbox/0071__20260926_1843.eml', 'GST REG-06.pdf', 'documents/VOR-26-0498/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0498', '2026-09-26 18:43:00', 'suresh.iyer@tapticoncrete.co.in', 'mailbox/inbox/0071__20260926_1843.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0498/Incorporation Certificate.pdf', '1', '3.3'),
('VOR-26-0498', '2026-09-26 18:43:00', 'suresh.iyer@tapticoncrete.co.in', 'mailbox/inbox/0071__20260926_1843.eml', 'PAN Card.pdf', 'documents/VOR-26-0498/PAN Card.pdf', '1', '2.5'),
('VOR-26-0498', '2026-09-26 18:43:00', 'suresh.iyer@tapticoncrete.co.in', 'mailbox/inbox/0071__20260926_1843.eml', 'QMS Certificate.pdf', 'documents/VOR-26-0498/QMS Certificate.pdf', '1', '3.0'),
('VOR-26-0498', '2026-09-26 18:43:00', 'suresh.iyer@tapticoncrete.co.in', 'mailbox/inbox/0071__20260926_1843.eml', 'TC Profile.pdf', 'documents/VOR-26-0498/TC Profile.pdf', '1', '2.7'),
('VOR-26-0498', '2026-09-26 18:43:00', 'suresh.iyer@tapticoncrete.co.in', 'mailbox/inbox/0071__20260926_1843.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0498/Udyam Registration.pdf', '1', '3.3'),
('VOR-26-0498', '2026-09-26 18:43:00', 'suresh.iyer@tapticoncrete.co.in', 'mailbox/inbox/0071__20260926_1843.eml', 'cancel cheque.pdf', 'documents/VOR-26-0498/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0496', '2026-09-26 20:52:00', 'vivek.verma@vihaanbuildingmate.in', 'mailbox/inbox/0072__20260926_2052.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0496/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0496', '2026-09-26 20:52:00', 'vivek.verma@vihaanbuildingmate.in', 'mailbox/inbox/0072__20260926_2052.eml', 'GST REG-06.pdf', 'documents/VOR-26-0496/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0496', '2026-09-26 20:52:00', 'vivek.verma@vihaanbuildingmate.in', 'mailbox/inbox/0072__20260926_2052.eml', 'LLP Incorporation.pdf', 'documents/VOR-26-0496/LLP Incorporation.pdf', '1', '3.2'),
('VOR-26-0496', '2026-09-26 20:52:00', 'vivek.verma@vihaanbuildingmate.in', 'mailbox/inbox/0072__20260926_2052.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0496/Udyam Registration.pdf', '1', '3.3'),
('VOR-26-0496', '2026-09-26 20:52:00', 'vivek.verma@vihaanbuildingmate.in', 'mailbox/inbox/0072__20260926_2052.eml', 'VBM PAN.pdf', 'documents/VOR-26-0496/VBM PAN.pdf', '1', '2.5'),
('VOR-26-0509', '2026-09-27 16:38:00', 'rohit.bhatt@dharaaccesssystems.com', 'mailbox/inbox/0073__20260927_1638.eml', 'CamScanner 27-09-2026 13.40.pdf', 'documents/VOR-26-0509/CamScanner 27-09-2026 13.40.pdf', '1', '97.7'),
('VOR-26-0509', '2026-09-27 16:38:00', 'rohit.bhatt@dharaaccesssystems.com', 'mailbox/inbox/0073__20260927_1638.eml', 'Cheque.pdf', 'documents/VOR-26-0509/Cheque.pdf', '1', '2.4'),
('VOR-26-0509', '2026-09-27 16:38:00', 'rohit.bhatt@dharaaccesssystems.com', 'mailbox/inbox/0073__20260927_1638.eml', 'Gumasta.pdf', 'documents/VOR-26-0509/Gumasta.pdf', '1', '3.2'),
('VOR-26-0509', '2026-09-27 16:38:00', 'rohit.bhatt@dharaaccesssystems.com', 'mailbox/inbox/0073__20260927_1638.eml', 'MSME.pdf', 'documents/VOR-26-0509/MSME.pdf', '1', '3.2'),
('VOR-26-0509', '2026-09-27 16:38:00', 'rohit.bhatt@dharaaccesssystems.com', 'mailbox/inbox/0073__20260927_1638.eml', 'PAN Card.pdf', 'documents/VOR-26-0509/PAN Card.pdf', '1', '2.5'),
('VOR-26-0509', '2026-09-27 16:38:00', 'rohit.bhatt@dharaaccesssystems.com', 'mailbox/inbox/0073__20260927_1638.eml', 'WC Policy.pdf', 'documents/VOR-26-0509/WC Policy.pdf', '1', '2.9'),
('VOR-26-0509', '2026-09-27 16:38:00', 'rohit.bhatt@dharaaccesssystems.com', 'mailbox/inbox/0073__20260927_1638.eml', 'gst.pdf', 'documents/VOR-26-0509/gst.pdf', '1', '3.4'),
('VOR-26-0483', '2026-09-28 09:19:00', 'riya.joshi@indussteel.co.in', 'mailbox/inbox/0074__20260928_0919.eml', 'Bank Letter.pdf', 'documents/VOR-26-0483/Bank Letter.pdf', '1', '3.5'),
('VOR-26-0506', '2026-09-28 15:19:00', 'sagar.vaghela@jyotiindustrialsaf.com', 'mailbox/inbox/0075__20260928_1519.eml', 'Cheque.pdf', 'documents/VOR-26-0506/Cheque.pdf', '1', '2.4'),
('VOR-26-0506', '2026-09-28 15:19:00', 'sagar.vaghela@jyotiindustrialsaf.com', 'mailbox/inbox/0075__20260928_1519.eml', 'Company PAN.pdf', 'documents/VOR-26-0506/Company PAN.pdf', '1', '2.5'),
('VOR-26-0506', '2026-09-28 15:19:00', 'sagar.vaghela@jyotiindustrialsaf.com', 'mailbox/inbox/0075__20260928_1519.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0506/ISO Certificate.pdf', '1', '3.0'),
('VOR-26-0506', '2026-09-28 15:19:00', 'sagar.vaghela@jyotiindustrialsaf.com', 'mailbox/inbox/0075__20260928_1519.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0506/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0506', '2026-09-28 15:19:00', 'sagar.vaghela@jyotiindustrialsaf.com', 'mailbox/inbox/0075__20260928_1519.eml', 'gst.pdf', 'documents/VOR-26-0506/gst.pdf', '1', '3.4'),
('VOR-26-0516', '2026-09-28 17:32:00', 'ankit.jadeja@udayinfra.in', 'mailbox/inbox/0076__20260928_1732.eml', 'Cheque.pdf', 'documents/VOR-26-0516/Cheque.pdf', '1', '2.4'),
('VOR-26-0516', '2026-09-28 17:32:00', 'ankit.jadeja@udayinfra.in', 'mailbox/inbox/0076__20260928_1732.eml', 'Deed extract.pdf', 'documents/VOR-26-0516/Deed extract.pdf', '1', '3.5'),
('VOR-26-0516', '2026-09-28 17:32:00', 'ankit.jadeja@udayinfra.in', 'mailbox/inbox/0076__20260928_1732.eml', 'ISO 45001 2018.pdf', 'documents/VOR-26-0516/ISO 45001 2018.pdf', '1', '3.3'),
('VOR-26-0516', '2026-09-28 17:32:00', 'ankit.jadeja@udayinfra.in', 'mailbox/inbox/0076__20260928_1732.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0516/Policy Certificate.pdf', '1', '3.0'),
('VOR-26-0516', '2026-09-28 17:32:00', 'ankit.jadeja@udayinfra.in', 'mailbox/inbox/0076__20260928_1732.eml', 'UI PAN.pdf', 'documents/VOR-26-0516/UI PAN.pdf', '1', '2.4'),
('VOR-26-0516', '2026-09-28 17:32:00', 'ankit.jadeja@udayinfra.in', 'mailbox/inbox/0076__20260928_1732.eml', 'gst.pdf', 'documents/VOR-26-0516/gst.pdf', '1', '3.4'),
('VOR-26-0516', '2026-09-28 17:32:00', 'ankit.jadeja@udayinfra.in', 'mailbox/inbox/0076__20260928_1732.eml', 'scan_0052.pdf', 'documents/VOR-26-0516/scan_0052.pdf', '1', '51.2'),
('VOR-26-0503', '2026-09-28 19:26:00', 'mitesh.sheikh@rudraaccesssystems.in', 'mailbox/inbox/0077__20260928_1926.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0503/Certificate of Incorporation.pdf', '1', '3.2'),
('VOR-26-0503', '2026-09-28 19:26:00', 'mitesh.sheikh@rudraaccesssystems.in', 'mailbox/inbox/0077__20260928_1926.eml', 'ISO 45001.pdf', 'documents/VOR-26-0503/ISO 45001.pdf', '1', '3.0'),
('VOR-26-0503', '2026-09-28 19:26:00', 'mitesh.sheikh@rudraaccesssystems.in', 'mailbox/inbox/0077__20260928_1926.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0503/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0503', '2026-09-28 19:26:00', 'mitesh.sheikh@rudraaccesssystems.in', 'mailbox/inbox/0077__20260928_1926.eml', 'Name Change Certificate.pdf', 'documents/VOR-26-0503/Name Change Certificate.pdf', '1', '3.2'),
('VOR-26-0503', '2026-09-28 19:26:00', 'mitesh.sheikh@rudraaccesssystems.in', 'mailbox/inbox/0077__20260928_1926.eml', 'RAS GST.pdf', 'documents/VOR-26-0503/RAS GST.pdf', '1', '3.5'),
('VOR-26-0503', '2026-09-28 19:26:00', 'mitesh.sheikh@rudraaccesssystems.in', 'mailbox/inbox/0077__20260928_1926.eml', 'cancel cheque.pdf', 'documents/VOR-26-0503/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0503', '2026-09-28 19:26:00', 'mitesh.sheikh@rudraaccesssystems.in', 'mailbox/inbox/0077__20260928_1926.eml', 'pan copy.pdf', 'documents/VOR-26-0503/pan copy.pdf', '1', '2.5'),
('VOR-26-0508', '2026-09-28 20:15:00', 'rutvik.sharma@gokullabourcontrac.in', 'mailbox/inbox/0078__20260928_2015.eml', 'GLC KYC.pdf', 'documents/VOR-26-0508/GLC KYC.pdf', '3', '7.1'),
('VOR-26-0508', '2026-09-28 20:15:00', 'rutvik.sharma@gokullabourcontrac.in', 'mailbox/inbox/0078__20260928_2015.eml', 'GST Certificate.pdf', 'documents/VOR-26-0508/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0508', '2026-09-28 20:15:00', 'rutvik.sharma@gokullabourcontrac.in', 'mailbox/inbox/0078__20260928_2015.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0508/Incorporation Certificate.pdf', '1', '3.2'),
('VOR-26-0521', '2026-09-28 21:13:00', 'zoya.sharma@sabarconsultants.in', 'mailbox/inbox/0079__20260928_2113.eml', 'Bank Details.pdf', 'documents/VOR-26-0521/Bank Details.pdf', '1', '2.7'),
('VOR-26-0521', '2026-09-28 21:13:00', 'zoya.sharma@sabarconsultants.in', 'mailbox/inbox/0079__20260928_2113.eml', 'LLP Certificate.pdf', 'documents/VOR-26-0521/LLP Certificate.pdf', '1', '3.1'),
('VOR-26-0521', '2026-09-28 21:13:00', 'zoya.sharma@sabarconsultants.in', 'mailbox/inbox/0079__20260928_2113.eml', 'PAN Card.pdf', 'documents/VOR-26-0521/PAN Card.pdf', '1', '2.5'),
('VOR-26-0521', '2026-09-28 21:13:00', 'zoya.sharma@sabarconsultants.in', 'mailbox/inbox/0079__20260928_2113.eml', 'gst.pdf', 'documents/VOR-26-0521/gst.pdf', '1', '3.5'),
('VOR-26-0512', '2026-09-28 22:58:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0080__20260928_2258.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0512/ESIC Registration.pdf', '1', '2.5'),
('VOR-26-0512', '2026-09-28 22:58:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0080__20260928_2258.eml', 'Insurance.pdf', 'documents/VOR-26-0512/Insurance.pdf', '1', '3.0'),
('VOR-26-0512', '2026-09-28 22:58:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0080__20260928_2258.eml', 'KYC Documents.pdf', 'documents/VOR-26-0512/KYC Documents.pdf', '3', '6.2'),
('VOR-26-0512', '2026-09-28 22:58:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0080__20260928_2258.eml', 'LLP Incorporation.pdf', 'documents/VOR-26-0512/LLP Incorporation.pdf', '1', '3.1'),
('VOR-26-0512', '2026-09-28 22:58:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0080__20260928_2258.eml', 'PF Certificate.pdf', 'documents/VOR-26-0512/PF Certificate.pdf', '1', '2.6'),
('VOR-26-0512', '2026-09-28 22:58:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0080__20260928_2258.eml', 'PSARA.pdf', 'documents/VOR-26-0512/PSARA.pdf', '1', '3.5'),
('VOR-26-0522', '2026-09-29 13:47:00', 'vivek.reddy@deccanindustrialsa.co.in', 'mailbox/inbox/0081__20260929_1347.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0522/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0522', '2026-09-29 13:47:00', 'vivek.reddy@deccanindustrialsa.co.in', 'mailbox/inbox/0081__20260929_1347.eml', 'GST Registration.pdf', 'documents/VOR-26-0522/GST Registration.pdf', '1', '3.5'),
('VOR-26-0522', '2026-09-29 13:47:00', 'vivek.reddy@deccanindustrialsa.co.in', 'mailbox/inbox/0081__20260929_1347.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0522/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0522', '2026-09-29 13:47:00', 'vivek.reddy@deccanindustrialsa.co.in', 'mailbox/inbox/0081__20260929_1347.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0522/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0522', '2026-09-29 13:47:00', 'vivek.reddy@deccanindustrialsa.co.in', 'mailbox/inbox/0081__20260929_1347.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0522/Incorporation Certificate.pdf', '1', '3.1'),
('VOR-26-0522', '2026-09-29 13:47:00', 'vivek.reddy@deccanindustrialsa.co.in', 'mailbox/inbox/0081__20260929_1347.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0522/MSME Certificate.pdf', '1', '3.3'),
('VOR-26-0522', '2026-09-29 13:47:00', 'vivek.reddy@deccanindustrialsa.co.in', 'mailbox/inbox/0081__20260929_1347.eml', 'PAN.pdf', 'documents/VOR-26-0522/PAN.pdf', '1', '2.5'),
('VOR-26-0479', '2026-09-29 15:39:00', 'nisha.menon@neelkanthinfraproj.in', 'mailbox/inbox/0083__20260929_1539.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0479/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0525', '2026-09-29 18:38:00', 'yamunalogistic76@gmail.com', 'mailbox/inbox/0084__20260929_1838.eml', 'Documents.pdf', 'documents/VOR-26-0525/Documents.pdf', '2', '5.2'),
('VOR-26-0525', '2026-09-29 18:38:00', 'yamunalogistic76@gmail.com', 'mailbox/inbox/0084__20260929_1838.eml', 'PAN.pdf', 'documents/VOR-26-0525/PAN.pdf', '1', '2.5'),
('VOR-26-0525', '2026-09-29 18:38:00', 'yamunalogistic76@gmail.com', 'mailbox/inbox/0084__20260929_1838.eml', 'Shop Act.pdf', 'documents/VOR-26-0525/Shop Act.pdf', '1', '3.1'),
('VOR-26-0525', '2026-09-29 18:38:00', 'yamunalogistic76@gmail.com', 'mailbox/inbox/0084__20260929_1838.eml', 'cancel cheque.pdf', 'documents/VOR-26-0525/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0518', '2026-09-30 02:14:00', 'urvashi.pandya@prayagqualitylabs.co.in', 'mailbox/inbox/0085__20260930_0214.eml', 'Cheque.pdf', 'documents/VOR-26-0518/Cheque.pdf', '1', '2.4'),
('VOR-26-0518', '2026-09-30 02:14:00', 'urvashi.pandya@prayagqualitylabs.co.in', 'mailbox/inbox/0085__20260930_0214.eml', 'GST Certificate.pdf', 'documents/VOR-26-0518/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0518', '2026-09-30 02:14:00', 'urvashi.pandya@prayagqualitylabs.co.in', 'mailbox/inbox/0085__20260930_0214.eml', 'Gumasta.pdf', 'documents/VOR-26-0518/Gumasta.pdf', '1', '3.1'),
('VOR-26-0518', '2026-09-30 02:14:00', 'urvashi.pandya@prayagqualitylabs.co.in', 'mailbox/inbox/0085__20260930_0214.eml', 'MSME.pdf', 'documents/VOR-26-0518/MSME.pdf', '1', '3.2'),
('VOR-26-0518', '2026-09-30 02:14:00', 'urvashi.pandya@prayagqualitylabs.co.in', 'mailbox/inbox/0085__20260930_0214.eml', 'NABL Certificate.pdf', 'documents/VOR-26-0518/NABL Certificate.pdf', '1', '3.2'),
('VOR-26-0518', '2026-09-30 02:14:00', 'urvashi.pandya@prayagqualitylabs.co.in', 'mailbox/inbox/0085__20260930_0214.eml', 'PAN Card.pdf', 'documents/VOR-26-0518/PAN Card.pdf', '1', '2.5'),
('VOR-26-0518', '2026-09-30 02:14:00', 'urvashi.pandya@prayagqualitylabs.co.in', 'mailbox/inbox/0085__20260930_0214.eml', 'Renewal.pdf', 'documents/VOR-26-0518/Renewal.pdf', '1', '2.5'),
('VOR-26-0517', '2026-09-30 09:49:00', 'sneha.menon@parshvaroadlines.co.in', 'mailbox/inbox/0086__20260930_0949.eml', 'GTA Declaration.pdf', 'documents/VOR-26-0517/GTA Declaration.pdf', '1', '3.4'),
('VOR-26-0517', '2026-09-30 09:49:00', 'sneha.menon@parshvaroadlines.co.in', 'mailbox/inbox/0086__20260930_0949.eml', 'PR PAN.pdf', 'documents/VOR-26-0517/PR PAN.pdf', '1', '2.5'),
('VOR-26-0517', '2026-09-30 09:49:00', 'sneha.menon@parshvaroadlines.co.in', 'mailbox/inbox/0086__20260930_0949.eml', 'gst.pdf', 'documents/VOR-26-0517/gst.pdf', '1', '3.5'),
('VOR-26-0533', '2026-09-30 11:17:00', 'kruti.gill@orbitsafetysolutio.in', 'mailbox/inbox/0087__20260930_1117.eml', 'COI.pdf', 'documents/VOR-26-0533/COI.pdf', '1', '3.2'),
('VOR-26-0533', '2026-09-30 11:17:00', 'kruti.gill@orbitsafetysolutio.in', 'mailbox/inbox/0087__20260930_1117.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0533/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0533', '2026-09-30 11:17:00', 'kruti.gill@orbitsafetysolutio.in', 'mailbox/inbox/0087__20260930_1117.eml', 'GST Certificate.pdf', 'documents/VOR-26-0533/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0533', '2026-09-30 11:17:00', 'kruti.gill@orbitsafetysolutio.in', 'mailbox/inbox/0087__20260930_1117.eml', 'GST REG-06.pdf', 'documents/VOR-26-0533/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0533', '2026-09-30 11:17:00', 'kruti.gill@orbitsafetysolutio.in', 'mailbox/inbox/0087__20260930_1117.eml', 'ISO 9001 2015.pdf', 'documents/VOR-26-0533/ISO 9001 2015.pdf', '1', '3.2'),
('VOR-26-0533', '2026-09-30 11:17:00', 'kruti.gill@orbitsafetysolutio.in', 'mailbox/inbox/0087__20260930_1117.eml', 'PAN Card.pdf', 'documents/VOR-26-0533/PAN Card.pdf', '1', '2.5'),
('VOR-26-0528', '2026-09-30 12:14:00', 'sana.trivedi@darshanaccesssyste.in', 'mailbox/inbox/0088__20260930_1214.eml', 'DAS COI.pdf', 'documents/VOR-26-0528/DAS COI.pdf', '1', '3.1'),
('VOR-26-0528', '2026-09-30 12:14:00', 'sana.trivedi@darshanaccesssyste.in', 'mailbox/inbox/0088__20260930_1214.eml', 'GST Certificate.pdf', 'documents/VOR-26-0528/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0528', '2026-09-30 12:14:00', 'sana.trivedi@darshanaccesssyste.in', 'mailbox/inbox/0088__20260930_1214.eml', 'ISO 45001 2018.pdf', 'documents/VOR-26-0528/ISO 45001 2018.pdf', '1', '3.0'),
('VOR-26-0528', '2026-09-30 12:14:00', 'sana.trivedi@darshanaccesssyste.in', 'mailbox/inbox/0088__20260930_1214.eml', 'PAN Card.pdf', 'documents/VOR-26-0528/PAN Card.pdf', '1', '2.5'),
('VOR-26-0528', '2026-09-30 12:14:00', 'sana.trivedi@darshanaccesssyste.in', 'mailbox/inbox/0088__20260930_1214.eml', 'WC Policy.pdf', 'documents/VOR-26-0528/WC Policy.pdf', '1', '3.0'),
('VOR-26-0528', '2026-09-30 12:14:00', 'sana.trivedi@darshanaccesssyste.in', 'mailbox/inbox/0088__20260930_1214.eml', 'cancelled chq.pdf', 'documents/VOR-26-0528/cancelled chq.pdf', '1', '2.4');
insert into public."received_document" ("request_id", "received_at", "from_address", "mailbox_file", "attachment_name", "stored_path", "page_count", "size_kb") values
('VOR-26-0508', '2026-09-30 17:51:00', 'rutvik.sharma@gokullabourcontrac.in', 'mailbox/inbox/0090__20260930_1751.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0508/Cancelled_Cheque.pdf', '1', '2.5'),
('VOR-26-0508', '2026-09-30 17:51:00', 'rutvik.sharma@gokullabourcontrac.in', 'mailbox/inbox/0090__20260930_1751.eml', 'PF Registration.pdf', 'documents/VOR-26-0508/PF Registration.pdf', '1', '2.6'),
('VOR-26-0526', '2026-09-30 21:51:00', 'krunal.parikh@shivammaintenances.co.in', 'mailbox/inbox/0091__20260930_2151.eml', 'Cheque.pdf', 'documents/VOR-26-0526/Cheque.pdf', '1', '2.4'),
('VOR-26-0526', '2026-09-30 21:51:00', 'krunal.parikh@shivammaintenances.co.in', 'mailbox/inbox/0091__20260930_2151.eml', 'IMG_20260930_126313.pdf', 'documents/VOR-26-0526/IMG_20260930_126313.pdf', '1', '12.9'),
('VOR-26-0526', '2026-09-30 21:51:00', 'krunal.parikh@shivammaintenances.co.in', 'mailbox/inbox/0091__20260930_2151.eml', 'SMS PAN.pdf', 'documents/VOR-26-0526/SMS PAN.pdf', '1', '2.5'),
('VOR-26-0526', '2026-09-30 21:51:00', 'krunal.parikh@shivammaintenances.co.in', 'mailbox/inbox/0091__20260930_2151.eml', 'Shop Act.pdf', 'documents/VOR-26-0526/Shop Act.pdf', '1', '3.1'),
('VOR-26-0485', '2026-09-30 21:52:00', 'ronak.reddy@harsiddhiinfra.com', 'mailbox/inbox/0092__20260930_2152.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0485/Policy Certificate.pdf', '1', '3.0'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0529/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0529/ESIC Registration.pdf', '1', '2.5'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'Labour Licence.pdf', 'documents/VOR-26-0529/Labour Licence.pdf', '1', '3.7'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0529/MSME Certificate.pdf', '1', '3.2'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'PF Registration.pdf', 'documents/VOR-26-0529/PF Registration.pdf', '1', '2.6'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'Partnership Deed.pdf', 'documents/VOR-26-0529/Partnership Deed.pdf', '1', '3.5'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0529/Policy Certificate.pdf', '1', '2.9'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'gst.pdf', 'documents/VOR-26-0529/gst.pdf', '1', '3.5'),
('VOR-26-0529', '2026-09-30 22:35:00', 'dhaval.brahmbhatt@anandguardingservi.in', 'mailbox/inbox/0093__20260930_2235.eml', 'pan copy.pdf', 'documents/VOR-26-0529/pan copy.pdf', '1', '2.5'),
('VOR-26-0507', '2026-09-30 23:05:00', 'mitesh.pathan@bansiequipmenthire.com', 'mailbox/inbox/0094__20260930_2305.eml', 'PAN.pdf', 'documents/VOR-26-0507/PAN.pdf', '1', '2.5'),
('VOR-26-0535', '2026-10-01 09:17:00', 'foram.singh@mahalaxmiroadlines.in', 'mailbox/inbox/0095__20261001_0917.eml', 'Annexure V.pdf', 'documents/VOR-26-0535/Annexure V.pdf', '1', '3.3'),
('VOR-26-0535', '2026-10-01 09:17:00', 'foram.singh@mahalaxmiroadlines.in', 'mailbox/inbox/0095__20261001_0917.eml', 'Cheque.pdf', 'documents/VOR-26-0535/Cheque.pdf', '1', '2.4'),
('VOR-26-0535', '2026-10-01 09:17:00', 'foram.singh@mahalaxmiroadlines.in', 'mailbox/inbox/0095__20261001_0917.eml', 'Company PAN.pdf', 'documents/VOR-26-0535/Company PAN.pdf', '1', '2.5'),
('VOR-26-0535', '2026-10-01 09:17:00', 'foram.singh@mahalaxmiroadlines.in', 'mailbox/inbox/0095__20261001_0917.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0535/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0535', '2026-10-01 09:17:00', 'foram.singh@mahalaxmiroadlines.in', 'mailbox/inbox/0095__20261001_0917.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0535/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0514', '2026-10-01 11:15:00', 'kavya.dsouza@ashvakagroup.in', 'mailbox/inbox/0096__20261001_1115.eml', 'All documents.pdf', 'documents/VOR-26-0514/All documents.pdf', '3', '6.1'),
('VOR-26-0514', '2026-10-01 11:15:00', 'kavya.dsouza@ashvakagroup.in', 'mailbox/inbox/0096__20261001_1115.eml', 'Partnership deed copy.pdf', 'documents/VOR-26-0514/Partnership deed copy.pdf', '1', '3.5'),
('VOR-26-0515', '2026-10-01 14:13:00', 'rohit.brahmbhatt@pinnacledigitalser.in', 'mailbox/inbox/0097__20261001_1413.eml', 'All documents.pdf', 'documents/VOR-26-0515/All documents.pdf', '4', '8.5'),
('VOR-26-0520', '2026-10-01 15:07:00', 'mitesh.reddy@riddhiroadways.co.in', 'mailbox/inbox/0098__20261001_1507.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0520/Certificate of Incorporation.pdf', '1', '3.3'),
('VOR-26-0520', '2026-10-01 15:07:00', 'mitesh.reddy@riddhiroadways.co.in', 'mailbox/inbox/0098__20261001_1507.eml', 'Company PAN.pdf', 'documents/VOR-26-0520/Company PAN.pdf', '1', '2.5'),
('VOR-26-0520', '2026-10-01 15:07:00', 'mitesh.reddy@riddhiroadways.co.in', 'mailbox/inbox/0098__20261001_1507.eml', 'GST Certificate.pdf', 'documents/VOR-26-0520/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0520', '2026-10-01 15:07:00', 'mitesh.reddy@riddhiroadways.co.in', 'mailbox/inbox/0098__20261001_1507.eml', 'GTA Declaration.pdf', 'documents/VOR-26-0520/GTA Declaration.pdf', '1', '3.3'),
('VOR-26-0520', '2026-10-01 15:07:00', 'mitesh.reddy@riddhiroadways.co.in', 'mailbox/inbox/0098__20261001_1507.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0520/Udyam Certificate.pdf', '1', '3.2'),
('VOR-26-0520', '2026-10-01 15:07:00', 'mitesh.reddy@riddhiroadways.co.in', 'mailbox/inbox/0098__20261001_1507.eml', 'cancel cheque.pdf', 'documents/VOR-26-0520/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0532', '2026-10-01 19:00:00', 'imran.shukla@vishwakarmatechnol.com', 'mailbox/inbox/0099__20261001_1900.eml', 'Company PAN.pdf', 'documents/VOR-26-0532/Company PAN.pdf', '1', '2.5'),
('VOR-26-0532', '2026-10-01 19:00:00', 'imran.shukla@vishwakarmatechnol.com', 'mailbox/inbox/0099__20261001_1900.eml', 'GST REG-06.pdf', 'documents/VOR-26-0532/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0532', '2026-10-01 19:00:00', 'imran.shukla@vishwakarmatechnol.com', 'mailbox/inbox/0099__20261001_1900.eml', 'VT COI.pdf', 'documents/VOR-26-0532/VT COI.pdf', '1', '3.1'),
('VOR-26-0532', '2026-10-01 19:00:00', 'imran.shukla@vishwakarmatechnol.com', 'mailbox/inbox/0099__20261001_1900.eml', 'cancel cheque.pdf', 'documents/VOR-26-0532/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'COI.pdf', 'documents/VOR-26-0539/COI.pdf', '1', '3.1'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0539/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'ESIC Certificate.pdf', 'documents/VOR-26-0539/ESIC Certificate.pdf', '1', '2.5'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'GST Certificate.pdf', 'documents/VOR-26-0539/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'KPF PAN.pdf', 'documents/VOR-26-0539/KPF PAN.pdf', '1', '2.5'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'Labour License.pdf', 'documents/VOR-26-0539/Labour License.pdf', '1', '3.9'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'PSARA Licence.pdf', 'documents/VOR-26-0539/PSARA Licence.pdf', '1', '3.5'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0539/Policy Certificate.pdf', '1', '3.0'),
('VOR-26-0539', '2026-10-01 20:54:00', 'aakash.panchal@keystoneprotection.in', 'mailbox/inbox/0100__20261001_2054.eml', 'scan_0059.pdf', 'documents/VOR-26-0539/scan_0059.pdf', '1', '6.9'),
('VOR-26-0512', '2026-10-01 21:16:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0101__20261001_2116.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0512/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0512', '2026-10-01 21:16:00', 'nisha.sanghvi@narmadaguardingser.co.in', 'mailbox/inbox/0101__20261001_2116.eml', 'scan_0049.pdf', 'documents/VOR-26-0512/scan_0049.pdf', '1', '13.5'),
('VOR-26-0557', '2026-10-01 22:27:00', 'amit.kapadia@horizonbuilders.co.in', 'mailbox/inbox/0102__20261001_2227.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0557/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0557', '2026-10-01 22:27:00', 'amit.kapadia@horizonbuilders.co.in', 'mailbox/inbox/0102__20261001_2227.eml', 'HB KYC.pdf', 'documents/VOR-26-0557/HB KYC.pdf', '4', '9.0'),
('VOR-26-0557', '2026-10-01 22:27:00', 'amit.kapadia@horizonbuilders.co.in', 'mailbox/inbox/0102__20261001_2227.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0557/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0543', '2026-10-02 09:19:00', 'sneha.rathod@eshanconstruction.in', 'mailbox/inbox/0103__20261002_0919.eml', 'EC COI.pdf', 'documents/VOR-26-0543/EC COI.pdf', '1', '3.4'),
('VOR-26-0543', '2026-10-02 09:19:00', 'sneha.rathod@eshanconstruction.in', 'mailbox/inbox/0103__20261002_0919.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0543/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0543', '2026-10-02 09:19:00', 'sneha.rathod@eshanconstruction.in', 'mailbox/inbox/0103__20261002_0919.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0543/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0543', '2026-10-02 09:19:00', 'sneha.rathod@eshanconstruction.in', 'mailbox/inbox/0103__20261002_0919.eml', 'PAN.pdf', 'documents/VOR-26-0543/PAN.pdf', '1', '2.5'),
('VOR-26-0543', '2026-10-02 09:19:00', 'sneha.rathod@eshanconstruction.in', 'mailbox/inbox/0103__20261002_0919.eml', 'gst.pdf', 'documents/VOR-26-0543/gst.pdf', '1', '3.4'),
('VOR-26-0543', '2026-10-02 09:19:00', 'sneha.rathod@eshanconstruction.in', 'mailbox/inbox/0103__20261002_0919.eml', 'scan_0064.pdf', 'documents/VOR-26-0543/scan_0064.pdf', '1', '38.0'),
('VOR-26-0544', '2026-10-02 10:28:00', 'pooja.vaghela@chitraconsultants.co.in', 'mailbox/inbox/0104__20261002_1028.eml', 'KYC Documents.pdf', 'documents/VOR-26-0544/KYC Documents.pdf', '4', '8.4'),
('VOR-26-0554', '2026-10-02 10:38:00', 'riya.bhatt@unnatiformworksyst.in', 'mailbox/inbox/0105__20261002_1038.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0554/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0554', '2026-10-02 10:38:00', 'riya.bhatt@unnatiformworksyst.in', 'mailbox/inbox/0105__20261002_1038.eml', 'GST Certificate.pdf', 'documents/VOR-26-0554/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0554', '2026-10-02 10:38:00', 'riya.bhatt@unnatiformworksyst.in', 'mailbox/inbox/0105__20261002_1038.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0554/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0554', '2026-10-02 10:38:00', 'riya.bhatt@unnatiformworksyst.in', 'mailbox/inbox/0105__20261002_1038.eml', 'KYC Documents.pdf', 'documents/VOR-26-0554/KYC Documents.pdf', '2', '5.2'),
('VOR-26-0554', '2026-10-02 10:38:00', 'riya.bhatt@unnatiformworksyst.in', 'mailbox/inbox/0105__20261002_1038.eml', 'PAN.pdf', 'documents/VOR-26-0554/PAN.pdf', '1', '2.5'),
('VOR-26-0541', '2026-10-02 16:25:00', 'neha.panchal@rudraconcrete.co.in', 'mailbox/inbox/0106__20261002_1625.eml', 'Company PAN.pdf', 'documents/VOR-26-0541/Company PAN.pdf', '1', '2.5'),
('VOR-26-0541', '2026-10-02 16:25:00', 'neha.panchal@rudraconcrete.co.in', 'mailbox/inbox/0106__20261002_1625.eml', 'QMS Certificate.pdf', 'documents/VOR-26-0541/QMS Certificate.pdf', '1', '3.3'),
('VOR-26-0541', '2026-10-02 16:25:00', 'neha.panchal@rudraconcrete.co.in', 'mailbox/inbox/0106__20261002_1625.eml', 'RC COI.pdf', 'documents/VOR-26-0541/RC COI.pdf', '1', '3.1'),
('VOR-26-0541', '2026-10-02 16:25:00', 'neha.panchal@rudraconcrete.co.in', 'mailbox/inbox/0106__20261002_1625.eml', 'cancel cheque.pdf', 'documents/VOR-26-0541/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0541', '2026-10-02 16:25:00', 'neha.panchal@rudraconcrete.co.in', 'mailbox/inbox/0106__20261002_1625.eml', 'gst.pdf', 'documents/VOR-26-0541/gst.pdf', '1', '3.5'),
('VOR-26-0536', '2026-10-02 20:54:00', 'parth.pathan@orbitearthmovers.in', 'mailbox/inbox/0108__20261002_2054.eml', 'All documents.pdf', 'documents/VOR-26-0536/All documents.pdf', '2', '4.1'),
('VOR-26-0536', '2026-10-02 20:54:00', 'parth.pathan@orbitearthmovers.in', 'mailbox/inbox/0108__20261002_2054.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0536/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0536', '2026-10-02 20:54:00', 'parth.pathan@orbitearthmovers.in', 'mailbox/inbox/0108__20261002_2054.eml', 'OE COI.pdf', 'documents/VOR-26-0536/OE COI.pdf', '1', '3.1'),
('VOR-26-0536', '2026-10-02 20:54:00', 'parth.pathan@orbitearthmovers.in', 'mailbox/inbox/0108__20261002_2054.eml', 'OHSMS Certificate.pdf', 'documents/VOR-26-0536/OHSMS Certificate.pdf', '1', '3.1'),
('VOR-26-0536', '2026-10-02 20:54:00', 'parth.pathan@orbitearthmovers.in', 'mailbox/inbox/0108__20261002_2054.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0536/Udyam Certificate.pdf', '1', '3.3'),
('VOR-26-0536', '2026-10-02 20:54:00', 'parth.pathan@orbitearthmovers.in', 'mailbox/inbox/0108__20261002_2054.eml', 'scan_0053.pdf', 'documents/VOR-26-0536/scan_0053.pdf', '1', '37.5'),
('VOR-26-0558', '2026-10-03 00:03:00', 'aakash.oza@vishwakarmamanpowe.co.in', 'mailbox/inbox/0109__20261003_0003.eml', 'All documents.pdf', 'documents/VOR-26-0558/All documents.pdf', '3', '5.7'),
('VOR-26-0558', '2026-10-03 00:03:00', 'aakash.oza@vishwakarmamanpowe.co.in', 'mailbox/inbox/0109__20261003_0003.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0558/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0558', '2026-10-03 00:03:00', 'aakash.oza@vishwakarmamanpowe.co.in', 'mailbox/inbox/0109__20261003_0003.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0558/MSME Certificate.pdf', '1', '3.3'),
('VOR-26-0558', '2026-10-03 00:03:00', 'aakash.oza@vishwakarmamanpowe.co.in', 'mailbox/inbox/0109__20261003_0003.eml', 'Partnership deed copy.pdf', 'documents/VOR-26-0558/Partnership deed copy.pdf', '1', '3.6'),
('VOR-26-0558', '2026-10-03 00:03:00', 'aakash.oza@vishwakarmamanpowe.co.in', 'mailbox/inbox/0109__20261003_0003.eml', 'gst.pdf', 'documents/VOR-26-0558/gst.pdf', '1', '3.4'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'Application Receipt.pdf', 'documents/VOR-26-0549/Application Receipt.pdf', '1', '2.5'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0549/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0549/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0549/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0549/ESIC Registration.pdf', '1', '2.5'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'GST Registration.pdf', 'documents/VOR-26-0549/GST Registration.pdf', '1', '3.4'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'Insurance.pdf', 'documents/VOR-26-0549/Insurance.pdf', '1', '3.0'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'KGS COI.pdf', 'documents/VOR-26-0549/KGS COI.pdf', '1', '3.1'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'MSME.pdf', 'documents/VOR-26-0549/MSME.pdf', '1', '3.3'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'PSARA.pdf', 'documents/VOR-26-0549/PSARA.pdf', '1', '3.5'),
('VOR-26-0549', '2026-10-03 07:43:00', 'gurpreet.reddy@kesarguardingservi.com', 'mailbox/inbox/0110__20261003_0743.eml', 'pan copy.pdf', 'documents/VOR-26-0549/pan copy.pdf', '1', '2.5'),
('VOR-26-0538', '2026-10-03 10:26:00', 'imran.chauhan@chitralogistics.com', 'mailbox/inbox/0111__20261003_1026.eml', 'Annexure V.pdf', 'documents/VOR-26-0538/Annexure V.pdf', '1', '3.3'),
('VOR-26-0538', '2026-10-03 10:26:00', 'imran.chauhan@chitralogistics.com', 'mailbox/inbox/0111__20261003_1026.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0538/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0538', '2026-10-03 10:26:00', 'imran.chauhan@chitralogistics.com', 'mailbox/inbox/0111__20261003_1026.eml', 'Company PAN.pdf', 'documents/VOR-26-0538/Company PAN.pdf', '1', '2.5'),
('VOR-26-0538', '2026-10-03 10:26:00', 'imran.chauhan@chitralogistics.com', 'mailbox/inbox/0111__20261003_1026.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0538/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0538', '2026-10-03 10:26:00', 'imran.chauhan@chitralogistics.com', 'mailbox/inbox/0111__20261003_1026.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0538/Incorporation Certificate.pdf', '1', '3.1'),
('VOR-26-0538', '2026-10-03 10:26:00', 'imran.chauhan@chitralogistics.com', 'mailbox/inbox/0111__20261003_1026.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0538/Udyam Registration.pdf', '1', '3.3'),
('VOR-26-0546', '2026-10-03 11:51:00', 'suresh.kapadia@avadhelectricco.com', 'mailbox/inbox/0112__20261003_1151.eml', 'GST Registration.pdf', 'documents/VOR-26-0546/GST Registration.pdf', '1', '3.4'),
('VOR-26-0546', '2026-10-03 11:51:00', 'suresh.kapadia@avadhelectricco.com', 'mailbox/inbox/0112__20261003_1151.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0546/ISO Certificate.pdf', '1', '3.0'),
('VOR-26-0546', '2026-10-03 11:51:00', 'suresh.kapadia@avadhelectricco.com', 'mailbox/inbox/0112__20261003_1151.eml', 'KYC Documents.pdf', 'documents/VOR-26-0546/KYC Documents.pdf', '4', '8.3'),
('VOR-26-0545', '2026-10-03 21:12:00', 'parth.chauhan@kesarearthmovers.in', 'mailbox/inbox/0113__20261003_2112.eml', 'Documents.pdf', 'documents/VOR-26-0545/Documents.pdf', '2', '4.2'),
('VOR-26-0545', '2026-10-03 21:12:00', 'parth.chauhan@kesarearthmovers.in', 'mailbox/inbox/0113__20261003_2112.eml', 'ISO 45001.pdf', 'documents/VOR-26-0545/ISO 45001.pdf', '1', '3.2'),
('VOR-26-0545', '2026-10-03 21:12:00', 'parth.chauhan@kesarearthmovers.in', 'mailbox/inbox/0113__20261003_2112.eml', 'KE PAN.pdf', 'documents/VOR-26-0545/KE PAN.pdf', '1', '2.5'),
('VOR-26-0545', '2026-10-03 21:12:00', 'parth.chauhan@kesarearthmovers.in', 'mailbox/inbox/0113__20261003_2112.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0545/Udyam Certificate.pdf', '1', '3.2'),
('VOR-26-0545', '2026-10-03 21:12:00', 'parth.chauhan@kesarearthmovers.in', 'mailbox/inbox/0113__20261003_2112.eml', 'WC Policy.pdf', 'documents/VOR-26-0545/WC Policy.pdf', '1', '2.9'),
('VOR-26-0545', '2026-10-03 21:12:00', 'parth.chauhan@kesarearthmovers.in', 'mailbox/inbox/0113__20261003_2112.eml', 'gst.pdf', 'documents/VOR-26-0545/gst.pdf', '1', '3.3'),
('VOR-26-0555', '2026-10-04 01:45:00', 'sameer.trivedi@crestlinecement.com', 'mailbox/inbox/0114__20261004_0145.eml', 'CC KYC.pdf', 'documents/VOR-26-0555/CC KYC.pdf', '2', '20.3'),
('VOR-26-0555', '2026-10-04 01:45:00', 'sameer.trivedi@crestlinecement.com', 'mailbox/inbox/0114__20261004_0145.eml', 'GST Registration.pdf', 'documents/VOR-26-0555/GST Registration.pdf', '1', '3.5'),
('VOR-26-0555', '2026-10-04 01:45:00', 'sameer.trivedi@crestlinecement.com', 'mailbox/inbox/0114__20261004_0145.eml', 'MSME.pdf', 'documents/VOR-26-0555/MSME.pdf', '1', '3.3'),
('VOR-26-0555', '2026-10-04 01:45:00', 'sameer.trivedi@crestlinecement.com', 'mailbox/inbox/0114__20261004_0145.eml', 'cancel cheque.pdf', 'documents/VOR-26-0555/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0547', '2026-10-04 10:38:00', 'pooja.trivedi@ashvakagroup.in', 'mailbox/inbox/0115__20261004_1038.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0547/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0547', '2026-10-04 10:38:00', 'pooja.trivedi@ashvakagroup.in', 'mailbox/inbox/0115__20261004_1038.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0547/ISO Certificate.pdf', '1', '3.0'),
('VOR-26-0552', '2026-10-04 13:02:00', 'hetal.nair@lotussolar.com', 'mailbox/inbox/0116__20261004_1302.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0552/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0552', '2026-10-04 13:02:00', 'hetal.nair@lotussolar.com', 'mailbox/inbox/0116__20261004_1302.eml', 'ISO 9001 (2).pdf', 'documents/VOR-26-0552/ISO 9001 (2).pdf', '1', '3.3'),
('VOR-26-0552', '2026-10-04 13:02:00', 'hetal.nair@lotussolar.com', 'mailbox/inbox/0116__20261004_1302.eml', 'ISO 9001.pdf', 'documents/VOR-26-0552/ISO 9001.pdf', '1', '3.3'),
('VOR-26-0552', '2026-10-04 13:02:00', 'hetal.nair@lotussolar.com', 'mailbox/inbox/0116__20261004_1302.eml', 'LS COI.pdf', 'documents/VOR-26-0552/LS COI.pdf', '1', '3.3'),
('VOR-26-0552', '2026-10-04 13:02:00', 'hetal.nair@lotussolar.com', 'mailbox/inbox/0116__20261004_1302.eml', 'PAN Card.pdf', 'documents/VOR-26-0552/PAN Card.pdf', '1', '2.5'),
('VOR-26-0552', '2026-10-04 13:02:00', 'hetal.nair@lotussolar.com', 'mailbox/inbox/0116__20261004_1302.eml', 'gst.pdf', 'documents/VOR-26-0552/gst.pdf', '1', '3.5'),
('VOR-26-0553', '2026-10-04 14:40:00', 'pooja.amin@kaveristeel.co.in', 'mailbox/inbox/0117__20261004_1440.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0553/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0553', '2026-10-04 14:40:00', 'pooja.amin@kaveristeel.co.in', 'mailbox/inbox/0117__20261004_1440.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0553/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0553', '2026-10-04 14:40:00', 'pooja.amin@kaveristeel.co.in', 'mailbox/inbox/0117__20261004_1440.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0553/Incorporation Certificate.pdf', '1', '3.1'),
('VOR-26-0553', '2026-10-04 14:40:00', 'pooja.amin@kaveristeel.co.in', 'mailbox/inbox/0117__20261004_1440.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0553/MSME Certificate.pdf', '1', '3.2'),
('VOR-26-0553', '2026-10-04 14:40:00', 'pooja.amin@kaveristeel.co.in', 'mailbox/inbox/0117__20261004_1440.eml', 'pan copy.pdf', 'documents/VOR-26-0553/pan copy.pdf', '1', '2.5'),
('VOR-26-0547', '2026-10-05 10:14:00', 'harsh.patel@arihantearthmovers.in', 'mailbox/inbox/0119__20261005_1014.eml', 'GST Certificate.pdf', 'documents/VOR-26-0547/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0547', '2026-10-05 10:14:00', 'harsh.patel@arihantearthmovers.in', 'mailbox/inbox/0119__20261005_1014.eml', 'WC Policy.pdf', 'documents/VOR-26-0547/WC Policy.pdf', '1', '2.9'),
('VOR-26-0576', '2026-10-05 17:08:00', 'ishaan.sheikh@bhagyodayengineeri.in', 'mailbox/inbox/0121__20261005_1708.eml', 'BES KYC.pdf', 'documents/VOR-26-0576/BES KYC.pdf', '2', '4.5'),
('VOR-26-0576', '2026-10-05 17:08:00', 'ishaan.sheikh@bhagyodayengineeri.in', 'mailbox/inbox/0121__20261005_1708.eml', 'Shop Act.pdf', 'documents/VOR-26-0576/Shop Act.pdf', '1', '3.1'),
('VOR-26-0576', '2026-10-05 17:08:00', 'ishaan.sheikh@bhagyodayengineeri.in', 'mailbox/inbox/0121__20261005_1708.eml', 'cancel cheque.pdf', 'documents/VOR-26-0576/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0567', '2026-10-05 17:53:00', 'meera.amin@sankalpequipmenthi.co.in', 'mailbox/inbox/0122__20261005_1753.eml', 'Bank certificate.pdf', 'documents/VOR-26-0567/Bank certificate.pdf', '1', '3.4'),
('VOR-26-0567', '2026-10-05 17:53:00', 'meera.amin@sankalpequipmenthi.co.in', 'mailbox/inbox/0122__20261005_1753.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0567/ISO Certificate.pdf', '1', '3.0'),
('VOR-26-0567', '2026-10-05 17:53:00', 'meera.amin@sankalpequipmenthi.co.in', 'mailbox/inbox/0122__20261005_1753.eml', 'PAN.pdf', 'documents/VOR-26-0567/PAN.pdf', '1', '2.5'),
('VOR-26-0567', '2026-10-05 17:53:00', 'meera.amin@sankalpequipmenthi.co.in', 'mailbox/inbox/0122__20261005_1753.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0567/Policy Certificate.pdf', '1', '2.9'),
('VOR-26-0567', '2026-10-05 17:53:00', 'meera.amin@sankalpequipmenthi.co.in', 'mailbox/inbox/0122__20261005_1753.eml', 'SEH COI.pdf', 'documents/VOR-26-0567/SEH COI.pdf', '1', '3.3'),
('VOR-26-0567', '2026-10-05 17:53:00', 'meera.amin@sankalpequipmenthi.co.in', 'mailbox/inbox/0122__20261005_1753.eml', 'SEH GST.pdf', 'documents/VOR-26-0567/SEH GST.pdf', '1', '3.4'),
('VOR-26-0559', '2026-10-06 03:32:00', 'zoya.nair@chitraaccesssystem.co.in', 'mailbox/inbox/0123__20261006_0332.eml', 'CAS GST.pdf', 'documents/VOR-26-0559/CAS GST.pdf', '1', '3.5'),
('VOR-26-0559', '2026-10-06 03:32:00', 'zoya.nair@chitraaccesssystem.co.in', 'mailbox/inbox/0123__20261006_0332.eml', 'COI.pdf', 'documents/VOR-26-0559/COI.pdf', '1', '3.1'),
('VOR-26-0559', '2026-10-06 03:32:00', 'zoya.nair@chitraaccesssystem.co.in', 'mailbox/inbox/0123__20261006_0332.eml', 'Company PAN.pdf', 'documents/VOR-26-0559/Company PAN.pdf', '1', '2.5'),
('VOR-26-0559', '2026-10-06 03:32:00', 'zoya.nair@chitraaccesssystem.co.in', 'mailbox/inbox/0123__20261006_0332.eml', 'Insurance.pdf', 'documents/VOR-26-0559/Insurance.pdf', '1', '3.0'),
('VOR-26-0559', '2026-10-06 03:32:00', 'zoya.nair@chitraaccesssystem.co.in', 'mailbox/inbox/0123__20261006_0332.eml', 'OHSMS Certificate.pdf', 'documents/VOR-26-0559/OHSMS Certificate.pdf', '1', '3.0'),
('VOR-26-0559', '2026-10-06 03:32:00', 'zoya.nair@chitraaccesssystem.co.in', 'mailbox/inbox/0123__20261006_0332.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0559/Udyam Registration.pdf', '1', '3.3'),
('VOR-26-0559', '2026-10-06 03:32:00', 'zoya.nair@chitraaccesssystem.co.in', 'mailbox/inbox/0123__20261006_0332.eml', 'cancel cheque.pdf', 'documents/VOR-26-0559/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0563', '2026-10-06 04:50:00', 'joseph.thakkar@darshantransportco.in', 'mailbox/inbox/0124__20261006_0450.eml', 'COI.pdf', 'documents/VOR-26-0563/COI.pdf', '1', '3.3'),
('VOR-26-0563', '2026-10-06 04:50:00', 'joseph.thakkar@darshantransportco.in', 'mailbox/inbox/0124__20261006_0450.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0563/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0563', '2026-10-06 04:50:00', 'joseph.thakkar@darshantransportco.in', 'mailbox/inbox/0124__20261006_0450.eml', 'DTC PAN.pdf', 'documents/VOR-26-0563/DTC PAN.pdf', '1', '2.5'),
('VOR-26-0563', '2026-10-06 04:50:00', 'joseph.thakkar@darshantransportco.in', 'mailbox/inbox/0124__20261006_0450.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0563/Vendor Registration Documents.pdf', '2', '4.4'),
('VOR-26-0563', '2026-10-06 04:50:00', 'joseph.thakkar@darshantransportco.in', 'mailbox/inbox/0124__20261006_0450.eml', 'gst.pdf', 'documents/VOR-26-0563/gst.pdf', '1', '3.5'),
('VOR-26-0517', '2026-10-06 12:17:00', 'sneha.menon@parshvaroadlines.co.in', 'mailbox/inbox/0125__20261006_1217.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0517/Certificate of Incorporation.pdf', '1', '3.4'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0582/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'Cheque.pdf', 'documents/VOR-26-0582/Cheque.pdf', '1', '2.4'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'DLC GST.pdf', 'documents/VOR-26-0582/DLC GST.pdf', '1', '3.4'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'DLC PAN.pdf', 'documents/VOR-26-0582/DLC PAN.pdf', '1', '2.5'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0582/ESIC Registration.pdf', '1', '2.6'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'Gumasta.pdf', 'documents/VOR-26-0582/Gumasta.pdf', '1', '3.1'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'PF Registration.pdf', 'documents/VOR-26-0582/PF Registration.pdf', '1', '2.6'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0582/Policy Certificate.pdf', '1', '2.9'),
('VOR-26-0582', '2026-10-06 16:11:00', 'farhan.oza@deccanlabourcontra.in', 'mailbox/inbox/0127__20261006_1611.eml', 'renewal receipt.pdf', 'documents/VOR-26-0582/renewal receipt.pdf', '1', '2.5'),
('VOR-26-0547', '2026-10-06 17:47:00', 'harsh.patel@arihantearthmovers.in', 'mailbox/inbox/0128__20261006_1747.eml', 'Deed extract.pdf', 'documents/VOR-26-0547/Deed extract.pdf', '1', '3.5'),
('VOR-26-0547', '2026-10-06 17:47:00', 'harsh.patel@arihantearthmovers.in', 'mailbox/inbox/0128__20261006_1747.eml', 'pan copy.pdf', 'documents/VOR-26-0547/pan copy.pdf', '1', '2.5'),
('VOR-26-0590', '2026-10-06 20:49:00', 'krunal.pandya@keystoneequipmenth.com', 'mailbox/inbox/0129__20261006_2049.eml', 'Cheque.pdf', 'documents/VOR-26-0590/Cheque.pdf', '1', '2.4'),
('VOR-26-0590', '2026-10-06 20:49:00', 'krunal.pandya@keystoneequipmenth.com', 'mailbox/inbox/0129__20261006_2049.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0590/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0590', '2026-10-06 20:49:00', 'krunal.pandya@keystoneequipmenth.com', 'mailbox/inbox/0129__20261006_2049.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0590/ISO Certificate.pdf', '1', '3.3'),
('VOR-26-0590', '2026-10-06 20:49:00', 'krunal.pandya@keystoneequipmenth.com', 'mailbox/inbox/0129__20261006_2049.eml', 'KEH PAN.pdf', 'documents/VOR-26-0590/KEH PAN.pdf', '1', '2.5'),
('VOR-26-0590', '2026-10-06 20:49:00', 'krunal.pandya@keystoneequipmenth.com', 'mailbox/inbox/0129__20261006_2049.eml', 'LLP Incorporation.pdf', 'documents/VOR-26-0590/LLP Incorporation.pdf', '1', '3.2'),
('VOR-26-0590', '2026-10-06 20:49:00', 'krunal.pandya@keystoneequipmenth.com', 'mailbox/inbox/0129__20261006_2049.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0590/Policy Certificate.pdf', '1', '3.0'),
('VOR-26-0587', '2026-10-06 21:21:00', 'zoya.amin@sabarearthmovers.in', 'mailbox/inbox/0130__20261006_2121.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0587/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0587', '2026-10-06 21:21:00', 'zoya.amin@sabarearthmovers.in', 'mailbox/inbox/0130__20261006_2121.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0587/Certificate of Incorporation.pdf', '1', '3.1'),
('VOR-26-0587', '2026-10-06 21:21:00', 'zoya.amin@sabarearthmovers.in', 'mailbox/inbox/0130__20261006_2121.eml', 'GST REG-06.pdf', 'documents/VOR-26-0587/GST REG-06.pdf', '1', '3.5'),
('VOR-26-0587', '2026-10-06 21:21:00', 'zoya.amin@sabarearthmovers.in', 'mailbox/inbox/0130__20261006_2121.eml', 'ISO 45001 2018.pdf', 'documents/VOR-26-0587/ISO 45001 2018.pdf', '1', '3.0'),
('VOR-26-0587', '2026-10-06 21:21:00', 'zoya.amin@sabarearthmovers.in', 'mailbox/inbox/0130__20261006_2121.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0587/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0587', '2026-10-06 21:21:00', 'zoya.amin@sabarearthmovers.in', 'mailbox/inbox/0130__20261006_2121.eml', 'SE PAN.pdf', 'documents/VOR-26-0587/SE PAN.pdf', '1', '2.5'),
('VOR-26-0587', '2026-10-06 21:21:00', 'zoya.amin@sabarearthmovers.in', 'mailbox/inbox/0130__20261006_2121.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0587/Udyam Certificate.pdf', '1', '3.3'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0603/Cancelled_Cheque.pdf', '1', '2.5'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'Company PAN.pdf', 'documents/VOR-26-0603/Company PAN.pdf', '1', '2.5'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0603/ESIC Registration.pdf', '1', '2.6'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'GST Registration.pdf', 'documents/VOR-26-0603/GST Registration.pdf', '1', '3.4'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'IMG_20261006_117889.pdf', 'documents/VOR-26-0603/IMG_20261006_117889.pdf', '1', '12.1'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'IMG_20261006_162679.pdf', 'documents/VOR-26-0603/IMG_20261006_162679.pdf', '1', '12.4'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'Policy Certificate.pdf', 'documents/VOR-26-0603/Policy Certificate.pdf', '1', '3.0'),
('VOR-26-0603', '2026-10-06 21:46:00', 'dhruv.parikh@mahalaxmiworkforce.in', 'mailbox/inbox/0131__20261006_2146.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0603/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0574', '2026-10-06 22:24:00', 'devang.menon@ashvakagroup.in', 'mailbox/inbox/0132__20261006_2224.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0574/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0574', '2026-10-06 22:24:00', 'devang.menon@ashvakagroup.in', 'mailbox/inbox/0132__20261006_2224.eml', 'Company PAN.pdf', 'documents/VOR-26-0574/Company PAN.pdf', '1', '2.5'),
('VOR-26-0574', '2026-10-06 22:24:00', 'devang.menon@ashvakagroup.in', 'mailbox/inbox/0132__20261006_2224.eml', 'GST REG-06.pdf', 'documents/VOR-26-0574/GST REG-06.pdf', '1', '3.4'),
('VOR-26-0574', '2026-10-06 22:24:00', 'devang.menon@ashvakagroup.in', 'mailbox/inbox/0132__20261006_2224.eml', 'ISO 45001.pdf', 'documents/VOR-26-0574/ISO 45001.pdf', '1', '3.3'),
('VOR-26-0574', '2026-10-06 22:24:00', 'devang.menon@ashvakagroup.in', 'mailbox/inbox/0132__20261006_2224.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0574/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0574', '2026-10-06 22:24:00', 'devang.menon@ashvakagroup.in', 'mailbox/inbox/0132__20261006_2224.eml', 'QI COI.pdf', 'documents/VOR-26-0574/QI COI.pdf', '1', '3.4'),
('VOR-26-0602', '2026-10-07 01:58:00', 'harsh.trivedi@kesarcraneservices.co.in', 'mailbox/inbox/0133__20261007_0158.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0602/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0602', '2026-10-07 01:58:00', 'harsh.trivedi@kesarcraneservices.co.in', 'mailbox/inbox/0133__20261007_0158.eml', 'ISO Certificate.pdf', 'documents/VOR-26-0602/ISO Certificate.pdf', '1', '3.0'),
('VOR-26-0602', '2026-10-07 01:58:00', 'harsh.trivedi@kesarcraneservices.co.in', 'mailbox/inbox/0133__20261007_0158.eml', 'Incorporation Certificate.pdf', 'documents/VOR-26-0602/Incorporation Certificate.pdf', '1', '3.1'),
('VOR-26-0602', '2026-10-07 01:58:00', 'harsh.trivedi@kesarcraneservices.co.in', 'mailbox/inbox/0133__20261007_0158.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0602/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0602', '2026-10-07 01:58:00', 'harsh.trivedi@kesarcraneservices.co.in', 'mailbox/inbox/0133__20261007_0158.eml', 'KCS GST.pdf', 'documents/VOR-26-0602/KCS GST.pdf', '1', '3.5'),
('VOR-26-0602', '2026-10-07 01:58:00', 'harsh.trivedi@kesarcraneservices.co.in', 'mailbox/inbox/0133__20261007_0158.eml', 'Udyam Certificate.pdf', 'documents/VOR-26-0602/Udyam Certificate.pdf', '1', '3.3'),
('VOR-26-0602', '2026-10-07 01:58:00', 'harsh.trivedi@kesarcraneservices.co.in', 'mailbox/inbox/0133__20261007_0158.eml', 'pan copy.pdf', 'documents/VOR-26-0602/pan copy.pdf', '1', '2.5'),
('VOR-26-0588', '2026-10-07 02:26:00', 'hetal.sanghvi@aashirwadcarriers.in', 'mailbox/inbox/0134__20261007_0226.eml', 'Annexure V.pdf', 'documents/VOR-26-0588/Annexure V.pdf', '1', '3.3'),
('VOR-26-0588', '2026-10-07 02:26:00', 'hetal.sanghvi@aashirwadcarriers.in', 'mailbox/inbox/0134__20261007_0226.eml', 'Form 16 LLP.pdf', 'documents/VOR-26-0588/Form 16 LLP.pdf', '1', '3.1'),
('VOR-26-0588', '2026-10-07 02:26:00', 'hetal.sanghvi@aashirwadcarriers.in', 'mailbox/inbox/0134__20261007_0226.eml', 'MSME Certificate.pdf', 'documents/VOR-26-0588/MSME Certificate.pdf', '1', '3.2'),
('VOR-26-0588', '2026-10-07 02:26:00', 'hetal.sanghvi@aashirwadcarriers.in', 'mailbox/inbox/0134__20261007_0226.eml', 'PAN.pdf', 'documents/VOR-26-0588/PAN.pdf', '1', '2.5'),
('VOR-26-0588', '2026-10-07 02:26:00', 'hetal.sanghvi@aashirwadcarriers.in', 'mailbox/inbox/0134__20261007_0226.eml', 'cancelled chq.pdf', 'documents/VOR-26-0588/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0588', '2026-10-07 02:26:00', 'hetal.sanghvi@aashirwadcarriers.in', 'mailbox/inbox/0134__20261007_0226.eml', 'gst.pdf', 'documents/VOR-26-0588/gst.pdf', '1', '3.5'),
('VOR-26-0593', '2026-10-07 09:50:00', 'aakash.mistry@crestlinecementtra.in', 'mailbox/inbox/0135__20261007_0950.eml', 'Cheque.pdf', 'documents/VOR-26-0593/Cheque.pdf', '1', '2.4'),
('VOR-26-0593', '2026-10-07 09:50:00', 'aakash.mistry@crestlinecementtra.in', 'mailbox/inbox/0135__20261007_0950.eml', 'IMG_20261007_102262.pdf', 'documents/VOR-26-0593/IMG_20261007_102262.pdf', '1', '108.3'),
('VOR-26-0593', '2026-10-07 09:50:00', 'aakash.mistry@crestlinecementtra.in', 'mailbox/inbox/0135__20261007_0950.eml', 'PAN.pdf', 'documents/VOR-26-0593/PAN.pdf', '1', '2.5'),
('VOR-26-0593', '2026-10-07 09:50:00', 'aakash.mistry@crestlinecementtra.in', 'mailbox/inbox/0135__20261007_0950.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0593/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0571', '2026-10-07 10:11:00', 'riya.qureshi@sthapatyaitsolutio.co.in', 'mailbox/inbox/0136__20261007_1011.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0571/Cancelled Cheque.pdf', '1', '2.5');
insert into public."received_document" ("request_id", "received_at", "from_address", "mailbox_file", "attachment_name", "stored_path", "page_count", "size_kb") values
('VOR-26-0571', '2026-10-07 10:11:00', 'riya.qureshi@sthapatyaitsolutio.co.in', 'mailbox/inbox/0136__20261007_1011.eml', 'SIS KYC.pdf', 'documents/VOR-26-0571/SIS KYC.pdf', '3', '7.1'),
('VOR-26-0560', '2026-10-07 10:29:00', 'vivek.solanki@omkarrmc.co.in', 'mailbox/inbox/0137__20261007_1029.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0560/Certificate of Incorporation.pdf', '1', '3.2'),
('VOR-26-0560', '2026-10-07 10:29:00', 'vivek.solanki@omkarrmc.co.in', 'mailbox/inbox/0137__20261007_1029.eml', 'Company PAN.pdf', 'documents/VOR-26-0560/Company PAN.pdf', '1', '2.5'),
('VOR-26-0560', '2026-10-07 10:29:00', 'vivek.solanki@omkarrmc.co.in', 'mailbox/inbox/0137__20261007_1029.eml', 'GST Registration.pdf', 'documents/VOR-26-0560/GST Registration.pdf', '1', '3.4'),
('VOR-26-0560', '2026-10-07 10:29:00', 'vivek.solanki@omkarrmc.co.in', 'mailbox/inbox/0137__20261007_1029.eml', 'ISO 9001 2015.pdf', 'documents/VOR-26-0560/ISO 9001 2015.pdf', '1', '3.2'),
('VOR-26-0560', '2026-10-07 10:29:00', 'vivek.solanki@omkarrmc.co.in', 'mailbox/inbox/0137__20261007_1029.eml', 'cancel cheque.pdf', 'documents/VOR-26-0560/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0570', '2026-10-07 11:07:00', 'jignesh.rao@mahalaxmilabourcon.in', 'mailbox/inbox/0138__20261007_1107.eml', 'All documents.pdf', 'documents/VOR-26-0570/All documents.pdf', '2', '4.4'),
('VOR-26-0570', '2026-10-07 11:07:00', 'jignesh.rao@mahalaxmilabourcon.in', 'mailbox/inbox/0138__20261007_1107.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0570/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0570', '2026-10-07 11:07:00', 'jignesh.rao@mahalaxmilabourcon.in', 'mailbox/inbox/0138__20261007_1107.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0570/Certificate of Incorporation.pdf', '1', '3.1'),
('VOR-26-0570', '2026-10-07 11:07:00', 'jignesh.rao@mahalaxmilabourcon.in', 'mailbox/inbox/0138__20261007_1107.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0570/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0570', '2026-10-07 11:07:00', 'jignesh.rao@mahalaxmilabourcon.in', 'mailbox/inbox/0138__20261007_1107.eml', 'IMG_20261007_102508.pdf', 'documents/VOR-26-0570/IMG_20261007_102508.pdf', '1', '94.1'),
('VOR-26-0570', '2026-10-07 11:07:00', 'jignesh.rao@mahalaxmilabourcon.in', 'mailbox/inbox/0138__20261007_1107.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0570/Insurance Policy.pdf', '1', '2.9'),
('VOR-26-0570', '2026-10-07 11:07:00', 'jignesh.rao@mahalaxmilabourcon.in', 'mailbox/inbox/0138__20261007_1107.eml', 'MLC PAN.pdf', 'documents/VOR-26-0570/MLC PAN.pdf', '1', '2.5'),
('VOR-26-0580', '2026-10-07 14:08:00', 'suresh.sheikh@sankalptestinglabo.co.in', 'mailbox/inbox/0139__20261007_1408.eml', 'Application Receipt.pdf', 'documents/VOR-26-0580/Application Receipt.pdf', '1', '2.5'),
('VOR-26-0580', '2026-10-07 14:08:00', 'suresh.sheikh@sankalptestinglabo.co.in', 'mailbox/inbox/0139__20261007_1408.eml', 'GST Certificate.pdf', 'documents/VOR-26-0580/GST Certificate.pdf', '1', '3.5'),
('VOR-26-0580', '2026-10-07 14:08:00', 'suresh.sheikh@sankalptestinglabo.co.in', 'mailbox/inbox/0139__20261007_1408.eml', 'NABL Certificate.pdf', 'documents/VOR-26-0580/NABL Certificate.pdf', '1', '3.3'),
('VOR-26-0580', '2026-10-07 14:08:00', 'suresh.sheikh@sankalptestinglabo.co.in', 'mailbox/inbox/0139__20261007_1408.eml', 'STL COI.pdf', 'documents/VOR-26-0580/STL COI.pdf', '1', '3.3'),
('VOR-26-0580', '2026-10-07 14:08:00', 'suresh.sheikh@sankalptestinglabo.co.in', 'mailbox/inbox/0139__20261007_1408.eml', 'cancel cheque.pdf', 'documents/VOR-26-0580/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0580', '2026-10-07 14:08:00', 'suresh.sheikh@sankalptestinglabo.co.in', 'mailbox/inbox/0139__20261007_1408.eml', 'pan copy.pdf', 'documents/VOR-26-0580/pan copy.pdf', '1', '2.5'),
('VOR-26-0577', '2026-10-07 14:12:00', 'jinal.dsouza@mahiispat.in', 'mailbox/inbox/0140__20261007_1412.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0577/Certificate of Incorporation.pdf', '1', '3.3'),
('VOR-26-0577', '2026-10-07 14:12:00', 'jinal.dsouza@mahiispat.in', 'mailbox/inbox/0140__20261007_1412.eml', 'Cheque.pdf', 'documents/VOR-26-0577/Cheque.pdf', '1', '2.4'),
('VOR-26-0577', '2026-10-07 14:12:00', 'jinal.dsouza@mahiispat.in', 'mailbox/inbox/0140__20261007_1412.eml', 'Company PAN.pdf', 'documents/VOR-26-0577/Company PAN.pdf', '1', '2.5'),
('VOR-26-0577', '2026-10-07 14:12:00', 'jinal.dsouza@mahiispat.in', 'mailbox/inbox/0140__20261007_1412.eml', 'gst.pdf', 'documents/VOR-26-0577/gst.pdf', '1', '3.5'),
('VOR-26-0586', '2026-10-07 16:02:00', 'sagar.parmar@bhagyodayaggregate.in', 'mailbox/inbox/0141__20261007_1602.eml', 'BA GST.pdf', 'documents/VOR-26-0586/BA GST.pdf', '1', '3.4'),
('VOR-26-0586', '2026-10-07 16:02:00', 'sagar.parmar@bhagyodayaggregate.in', 'mailbox/inbox/0141__20261007_1602.eml', 'PAN Card.pdf', 'documents/VOR-26-0586/PAN Card.pdf', '1', '2.5'),
('VOR-26-0586', '2026-10-07 16:02:00', 'sagar.parmar@bhagyodayaggregate.in', 'mailbox/inbox/0141__20261007_1602.eml', 'Shop Act.pdf', 'documents/VOR-26-0586/Shop Act.pdf', '1', '3.1'),
('VOR-26-0586', '2026-10-07 16:02:00', 'sagar.parmar@bhagyodayaggregate.in', 'mailbox/inbox/0141__20261007_1602.eml', 'cancel cheque.pdf', 'documents/VOR-26-0586/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'AWS COI.pdf', 'documents/VOR-26-0601/AWS COI.pdf', '1', '3.2'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'AWS GST.pdf', 'documents/VOR-26-0601/AWS GST.pdf', '1', '3.5'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'Cheque.pdf', 'documents/VOR-26-0601/Cheque.pdf', '1', '2.4'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'Company PAN.pdf', 'documents/VOR-26-0601/Company PAN.pdf', '1', '2.5'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'ESIC Certificate.pdf', 'documents/VOR-26-0601/ESIC Certificate.pdf', '1', '2.6'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0601/Insurance Policy.pdf', '1', '2.9'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'Labour Licence.pdf', 'documents/VOR-26-0601/Labour Licence.pdf', '1', '3.8'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'MSME.pdf', 'documents/VOR-26-0601/MSME.pdf', '1', '3.3'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'PF Registration.pdf', 'documents/VOR-26-0601/PF Registration.pdf', '1', '2.6'),
('VOR-26-0601', '2026-10-07 18:49:00', 'vivek.chauhan@aashirwadworkforce.in', 'mailbox/inbox/0143__20261007_1849.eml', 'renewal receipt.pdf', 'documents/VOR-26-0601/renewal receipt.pdf', '1', '2.6'),
('VOR-26-0596', '2026-10-08 10:15:00', 'vivek.jadeja@trikamaggregates.in', 'mailbox/inbox/0144__20261008_1015.eml', 'TA PAN.pdf', 'documents/VOR-26-0596/TA PAN.pdf', '1', '2.5'),
('VOR-26-0596', '2026-10-08 10:15:00', 'vivek.jadeja@trikamaggregates.in', 'mailbox/inbox/0144__20261008_1015.eml', 'Vendor Registration Documents.pdf', 'documents/VOR-26-0596/Vendor Registration Documents.pdf', '2', '5.2'),
('VOR-26-0596', '2026-10-08 10:15:00', 'vivek.jadeja@trikamaggregates.in', 'mailbox/inbox/0144__20261008_1015.eml', 'cancelled chq.pdf', 'documents/VOR-26-0596/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0598', '2026-10-08 11:17:00', 'rutvik.chauhan@ashvakagroup.in', 'mailbox/inbox/0145__20261008_1117.eml', 'Company PAN.pdf', 'documents/VOR-26-0598/Company PAN.pdf', '1', '2.5'),
('VOR-26-0598', '2026-10-08 11:17:00', 'rutvik.chauhan@ashvakagroup.in', 'mailbox/inbox/0145__20261008_1117.eml', 'Documents.pdf', 'documents/VOR-26-0598/Documents.pdf', '3', '7.2'),
('VOR-26-0598', '2026-10-08 11:17:00', 'rutvik.chauhan@ashvakagroup.in', 'mailbox/inbox/0145__20261008_1117.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0598/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0598', '2026-10-08 11:17:00', 'rutvik.chauhan@ashvakagroup.in', 'mailbox/inbox/0145__20261008_1117.eml', 'ESIC Registration.pdf', 'documents/VOR-26-0598/ESIC Registration.pdf', '1', '2.6'),
('VOR-26-0598', '2026-10-08 11:17:00', 'rutvik.chauhan@ashvakagroup.in', 'mailbox/inbox/0145__20261008_1117.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0598/GSTIN Certificate.pdf', '1', '3.4'),
('VOR-26-0598', '2026-10-08 11:17:00', 'rutvik.chauhan@ashvakagroup.in', 'mailbox/inbox/0145__20261008_1117.eml', 'Gumasta.pdf', 'documents/VOR-26-0598/Gumasta.pdf', '1', '3.1'),
('VOR-26-0598', '2026-10-08 11:17:00', 'rutvik.chauhan@ashvakagroup.in', 'mailbox/inbox/0145__20261008_1117.eml', 'Insurance Policy.pdf', 'documents/VOR-26-0598/Insurance Policy.pdf', '1', '3.0'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0607/CLRA Licence.pdf', '1', '3.7'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'Company PAN.pdf', 'documents/VOR-26-0607/Company PAN.pdf', '1', '2.5'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0607/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'ESI Code.pdf', 'documents/VOR-26-0607/ESI Code.pdf', '1', '2.5'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0607/GSTIN Certificate.pdf', '1', '3.3'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'Insurance.pdf', 'documents/VOR-26-0607/Insurance.pdf', '1', '2.9'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'PSARA Licence.pdf', 'documents/VOR-26-0607/PSARA Licence.pdf', '1', '3.5'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'Shop Act.pdf', 'documents/VOR-26-0607/Shop Act.pdf', '1', '3.1'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0607/Udyam Registration.pdf', '1', '3.2'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'cancel cheque.pdf', 'documents/VOR-26-0607/cancel cheque.pdf', '1', '2.4'),
('VOR-26-0607', '2026-10-08 16:23:00', 'rakesh.thakkar@navjivanguardingse.in', 'mailbox/inbox/0146__20261008_1623.eml', 'renewal receipt.pdf', 'documents/VOR-26-0607/renewal receipt.pdf', '1', '2.5'),
('VOR-26-0564', '2026-10-08 18:28:00', 'arjun.nair@gokulsafetysolutio.in', 'mailbox/inbox/0147__20261008_1828.eml', 'Cancelled Cheque.pdf', 'documents/VOR-26-0564/Cancelled Cheque.pdf', '1', '2.4'),
('VOR-26-0564', '2026-10-08 18:28:00', 'arjun.nair@gokulsafetysolutio.in', 'mailbox/inbox/0147__20261008_1828.eml', 'Company PAN.pdf', 'documents/VOR-26-0564/Company PAN.pdf', '1', '2.5'),
('VOR-26-0564', '2026-10-08 18:28:00', 'arjun.nair@gokulsafetysolutio.in', 'mailbox/inbox/0147__20261008_1828.eml', 'GSS GST.pdf', 'documents/VOR-26-0564/GSS GST.pdf', '1', '3.5'),
('VOR-26-0564', '2026-10-08 18:28:00', 'arjun.nair@gokulsafetysolutio.in', 'mailbox/inbox/0147__20261008_1828.eml', 'ISO 9001.pdf', 'documents/VOR-26-0564/ISO 9001.pdf', '1', '3.2'),
('VOR-26-0564', '2026-10-08 18:28:00', 'arjun.nair@gokulsafetysolutio.in', 'mailbox/inbox/0147__20261008_1828.eml', 'Partnership deed copy.pdf', 'documents/VOR-26-0564/Partnership deed copy.pdf', '1', '3.5'),
('VOR-26-0604', '2026-10-09 10:10:00', 'maria.rao@suryodayminerals.com', 'mailbox/inbox/0149__20261009_1010.eml', 'Cancelled_Cheque.pdf', 'documents/VOR-26-0604/Cancelled_Cheque.pdf', '1', '2.4'),
('VOR-26-0604', '2026-10-09 10:10:00', 'maria.rao@suryodayminerals.com', 'mailbox/inbox/0149__20261009_1010.eml', 'GST Certificate.pdf', 'documents/VOR-26-0604/GST Certificate.pdf', '1', '3.4'),
('VOR-26-0604', '2026-10-09 10:10:00', 'maria.rao@suryodayminerals.com', 'mailbox/inbox/0149__20261009_1010.eml', 'MSME.pdf', 'documents/VOR-26-0604/MSME.pdf', '1', '3.2'),
('VOR-26-0604', '2026-10-09 10:10:00', 'maria.rao@suryodayminerals.com', 'mailbox/inbox/0149__20261009_1010.eml', 'PAN Card.pdf', 'documents/VOR-26-0604/PAN Card.pdf', '1', '2.5'),
('VOR-26-0604', '2026-10-09 10:10:00', 'maria.rao@suryodayminerals.com', 'mailbox/inbox/0149__20261009_1010.eml', 'Shop Establishment Certificate.pdf', 'documents/VOR-26-0604/Shop Establishment Certificate.pdf', '1', '3.1'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'CLRA Licence.pdf', 'documents/VOR-26-0608/CLRA Licence.pdf', '1', '3.8'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'Certificate of Incorporation.pdf', 'documents/VOR-26-0608/Certificate of Incorporation.pdf', '1', '3.1'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'Company PAN.pdf', 'documents/VOR-26-0608/Company PAN.pdf', '1', '2.5'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0608/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'ESIC Certificate.pdf', 'documents/VOR-26-0608/ESIC Certificate.pdf', '1', '2.6'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'GST Registration.pdf', 'documents/VOR-26-0608/GST Registration.pdf', '1', '3.5'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'Insurance.pdf', 'documents/VOR-26-0608/Insurance.pdf', '1', '3.0'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'MSME.pdf', 'documents/VOR-26-0608/MSME.pdf', '1', '3.2'),
('VOR-26-0608', '2026-10-09 12:29:00', 'hardik.rathod@dharafacilityservi.in', 'mailbox/inbox/0150__20261009_1229.eml', 'cancelled chq.pdf', 'documents/VOR-26-0608/cancelled chq.pdf', '1', '2.4'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'COI.pdf', 'documents/VOR-26-0609/COI.pdf', '1', '3.4'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'Cheque.pdf', 'documents/VOR-26-0609/Cheque.pdf', '1', '2.4'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'EPF Code Letter.pdf', 'documents/VOR-26-0609/EPF Code Letter.pdf', '1', '2.6'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'ESI Code.pdf', 'documents/VOR-26-0609/ESI Code.pdf', '1', '2.6'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'GSTIN Certificate.pdf', 'documents/VOR-26-0609/GSTIN Certificate.pdf', '1', '3.5'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'Labour Licence.pdf', 'documents/VOR-26-0609/Labour Licence.pdf', '1', '3.8'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'Udyam Registration.pdf', 'documents/VOR-26-0609/Udyam Registration.pdf', '1', '3.3'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'WC Policy.pdf', 'documents/VOR-26-0609/WC Policy.pdf', '1', '2.9'),
('VOR-26-0609', '2026-10-09 16:23:00', 'mitesh.dsouza@pragatihousekeepin.in', 'mailbox/inbox/0151__20261009_1623.eml', 'pan copy.pdf', 'documents/VOR-26-0609/pan copy.pdf', '1', '2.5');

drop table if exists public."vendor_master";
create table public."vendor_master" (
  row_id bigint generated always as identity primary key,
  "vendor_number" text,
  "name_line_1" text,
  "name_line_2" text,
  "search_term" text,
  "street" text,
  "city" text,
  "state_code" text,
  "pin_code" text,
  "country" text,
  "phone" text,
  "email" text,
  "pan" text,
  "gstin" text,
  "bank_country" text,
  "ifsc" text,
  "bank_account_number" text,
  "account_holder" text,
  "msme_flag" text,
  "udyam_number" text,
  "account_group" text,
  "purchase_category" text,
  "created_on" text,
  "posting_block" text,
  "deletion_flag" text,
  "company_codes_extended" text
);
comment on table public."vendor_master" is 'One vendor that already exists in SAP, with its PAN, GSTIN and bank details.';
insert into public."vendor_master" ("vendor_number", "name_line_1", "name_line_2", "search_term", "street", "city", "state_code", "pin_code", "country", "phone", "email", "pan", "gstin", "bank_country", "ifsc", "bank_account_number", "account_holder", "msme_flag", "udyam_number", "account_group", "purchase_category", "created_on", "posting_block", "deletion_flag", "company_codes_extended") values
('200100', 'RADHE RMC & CO', NULL, 'RADHERMCCO', '21, GIDC Estate', 'Hosur', 'TN', '605706', 'IN', '+91 8490350503', 'manan.dave@radhermc.in', 'DHTFR7891Z', '33DHTFR7891Z1ZY', 'IN', 'UBIN0753645', '668151884472940', 'RADHE RMC & CO', 'Y', 'UDYAM-TN-07-8543956', 'ZMSE', 'RMC', '03.07.2025', NULL, NULL, 'AI10'),
('200107', 'PRAYAG CONCRETE & CO', NULL, 'PRAYAGCONC', '123, Trade Centre', 'Sanand', 'GJ', '389486', 'IN', '+91 9819142805', 'deepa.jadeja@prayagconcrete.com', 'NQZFP9045M', '24NQZFP9045M1Z0', 'IN', 'INDB0093208', '296727317784', 'PRAYAG CONCRETE & CO', 'N', NULL, 'ZDOM', 'RMC', '14.07.2025', NULL, NULL, 'AE30;AL40'),
('200114', 'Suryoday RMC LLP', NULL, 'SURYODAYRM', '197, Highway Complex', 'Vadodara', 'GJ', '388114', 'IN', '+91 7582534007', 'devang.gill@suryodayrmc.co.in', 'UTOFS9567P', '24UTOFS9567P1ZE', 'IN', 'BARB0804571', '88472671475136', 'SURYODAY RMC LLP', 'N', NULL, 'ZDOM', 'RMC', '15.01.2019', NULL, NULL, 'AI10;AL40'),
('200121', 'Pragati Concrete Pvt Ltd', NULL, 'PRAGATICON', '150, Trade Centre', 'Bhuj', 'GJ', '389060', 'IN', '+91 6518059205', 'amit.patel@pragaticoncrete.com', 'BYRCP5399V', '24BYRCP5399V1ZJ', 'IN', 'CNRB0929841', '7229486628360', 'Pragati Concrete Pvt Ltd', 'Y', 'UDYAM-GJ-09-4740105', 'ZMSE', 'RMC', '27.01.2019', NULL, NULL, 'AI10'),
('200128', 'Indus Concrete LLP', NULL, 'INDUSCONCR', '120, Trade Centre', 'New Delhi', 'DL', '113797', 'IN', '+91 6796032518', 'karan.bhatt@indusconcrete.in', 'AQPFI6370V', '07AQPFI6370V1ZA', 'IN', 'KKBK0298369', '6793186032', 'INDUS CONCRETE LLP', 'N', NULL, 'ZDOM', 'RMC', '28.08.2018', NULL, NULL, 'AE30;AI10'),
('200135', 'Omkar RMC Ltd', NULL, 'OMKARRMCLT', '109, Trade Centre', 'Mumbai', 'MH', '417784', 'IN', '+91 8976336909', 'vivek.solanki@omkarrmc.co.in', 'EUQCO4583Z', '27EUQCO4583Z1ZK', 'IN', 'INDB0164252', '577647258771', 'OMKAR RMC LTD', 'N', NULL, 'ZDOM', 'RMC', '01.04.2021', NULL, NULL, 'AE30;AL40'),
('200142', 'Unnati RMC Ltd', NULL, 'UNNATIRMCL', '72, Trade Centre', 'Anand', 'GJ', '384513', 'IN', '+91 8397196778', 'meera.bhatt@unnatirmc.com', 'ZVFCU1445L', '24ZVFCU1445L1ZD', 'IN', 'SBIN0949482', '24162105218', 'UNNATI RMC LTD', 'N', NULL, 'ZDOM', 'RMC', '11.05.2019', NULL, NULL, 'AC20;AE30'),
('200149', 'Gokul Cement Traders LLP', NULL, 'GOKULCEMEN', '176, Trade Centre', 'Gandhinagar', 'GJ', '386739', 'IN', '+91 8846573366', 'krunal.panchal@gokulcement.co.in', 'YINFG1252B', '24YINFG1252B1ZS', 'IN', 'ICIC0906593', '861584645060', 'GOKUL CEMENT TRADERS LLP', 'Y', 'UDYAM-GJ-21-8651160', 'ZMSE', 'CEMENT', '24.05.2023', NULL, NULL, 'AE30'),
('200156', 'Radhe Cement Traders Enterprises', NULL, 'RADHECEMEN', '134, Ring Road', 'Ahmedabad', 'GJ', '385951', 'IN', '+91 6117819606', 'priyanka.bhatt@radhecement.co.in', 'RKGFR1919X', '24RKGFR1919X1ZC', 'IN', 'ICIC0256663', '732280886423', 'RADHE CEMENT TRADERS ENTERPRISES', 'Y', 'UDYAM-GJ-02-8126459', 'ZMSE', 'CEMENT', '16.09.2022', NULL, NULL, 'AC20;AL40'),
('200163', 'RIDDHI CEMENT TRADERS LLP', NULL, 'RIDDHICEME', '191, Ring Road', 'Bhuj', 'GJ', '381921', 'IN', '+91 9946783894', 'shreya.kothari@riddhicement.com', 'CFRFR1622U', '24CFRFR1622U1Z5', 'IN', 'INDB0037038', '365384535577', 'RIDDHI CEMENT TRADERS LLP', 'N', NULL, 'ZDOM', 'CEMENT', '06.04.2022', NULL, NULL, 'AC20'),
('200170', 'Quartz Cement Enterprises', NULL, 'QUARTZCEME', '68, Industrial Area', 'Mysuru', 'KA', '562650', 'IN', '+91 8687863301', 'zoya.qureshi@quartzcement.in', 'QWNFQ1614U', '29QWNFQ1614U1ZN', 'IN', 'SBIN0083949', '16688281126', 'QUARTZ CEMENT ENTERPRISES', 'N', NULL, 'ZDOM', 'CEMENT', '24.01.2022', NULL, NULL, 'AE30'),
('200177', 'Omkar Cement LLP', NULL, 'OMKARCEMEN', '198, Trade Centre', 'Rajkot', 'GJ', '383799', 'IN', '+91 8620297489', 'nikhil.reddy@omkarcement.in', 'LEMFO4091X', '24LEMFO4091X1ZN', 'IN', 'CNRB0822018', '1515438299321', 'Omkar Cement LLP', 'Y', 'UDYAM-GJ-02-4013575', 'ZMSE', 'CEMENT', '03.12.2019', NULL, NULL, 'AC20;AL40'),
('200184', 'Mangalam Cement Traders & Co', NULL, 'MANGALAMCE', '89, GIDC Estate', 'Sanand', 'GJ', '382131', 'IN', '+91 7839981080', 'vikram.verma@mangalamcement.co.in', 'LPPFM2981R', '24LPPFM2981R1Z8', 'IN', 'INDB0174432', '668855765237', 'MANGALAM CEMENT TRADERS & CO', 'N', NULL, 'ZDOM', 'CEMENT', '27.07.2023', NULL, NULL, 'AC20;AI10'),
('200191', 'Mangalam Cement Pvt Ltd', NULL, 'MANGALAMCE', '114, Ring Road', 'Bhuj', 'GJ', '383381', 'IN', '+91 7555735051', 'rohit.shukla@mangalamcement.in', 'VXECM8066I', '24VXECM8066I1ZD', 'IN', 'BARB0843528', '24497660856517', 'MANGALAM CEMENT PVT LTD', 'N', NULL, 'ZDOM', 'CEMENT', '13.01.2023', NULL, NULL, 'AC20;AE30'),
('200198', 'Sthapatya Steel LLP', NULL, 'STHAPATYAS', '57, Business Park', 'Rajkot', 'GJ', '382979', 'IN', '+91 7857541912', 'shreya.patel@sthapatyasteel.in', 'EKSFS7793Y', '24EKSFS7793Y1ZQ', 'IN', 'IDFB0378495', '28380125373', 'STHAPATYA STEEL LLP', 'Y', 'UDYAM-GJ-18-6479668', 'ZMSE', 'STEEL', '19.02.2022', NULL, NULL, 'AL40'),
('200205', 'Riddhi Steel Traders Pvt Ltd', NULL, 'RIDDHISTEE', '123, Ring Road', 'Gandhinagar', 'GJ', '389000', 'IN', '+91 6879419380', 'shreya.sheikh@riddhisteel.com', 'BFRCR9411H', '24BFRCR9411H1ZS', 'IN', 'IDFB0720754', '83548643906', 'Riddhi Steel Traders Pvt Ltd', 'Y', 'UDYAM-GJ-21-5196018', 'ZMSE', 'STEEL', '20.08.2022', NULL, NULL, 'AE30;AI10'),
('200212', 'Unnati Ispat Enterprises', NULL, 'UNNATIISPA', '8, Highway Complex', 'Bharuch', 'GJ', '384946', 'IN', '+91 7263201014', 'foram.brahmbhatt@unnatiispat.in', 'LFCFU3856Y', '24LFCFU3856Y1ZK', 'IN', 'KKBK0368828', '4472855689', 'Unnati Ispat Enterprises', 'N', NULL, 'ZDOM', 'STEEL', '05.12.2020', NULL, NULL, 'AL40'),
('200219', 'Bhagyoday Steel Ltd', NULL, 'BHAGYODAYS', '178, GIDC Estate', 'Mysuru', 'KA', '564041', 'IN', '+91 6162458707', 'rakesh.verma@bhagyodaysteel.com', 'ZJFCB3280I', '29ZJFCB3280I1ZB', 'IN', 'INDB0978043', '958176252807', 'Bhagyoday Steel Ltd', 'Y', 'UDYAM-KA-10-7944378', 'ZMSE', 'STEEL', '19.06.2019', NULL, NULL, 'AE30;AI10'),
('200226', 'Konark Ispat Pvt Ltd', NULL, 'KONARKISPA', '41, Trade Centre', 'Surat', 'GJ', '387913', 'IN', '+91 9303258528', 'sneha.gill@konarkispat.co.in', 'CNVCK8096G', '24CNVCK8096G1Z0', 'IN', 'SBIN0347897', '23311592123', 'KONARK ISPAT PVT LTD', 'Y', 'UDYAM-GJ-28-8707230', 'ZMSE', 'STEEL', '18.01.2024', NULL, NULL, 'AE30'),
('200233', 'Trikam Ispat LLP', NULL, 'TRIKAMISPA', '144, Industrial Area', 'Bhiwandi', 'MH', '416881', 'IN', '+91 6175430666', 'mahesh.pandya@trikamispat.in', 'APQFT8539I', '27APQFT8539I1ZH', 'IN', 'BARB0769908', '64177588814401', 'TRIKAM ISPAT LLP', 'N', NULL, 'ZDOM', 'STEEL', '04.10.2025', NULL, NULL, 'AI10;AL40'),
('200240', 'Nandan Metals & Co', NULL, 'NANDANMETA', '5, GIDC Estate', 'Ahmedabad', 'GJ', '382165', 'IN', '+91 7925479381', 'ankit.menon@nandanmetals.in', 'EKEFN1435D', '24EKEFN1435D1Z5', 'IN', 'PUNB0981524', '8357363856073927', 'NANDAN METALS & CO', 'N', NULL, 'ZDOM', 'STEEL', '13.10.2025', NULL, NULL, 'AE30'),
('200247', 'Bansi Minerals Pvt Ltd', NULL, 'BANSIMINER', '197, Highway Complex', 'Surat', 'GJ', '381430', 'IN', '+91 7154882025', 'rutvik.fernandes@bansiminerals.com', 'MXBCB9675O', '24MXBCB9675O1ZF', 'IN', 'SBIN0819539', '28276116603', 'Bansi Minerals Pvt Ltd', 'Y', 'UDYAM-GJ-23-9724276', 'ZMSE', 'AGGREGATE', '17.03.2022', NULL, NULL, 'AI10'),
('200254', 'MAHI AGGREGATES PVT LTD', NULL, 'MAHIAGGREG', '132, Business Park', 'Ahmedabad', 'GJ', '381567', 'IN', '+91 7631788513', 'vikram.verma@mahiaggregates.in', 'GWUCM2895O', '24GWUCM2895O1Z1', 'IN', 'INDB0370412', '243049074182', 'MAHI AGGREGATES PVT LTD', 'N', NULL, 'ZDOM', 'AGGREGATE', '18.04.2023', NULL, NULL, 'AC20'),
('200261', 'Orbit Aggregates Pvt Ltd', NULL, 'ORBITAGGRE', '52, Trade Centre', 'Ahmedabad', 'GJ', '386522', 'IN', '+91 9196196147', 'ankit.dave@orbitaggregates.co.in', 'NMRCO2464O', '24NMRCO2464O1ZQ', 'IN', 'CNRB0271051', '3983725278120', 'Orbit Aggregates Pvt Ltd', 'Y', 'UDYAM-GJ-26-5679635', 'ZMSE', 'AGGREGATE', '14.11.2025', NULL, NULL, 'AI10'),
('200268', 'Horizon Minerals LLP', NULL, 'HORIZONMIN', '175, Trade Centre', 'Bhuj', 'GJ', '383943', 'IN', '+91 7537777108', 'zoya.brahmbhatt@horizonminerals.co.in', 'AUIFH4899D', '24AUIFH4899D1Z1', 'IN', 'PUNB0480052', '8913729871120984', 'HORIZON MINERALS LLP', 'N', NULL, 'ZDOM', 'AGGREGATE', '20.08.2018', NULL, NULL, 'AL40'),
('200275', 'Arihant Stone Crusher Enterprises', NULL, 'ARIHANTSTO', '113, Highway Complex', 'Mumbai', 'MH', '415872', 'IN', '+91 7513564699', 'hetal.pathan@arihantstone.in', 'OSDFA2576H', '27OSDFA2576H1Z3', 'IN', 'BARB0479674', '62198033463521', 'ARIHANT STONE CRUSHER ENTERPRISES', 'N', NULL, 'ZDOM', 'AGGREGATE', '18.11.2023', NULL, NULL, 'AC20'),
('200282', 'Orbit Stone Crusher & Co', NULL, 'ORBITSTONE', '189, Trade Centre', 'Anand', 'GJ', '384201', 'IN', '+91 8960132984', 'sagar.dsouza@orbitstone.co.in', 'RMWFO5319L', '24RMWFO5319L1ZH', 'IN', 'IDFB0927670', '50985846388', 'Orbit Stone Crusher & Co', 'Y', 'UDYAM-GJ-20-3849340', 'ZMSE', 'AGGREGATE', '25.06.2023', NULL, NULL, 'AE30;AL40'),
('200289', 'NANDAN MINERALS PVT LTD', NULL, 'NANDANMINE', '56, Industrial Area', 'Anand', 'GJ', '389036', 'IN', '+91 6203844809', 'vikram.shah@nandanminerals.in', 'NMTCN6967Z', '24NMTCN6967Z1ZN', 'IN', 'UTIB0683508', '211361795816354', 'Nandan Minerals Pvt Ltd', 'Y', 'UDYAM-GJ-26-8933659', 'ZMSE', 'AGGREGATE', '22.06.2019', NULL, NULL, 'AE30;AL40'),
('200296', 'Aashirwad Labour Contractors Ltd', NULL, 'AASHIRWADL', '39, Highway Complex', 'Sanand', 'GJ', '388639', 'IN', '+91 9217011682', 'priyanka.trivedi@aashirwadlabour.co.in', 'GZRCA8957K', '24GZRCA8957K1ZB', 'IN', 'UBIN0107617', '807751062614883', 'AASHIRWAD LABOUR CONTRACTORS LTD', 'Y', 'UDYAM-GJ-07-8106560', 'ZMSE', 'MANPOWER', '01.03.2023', NULL, NULL, 'AI10'),
('200303', 'Trikam Workforce Solutions & Co', NULL, 'TRIKAMWORK', '22, Trade Centre', 'Jodhpur', 'RJ', '305328', 'IN', '+91 9274999413', 'pooja.nair@trikamworkforce.com', 'YZNFT2676W', '08YZNFT2676W1ZQ', 'IN', 'UTIB0569943', '928640894874643', 'TRIKAM WORKFORCE SOLUTIONS & CO', 'N', NULL, 'ZDOM', 'MANPOWER', '10.05.2022', NULL, NULL, 'AE30;AI10'),
('200310', 'Harsiddhi Workforce Solutions Pvt', 'Ltd', 'HARSIDDHIW', '157, Highway Complex', 'Surat', 'GJ', '387165', 'IN', '+91 6861307985', 'shreya.iyer@harsiddhiworkforce.in', 'TTKCH6213X', '24TTKCH6213X1Z7', 'IN', 'CNRB0156795', '7505654705670', 'HARSIDDHI WORKFORCE SOLUTIONS PVT LTD', 'N', NULL, 'ZDOM', 'MANPOWER', '25.02.2018', NULL, NULL, 'AE30'),
('200317', 'Garuda Labour Contractors LLP', NULL, 'GARUDALABO', '159, Trade Centre', 'Rajkot', 'GJ', '388473', 'IN', '+91 6912206401', 'chirag.qureshi@garudalabour.co.in', 'AGGFG1944C', '24AGGFG1944C1ZJ', 'IN', 'UTIB0198890', '521631111960278', 'GARUDA LABOUR CONTRACTORS LLP', 'N', NULL, 'ZDOM', 'MANPOWER', '18.06.2024', NULL, NULL, 'AI10'),
('200324', 'Uday Manpower Services Pvt Ltd', NULL, 'UDAYMANPOW', '106, Highway Complex', 'Vadodara', 'GJ', '388226', 'IN', '+91 8519740001', 'hetal.verma@udaymanpower.in', 'IURCU3703T', '24IURCU3703T1Z7', 'IN', 'PUNB0204126', '4478923524013761', 'UDAY MANPOWER SERVICES PVT LTD', 'N', NULL, 'ZDOM', 'MANPOWER', '19.06.2018', NULL, NULL, 'AI10;AL40'),
('200331', 'Unnati Labour Contractors & Co', NULL, 'UNNATILABO', '202, Industrial Area', 'Bharuch', 'GJ', '383798', 'IN', '+91 8957186821', 'sneha.verma@unnatilabour.in', 'ICJFU9831R', '24ICJFU9831R1ZX', 'IN', 'ICIC0238416', '597533257192', 'Unnati Labour Contractors & Co', 'N', NULL, 'ZDOM', 'MANPOWER', '12.09.2018', NULL, NULL, 'AE30'),
('200338', 'Aravalli Workforce Solutions LLP', NULL, 'ARAVALLIWO', '174, Highway Complex', 'Ahmedabad', 'GJ', '382177', 'IN', '+91 8680477595', 'ishaan.panchal@aravalliworkforce.in', 'JEIFA8442M', '24JEIFA8442M1ZQ', 'IN', 'YESB0420146', '233800530514786', 'Aravalli Workforce Solutions LLP', 'Y', 'UDYAM-GJ-31-6305105', 'ZMSE', 'MANPOWER', '12.01.2021', NULL, NULL, 'AI10;AL40'),
('200345', 'DARSHAN GUARDING SERVICES', 'ENTERPRISES', 'DARSHANGUA', '196, GIDC Estate', 'Mumbai', 'MH', '411340', 'IN', '+91 8329114756', 'aditi.iyer@darshanguarding.com', 'UUKFD6948G', '27UUKFD6948G1ZD', 'IN', 'INDB0670907', '376151413633', 'Darshan Guarding Services Enterprises', 'N', NULL, 'ZDOM', 'SECURITY', '02.02.2018', NULL, NULL, 'AE30;AL40'),
('200352', 'Meridian Protection Force LLP', NULL, 'MERIDIANPR', '143, Highway Complex', 'Vadodara', 'GJ', '384292', 'IN', '+91 7894229772', 'imran.reddy@meridianprotection.in', 'GWTFM5940F', '24GWTFM5940F1ZN', 'IN', 'KKBK0166539', '9997453581', 'Meridian Protection Force LLP', 'N', NULL, 'ZDOM', 'SECURITY', '15.02.2020', NULL, NULL, 'AI10'),
('200359', 'Sthapatya Security Services Ltd', NULL, 'STHAPATYAS', '214, Highway Complex', 'Jodhpur', 'RJ', '306507', 'IN', '+91 8759439832', 'riya.kothari@sthapatyasecurity.com', 'TNOCS8449B', '08TNOCS8449B1ZP', 'IN', 'KKBK0865611', '5108235953', 'Sthapatya Security Services Ltd', 'Y', 'UDYAM-RJ-05-7502623', 'ZMSE', 'SECURITY', '22.01.2022', NULL, NULL, 'AC20;AI10'),
('200366', 'Shivam Security Services & Co', NULL, 'SHIVAMSECU', '46, Highway Complex', 'New Delhi', 'DL', '112521', 'IN', '+91 6576405265', 'anjali.shukla@shivamsecurity.co.in', 'IOQFS2218Y', '07IOQFS2218Y1Z2', 'IN', 'INDB0956808', '110005200700', 'Shivam Security Services & Co', 'N', NULL, 'ZDOM', 'SECURITY', '05.10.2021', NULL, NULL, 'AI10;AL40'),
('200373', 'DARSHAN SECURITY SERVICES PVT LTD', NULL, 'DARSHANSEC', '25, Highway Complex', 'Mehsana', 'GJ', '387550', 'IN', '+91 7103699727', 'dhaval.fernandes@darshansecurity.in', 'BGBCD6108Q', '24BGBCD6108Q1Z5', 'IN', 'INDB0114635', '210203830040', 'Darshan Security Services Pvt Ltd', 'N', NULL, 'ZDOM', 'SECURITY', '13.03.2022', NULL, NULL, 'AC20;AE30'),
('200380', 'Suryoday Protection Force Pvt Ltd', NULL, 'SURYODAYPR', '11, Trade Centre', 'Mysuru', 'KA', '562533', 'IN', '+91 9834733429', 'nisha.parikh@suryodayprotection.in', 'DKLCS3921S', '29DKLCS3921S1ZS', 'IN', 'UTIB0297705', '892992398133702', 'SURYODAY PROTECTION FORCE PVT LTD', 'N', NULL, 'ZDOM', 'SECURITY', '12.02.2024', NULL, NULL, 'AE30'),
('200387', 'RADHE SECURITY SERVICES & CO', NULL, 'RADHESECUR', '140, Ring Road', 'Hubballi', 'KA', '561926', 'IN', '+91 9385162353', 'kruti.kapadia@radhesecurity.in', 'TDJFR9011A', '29TDJFR9011A1ZO', 'IN', 'CNRB0516768', '3597348124172', 'RADHE SECURITY SERVICES & CO', 'Y', 'UDYAM-KA-28-7631480', 'ZMSE', 'SECURITY', '14.12.2021', NULL, NULL, 'AL40'),
('200394', 'Orbit Facility Services & Co', NULL, 'ORBITFACIL', '7, Business Park', 'Pithampur', 'MP', '455818', 'IN', '+91 6420654917', 'arjun.chauhan@orbitfacility.co.in', 'AVTFO3848A', '23AVTFO3848A1Z2', 'IN', 'INDB0262837', '195060188987', 'ORBIT FACILITY SERVICES & CO', 'N', NULL, 'ZDOM', 'HOUSEKEEPING', '15.02.2023', NULL, NULL, 'AL40'),
('200401', 'Crestline Facility Services Pvt Ltd', NULL, 'CRESTLINEF', '206, Industrial Area', 'Vadodara', 'GJ', '388664', 'IN', '+91 9918058326', 'kruti.fernandes@crestlinefacility.co.in', 'KFMCC6971X', '24KFMCC6971X1ZV', 'IN', 'PUNB0608219', '7121385607002238', 'CRESTLINE FACILITY SERVICES PVT LTD', 'N', NULL, 'ZDOM', 'HOUSEKEEPING', '11.10.2024', NULL, NULL, 'AI10'),
('200408', 'Narmada Housekeeping Services Pvt', 'Ltd', 'NARMADAHOU', '181, GIDC Estate', 'Rajkot', 'GJ', '388141', 'IN', '+91 6929248006', 'gurpreet.bhatt@narmadahousekeepin.co.in', 'YMKCN6252B', '24YMKCN6252B1ZC', 'IN', 'ICIC0711243', '451658509868', 'NARMADA HOUSEKEEPING SERVICES PVT LTD', 'Y', 'UDYAM-GJ-13-9128827', 'ZMSE', 'HOUSEKEEPING', '09.06.2019', NULL, NULL, 'AE30'),
('200415', 'Sabar Facility Services Enterprises', NULL, 'SABARFACIL', '1, Ring Road', 'Surat', 'GJ', '382930', 'IN', '+91 8958554964', 'foram.sheikh@sabarfacility.co.in', 'UAEFS3899L', '24UAEFS3899L1Z0', 'IN', 'HDFC0148294', '28341908238613', 'Sabar Facility Services Enterprises', 'N', NULL, 'ZDOM', 'HOUSEKEEPING', '05.12.2019', NULL, NULL, 'AL40'),
('200422', 'Vishwakarma Facility Services Pvt', 'Ltd', 'VISHWAKARM', '183, GIDC Estate', 'Aurangabad', 'MH', '416891', 'IN', '+91 9142416521', 'aakash.iyer@vishwakarmafacilit.in', 'VWMCV4354P', '27VWMCV4354P1ZN', 'IN', 'INDB0685424', '376412974476', 'Vishwakarma Facility Services Pvt Ltd', 'Y', 'UDYAM-MH-20-3875278', 'ZMSE', 'HOUSEKEEPING', '15.12.2022', NULL, NULL, 'AC20;AE30'),
('200429', 'Unnati Facility Services & Co', NULL, 'UNNATIFACI', '106, GIDC Estate', 'Ahmedabad', 'GJ', '386533', 'IN', '+91 8966141117', 'gurpreet.verma@unnatifacility.in', 'VLKFU1346J', '24VLKFU1346J1ZU', 'IN', 'UBIN0333879', '368771099644469', 'Unnati Facility Services & Co', 'Y', 'UDYAM-GJ-28-5445146', 'ZMSE', 'HOUSEKEEPING', '15.04.2018', NULL, NULL, 'AE30;AL40'),
('200436', 'Sthapatya Facility Services LLP', NULL, 'STHAPATYAF', '91, GIDC Estate', 'Surat', 'GJ', '387701', 'IN', '+91 7879547503', 'sameer.raval@sthapatyafacility.in', 'ENMFS1067P', '24ENMFS1067P1ZT', 'IN', 'BARB0480788', '30396220987695', 'STHAPATYA FACILITY SERVICES LLP', 'N', NULL, 'ZDOM', 'HOUSEKEEPING', '04.02.2025', NULL, NULL, 'AC20'),
('200443', 'Shree Umiya Roadlines & Co', NULL, 'SHREEUMIYA', '5, GIDC Estate', 'Mehsana', 'GJ', '387952', 'IN', '+91 9393338348', 'ankit.patel@shreeumiyaroadline.co.in', 'NVAFS1482F', '24NVAFS1482F1ZY', 'IN', 'INDB0929844', '378206244317', 'SHREE UMIYA ROADLINES & CO', 'N', NULL, 'ZDOM', 'TRANSPORT', '07.05.2024', NULL, NULL, 'AI10;AL40'),
('200450', 'SAMARTH LOGISTICS PVT LTD', NULL, 'SAMARTHLOG', '195, Ring Road', 'Mehsana', 'GJ', '385906', 'IN', '+91 7883096393', 'simran.vaghela@samarthlogistics.in', 'OOTCS3593C', '24OOTCS3593C1ZW', 'IN', 'KKBK0796725', '3189903321', 'Samarth Logistics Pvt Ltd', 'N', NULL, 'ZDOM', 'TRANSPORT', '14.09.2024', NULL, NULL, 'AI10'),
('200457', 'Gokul Logistics Enterprises', NULL, 'GOKULLOGIS', '8, Business Park', 'Indore', 'MP', '453081', 'IN', '+91 6860101057', 'aakash.trivedi@gokullogistics.com', 'QGYFG2945F', '23QGYFG2945F1ZE', 'IN', 'UBIN0207425', '757983717634526', 'Gokul Logistics Enterprises', 'Y', 'UDYAM-MP-24-3507071', 'ZMSE', 'TRANSPORT', '09.12.2024', NULL, NULL, 'AE30'),
('200464', 'Ekta Roadlines Pvt Ltd', NULL, 'EKTAROADLI', '85, Business Park', 'Bharuch', 'GJ', '381753', 'IN', '+91 9649255388', 'gurpreet.kothari@ektaroadlines.in', 'TYJCE7730B', '24TYJCE7730B1Z2', 'IN', 'UBIN0074851', '581013315604083', 'Ekta Roadlines Pvt Ltd', 'N', NULL, 'ZDOM', 'TRANSPORT', '25.11.2023', NULL, NULL, 'AC20;AE30'),
('200471', 'Riddhi Roadlines Pvt Ltd', NULL, 'RIDDHIROAD', '91, Highway Complex', 'Sanand', 'GJ', '386710', 'IN', '+91 7181280782', 'hetal.qureshi@riddhiroadlines.in', 'SWKCR5681I', '24SWKCR5681I1Z8', 'IN', 'KKBK0025490', '3188904995', 'Riddhi Roadlines Pvt Ltd', 'Y', 'UDYAM-GJ-16-3247011', 'ZMSE', 'TRANSPORT', '08.03.2022', NULL, NULL, 'AC20'),
('200478', 'Chitra Logistics Pvt Ltd', NULL, 'CHITRALOGI', '78, Ring Road', 'Aurangabad', 'MH', '419328', 'IN', '+91 6792559915', 'imran.chauhan@chitralogistics.com', 'YOSCC6224D', '27YOSCC6224D1Z5', 'IN', 'PUNB0498065', '6856252845618634', 'CHITRA LOGISTICS PVT LTD', 'Y', 'UDYAM-MH-01-6592248', 'ZMSE', 'TRANSPORT', '03.07.2023', NULL, NULL, 'AE30;AI10'),
('200485', 'Sabar Transport Co Enterprises', NULL, 'SABARTRANS', '54, Industrial Area', 'Jaipur', 'RJ', '302220', 'IN', '+91 7799285662', 'priyanka.sanghvi@sabartransport.in', 'NSWFS5696F', '08NSWFS5696F1ZW', 'IN', 'PUNB0307477', '8638869180441861', 'Sabar Transport Co Enterprises', 'Y', 'UDYAM-RJ-30-2368350', 'ZMSE', 'TRANSPORT', '27.01.2022', NULL, NULL, 'AE30'),
('200492', 'SANKALP ELECTRIC CO LTD', NULL, 'SANKALPELE', '115, Ring Road', 'Surat', 'GJ', '387263', 'IN', '+91 9919515898', 'jinal.dsouza@sankalpelectric.in', 'DIGCS6918I', '24DIGCS6918I1ZK', 'IN', 'YESB0724664', '222028485258025', 'Sankalp Electric Co Ltd', 'Y', 'UDYAM-GJ-29-9916586', 'ZMSE', 'ELECTRICAL', '03.09.2025', NULL, NULL, 'AE30;AI10'),
('200499', 'Chitra Switchgear & Co', NULL, 'CHITRASWIT', '223, Business Park', 'Anand', 'GJ', '386652', 'IN', '+91 7174763036', 'aakash.brahmbhatt@chitraswitchgear.in', 'ISSFC7596Y', '24ISSFC7596Y1ZL', 'IN', 'CNRB0575660', '6548367088785', 'CHITRA SWITCHGEAR & CO', 'N', NULL, 'ZDOM', 'ELECTRICAL', '25.05.2020', NULL, NULL, 'AC20'),
('200506', 'Bhumi Electric Co Enterprises', NULL, 'BHUMIELECT', '146, GIDC Estate', 'Mehsana', 'GJ', '388257', 'IN', '+91 9730073034', 'aarav.parikh@bhumielectric.in', 'IQGFB7671U', '24IQGFB7671U1ZI', 'IN', 'KKBK0035750', '6807778545', 'BHUMI ELECTRIC CO ENTERPRISES', 'Y', 'UDYAM-GJ-11-3312179', 'ZMSE', 'ELECTRICAL', '04.01.2019', NULL, NULL, 'AC20;AI10'),
('200513', 'Nandan Electric Co & Co', NULL, 'NANDANELEC', '72, Ring Road', 'Bhuj', 'GJ', '383030', 'IN', '+91 8601920590', 'riya.singh@nandanelectric.in', 'GXXFN9697G', '24GXXFN9697G1ZS', 'IN', 'SBIN0435115', '47873667471', 'NANDAN ELECTRIC CO & CO', 'N', NULL, 'ZDOM', 'ELECTRICAL', '03.04.2020', NULL, NULL, 'AI10'),
('200520', 'Samarth Switchgear LLP', NULL, 'SAMARTHSWI', '204, GIDC Estate', 'Anand', 'GJ', '385845', 'IN', '+91 8847082107', 'anjali.vyas@samarthswitchgear.in', 'PPDFS4708F', '24PPDFS4708F1Z6', 'IN', 'YESB0309642', '924314335918381', 'Samarth Switchgear LLP', 'N', NULL, 'ZDOM', 'ELECTRICAL', '10.08.2023', NULL, NULL, 'AE30'),
('200527', 'ARIHANT ELECTRICALS LLP', NULL, 'ARIHANTELE', '182, Ring Road', 'Coimbatore', 'TN', '603338', 'IN', '+91 6864425805', 'amit.shah@arihantelectricals.com', 'MFUFA8723C', '33MFUFA8723C1ZV', 'IN', 'SBIN0651162', '79583590271', 'Arihant Electricals LLP', 'N', NULL, 'ZDOM', 'ELECTRICAL', '27.09.2020', NULL, NULL, 'AC20;AI10'),
('200534', 'Orbit Switchgear Ltd', NULL, 'ORBITSWITC', '161, GIDC Estate', 'Gandhinagar', 'GJ', '388423', 'IN', '+91 9870651286', 'chirag.shah@orbitswitchgear.co.in', 'AKLCO2528U', '24AKLCO2528U1Z4', 'IN', 'INDB0146555', '822348883022', 'Orbit Switchgear Ltd', 'N', NULL, 'ZDOM', 'ELECTRICAL', '26.10.2022', NULL, NULL, 'AL40'),
('200541', 'KESAR CABLE INDUSTRIES & CO', NULL, 'KESARCABLE', '158, Industrial Area', 'Surat', 'GJ', '383340', 'IN', '+91 6598162050', 'hardik.reddy@kesarcable.com', 'HQZFK5382G', '24HQZFK5382G1ZO', 'IN', 'HDFC0354834', '57445199559392', 'Kesar Cable Industries & Co', 'Y', 'UDYAM-GJ-29-7201947', 'ZMSE', 'CABLE', '07.12.2018', NULL, NULL, 'AI10;AL40'),
('200548', 'QUARTZ CABLES LTD', NULL, 'QUARTZCABL', '127, Trade Centre', 'Anand', 'GJ', '387669', 'IN', '+91 6637637947', 'karthik.dsouza@quartzcables.co.in', 'OGACQ5035O', '24OGACQ5035O1ZK', 'IN', 'BARB0183761', '35398257537073', 'Quartz Cables Ltd', 'Y', 'UDYAM-GJ-04-6502534', 'ZMSE', 'CABLE', '02.10.2018', NULL, NULL, 'AI10'),
('200555', 'Crestline Wires and Cables Pvt Ltd', NULL, 'CRESTLINEW', '142, GIDC Estate', 'Surat', 'GJ', '385370', 'IN', '+91 9793854637', 'sana.thakkar@crestlinewires.in', 'ENICC5550K', '24ENICC5550K1ZP', 'IN', 'SBIN0310417', '36142251521', 'CRESTLINE WIRES AND CABLES PVT LTD', 'N', NULL, 'ZDOM', 'CABLE', '15.07.2025', NULL, NULL, 'AE30;AI10'),
('200562', 'JYOTI CABLE INDUSTRIES PVT LTD', NULL, 'JYOTICABLE', '41, Trade Centre', 'Chennai', 'TN', '601479', 'IN', '+91 9738502122', 'kavya.fernandes@jyoticable.com', 'LRVCJ2438Q', '33LRVCJ2438Q1ZI', 'IN', 'INDB0913175', '806016967644', 'JYOTI CABLE INDUSTRIES PVT LTD', 'Y', 'UDYAM-TN-29-8980203', 'ZMSE', 'CABLE', '08.09.2025', NULL, NULL, 'AC20;AI10'),
('200569', 'Darshan Wires and Cables & Co', NULL, 'DARSHANWIR', '81, Business Park', 'Sanand', 'GJ', '387854', 'IN', '+91 9836432447', 'sana.parikh@darshanwires.co.in', 'OXOFD8077W', '24OXOFD8077W1ZI', 'IN', 'HDFC0683754', '84154773337436', 'DARSHAN WIRES AND CABLES & CO', 'Y', 'UDYAM-GJ-25-1725638', 'ZMSE', 'CABLE', '27.01.2021', NULL, NULL, 'AL40'),
('200576', 'Dhara Wires and Cables Enterprises', NULL, 'DHARAWIRES', '171, Business Park', 'Sanand', 'GJ', '386077', 'IN', '+91 6958359110', 'chirag.amin@dharawires.co.in', 'DQHFD4458D', '24DQHFD4458D1ZO', 'IN', 'IDFB0216870', '88443173675', 'Dhara Wires and Cables Enterprises', 'Y', 'UDYAM-GJ-08-7249453', 'ZMSE', 'CABLE', '22.08.2020', NULL, NULL, 'AC20'),
('200583', 'Gokul Wires and Cables LLP', NULL, 'GOKULWIRES', '22, Industrial Area', 'Bhiwandi', 'MH', '411968', 'IN', '+91 6560920602', 'deepa.mehta@gokulwires.co.in', 'KDOFG6079Y', '27KDOFG6079Y1ZG', 'IN', 'IDFB0279736', '86669716973', 'GOKUL WIRES AND CABLES LLP', 'Y', 'UDYAM-MH-12-7524923', 'ZMSE', 'CABLE', '19.09.2022', NULL, NULL, 'AE30;AI10'),
('200590', 'ANAND SOLAR SYSTEMS & CO', NULL, 'ANANDSOLAR', '42, Industrial Area', 'Mumbai', 'MH', '415979', 'IN', '+91 6259909855', 'sana.oza@anandsolar.in', 'TTGFA8713S', '27TTGFA8713S1Z7', 'IN', 'YESB0471848', '178269550439744', 'Anand Solar Systems & Co', 'Y', 'UDYAM-MH-23-1175951', 'ZMSE', 'SOLAR', '04.03.2023', NULL, NULL, 'AC20'),
('200597', 'SANKALP SOLAR ENTERPRISES', NULL, 'SANKALPSOL', '203, Highway Complex', 'Surat', 'GJ', '387702', 'IN', '+91 9692912322', 'sana.singh@sankalpsolar.in', 'RNKFS4530L', '24RNKFS4530L1ZS', 'IN', 'ICIC0504997', '262262492170', 'SANKALP SOLAR ENTERPRISES', 'Y', 'UDYAM-GJ-06-4942062', 'ZMSE', 'SOLAR', '11.05.2025', NULL, NULL, 'AI10'),
('200604', 'Tapti Solar Systems Ltd', NULL, 'TAPTISOLAR', '88, GIDC Estate', 'Pithampur', 'MP', '455210', 'IN', '+91 8513654657', 'mahesh.rathod@taptisolar.co.in', 'VXUCT5294W', '23VXUCT5294W1Z0', 'IN', 'BARB0351976', '14343817216839', 'Tapti Solar Systems Ltd', 'N', NULL, 'ZDOM', 'SOLAR', '14.12.2019', NULL, NULL, 'AL40'),
('200611', 'Sthapatya Solar Pvt Ltd', NULL, 'STHAPATYAS', '91, GIDC Estate', 'Sanand', 'GJ', '383985', 'IN', '+91 7164239127', 'gurpreet.parmar@sthapatyasolar.in', 'BHKCS4041J', '24BHKCS4041J1ZX', 'IN', 'IDFB0748878', '20108102320', 'Sthapatya Solar Pvt Ltd', 'Y', 'UDYAM-GJ-32-8614099', 'ZMSE', 'SOLAR', '26.06.2024', NULL, NULL, 'AC20;AE30'),
('200618', 'MAHI RENEWABLES ENTERPRISES', NULL, 'MAHIRENEWA', '90, Industrial Area', 'Surat', 'GJ', '384301', 'IN', '+91 9223534541', 'sagar.mehta@mahirenewables.in', 'PYNFM3618R', '24PYNFM3618R1ZW', 'IN', 'YESB0161881', '543376001212066', 'Mahi Renewables Enterprises', 'N', NULL, 'ZDOM', 'SOLAR', '11.11.2018', NULL, NULL, 'AI10'),
('200625', 'Garuda Solar Systems Ltd', NULL, 'GARUDASOLA', '94, Highway Complex', 'Udaipur', 'RJ', '307832', 'IN', '+91 9205069107', 'chirag.trivedi@garudasolar.in', 'WERCG3159K', '08WERCG3159K1Z6', 'IN', 'HDFC0524913', '91146203258832', 'Garuda Solar Systems Ltd', 'Y', 'UDYAM-RJ-05-3148384', 'ZMSE', 'SOLAR', '27.12.2024', NULL, NULL, 'AI10;AL40'),
('200632', 'Omkar Solar & Co', NULL, 'OMKARSOLAR', '32, Ring Road', 'Bharuch', 'GJ', '385045', 'IN', '+91 7156632297', 'imran.panchal@omkarsolar.co.in', 'DBBFO3778S', '24DBBFO3778S1ZE', 'IN', 'KKBK0772108', '4579996195', 'Omkar Solar & Co', 'Y', 'UDYAM-GJ-08-4847664', 'ZMSE', 'SOLAR', '05.06.2023', NULL, NULL, 'AE30'),
('200639', 'Radhe Systems Pvt Ltd', NULL, 'RADHESYSTE', '83, Highway Complex', 'Jaipur', 'RJ', '308553', 'IN', '+91 7394624637', 'devang.mehta@radhesystems.com', 'NQPCR3294R', '08NQPCR3294R1ZZ', 'IN', 'CNRB0112116', '9445584195708', 'Radhe Systems Pvt Ltd', 'Y', 'UDYAM-RJ-12-2775244', 'ZMSE', 'IT_HW', '18.10.2018', NULL, NULL, 'AI10'),
('200646', 'Aravalli Systems & Co', NULL, 'ARAVALLISY', '211, Ring Road', 'Mysuru', 'KA', '568844', 'IN', '+91 6145033918', 'hardik.gill@aravallisystems.in', 'HUSFA6053T', '29HUSFA6053T1Z2', 'IN', 'ICIC0404918', '153501919652', 'ARAVALLI SYSTEMS & CO', 'Y', 'UDYAM-KA-17-3138531', 'ZMSE', 'IT_HW', '10.11.2021', NULL, NULL, 'AL40'),
('200653', 'Prayag Systems LLP', NULL, 'PRAYAGSYST', '122, Highway Complex', 'Surat', 'GJ', '381381', 'IN', '+91 6870131975', 'gurpreet.parikh@prayagsystems.in', 'JBYFP8539M', '24JBYFP8539M1ZV', 'IN', 'KKBK0656200', '2108753070', 'PRAYAG SYSTEMS LLP', 'Y', 'UDYAM-GJ-22-4869377', 'ZMSE', 'IT_HW', '23.06.2019', NULL, NULL, 'AC20'),
('200660', 'Sabar Computers & Co', NULL, 'SABARCOMPU', '82, Trade Centre', 'Bengaluru', 'KA', '565644', 'IN', '+91 9746331826', 'ankit.parikh@sabarcomputers.in', 'ADOFS3177P', '29ADOFS3177P1ZZ', 'IN', 'ICIC0293131', '490026440818', 'Sabar Computers & Co', 'Y', 'UDYAM-KA-04-5659780', 'ZMSE', 'IT_HW', '07.11.2023', NULL, NULL, 'AE30;AI10'),
('200667', 'Orbit Infotech Enterprises', NULL, 'ORBITINFOT', '161, GIDC Estate', 'Bengaluru', 'KA', '568522', 'IN', '+91 7139929741', 'aakash.jadeja@orbitinfotech.in', 'GFIFO7220U', '29GFIFO7220U1ZX', 'IN', 'BARB0946432', '20772575509008', 'ORBIT INFOTECH ENTERPRISES', 'N', NULL, 'ZDOM', 'IT_HW', '09.06.2022', NULL, NULL, 'AE30'),
('200674', 'Aravalli Computers Pvt Ltd', NULL, 'ARAVALLICO', '77, Business Park', 'Mehsana', 'GJ', '384523', 'IN', '+91 9355177968', 'farhan.shah@aravallicomputers.com', 'KBPCA8670O', '24KBPCA8670O1ZK', 'IN', 'UTIB0964103', '507512280856903', 'ARAVALLI COMPUTERS PVT LTD', 'Y', 'UDYAM-GJ-33-2727041', 'ZMSE', 'IT_HW', '10.06.2022', NULL, NULL, 'AI10;AL40'),
('200681', 'Tirth Infotech Ltd', NULL, 'TIRTHINFOT', '203, Business Park', 'Bharuch', 'GJ', '382853', 'IN', '+91 9434284198', 'chirag.qureshi@tirthinfotech.co.in', 'XVWCT8507E', '24XVWCT8507E1Z5', 'IN', 'ICIC0505265', '270336996538', 'Tirth Infotech Ltd', 'Y', 'UDYAM-GJ-27-8728228', 'ZMSE', 'IT_HW', '16.04.2020', NULL, NULL, 'AE30'),
('200688', 'SANKALP DIGITAL SERVICES LLP', NULL, 'SANKALPDIG', '65, Trade Centre', 'Pithampur', 'MP', '457812', 'IN', '+91 6687165442', 'bhavin.vaghela@sankalpdigital.in', 'GJEFS9139K', '23GJEFS9139K1Z6', 'IN', 'BARB0023729', '71317857104249', 'Sankalp Digital Services LLP', 'N', NULL, 'ZDOM', 'IT_SVC', '17.08.2022', NULL, NULL, 'AC20'),
('200695', 'Lotus IT Solutions Ltd', NULL, 'LOTUSITSOL', '160, Industrial Area', 'Vadodara', 'GJ', '382697', 'IN', '+91 7401656131', 'parth.parikh@lotusit.co.in', 'YQKCL4078T', '24YQKCL4078T1Z1', 'IN', 'BARB0095117', '12775216214461', 'LOTUS IT SOLUTIONS LTD', 'N', NULL, 'ZDOM', 'IT_SVC', '19.12.2023', NULL, NULL, 'AC20;AL40'),
('200702', 'Mangalam IT Solutions LLP', NULL, 'MANGALAMIT', '37, Industrial Area', 'Bhilwara', 'RJ', '304599', 'IN', '+91 9955923154', 'sameer.nair@mangalamit.com', 'EBLFM6316I', '08EBLFM6316I1ZV', 'IN', 'INDB0258966', '595071353493', 'MANGALAM IT SOLUTIONS LLP', 'Y', 'UDYAM-RJ-25-2675537', 'ZMSE', 'IT_SVC', '13.04.2024', NULL, NULL, 'AC20'),
('200709', 'Yamuna Digital Services & Co', NULL, 'YAMUNADIGI', '38, Highway Complex', 'Bengaluru', 'KA', '569652', 'IN', '+91 6146215215', 'urvashi.panchal@yamunadigital.com', 'NJDFY8613H', '29NJDFY8613H1ZW', 'IN', 'CNRB0188120', '7419711005249', 'YAMUNA DIGITAL SERVICES & CO', 'N', NULL, 'ZDOM', 'IT_SVC', '09.02.2023', NULL, NULL, 'AC20;AI10'),
('200716', 'AASHIRWAD DIGITAL SERVICES PVT LTD', NULL, 'AASHIRWADD', '73, Ring Road', 'Bhuj', 'GJ', '385656', 'IN', '+91 7107904240', 'chirag.amin@aashirwaddigital.com', 'FJCCA1189R', '24FJCCA1189R1ZN', 'IN', 'HDFC0860719', '74678318453145', 'Aashirwad Digital Services Pvt Ltd', 'N', NULL, 'ZDOM', 'IT_SVC', '10.05.2023', NULL, NULL, 'AC20;AL40'),
('200723', 'Pragati Digital Services Pvt Ltd', NULL, 'PRAGATIDIG', '40, GIDC Estate', 'Sanand', 'GJ', '385616', 'IN', '+91 9907167745', 'farhan.kapadia@pragatidigital.com', 'PUYCP5617A', '24PUYCP5617A1ZS', 'IN', 'BARB0204687', '11125157897948', 'PRAGATI DIGITAL SERVICES PVT LTD', 'N', NULL, 'ZDOM', 'IT_SVC', '26.03.2018', NULL, NULL, 'AI10'),
('200730', 'PRAYAG IT SOLUTIONS PVT LTD', NULL, 'PRAYAGITSO', '120, Ring Road', 'Gandhinagar', 'GJ', '389426', 'IN', '+91 8661128323', 'nirav.thakkar@prayagit.in', 'RICCP7973Q', '24RICCP7973Q1ZO', 'IN', 'BARB0510054', '75986584619573', 'Prayag IT Solutions Pvt Ltd', 'Y', 'UDYAM-GJ-06-9202341', 'ZMSE', 'IT_SVC', '05.04.2019', NULL, NULL, 'AE30'),
('200737', 'Zenith Advisory LLP', NULL, 'ZENITHADVI', '184, Business Park', 'Sanand', 'GJ', '382896', 'IN', '+91 7385330060', 'maria.shah@zenithadvisory.in', 'FTMFZ4945I', '24FTMFZ4945I1ZE', 'IN', 'IDFB0124157', '53890327069', 'Zenith Advisory LLP', 'Y', 'UDYAM-GJ-17-9586020', 'ZMSE', 'CONSULTING', '02.10.2019', NULL, NULL, 'AI10'),
('200744', 'Saurashtra Advisory Pvt Ltd', NULL, 'SAURASHTRA', '108, Highway Complex', 'Sanand', 'GJ', '381579', 'IN', '+91 7347684869', 'lakshmi.kothari@saurashtraadvisory.co.in', 'SEPCS3687I', '24SEPCS3687I1Z1', 'IN', 'UTIB0364270', '675540819507392', 'SAURASHTRA ADVISORY PVT LTD', 'N', NULL, 'ZDOM', 'CONSULTING', '07.02.2019', NULL, NULL, 'AE30;AI10'),
('200751', 'Sai Krupa Engineering Consultants', 'Pvt Ltd', 'SAIKRUPAEN', '31, Ring Road', 'Jaipur', 'RJ', '306662', 'IN', '+91 7678364991', 'deepa.nair@saikrupaengineerin.in', 'XLPCS5315U', '08XLPCS5315U1Z2', 'IN', 'IDFB0093423', '14054187359', 'SAI KRUPA ENGINEERING CONSULTANTS PVT LTD', 'N', NULL, 'ZDOM', 'CONSULTING', '03.04.2024', NULL, NULL, 'AC20'),
('200758', 'Samarth Consultants Pvt Ltd', NULL, 'SAMARTHCON', '172, Ring Road', 'Mehsana', 'GJ', '385138', 'IN', '+91 6924544352', 'nisha.gill@samarthconsultants.in', 'SFNCS3870P', '24SFNCS3870P1ZU', 'IN', 'HDFC0651229', '35790817362184', 'SAMARTH CONSULTANTS PVT LTD', 'N', NULL, 'ZDOM', 'CONSULTING', '17.05.2023', NULL, NULL, 'AC20'),
('200765', 'Sankalp Consultants Ltd', NULL, 'SANKALPCON', '1, Ring Road', 'Vadodara', 'GJ', '385250', 'IN', '+91 8941350691', 'rohit.nair@sankalpconsultants.com', 'XFZCS3647G', '24XFZCS3647G1ZX', 'IN', 'SBIN0253120', '24129432144', 'Sankalp Consultants Ltd', 'Y', 'UDYAM-GJ-15-5406237', 'ZMSE', 'CONSULTING', '07.06.2024', NULL, NULL, 'AI10'),
('200772', 'Omkar Advisory & Co', NULL, 'OMKARADVIS', '129, Ring Road', 'New Delhi', 'DL', '111809', 'IN', '+91 6911888714', 'kruti.panchal@omkaradvisory.in', 'UXXFO3642Q', '07UXXFO3642Q1ZF', 'IN', 'UTIB0122822', '384980730465239', 'OMKAR ADVISORY & CO', 'N', NULL, 'ZDOM', 'CONSULTING', '01.10.2023', NULL, NULL, 'AC20'),
('200779', 'Horizon Engineering Consultants Ltd', NULL, 'HORIZONENG', '154, Trade Centre', 'Bhuj', 'GJ', '381448', 'IN', '+91 9152686677', 'meera.menon@horizonengineering.co.in', 'BYRCH6009L', '24BYRCH6009L1ZU', 'IN', 'KKBK0841644', '2320765364', 'HORIZON ENGINEERING CONSULTANTS LTD', 'N', NULL, 'ZDOM', 'CONSULTING', '16.02.2024', NULL, NULL, 'AL40'),
('200786', 'Tapti Infra LLP', NULL, 'TAPTIINFRA', '127, Industrial Area', 'Hubballi', 'KA', '566696', 'IN', '+91 6380977745', 'deepa.dsouza@taptiinfra.co.in', 'JMBFT7769L', '29JMBFT7769L1ZD', 'IN', 'KKBK0175911', '6060213311', 'TAPTI INFRA LLP', 'Y', 'UDYAM-KA-16-2791256', 'ZMSE', 'CIVIL_WORKS', '20.05.2023', NULL, NULL, 'AC20;AL40'),
('200793', 'Bhumi Builders Ltd', NULL, 'BHUMIBUILD', '206, Trade Centre', 'Bhuj', 'GJ', '387503', 'IN', '+91 7991384909', 'dhaval.vaghela@bhumibuilders.com', 'VPDCB9829C', '24VPDCB9829C1ZD', 'IN', 'PUNB0984446', '6370500620139141', 'BHUMI BUILDERS LTD', 'Y', 'UDYAM-GJ-17-4409699', 'ZMSE', 'CIVIL_WORKS', '21.03.2021', NULL, NULL, 'AC20;AL40'),
('200800', 'Indus Infra Pvt Ltd', NULL, 'INDUSINFRA', '117, Business Park', 'Bhilwara', 'RJ', '307440', 'IN', '+91 7644996308', 'kavya.iyer@indusinfra.co.in', 'QHUCI3497M', '08QHUCI3497M1ZO', 'IN', 'CNRB0480761', '4420779416557', 'INDUS INFRA PVT LTD', 'N', NULL, 'ZDOM', 'CIVIL_WORKS', '13.08.2022', NULL, NULL, 'AC20'),
('200807', 'Tirth Infraprojects Enterprises', NULL, 'TIRTHINFRA', '185, GIDC Estate', 'Surat', 'GJ', '389837', 'IN', '+91 8731225501', 'sneha.sheikh@tirthinfraprojects.co.in', 'IIQFT2992A', '24IIQFT2992A1ZD', 'IN', 'SBIN0635446', '54332943030', 'TIRTH INFRAPROJECTS ENTERPRISES', 'N', NULL, 'ZDOM', 'CIVIL_WORKS', '08.08.2019', NULL, NULL, 'AE30;AI10'),
('200814', 'JYOTI INFRAPROJECTS LTD', NULL, 'JYOTIINFRA', '52, GIDC Estate', 'Mumbai', 'MH', '416067', 'IN', '+91 7214290180', 'ankit.gill@jyotiinfraprojects.in', 'PDACJ2041U', '27PDACJ2041U1ZM', 'IN', 'UTIB0866941', '653635492640886', 'JYOTI INFRAPROJECTS LTD', 'Y', 'UDYAM-MH-25-2221822', 'ZMSE', 'CIVIL_WORKS', '16.05.2023', NULL, NULL, 'AC20'),
('200821', 'Avadh Infra Pvt Ltd', NULL, 'AVADHINFRA', '220, Ring Road', 'Nashik', 'MH', '419812', 'IN', '+91 6424592497', 'rakesh.brahmbhatt@avadhinfra.co.in', 'MZECA3346D', '27MZECA3346D1ZA', 'IN', 'HDFC0889510', '98283259489354', 'Avadh Infra Pvt Ltd', 'N', NULL, 'ZDOM', 'CIVIL_WORKS', '11.03.2023', NULL, NULL, 'AE30'),
('200828', 'ESHAN CONSTRUCTIONS PVT LTD', NULL, 'ESHANCONST', '138, Ring Road', 'Surat', 'GJ', '383703', 'IN', '+91 7496510207', 'joseph.sanghvi@eshanconstructions.in', 'NHCCE6011Y', '24NHCCE6011Y1ZF', 'IN', 'YESB0491588', '281906377117294', 'Eshan Constructions Pvt Ltd', 'N', NULL, 'ZDOM', 'CIVIL_WORKS', '08.10.2022', NULL, NULL, 'AL40'),
('200835', 'Omkar Equipment Hire LLP', NULL, 'OMKAREQUIP', '35, Highway Complex', 'Gandhinagar', 'GJ', '381906', 'IN', '+91 8297001526', 'yash.amin@omkarequipment.in', 'FAYFO8579G', '24FAYFO8579G1Z7', 'IN', 'UTIB0293258', '485153482864642', 'Omkar Equipment Hire LLP', 'N', NULL, 'ZDOM', 'EQUIP_RENTAL', '28.04.2025', NULL, NULL, 'AE30;AL40'),
('200842', 'Deccan Earthmovers Pvt Ltd', NULL, 'DECCANEART', '124, Trade Centre', 'Vadodara', 'GJ', '382317', 'IN', '+91 7734348723', 'jignesh.chauhan@deccanearthmovers.in', 'UAFCD3338T', '24UAFCD3338T1ZM', 'IN', 'SBIN0547850', '52103778597', 'DECCAN EARTHMOVERS PVT LTD', 'N', NULL, 'ZDOM', 'EQUIP_RENTAL', '01.02.2025', NULL, NULL, 'AC20;AI10'),
('200849', 'RUDRA EARTHMOVERS PVT LTD', NULL, 'RUDRAEARTH', '173, Highway Complex', 'Mumbai', 'MH', '412114', 'IN', '+91 7407890622', 'vikram.mehta@rudraearthmovers.co.in', 'ZKRCR5781V', '27ZKRCR5781V1ZL', 'IN', 'PUNB0240686', '4037484538105981', 'Rudra Earthmovers Pvt Ltd', 'Y', 'UDYAM-MH-30-3426026', 'ZMSE', 'EQUIP_RENTAL', '02.08.2019', NULL, NULL, 'AE30'),
('200856', 'DECCAN CRANE SERVICES PVT LTD', NULL, 'DECCANCRAN', '176, Business Park', 'Vadodara', 'GJ', '386776', 'IN', '+91 9658035697', 'nirav.parmar@deccancrane.in', 'JTHCD3272P', '24JTHCD3272P1ZZ', 'IN', 'UBIN0375578', '802852413248340', 'Deccan Crane Services Pvt Ltd', 'Y', 'UDYAM-GJ-29-7601293', 'ZMSE', 'EQUIP_RENTAL', '26.05.2021', NULL, NULL, 'AE30;AI10'),
('200863', 'Bhagyoday Equipment Hire Pvt Ltd', NULL, 'BHAGYODAYE', '96, Industrial Area', 'Rajkot', 'GJ', '388253', 'IN', '+91 6787704647', 'simran.sheikh@bhagyodayequipment.co.in', 'NQFCB8232Q', '24NQFCB8232Q1Z1', 'IN', 'CNRB0002409', '5407411397415', 'Bhagyoday Equipment Hire Pvt Ltd', 'Y', 'UDYAM-GJ-14-9095328', 'ZMSE', 'EQUIP_RENTAL', '04.01.2023', NULL, NULL, 'AC20;AL40'),
('200870', 'Darshan Earthmovers Pvt Ltd', NULL, 'DARSHANEAR', '38, Business Park', 'Mehsana', 'GJ', '387656', 'IN', '+91 8669682543', 'zoya.rathod@darshanearthmovers.com', 'NKWCD1601C', '24NKWCD1601C1Z4', 'IN', 'KKBK0837083', '7488285729', 'Darshan Earthmovers Pvt Ltd', 'Y', 'UDYAM-GJ-17-2986881', 'ZMSE', 'EQUIP_RENTAL', '22.08.2022', NULL, NULL, 'AC20;AE30'),
('200877', 'VRAJ CRANE SERVICES ENTERPRISES', NULL, 'VRAJCRANES', '16, Ring Road', 'Surat', 'GJ', '387215', 'IN', '+91 7257642612', 'gurpreet.gill@vrajcrane.com', 'XEIFV6454U', '24XEIFV6454U1ZB', 'IN', 'ICIC0427751', '619747277859', 'Vraj Crane Services Enterprises', 'N', NULL, 'ZDOM', 'EQUIP_RENTAL', '12.10.2024', NULL, NULL, 'AC20'),
('200884', 'HARSIDDHI INDUSTRIAL SAFETY LTD', NULL, 'HARSIDDHII', '183, Industrial Area', 'Surat', 'GJ', '387045', 'IN', '+91 8535675063', 'sameer.verma@harsiddhiindustria.co.in', 'LAQCH6001P', '24LAQCH6001P1ZY', 'IN', 'SBIN0312559', '12229777976', 'Harsiddhi Industrial Safety Ltd', 'Y', 'UDYAM-GJ-23-4809073', 'ZMSE', 'SAFETY_PPE', '12.12.2023', NULL, NULL, 'AC20;AE30'),
('200891', 'Arihant Safety Solutions Ltd', NULL, 'ARIHANTSAF', '34, Ring Road', 'Bharuch', 'GJ', '381969', 'IN', '+91 9503003188', 'heena.shah@arihantsafety.in', 'NWOCA3189C', '24NWOCA3189C1Z4', 'IN', 'INDB0351776', '974565001853', 'Arihant Safety Solutions Ltd', 'Y', 'UDYAM-GJ-10-4219038', 'ZMSE', 'SAFETY_PPE', '24.12.2019', NULL, NULL, 'AC20;AI10'),
('200898', 'Harsiddhi Industrial Safety Pvt Ltd', NULL, 'HARSIDDHII', '55, GIDC Estate', 'Mumbai', 'MH', '417137', 'IN', '+91 7835258455', 'rutvik.pandya@harsiddhiindustria.com', 'WFOCH4353C', '27WFOCH4353C1ZP', 'IN', 'CNRB0717865', '7100662334551', 'HARSIDDHI INDUSTRIAL SAFETY PVT LTD', 'N', NULL, 'ZDOM', 'SAFETY_PPE', '07.01.2020', NULL, NULL, 'AC20;AE30'),
('200905', 'Navjivan Safety Products Pvt Ltd', NULL, 'NAVJIVANSA', '122, Industrial Area', 'Mehsana', 'GJ', '389441', 'IN', '+91 8113169017', 'krunal.sharma@navjivansafety.com', 'BQOCN5673A', '24BQOCN5673A1ZI', 'IN', 'IDFB0285723', '83312196013', 'Navjivan Safety Products Pvt Ltd', 'N', NULL, 'ZDOM', 'SAFETY_PPE', '13.08.2023', NULL, NULL, 'AI10;AL40'),
('200912', 'Kaveri Safety Solutions & Co', NULL, 'KAVERISAFE', '118, Highway Complex', 'Bharuch', 'GJ', '385120', 'IN', '+91 9972158048', 'manan.dsouza@kaverisafety.in', 'IXPFK1964U', '24IXPFK1964U1ZU', 'IN', 'PUNB0034997', '7256915175075721', 'KAVERI SAFETY SOLUTIONS & CO', 'Y', 'UDYAM-GJ-08-9936719', 'ZMSE', 'SAFETY_PPE', '07.05.2020', NULL, NULL, 'AI10'),
('200919', 'Quartz Industrial Safety', 'Enterprises', 'QUARTZINDU', '133, GIDC Estate', 'Bharuch', 'GJ', '388230', 'IN', '+91 8331514834', 'bhavin.panchal@quartzindustrial.co.in', 'GPBFQ8033P', '24GPBFQ8033P1ZW', 'IN', 'SBIN0760399', '82463767378', 'QUARTZ INDUSTRIAL SAFETY ENTERPRISES', 'N', NULL, 'ZDOM', 'SAFETY_PPE', '16.03.2022', NULL, NULL, 'AI10'),
('200926', 'Avadh Safety Products Pvt Ltd', NULL, 'AVADHSAFET', '14, Ring Road', 'Vadodara', 'GJ', '384309', 'IN', '+91 7673921467', 'neha.trivedi@avadhsafety.co.in', 'EZNCA5476D', '24EZNCA5476D1Z4', 'IN', 'HDFC0556838', '30801125006530', 'AVADH SAFETY PRODUCTS PVT LTD', 'N', NULL, 'ZDOM', 'SAFETY_PPE', '05.05.2024', NULL, NULL, 'AI10;AL40'),
('200933', 'Radhe Testing Laboratory LLP', NULL, 'RADHETESTI', '150, Trade Centre', 'Gandhinagar', 'GJ', '385472', 'IN', '+91 6937145380', 'foram.rao@radhetesting.co.in', 'HZWFR6133F', '24HZWFR6133F1ZD', 'IN', 'YESB0742061', '866752590617641', 'Radhe Testing Laboratory LLP', 'Y', 'UDYAM-GJ-04-8950770', 'ZMSE', 'LAB_TESTING', '16.08.2023', NULL, NULL, 'AE30'),
('200940', 'MANGALAM TESTING LABORATORY LTD', NULL, 'MANGALAMTE', '85, Industrial Area', 'Mumbai', 'MH', '414680', 'IN', '+91 9215190779', 'amit.brahmbhatt@mangalamtesting.in', 'ZLLCM2611E', '27ZLLCM2611E1ZE', 'IN', 'YESB0290777', '828842062053454', 'MANGALAM TESTING LABORATORY LTD', 'Y', 'UDYAM-MH-32-6771243', 'ZMSE', 'LAB_TESTING', '21.02.2019', NULL, NULL, 'AE30'),
('200947', 'Sai Krupa Testing Laboratory LLP', NULL, 'SAIKRUPATE', '136, GIDC Estate', 'Pune', 'MH', '414338', 'IN', '+91 8152674336', 'parth.trivedi@saikrupatesting.com', 'MAOFS4291Z', '27MAOFS4291Z1ZC', 'IN', 'BARB0319670', '84401878597029', 'SAI KRUPA TESTING LABORATORY LLP', 'Y', 'UDYAM-MH-14-4956253', 'ZMSE', 'LAB_TESTING', '20.11.2018', NULL, NULL, 'AE30'),
('200954', 'Shivam Quality Labs Pvt Ltd', NULL, 'SHIVAMQUAL', '16, Highway Complex', 'Pune', 'MH', '411452', 'IN', '+91 8267309348', 'palak.reddy@shivamquality.in', 'XRXCS9341X', '27XRXCS9341X1Z2', 'IN', 'IDFB0872879', '10592565708', 'SHIVAM QUALITY LABS PVT LTD', 'Y', 'UDYAM-MH-05-7569470', 'ZMSE', 'LAB_TESTING', '10.12.2023', NULL, NULL, 'AE30'),
('200961', 'Radhe Quality Labs Ltd', NULL, 'RADHEQUALI', '9, Industrial Area', 'Indore', 'MP', '454994', 'IN', '+91 6508396164', 'kruti.trivedi@radhequality.co.in', 'UOICR2097R', '23UOICR2097R1ZC', 'IN', 'CNRB0932071', '2664472660394', 'Radhe Quality Labs Ltd', 'N', NULL, 'ZDOM', 'LAB_TESTING', '21.05.2018', NULL, NULL, 'AI10'),
('200968', 'Mahalaxmi Quality Labs & Co', NULL, 'MAHALAXMIQ', '223, Trade Centre', 'Chennai', 'TN', '604821', 'IN', '+91 9818777572', 'riya.vyas@mahalaxmiquality.com', 'KXYFM9565E', '33KXYFM9565E1Z2', 'IN', 'IDFB0942567', '86959350351', 'MAHALAXMI QUALITY LABS & CO', 'N', NULL, 'ZDOM', 'LAB_TESTING', '21.12.2018', NULL, NULL, 'AC20;AI10'),
('200975', 'Pinnacle Quality Labs LLP', NULL, 'PINNACLEQU', '234, Industrial Area', 'Bhiwandi', 'MH', '416897', 'IN', '+91 7158432005', 'karthik.mehta@pinnaclequality.com', 'QZDFP2689K', '27QZDFP2689K1ZV', 'IN', 'INDB0040264', '595414950549', 'Pinnacle Quality Labs LLP', 'Y', 'UDYAM-MH-09-8830998', 'ZMSE', 'LAB_TESTING', '01.04.2021', NULL, NULL, 'AI10'),
('200982', 'Omkar Hospitality Pvt Ltd', NULL, 'OMKARHOSPI', '161, Industrial Area', 'New Delhi', 'DL', '118438', 'IN', '+91 9753282017', 'simran.verma@omkarhospitality.in', 'FNXCO7507W', '07FNXCO7507W1Z4', 'IN', 'UBIN0911235', '317065644949158', 'Omkar Hospitality Pvt Ltd', 'N', NULL, 'ZDOM', 'CATERING', '20.09.2023', NULL, NULL, 'AE30;AL40'),
('200989', 'Sabar Food Services LLP', NULL, 'SABARFOODS', '131, GIDC Estate', 'Anand', 'GJ', '382441', 'IN', '+91 7352285017', 'farhan.shah@sabarfood.in', 'FWZFS3059I', '24FWZFS3059I1Z7', 'IN', 'YESB0120831', '240423616447153', 'SABAR FOOD SERVICES LLP', 'N', NULL, 'ZDOM', 'CATERING', '10.10.2025', NULL, NULL, 'AC20;AE30'),
('200996', 'Bansi Food Services LLP', NULL, 'BANSIFOODS', '171, Ring Road', 'Anand', 'GJ', '384568', 'IN', '+91 9794506346', 'vivek.pandya@bansifood.in', 'NWBFB5169M', '24NWBFB5169M1ZP', 'IN', 'SBIN0861508', '71721496540', 'BANSI FOOD SERVICES LLP', 'N', NULL, 'ZDOM', 'CATERING', '26.02.2020', NULL, NULL, 'AE30'),
('201003', 'HARSIDDHI CATERERS LTD', NULL, 'HARSIDDHIC', '63, Ring Road', 'Sanand', 'GJ', '389482', 'IN', '+91 7874966619', 'vivek.kapadia@harsiddhicaterers.in', 'UHZCH1840W', '24UHZCH1840W1ZJ', 'IN', 'HDFC0510856', '39957021197496', 'Harsiddhi Caterers Ltd', 'N', NULL, 'ZDOM', 'CATERING', '13.06.2023', NULL, NULL, 'AE30;AL40'),
('201010', 'Horizon Hospitality LLP', NULL, 'HORIZONHOS', '92, Highway Complex', 'Bhopal', 'MP', '454807', 'IN', '+91 6320765017', 'rakesh.qureshi@horizonhospitality.in', 'UBFFH6379K', '23UBFFH6379K1ZF', 'IN', 'KKBK0755313', '1899986121', 'HORIZON HOSPITALITY LLP', 'Y', 'UDYAM-MP-11-2844051', 'ZMSE', 'CATERING', '04.07.2019', NULL, NULL, 'AE30'),
('201017', 'Kaveri Hospitality Enterprises', NULL, 'KAVERIHOSP', '74, GIDC Estate', 'Aurangabad', 'MH', '412517', 'IN', '+91 8521179000', 'anjali.bhatt@kaverihospitality.in', 'QYWFK2677G', '27QYWFK2677G1ZW', 'IN', 'INDB0501165', '935409502592', 'Kaveri Hospitality Enterprises', 'Y', 'UDYAM-MH-27-5883443', 'ZMSE', 'CATERING', '02.05.2023', NULL, NULL, 'AC20;AL40'),
('201024', 'Falcon Food Services LLP', NULL, 'FALCONFOOD', '165, GIDC Estate', 'Gandhinagar', 'GJ', '386692', 'IN', '+91 9221614440', 'meera.amin@falconfood.com', 'YYYFF4540H', '24YYYFF4540H1Z5', 'IN', 'BARB0557423', '42567104219052', 'Falcon Food Services LLP', 'N', NULL, 'ZDOM', 'CATERING', '17.04.2022', NULL, NULL, 'AC20;AL40'),
('201031', 'Tapti Access Systems Enterprises', NULL, 'TAPTIACCES', '191, Business Park', 'Rajkot', 'GJ', '382925', 'IN', '+91 8878809820', 'tejal.mehta@taptiaccess.in', 'LPPFT7158B', '24LPPFT7158B1ZV', 'IN', 'UBIN0652686', '152800243714413', 'TAPTI ACCESS SYSTEMS ENTERPRISES', 'N', NULL, 'ZDOM', 'SCAFFOLDING', '15.01.2022', NULL, NULL, 'AE30'),
('201038', 'Konark Scaffolding Pvt Ltd', NULL, 'KONARKSCAF', '41, Business Park', 'Bengaluru', 'KA', '562723', 'IN', '+91 9816198715', 'hetal.rathod@konarkscaffolding.com', 'IQSCK3335P', '29IQSCK3335P1ZI', 'IN', 'INDB0049799', '905736570034', 'Konark Scaffolding Pvt Ltd', 'N', NULL, 'ZDOM', 'SCAFFOLDING', '05.08.2018', NULL, NULL, 'AC20;AE30'),
('201045', 'Lotus Scaffolding Pvt Ltd', NULL, 'LOTUSSCAFF', '193, Trade Centre', 'New Delhi', 'DL', '115956', 'IN', '+91 8470186745', 'tejal.solanki@lotusscaffolding.in', 'CUACL7831H', '07CUACL7831H1ZB', 'IN', 'ICIC0375406', '271861700497', 'LOTUS SCAFFOLDING PVT LTD', 'Y', 'UDYAM-DL-17-3811059', 'ZMSE', 'SCAFFOLDING', '13.01.2023', NULL, NULL, 'AL40'),
('201052', 'Mahalaxmi Scaffolding & Co', NULL, 'MAHALAXMIS', '171, Ring Road', 'Sanand', 'GJ', '382045', 'IN', '+91 7102314425', 'venkat.sheikh@mahalaxmiscaffoldi.co.in', 'RUPFM3239Z', '24RUPFM3239Z1ZJ', 'IN', 'SBIN0556943', '75899143461', 'MAHALAXMI SCAFFOLDING & CO', 'Y', 'UDYAM-GJ-16-4575566', 'ZMSE', 'SCAFFOLDING', '14.04.2024', NULL, NULL, 'AI10'),
('201059', 'Gokul Formwork Systems Ltd', NULL, 'GOKULFORMW', '143, GIDC Estate', 'Chennai', 'TN', '608270', 'IN', '+91 7463347373', 'riya.gill@gokulformwork.in', 'BWSCG3024O', '33BWSCG3024O1Z0', 'IN', 'SBIN0595860', '80448149980', 'GOKUL FORMWORK SYSTEMS LTD', 'N', NULL, 'ZDOM', 'SCAFFOLDING', '06.06.2020', NULL, NULL, 'AC20;AI10'),
('201066', 'Nandan Formwork Systems Pvt Ltd', NULL, 'NANDANFORM', '179, Industrial Area', 'Bharuch', 'GJ', '386329', 'IN', '+91 9578480050', 'hardik.jadeja@nandanformwork.in', 'WIBCN2984Y', '24WIBCN2984Y1ZD', 'IN', 'IDFB0914251', '15979804339', 'NANDAN FORMWORK SYSTEMS PVT LTD', 'N', NULL, 'ZDOM', 'SCAFFOLDING', '20.03.2021', NULL, NULL, 'AE30;AL40'),
('201073', 'Pinnacle Access Systems Pvt Ltd', NULL, 'PINNACLEAC', '225, Highway Complex', 'Vadodara', 'GJ', '384615', 'IN', '+91 9588721974', 'anjali.sanghvi@pinnacleaccess.in', 'FAUCP4228M', '24FAUCP4228M1ZP', 'IN', 'SBIN0634624', '11886719001', 'PINNACLE ACCESS SYSTEMS PVT LTD', 'Y', 'UDYAM-GJ-33-8190000', 'ZMSE', 'SCAFFOLDING', '18.02.2020', NULL, NULL, 'AL40'),
('201080', 'Lotus Engineering Services Pvt Ltd', NULL, 'LOTUSENGIN', '199, Trade Centre', 'Indore', 'MP', '456447', 'IN', '+91 7358802580', 'rohit.dsouza@lotusengineering.in', 'MPXCL7800L', '23MPXCL7800L1ZS', 'IN', 'ICIC0850914', '544802008620', 'LOTUS ENGINEERING SERVICES PVT LTD', 'Y', 'UDYAM-MP-18-1106661', 'ZMSE', 'AMC', '25.03.2022', NULL, NULL, 'AI10'),
('201087', 'Mahi Engineering Services', 'Enterprises', 'MAHIENGINE', '170, Business Park', 'Surat', 'GJ', '389243', 'IN', '+91 7970036030', 'shreya.raval@mahiengineering.in', 'BWCFM1319F', '24BWCFM1319F1ZK', 'IN', 'BARB0528771', '87211053909301', 'MAHI ENGINEERING SERVICES ENTERPRISES', 'N', NULL, 'ZDOM', 'AMC', '15.01.2022', NULL, NULL, 'AC20;AI10'),
('201094', 'Kutch Engineering Services', 'Enterprises', 'KUTCHENGIN', '171, Trade Centre', 'Indore', 'MP', '457333', 'IN', '+91 8306703325', 'kruti.verma@kutchengineering.com', 'CWGFK3214L', '23CWGFK3214L1Z8', 'IN', 'UTIB0876750', '586521265006285', 'KUTCH ENGINEERING SERVICES ENTERPRISES', 'Y', 'UDYAM-MP-25-2886151', 'ZMSE', 'AMC', '26.06.2025', NULL, NULL, 'AC20;AE30'),
('201101', 'SAI KRUPA MAINTENANCE SERVICES & CO', NULL, 'SAIKRUPAMA', '195, Business Park', 'Bhopal', 'MP', '454104', 'IN', '+91 7962443874', 'mahesh.dsouza@saikrupamaintenanc.in', 'YREFS3021F', '23YREFS3021F1Z6', 'IN', 'UBIN0518960', '339332250327087', 'Sai Krupa Maintenance Services & Co', 'N', NULL, 'ZDOM', 'AMC', '27.04.2019', NULL, NULL, 'AI10'),
('201108', 'Garuda Technical Services Ltd', NULL, 'GARUDATECH', '12, Business Park', 'Anand', 'GJ', '381859', 'IN', '+91 9397906966', 'hiral.rathod@garudatechnical.com', 'USYCG2674O', '24USYCG2674O1Z4', 'IN', 'UTIB0149031', '183249575566598', 'Garuda Technical Services Ltd', 'Y', 'UDYAM-GJ-14-8924725', 'ZMSE', 'AMC', '13.08.2018', NULL, NULL, 'AE30;AI10'),
('201115', 'Vraj Maintenance Services Pvt Ltd', NULL, 'VRAJMAINTE', '208, Highway Complex', 'Pithampur', 'MP', '455455', 'IN', '+91 7560450808', 'priyanka.mehta@vrajmaintenance.co.in', 'PTHCV4624M', '23PTHCV4624M1ZL', 'IN', 'IDFB0874020', '94385225193', 'VRAJ MAINTENANCE SERVICES PVT LTD', 'N', NULL, 'ZDOM', 'AMC', '10.04.2018', NULL, NULL, 'AE30'),
('201122', 'BANSI ENGINEERING SERVICES PVT LTD', NULL, 'BANSIENGIN', '140, Industrial Area', 'Ahmedabad', 'GJ', '389934', 'IN', '+91 8578899427', 'bhavin.raval@bansiengineering.co.in', 'OVACB8233I', '24OVACB8233I1ZA', 'IN', 'PUNB0640463', '6360216730949857', 'Bansi Engineering Services Pvt Ltd', 'N', NULL, 'ZDOM', 'AMC', '26.07.2018', NULL, NULL, 'AC20'),
('300011', 'Bhagyoday Workforce Solutions', 'Enterprises', 'BHAGYODAYW', '124, Business Park', 'Bhuj', 'GJ', '385691', 'IN', '+91 8848860380', 'ankit.fernandes@bhagyodayworkforce.in', 'EDZFB9798J', '24EDZFB9798J1Z0', 'IN', 'IDFB0601489', '78640593867', 'BHAGYODAY WORKFORCE SOLUTIONS ENTERPRISES', 'N', NULL, 'ZDOM', 'MANPOWER', '10.08.2020', NULL, NULL, 'AC20'),
('300022', 'Chitra Security Services Pvt Ltd', NULL, 'CHITRASECU', '30, Industrial Area', 'Mysuru', 'KA', '565733', 'IN', '+91 7852984494', 'meera.sheikh@chitrasecurity.com', 'VPXCC2457L', '29VPXCC2457L1ZD', 'IN', 'BARB0665985', '39462821474536', 'CHITRA SECURITY SERVICES PVT LTD', 'Y', 'UDYAM-KA-02-7833980', 'ZMSE', 'SECURITY', '22.04.2019', NULL, NULL, 'AC20'),
('300033', 'Sankalp Housekeeping Services & Co', NULL, 'SANKALPHOU', '228, Trade Centre', 'Bhuj', 'GJ', '383279', 'IN', '+91 8297202079', 'gurpreet.desai@sankalphousekeepin.in', 'CVWFS1061H', '24CVWFS1061H1ZS', 'IN', 'HDFC0951604', '85815468472269', 'Sankalp Housekeeping Services & Co', 'N', NULL, 'ZDOM', 'HOUSEKEEPING', '23.02.2024', NULL, NULL, 'AC20'),
('300044', 'JYOTI LOGISTICS ENTERPRISES', NULL, 'JYOTILOGIS', '120, Business Park', 'Surat', 'GJ', '388507', 'IN', '+91 8727944714', 'nikhil.parikh@jyotilogistics.co.in', NULL, NULL, 'IN', 'YESB0470019', '978545642617741', 'JYOTI LOGISTICS ENTERPRISES', 'N', NULL, 'ZDOM', 'TRANSPORT', '24.06.2014', NULL, NULL, 'AL40'),
('300055', 'Lotus Quality Labs Enterprises', NULL, 'LOTUSQUALI', '138, Highway Complex', 'Mehsana', 'GJ', '385722', 'IN', '+91 7323266844', 'venkat.mistry@lotusquality.in', 'VXDFL4766B', '24VXDFL4766B1ZP', 'IN', 'SBIN0366601', '62443173282', 'Lotus Quality Labs Enterprises', 'N', NULL, 'ZDOM', 'LAB_TESTING', '23.10.2021', NULL, NULL, 'AL40'),
('300066', 'Mangalam Builders Pvt Ltd', NULL, 'MANGALAMBU', '28, Business Park', 'Gandhinagar', 'GJ', '383793', 'IN', '+91 8640994814', 'amit.amin@mangalambuilders.com', 'HMNCM7580W', '24HMNCM7580W1ZB', 'IN', 'SBIN0267260', '72173628256', 'Mangalam Builders Pvt Ltd', 'N', NULL, 'ZDOM', 'CIVIL_WORKS', '14.07.2025', NULL, NULL, 'AI10'),
('300077', 'FALCON EARTHMOVERS PVT LTD', NULL, 'FALCONEART', '125, Highway Complex', 'Faridabad', 'HR', '129639', 'IN', '+91 8879206529', 'parth.patel@falconearthmovers.co.in', 'FSPCF5474X', '06FSPCF5474X1Z5', 'IN', 'INDB0711284', '935774894352', 'FALCON EARTHMOVERS PVT LTD', 'Y', 'UDYAM-HR-30-9114432', 'ZMSE', 'EQUIP_RENTAL', '13.07.2023', NULL, NULL, 'AC20'),
('300088', 'NAVJIVAN FORMWORK SYSTEMS LLP', NULL, 'NAVJIVANFO', '178, Highway Complex', 'Pune', 'MH', '412849', 'IN', '+91 7194492792', 'mahesh.jadeja@navjivanformwork.in', 'QZOFN8165V', '27QZOFN8165V1Z1', 'IN', 'IDFB0896069', '58507027550', 'Navjivan Formwork Systems LLP', 'N', NULL, 'ZDOM', 'SCAFFOLDING', '28.04.2022', 'X', NULL, 'AC20'),
('300099', 'Tirth Concrete Enterprises', NULL, 'TIRTHCONCR', '176, Ring Road', 'Sanand', 'GJ', '389142', 'IN', '+91 7734616836', 'rutvik.singh@tirthconcrete.in', 'NMGFT8383F', '24NMGFT8383F1ZV', 'IN', 'BARB0353545', '85791944644502', 'Tirth Concrete Enterprises', 'N', NULL, 'ZDOM', 'RMC', '21.03.2018', NULL, NULL, 'AI10;AE30'),
('300110', 'CHITRA CEMENT TRADERS PVT LTD', NULL, 'CHITRACEME', '219, Industrial Area', 'Bharuch', 'GJ', '383536', 'IN', '+91 7685791434', 'tejal.parikh@chitracement.in', 'JPKCC2358W', '24JPKCC2358W1ZQ', 'IN', 'HDFC0219891', '68361784137588', 'Chitra Cement Traders Pvt Ltd', 'Y', 'UDYAM-GJ-30-8104433', 'ZMSE', 'CEMENT', '10.08.2018', NULL, NULL, 'AL40'),
('300121', 'Sai Krupa Metals Enterprises', NULL, 'SAIKRUPAME', '162, Industrial Area', 'Bengaluru', 'KA', '561938', 'IN', '+91 8226748717', 'imran.jadeja@saikrupametals.in', 'MFNFS3253K', '29MFNFS3253K1Z1', 'IN', 'HDFC0229238', '80760487992130', 'Sai Krupa Metals Enterprises', 'N', NULL, 'ZDOM', 'STEEL', '03.08.2025', NULL, NULL, 'AI10'),
('300132', 'GIRNAR STONE CRUSHER ENTERPRISES', NULL, 'GIRNARSTON', '143, Highway Complex', 'Sanand', 'GJ', '384474', 'IN', '+91 8919862238', 'tejal.kapadia@girnarstone.com', NULL, NULL, 'IN', 'BARB0407200', '26714980960078', 'Girnar Stone Crusher Enterprises', 'Y', 'UDYAM-GJ-15-8112035', 'ZMSE', 'AGGREGATE', '10.06.2016', NULL, NULL, 'AI10;AE30'),
('300143', 'Riddhi Electric Co & Co', NULL, 'RIDDHIELEC', '236, Business Park', 'Vadodara', 'GJ', '386793', 'IN', '+91 6880805730', 'gurpreet.dsouza@riddhielectric.in', 'VPMFR7132O', '24VPMFR7132O1Z9', 'IN', 'UTIB0105192', '220998822529179', 'RIDDHI ELECTRIC CO & CO', 'N', NULL, 'ZDOM', 'ELECTRICAL', '18.04.2024', NULL, NULL, 'AL40'),
('300154', 'Lotus Cables & Co', NULL, 'LOTUSCABLE', '9, Business Park', 'Jaipur', 'RJ', '302299', 'IN', '+91 8615429634', 'nikhil.parikh@lotuscables.in', 'QBWFL4781X', '08QBWFL4781X1Z6', 'IN', 'KKBK0974017', '3591769925', 'LOTUS CABLES & CO', 'N', NULL, 'ZDOM', 'CABLE', '25.07.2024', NULL, NULL, 'AL40'),
('300165', 'Jay Ambe Renewables Pvt Ltd', NULL, 'JAYAMBEREN', '157, GIDC Estate', 'Gandhinagar', 'GJ', '389267', 'IN', '+91 6989841830', 'priyanka.vaghela@jayamberenewables.in', 'MDKCJ3612I', '24MDKCJ3612I1Z6', 'IN', 'IDFB0663639', '95114292749', 'JAY AMBE RENEWABLES PVT LTD', 'Y', 'UDYAM-GJ-28-1131073', 'ZMSE', 'SOLAR', '21.10.2025', 'X', 'X', 'AI10'),
('300176', 'Yamuna Computers Enterprises', NULL, 'YAMUNACOMP', '190, GIDC Estate', 'Surat', 'GJ', '386762', 'IN', '+91 7274543418', 'shreya.panchal@yamunacomputers.in', 'OZPFY6926X', '24OZPFY6926X1ZW', 'IN', 'INDB0766653', '368203494710', 'YAMUNA COMPUTERS ENTERPRISES', 'Y', 'UDYAM-GJ-20-4769640', 'ZMSE', 'IT_HW', '15.09.2022', NULL, NULL, 'AI10;AE30'),
('300187', 'Ekta Technologies LLP', NULL, 'EKTATECHNO', '185, Business Park', 'Pithampur', 'MP', '458093', 'IN', '+91 8998899232', 'yash.shukla@ektatechnologies.co.in', 'TBEFE3060E', '23TBEFE3060E1ZH', 'IN', 'PUNB0811948', '1869133224680792', 'Ekta Technologies LLP', 'N', NULL, 'ZDOM', 'IT_SVC', '10.06.2022', NULL, NULL, 'AI10'),
('300198', 'NAVJIVAN ADVISORY PVT LTD', NULL, 'NAVJIVANAD', '21, Business Park', 'Bharuch', 'GJ', '384113', 'IN', '+91 7365109437', 'urvashi.singh@navjivanadvisory.in', 'BSJCN1763C', '24BSJCN1763C1ZO', 'IN', 'CNRB0752499', '8817330412556', 'NAVJIVAN ADVISORY PVT LTD', 'Y', 'UDYAM-GJ-20-8414070', 'ZMSE', 'CONSULTING', '24.02.2021', NULL, NULL, 'AL40'),
('300209', 'Lotus Safety Products LLP', NULL, 'LOTUSSAFET', '53, GIDC Estate', 'Gandhinagar', 'GJ', '389158', 'IN', '+91 9721883002', 'arjun.raval@lotussafety.co.in', 'FZQFL5748B', '24FZQFL5748B1ZO', 'IN', 'UBIN0004623', '257266355471873', 'Lotus Safety Products LLP', 'Y', 'UDYAM-GJ-11-5479402', 'ZMSE', 'SAFETY_PPE', '18.10.2023', NULL, NULL, 'AL40'),
('300220', 'MANGALAM ENGINEERING SERVICES LTD', NULL, 'MANGALAMEN', '192, Highway Complex', 'Ahmedabad', 'GJ', '387248', 'IN', '+91 6677936250', 'karan.dsouza@mangalamengineerin.com', NULL, NULL, 'IN', 'KKBK0238982', '9566516823', 'MANGALAM ENGINEERING SERVICES LTD', 'Y', 'UDYAM-GJ-19-8117257', 'ZMSE', 'AMC', '17.04.2014', NULL, NULL, 'AI10;AE30'),
('300231', 'Mahi Workforce Solutions Ltd', NULL, 'MAHIWORKFO', '45, Trade Centre', 'New Delhi', 'DL', '112096', 'IN', '+91 7264287480', 'riya.patel@mahiworkforce.com', 'XPXCM8584L', '07XPXCM8584L1ZR', 'IN', 'IDFB0299724', '44530820178', 'MAHI WORKFORCE SOLUTIONS LTD', 'Y', 'UDYAM-DL-20-8380818', 'ZMSE', 'MANPOWER', '28.09.2025', NULL, NULL, 'AI10'),
('300242', 'Sthapatya Security Services Pvt Ltd', NULL, 'STHAPATYAS', '211, GIDC Estate', 'Gandhinagar', 'GJ', '386091', 'IN', '+91 6827497455', 'tejal.fernandes@sthapatyasecurity2.com', 'VDBCS5627I', '24VDBCS5627I1ZM', 'IN', 'BARB0359798', '50438712683150', 'Sthapatya Security Services Pvt Ltd', 'Y', 'UDYAM-GJ-01-1016851', 'ZMSE', 'SECURITY', '16.12.2021', NULL, NULL, 'AL40'),
('300253', 'RUDRA FACILITY MANAGEMENT LTD', NULL, 'RUDRAFACIL', '147, Trade Centre', 'Mysuru', 'KA', '566245', 'IN', '+91 9963013838', 'yash.sheikh@rudrafacility.in', 'OGACR8725O', '29OGACR8725O1ZY', 'IN', 'UBIN0119550', '760568450094615', 'RUDRA FACILITY MANAGEMENT LTD', 'Y', 'UDYAM-KA-12-7952010', 'ZMSE', 'HOUSEKEEPING', '28.09.2025', 'X', NULL, 'AC20'),
('300264', 'Navjivan Transport Co LLP', NULL, 'NAVJIVANTR', '12, Business Park', 'Bhuj', 'GJ', '382316', 'IN', '+91 6479500016', 'simran.dave@navjivantransport.com', 'EXBFN2621X', '24EXBFN2621X1ZF', 'IN', 'UBIN0908263', '486231912511888', 'Navjivan Transport Co LLP', 'N', NULL, 'ZDOM', 'TRANSPORT', '07.02.2023', NULL, NULL, 'AI10'),
('300275', 'VRAJ MATERIAL TESTING LAB LTD', NULL, 'VRAJMATERI', '162, Industrial Area', 'Rajkot', 'GJ', '383584', 'IN', '+91 7332038630', 'devang.pandya@vrajmaterial.com', 'OEMCV7422J', '24OEMCV7422J1ZE', 'IN', 'ICIC0314736', '432854857966', 'Vraj Material Testing Lab Ltd', 'N', NULL, 'ZDOM', 'LAB_TESTING', '10.12.2025', NULL, NULL, 'AL40'),
('300286', 'RIDDHI CONSTRUCTIONS PVT LTD', NULL, 'RIDDHICONS', '5, Highway Complex', 'Rajkot', 'GJ', '387316', 'IN', '+91 6830457174', 'meera.mistry@riddhiconstruction.com', NULL, NULL, 'IN', 'YESB0356611', '230270239678407', 'RIDDHI CONSTRUCTIONS PVT LTD', 'Y', 'UDYAM-GJ-16-6916580', 'ZMSE', 'CIVIL_WORKS', '25.03.2014', NULL, NULL, 'AI10'),
('300297', 'Kesar Earthmovers Enterprises', NULL, 'KESAREARTH', '220, GIDC Estate', 'Rajkot', 'GJ', '389189', 'IN', '+91 6452662158', 'deepa.kothari@kesarearthmovers2.in', 'HORFK5163E', '24HORFK5163E1Z9', 'IN', 'BARB0733825', '38676619681273', 'Kesar Earthmovers Enterprises', 'Y', 'UDYAM-GJ-08-9655982', 'ZMSE', 'EQUIP_RENTAL', '09.08.2023', NULL, NULL, 'AC20'),
('300308', 'DHARA ACCESS SYSTEMS & CO', NULL, 'DHARAACCES', '91, Industrial Area', 'Mehsana', 'GJ', '386342', 'IN', '+91 9697491574', 'mitesh.trivedi@dharaaccess.co.in', 'ULDFD4189G', '24ULDFD4189G1ZB', 'IN', 'UTIB0601648', '294120283934700', 'DHARA ACCESS SYSTEMS & CO', 'N', NULL, 'ZDOM', 'SCAFFOLDING', '24.06.2020', NULL, NULL, 'AL40'),
('300319', 'Vishwakarma RMC & Co', NULL, 'VISHWAKARM', '200, Ring Road', 'Vadodara', 'GJ', '384165', 'IN', '+91 8474519300', 'hiral.sheikh@vishwakarmarmc.co.in', 'BKWFV1558F', '24BKWFV1558F1Z6', 'IN', 'HDFC0072534', '73947459506106', 'VISHWAKARMA RMC & CO', 'Y', 'UDYAM-GJ-25-2264720', 'ZMSE', 'RMC', '14.02.2018', NULL, NULL, 'AL40'),
('300330', 'Bansi Cement Enterprises', NULL, 'BANSICEMEN', '51, Business Park', 'Bharuch', 'GJ', '382349', 'IN', '+91 8357280948', 'simran.fernandes@bansicement.in', 'IYUFB8639N', '24IYUFB8639N1Z0', 'IN', 'HDFC0900168', '87595779646855', 'Bansi Cement Enterprises', 'N', NULL, 'ZDOM', 'CEMENT', '24.10.2018', NULL, NULL, 'AL40'),
('300341', 'Vishwakarma Technoloiges Pvt Ltd', NULL, 'VISHWAKARM', 'Office No. 250, Iscon Emporio', 'Surat', 'GJ', '386423', 'IN', '+91 8751178657', 'imran.shukla@vishwakarmatechnol.com', 'RCDCV6747W', '24RCDCV6747W1ZO', 'IN', 'SBIN0308015', '51635609683', 'VISHWAKARMA TECHNOLOGIES PRIVATE LIMITED', 'N', NULL, 'ZDOM', 'IT_SVC', '14.12.2019', NULL, NULL, 'AI10'),
('300352', 'HORIZONBUILDERS', NULL, 'HORIZONBUI', 'Shed No. A-52, GIDC Estate', 'Ahmedabad', 'GJ', '385297', 'IN', '+91 8560543382', 'amit.kapadia@horizonbuilders.co.in', NULL, NULL, 'IN', 'IDFB0092579', '89468627899', 'HORIZON BUILDERS', 'N', NULL, 'ZDOM', 'CIVIL_WORKS', '12.05.2016', NULL, NULL, 'AI10'),
('300363', 'PRAGATI LABOUR CONTRACTORS', NULL, 'PRAGATILAB', '63, Pinnacle Business Park, Ring Road', 'Surat', 'GJ', '381929', 'IN', '+91 8253111762', 'kinjal.shukla@pragatilabourcontr.com', 'DIUPD5561J', '24DIUPD5561J1ZV', 'IN', 'UTIB0506987', '433020418196935', 'PRAGATI LABOUR CONTRACTORS', 'Y', 'UDYAM-GJ-13-7608670', 'ZMSE', 'MANPOWER', '16.04.2020', 'X', NULL, 'AI10');
