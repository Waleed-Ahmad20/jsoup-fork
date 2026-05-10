-- PART F1: Normalised Schema for patients (3NF) [cite: 395]
CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fullName VARCHAR(255) NOT NULL,
    dateOfBirth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other') NOT NULL,
    address VARCHAR(255),
    city VARCHAR(255)
);

CREATE TABLE patient_phones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

-- REFACTORING R1: Fix Derived Data in billing [cite: 414]
ALTER TABLE billing DROP COLUMN tax_amt;
ALTER TABLE billing DROP COLUMN grand_total;
ALTER TABLE billing DROP COLUMN balance;

CREATE OR REPLACE VIEW v_billing_summary AS
SELECT 
    bill_no, pid, svc_cost, tax_pct,
    ROUND(svc_cost * tax_pct / 100, 2) AS tax_amt,
    ROUND(svc_cost + (svc_cost * tax_pct / 100), 2) AS grand_total,
    paid,
    ROUND((svc_cost + (svc_cost * tax_pct / 100)) - paid, 2) AS balance
FROM billing;

-- REFACTORING R2: Fix Overloaded Column in appointments.status [cite: 434]
CREATE TABLE appt_status_ref (
    status_code CHAR(1) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

INSERT INTO appt_status_ref VALUES 
('P', 'Pending'), ('C', 'Completed'), ('X', 'Cancelled'), 
('H', 'On Hold'), ('R', 'Rescheduled');

ALTER TABLE appointments 
ADD CONSTRAINT fk_appt_status 
FOREIGN KEY (status) REFERENCES appt_status_ref(status_code);

-- REFACTORING R3: Naming Standardisation (doctors table) [cite: 448]
ALTER TABLE doctors RENAME COLUMN DoctorID TO doctor_id;
ALTER TABLE doctors RENAME COLUMN FullName TO full_name;
ALTER TABLE doctors RENAME COLUMN Speciality TO speciality;
ALTER TABLE doctors RENAME COLUMN ContactNo TO contact_no;
ALTER TABLE doctors RENAME COLUMN JoinDt TO join_date;
ALTER TABLE doctors RENAME COLUMN Salary TO salary_monthly;
ALTER TABLE doctors RENAME COLUMN isActive TO is_active;

-- REFACTORING R4: Missing Constraints and Backfill [cite: 454]
ALTER TABLE billing ADD PRIMARY KEY (bill_no);
DELETE FROM billing WHERE pid NOT IN (SELECT pid FROM pat_master);
ALTER TABLE billing ADD CONSTRAINT fk_billing_patient 
FOREIGN KEY (pid) REFERENCES pat_master (pid);

-- REFACTORING R5: Audit Trail to appointments [cite: 469]
ALTER TABLE appointments 
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
