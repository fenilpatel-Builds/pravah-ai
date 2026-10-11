import re

with open('pack_B1/setup_kit/supabase_seed.sql', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

for m in re.findall(r'create table public\.[^;]+;', text, re.IGNORECASE):
    print(m)
    print('='*50)
