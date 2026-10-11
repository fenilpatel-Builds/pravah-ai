import unittest
import datetime
from pravah_engine import (
    normalize_name,
    names_match,
    validate_pan,
    validate_gstin,
    validate_ifsc,
    check_expiry,
    calculate_working_days,
    REFERENCE_DATE
)

class TestPravahEngine(unittest.TestCase):
    def test_name_matching(self):
        # Case 1: Identical legal names with suffix variants
        legal = "SANKALP EQUIPMENT HIRE PRIVATE LIMITED"
        chq = "SANKALP EQUIPMENT HIRE PVT. LTD."
        self.assertTrue(names_match(legal, chq), "Pvt. Ltd. should match Private Limited")
        
        # Case 2: Extra word 'Industries' should FAIL
        bank_letter = "M/s Sankalp Equipment Hire Industries Private Limited"
        self.assertFalse(names_match(legal, bank_letter), "Extra word 'Industries' must fail")
        
        # Case 3: Harmless M/s prefix and punctuation
        self.assertTrue(names_match("M/s Prayag Concrete Ltd.", "Prayag Concrete Limited"))
        
        # Case 4: Ampersand vs and
        self.assertTrue(names_match("ABC Engineering & Construction LLP", "ABC Engineering and Construction L.L.P."))

    def test_pan_validation(self):
        # Valid company PAN
        ok, msg = validate_pan("NLOCS1237Y", constitution="Private Limited Company")
        self.assertTrue(ok)
        
        # Invalid 4th character for company (P instead of C)
        ok, msg = validate_pan("NLOPS1237Y", constitution="Private Limited Company")
        self.assertFalse(ok)

    def test_gstin_validation(self):
        # Matching GSTIN and PAN
        ok, msg = validate_gstin("24NLOCS1237Y1ZE", pan="NLOCS1237Y", state_code="Gujarat")
        self.assertTrue(ok)
        
        # Embedded PAN mismatch
        ok, msg = validate_gstin("24ABCDE1234F1ZE", pan="NLOCS1237Y")
        self.assertFalse(ok)
        
        # State mismatch (24 = Gujarat, declared Maharashtra)
        ok, msg = validate_gstin("24NLOCS1237Y1ZE", state_code="Maharashtra")
        self.assertFalse(ok)

    def test_ifsc_validation(self):
        self.assertTrue(validate_ifsc("IDFB0305764")[0])
        self.assertFalse(validate_ifsc("IDFB1305764")[0])  # 5th char must be 0

    def test_expiry(self):
        # ISO runs to 2027-08-20 (Valid)
        status, _ = check_expiry("2027-08-20")
        self.assertEqual(status, "PASS")
        
        # Already expired before Oct 09, 2026
        status, _ = check_expiry("2026-09-15")
        self.assertEqual(status, "EXPIRED")
        
        # Expiring within 30 days (e.g. 2026-10-25)
        status, _ = check_expiry("2026-10-25")
        self.assertEqual(status, "FLAG_APPROVAL")

    def test_working_days_cadence(self):
        # Start Friday 2026-10-09 -> 2 working days -> Mon Oct 12, Tue Oct 13
        start = datetime.date(2026, 10, 9)
        due_chase1 = calculate_working_days(start, 2)
        self.assertEqual(due_chase1, datetime.date(2026, 10, 13))

if __name__ == "__main__":
    unittest.main()
