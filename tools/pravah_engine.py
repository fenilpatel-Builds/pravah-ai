#!/usr/bin/env python3
"""
pravah_engine.py - Core Deterministic Verification & Compliance Engine for Pravah AI
Ashvaka Industries Group - Vendor Onboarding Desk (Domain B: Track B1)
"""

import re
import datetime
from typing import Dict, List, Any, Tuple

# Fixed Business Reference Date per Hackathon Rules: 09 Oct 2026, 18:00 IST
REFERENCE_DATETIME = datetime.datetime(2026, 10, 9, 18, 0, 0)
REFERENCE_DATE = REFERENCE_DATETIME.date()

# Official Ashvaka Group Holidays 2026 (Excluding Weekends)
GROUP_HOLIDAYS_2026 = {
    datetime.date(2026, 8, 15),  # Independence Day
    datetime.date(2026, 8, 28),  # Raksha Bandhan
    datetime.date(2026, 9, 4),   # Janmashtami
    datetime.date(2026, 10, 2),  # Gandhi Jayanti
    datetime.date(2026, 10, 20), # Dussehra
    datetime.date(2026, 11, 9),  # Diwali
    datetime.date(2026, 11, 10), # Gujarati New Year
    datetime.date(2026, 11, 11), # Bhai Bij
}

def normalize_name(name: str) -> str:
    """
    Applies the official Ashvaka name normalization rules:
    - Drops capitalization, punctuation, extra spaces
    - Drops 'M/s' prefix
    - Treats Pvt Ltd, Private Limited, (P) Ltd, P. Ltd. as identical
    - Treats Limited and Ltd as identical
    - Treats LLP and L.L.P. as identical
    - Treats '&' and 'and' as identical
    """
    if not name:
        return ""
    
    s = name.strip()
    # Remove leading M/s or M/S
    s = re.sub(r'^(?:m/s|m/s\.)\s+', '', s, flags=re.IGNORECASE)
    
    # Replace & with and
    s = s.replace('&', ' and ')
    
    # Pre-collapse known dotted abbreviations before stripping dots
    s = re.sub(r'\bl\.l\.p\.?\b', 'llp', s, flags=re.IGNORECASE)
    s = re.sub(r'\bpvt\.?\s*ltd\.?\b', 'pvtltd', s, flags=re.IGNORECASE)
    s = re.sub(r'\(p\)\s*ltd\.?', 'pvtltd', s, flags=re.IGNORECASE)
    s = re.sub(r'\bp\.?\s*ltd\.?\b', 'pvtltd', s, flags=re.IGNORECASE)
    s = re.sub(r'\bprivate\s+limited\b', 'pvtltd', s, flags=re.IGNORECASE)
    s = re.sub(r'\blimited\b', 'ltd', s, flags=re.IGNORECASE)
    
    # Now remove all punctuation
    s = re.sub(r'[.,()\'"\-]', ' ', s)
    
    # Lowercase & collapse whitespace
    tokens = [t.lower() for t in s.split() if t]
    
    # Normalize remaining tokens
    normalized_tokens = []
    i = 0
    while i < len(tokens):
        token = tokens[i]
        if token in ["limited", "ltd"]:
            normalized_tokens.append("ltd")
        elif token in ["llp"]:
            normalized_tokens.append("llp")
        elif token in ["pvtltd"]:
            normalized_tokens.append("pvtltd")
        elif token in ["and"]:
            normalized_tokens.append("and")
        else:
            normalized_tokens.append(token)
        i += 1
    
    return " ".join(normalized_tokens)

def names_match(name1: str, name2: str) -> bool:
    norm1 = normalize_name(name1)
    norm2 = normalize_name(name2)
    return norm1 == norm2

def validate_pan(pan: str, constitution: str = None) -> Tuple[bool, str]:
    """VAL-02: 10 chars, 5 letters, 4 numbers, 1 letter. 4th char matches constitution."""
    if not pan or not isinstance(pan, str):
        return False, "PAN is missing or empty"
    pan = pan.strip().upper()
    if not re.match(r'^[A-Z]{5}[0-9]{4}[A-Z]$', pan):
        return False, f"Invalid PAN format: {pan}"
    
    fourth_char = pan[3]
    if constitution:
        const_norm = constitution.lower()
        if "private" in const_norm or "pvt" in const_norm or "company" in const_norm or "public" in const_norm:
            if fourth_char != 'C':
                return False, f"PAN 4th character '{fourth_char}' does not match company constitution ('C')"
        elif "llp" in const_norm or "partnership" in const_norm:
            if fourth_char not in ['F', 'L']:
                return False, f"PAN 4th character '{fourth_char}' does not match firm/LLP ('F')"
        elif "proprietor" in const_norm or "sole" in const_norm:
            if fourth_char != 'P':
                return False, f"PAN 4th character '{fourth_char}' does not match proprietorship ('P')"
    return True, "Valid PAN"

