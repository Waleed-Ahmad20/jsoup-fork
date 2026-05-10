# migration_etl.py - Load legacy CSV into refactored appointments schema
import csv
import mysql.connector
import re
from datetime import datetime

VALID_STATUSES = {'P', 'C', 'X', 'H', 'R'}

def parse_appt_date(raw):
    # T1: 'DD/MM/YYYY HH:MM' --> datetime object
    try:
        return datetime.strptime(raw, '%d/%m/%Y %H:%M')
    except ValueError:
        return None

def split_room(raw):
    # T2: 'Room 3 Block B' --> (3, 'Block B')
    # Using regex to extract the digits for the room number
    match = re.search(r'Room\s+(\d+)\s+(Block\s+\w+)', raw)
    if match:
        room_number = int(match.group(1))
        building_block = match.group(2)
        return room_number, building_block
    return None, raw # Fallback if format is unexpected

def migrate(csv_path, db_config):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("SET FOREIGN_KEY_CHECKS=0;")
    skipped = []
    success_count = 0

    try:
        with open(csv_path, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                # T4: validate status; skip and log unknown codes
                if row['status'] not in VALID_STATUSES:
                    skipped.append(row['appt_id'])
                    continue

                # T1: Parse date
                appt_dt = parse_appt_date(row['appt_date'])
                
                # T2: Split room and block
                room_no, block = split_room(row['room'])

                # T3: patient_nm, patient_ph, doc_name intentionally omitted
                query = """
                    INSERT INTO appointments 
                    (appt_id, patient_id, doc_id, appt_datetime, status, fee, discount, room_number, building_block)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
                values = (
                    row['appt_id'], row['patient_id'], row['doc_id'],
                    appt_dt, row['status'], row['fee'], row['discount'],
                    room_no, block
                )
                
                cursor.execute(query, values)
                success_count += 1

        conn.commit()
        print(f"Migration Complete.")
        print(f"Successfully migrated: {success_count} rows.")
        print(f"Skipped {len(skipped)} rows with invalid status: {skipped}")

    except Exception as e:
        conn.rollback()
        print(f"Migration failed. Transaction rolled back. Error: {e}")
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    db_config = {
        "user": "root",
        "password": "LirenMatte87!",
        "host": "127.0.0.1",
        "database": "sre",
    }
    migrate("appointments_legacy.csv", db_config)