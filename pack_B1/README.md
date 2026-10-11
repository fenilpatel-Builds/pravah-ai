# Vendor Onboarding: dataset

Vendor onboarding at Ashvaka Industries Group. Buyers raise onboarding requests; the Vendor Onboarding Desk sends each vendor a document checklist, collects what comes back by email, verifies it, chases what is missing or wrong, and hands a verified record to the master data team (vendor.master@ashvakagroup.in), who create the vendor in SAP. This pack is the desk's queue as of the date below.

Data as of 09 Oct 2026, 18:00 IST. Organisation: Ashvaka Industries Group (fictional). Every record, document and email is synthetic.

## What is where

- `B1_vendor_onboarding_export.xlsx`: the enterprise export as one workbook. `00_INDEX` describes it and `Field_Dictionary` explains every sheet.
- `csv/`: the same sheets as CSV files, one per sheet.
- `documents/`: one folder per request holding every attachment received so far, as the vendor named it
- `mailbox/inbox/`: emails received in vendor.onboarding@ashvakagroup.in up to the as-of time (.eml)
- `mailbox/staged_replies/`: vendor replies that arrive only after the desk sends the matching chase or request
- `mailbox/mailbox_index.csv`: one row per message; release_when says what releases each staged reply
- `reference/`: Verification_Rule_Set.md and .pdf (rules, chase cadence, holiday calendar, contacts)

## How the pieces connect

Each row of `Onboarding_Requests` is one request. The checklist the desk sent, and any chases, are in `Onboarding_Chase_Log` with their message_id. Vendor emails in `mailbox/inbox/` reply to those message ids (In-Reply-To) and quote the request id in the subject, though some vendors start a new thread, write from another address, or have a buyer forward their documents. Every attachment that has arrived is filed under `documents/<request_id>/` and listed in `Received_Documents`. Existing vendors are in `Vendor_Master_Extract`.

## Staged replies

`mailbox/staged_replies/` holds replies that have not arrived yet. Each one is released by an action on the desk's side, described in the `release_when` column of `mailbox/mailbox_index.csv` (for example, after chase round 1 is sent on a given request). A request that has no staged reply for a chase gets no reply to it. Staged replies carry the thread's existing Message-ID references, and their Date headers are indicative only.

## Formats

Dates appear in several formats. Timestamps are IST unless marked Z for UTC. Amounts use Indian digit grouping with some variation. PDFs from government portals, banks, certification bodies and vendors each have their own layout; some are scans with no text layer.

## Ground rules

- Treat 09 Oct 2026, 18:00 IST as the current time, and keep the business date as a setting in your build.
- Send outbound mail only to mailboxes you control. Every address in this pack is fictional.
- Staged replies are released by your team when the condition in mailbox_index.csv is met, by hand or with a simple automation, and should be shown in the demo.

## Using the data

Load the tables into the systems you connect (a database, an Airtable base, a ticketing or CRM tool) or park the files in a document store, and let your AI Employee read them through those integrations. The data is deliberately messy: mixed date and amount formats, spelling variants, blanks, duplicates, and documents that are present but wrong. Handling that is part of the job. Do not hardcode to these records; build for the pattern.

Google integrations (Drive, Sheets, Gmail, Calendar) are in beta for this event and must not be used. Host and read the data through alternatives such as Airtable, Supabase, SharePoint, OneDrive, Box, Dropbox or Outlook.