def validate_gstin(gstin: str, pan: str = None, state_code: str = None) -> Tuple[bool, str]:
    """VAL-01 & VAL-04: 15 chars, characters 3-12 equal PAN, state code matches."""
    if not gstin or not isinstance(gstin, str):
        return False, "GSTIN is missing or empty"
    gstin = gstin.strip().upper()
    if len(gstin) != 15 or not re.match(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]$', gstin):
        return False, f"Invalid GSTIN structure: {gstin}"
    
    gst_pan = gstin[2:12]
    if pan and gst_pan != pan.strip().upper():
        return False, f"GSTIN embedded PAN '{gst_pan}' does not match submitted PAN '{pan}'"
    
    gst_state = gstin[:2]
    if state_code:
        # State mapping check
        state_map = {
            "24": ["gujarat", "gj"],
            "27": ["maharashtra", "mh"],
            "08": ["rajasthan", "rj"],
            "23": ["madhya pradesh", "mp"]
        }
        target_states = state_map.get(gst_state, [])
        if target_states and state_code.lower() not in target_states:
            return False, f"GSTIN state code '{gst_state}' does not match declared state '{state_code}'"
    return True, "Valid GSTIN"

def validate_ifsc(ifsc: str) -> Tuple[bool, str]:
    """VAL-03: 11 characters: 4 letters, 0, 6 alphanumeric."""
    if not ifsc or not isinstance(ifsc, str):
        return False, "IFSC is missing"
    ifsc = ifsc.strip().upper()
    if not re.match(r'^[A-Z]{4}0[A-Z0-9]{6}$', ifsc):
        return False, f"Invalid IFSC structure: {ifsc}"
    return True, "Valid IFSC"

def check_expiry(expiry_date_str: str, has_renewal_receipt: bool = False, receipt_date_str: str = None) -> Tuple[str, str]:
    """
    EXP-01, EXP-02, EXP-03
    Returns: ('PASS' | 'FLAG_APPROVAL' | 'EXPIRED', message)
    """
    if not expiry_date_str:
        return "PASS", "No expiry date applicable"
    
    try:
        # parse date (handles YYYY-MM-DD or DD-MM-YYYY or DD.MM.YYYY)
        for fmt in ["%Y-%m-%d", "%d-%m-%Y", "%d.%m.%Y", "%d/%m/%Y"]:
            try:
                exp_date = datetime.datetime.strptime(expiry_date_str.strip(), fmt).date()
                break
            except ValueError:
                continue
        else:
            return "FLAG_APPROVAL", f"Unparseable expiry date: {expiry_date_str}"
    except Exception as e:
        return "FLAG_APPROVAL", f"Date error: {e}"
    
    days_until_expiry = (exp_date - REFERENCE_DATE).days
    
    if days_until_expiry < 0:
        if has_renewal_receipt and receipt_date_str:
            # Check EXP-03: renewal filed on/before expiry, receipt < 60 days old
            try:
                rec_date = datetime.datetime.strptime(receipt_date_str.strip(), "%Y-%m-%d").date()
                age = (REFERENCE_DATE - rec_date).days
                if age <= 60:
                    return "FLAG_APPROVAL", f"Document expired on {exp_date} but has valid renewal receipt ({age} days old). Needs human sign-off."
            except Exception:
                pass
        return "EXPIRED", f"Document lapsed on {exp_date} (verification date is {REFERENCE_DATE})"
    elif days_until_expiry <= 30:
        return "FLAG_APPROVAL", f"Document expires in {days_until_expiry} days ({exp_date}). Flag for approval and chase renewal."
    else:
        return "PASS", f"Document valid until {exp_date}"

def calculate_working_days(start_date: datetime.date, days_count: int) -> datetime.date:
    """Calculates future business date excluding weekends & Ashvaka holidays."""
    current = start_date
    added = 0
    while added < days_count:
        current += datetime.timedelta(days=1)
        # Saturday = 5, Sunday = 6
        if current.weekday() < 5 and current not in GROUP_HOLIDAYS_2026:
            added += 1
    return current
