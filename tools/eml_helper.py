#!/usr/bin/env python3
"""
eml_helper.py - Helper utility for inspecting, extracting, and listing .eml files
Conforming to the Supervity AutoPilot Hackathon build guide requirements.
"""

import sys
import os
import argparse
import email
from email import policy
import pandas as pd

def show_eml(filepath):
    if not os.path.exists(filepath):
        print(f"Error: File not found: {filepath}")
        return
    with open(filepath, "rb") as f:
        msg = email.message_from_binary_file(f, policy=policy.default)
    
    print("=" * 60)
    print(f"Subject : {msg['subject']}")
    print(f"From    : {msg['from']}")
    print(f"To      : {msg['to']}")
    print(f"Date    : {msg['date']}")
    print(f"Msg ID  : {msg['message-id']}")
    print(f"In-Reply: {msg['in-reply-to']}")
    print("-" * 60)
    
    body = msg.get_body(preferencelist=('plain', 'html'))
    if body:
        print("Body Content:\n")
        print(body.get_content())
    else:
        print("(No text body found)")
    print("-" * 60)
    
    attachments = list(msg.iter_attachments())
    if attachments:
        print(f"Attachments ({len(attachments)}):")
        for att in attachments:
            print(f" - {att.get_filename()} ({len(att.get_content())} bytes)")
    else:
        print("Attachments: None")
    print("=" * 60)

def extract_eml(filepath, outdir=None):
    if not os.path.exists(filepath):
        print(f"Error: File not found: {filepath}")
        return
    if not outdir:
        outdir = os.path.splitext(os.path.basename(filepath))[0] + "_extracted"
    os.makedirs(outdir, exist_ok=True)
    
    with open(filepath, "rb") as f:
        msg = email.message_from_binary_file(f, policy=policy.default)
    
    # Save body
    body = msg.get_body(preferencelist=('plain', 'html'))
    if body:
        body_file = os.path.join(outdir, "body.txt")
        with open(body_file, "w", encoding="utf-8") as bf:
            bf.write(body.get_content())
        print(f"Saved body to {body_file}")
    
    # Save attachments
    count = 0
    for att in msg.iter_attachments():
        fn = att.get_filename() or f"attachment_{count+1}"
        target_path = os.path.join(outdir, fn)
        with open(target_path, "wb") as af:
            af.write(att.get_content())
        print(f"Saved attachment: {target_path}")
        count += 1
    print(f"Extraction complete. {count} attachment(s) extracted into '{outdir}'.")

def list_eml(dataset_dir, thread_id=None):
    index_path = os.path.join(dataset_dir, "mailbox", "mailbox_index.csv")
    if not os.path.exists(index_path):
        # try direct
        index_path = os.path.join(dataset_dir, "mailbox_index.csv")
    
    if not os.path.exists(index_path):
        print(f"Error: mailbox_index.csv not found under {dataset_dir}")
        return
    
    df = pd.read_csv(index_path)
    if thread_id:
        df = df[df['thread_id'] == thread_id]
        print(f"Found {len(df)} message(s) for Thread {thread_id}:")
    else:
        print(f"Showing all messages in index ({len(df)} total):")
    
    for _, row in df.iterrows():
        print(f"[{row.get('folder', '')}] {row.get('file', '')}")
        print(f"  Thread: {row.get('thread_id')} | MsgID: {row.get('message_id')}")
        print(f"  From  : {row.get('from')} -> To: {row.get('to')}")
        print(f"  Subj  : {row.get('subject')}")
        if pd.notna(row.get('release_when')):
            print(f"  Release When: {row.get('release_when')}")
        print("-" * 50)

def main():
    parser = argparse.ArgumentParser(description="Pravah AI EML Helper Utility")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # show
    p_show = subparsers.add_parser("show", help="Show .eml metadata and body")
    p_show.add_argument("file", help="Path to .eml file")
    
    # extract
    p_ext = subparsers.add_parser("extract", help="Extract body and attachments from .eml")
    p_ext.add_argument("file", help="Path to .eml file")
    p_ext.add_argument("--outdir", help="Output directory")
    
    # list
    p_list = subparsers.add_parser("list", help="List staged replies or threads in dataset")
    p_list.add_argument("dataset", help="Path to dataset directory")
    p_list.add_argument("--thread", help="Filter by thread ID")
    
    args = parser.parse_args()
    if args.command == "show":
        show_eml(args.file)
    elif args.command == "extract":
        extract_eml(args.file, args.outdir)
    elif args.command == "list":
        list_eml(args.dataset, args.thread)

if __name__ == "__main__":
    main()
