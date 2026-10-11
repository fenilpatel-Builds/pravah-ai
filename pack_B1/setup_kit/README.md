# B1 setup kit

Ready-made tables so you do not seed them by hand. Your team still creates and owns the account the data lives in.

- `Column_Guide.csv` / `.md`: every table and column with a plain name and a one-line meaning.
- `csv_plain/`: one CSV per table with plain names. In Airtable, create a base and import one CSV per table. Airtable's free plan limits the records in a base, so load the tables your level needs (listed in 00_START_HERE.pdf).
- `supabase_seed.sql`: creates and fills every table in a Supabase project. Open the SQL editor, paste the file and run it. If the editor rejects the size, import the files in `csv_plain/` through the table editor instead.

Every value is text, exactly as in the pack. Reading the mixed date and amount formats correctly is part of the job. Documents and mail are not in the kit: upload the files your level needs to your document store and mailbox (see the Round 1 build guide).

Tables needed for the Round 1 minimum: `onboarding_request` (Onboarding_Requests), `document_requirement` (Document_Requirements), `received_document` (Received_Documents), `vendor_master` (Vendor_Master_Extract).
