-- V1: Row count must match valid rows in CSV [cite: 540]
SELECT COUNT(*) AS migrated_rows FROM appointments;

-- V2: No NULL datetime values [cite: 542]
SELECT COUNT(*) AS null_dates FROM appointments WHERE appt_datetime IS NULL;

-- V3: Only valid status codes exist [cite: 544]
SELECT DISTINCT status FROM appointments;

-- V4: No orphan appointments [cite: 546]
SELECT COUNT(*) AS orphans 
FROM appointments a
LEFT JOIN patients p ON a.patient_id = p.id
WHERE p.id IS NULL;
