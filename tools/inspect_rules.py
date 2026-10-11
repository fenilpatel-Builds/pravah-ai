import pandas as pd

print("=== VERIFICATION RULES ===")
df_rules = pd.read_csv('pack_B1/setup_kit/csv_plain/verification_rule.csv')
for _, r in df_rules.iterrows():
    print(f"[{r['rule_id']}] ({r['rule_area']}) Applies to: {r['applies_to']}")
    print(f"  Rule: {r['rule_text']}")
    print(f"  Evidence: {r['evidence']}")
    print(f"  If not met: {r['if_not_met']}\n")

print("\n=== DOCUMENT REQUIREMENTS ===")
df_doc = pd.read_csv('pack_B1/setup_kit/csv_plain/document_requirement.csv')
for _, r in df_doc.iterrows():
    print(f"[{r['requirement_id']}] {r['document_name']} | Mandatory: {r['is_mandatory']} | Applies to: {r['applies_to']}")
