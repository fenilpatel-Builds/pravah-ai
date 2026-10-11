-- ============================================================================
-- Pravah AI Extensions for Supabase (pravah-vendorflow)
-- 1. Contact Map (Redirects synthetic pack addresses to your Mailbox 2)
-- 2. Verification Audit Log (Persists all rule checks, evidence, and HITL decisions)
-- 3. Review Tasks (Human-in-the-Loop approval queue)
-- ============================================================================

-- Table 1: Contact Map
CREATE TABLE IF NOT EXISTS public."contact_map" (
    row_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pack_address text NOT NULL UNIQUE,
    redirect_to text NOT NULL,
    role_description text,
    created_at timestamptz DEFAULT timezone('utc'::text, now())
);

-- Seed initial contact mappings
-- NOTE: Replace 'your_mailbox_2@outlook.com' with your actual second Outlook address!
INSERT INTO public."contact_map" (pack_address, redirect_to, role_description)
VALUES
    ('vendor.onboarding@ashvakagroup.in', 'YOUR_MAILBOX_1@outlook.com', 'Desk Mailbox (Mailbox 1 - Triggers AI Employee)'),
    ('vendor.master@ashvakagroup.in', 'YOUR_MAILBOX_2@outlook.com', 'Master Data Team (Verified Handover Target)'),
    ('meera.amin@sankalpequipmenthi.co.in', 'YOUR_MAILBOX_2@outlook.com', 'Vendor Contact (Sankalp Equipment Hire)'),
    ('farhan.shah@ashvakagroup.in', 'YOUR_MAILBOX_2@outlook.com', 'Buyer (AC20 Rajkot RMC Plant)'),
    ('foram.shukla@ashvakagroup.in', 'YOUR_MAILBOX_2@outlook.com', 'Procurement Lead (AC20 / Approver)'),
    ('ronak.trivedi@ashvakagroup.in', 'YOUR_MAILBOX_2@outlook.com', 'Procurement Lead (AI10 / Approver)'),
    ('manan.kothari@ashvakagroup.in', 'YOUR_MAILBOX_2@outlook.com', 'Procurement Lead (AE30 / Approver)'),
    ('priyanka.sheikh@ashvakagroup.in', 'YOUR_MAILBOX_2@outlook.com', 'Procurement Lead (AL40 / Approver)')
ON CONFLICT (pack_address) DO NOTHING;

-- Table 2: Verification Audit Log
CREATE TABLE IF NOT EXISTS public."verification_audit" (
    audit_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id text NOT NULL,
    rule_id text NOT NULL,
    rule_area text,
    status text NOT NULL, -- PASS, FAIL, FLAG_APPROVAL, EXCEPTION
    evidence_summary text,
    detected_value text,
    expected_value text,
    human_review_required boolean DEFAULT false,
    evaluated_at timestamptz DEFAULT timezone('utc'::text, now())
);

-- Table 3: Human Review Tasks (Human-in-the-Loop Escalation Queue)
CREATE TABLE IF NOT EXISTS public."review_tasks" (
    task_id text PRIMARY KEY,
    request_id text NOT NULL,
    exception_type text NOT NULL, -- DUPLICATE_CHECK_DUP01, RENEWAL_EXP03, NAME_MISMATCH_XDC01
    assigned_to text NOT NULL,
    status text DEFAULT 'PENDING_APPROVAL', -- PENDING_APPROVAL, APPROVED, REJECTED, MERGED
    evidence_payload jsonb,
    human_decision text,
    decision_notes text,
    decided_by text,
    created_at timestamptz DEFAULT timezone('utc'::text, now()),
    decided_at timestamptz
);
