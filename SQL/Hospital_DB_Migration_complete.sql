-- SECTION 1:
USE hospital_db;

-- SECTION 2 : TABLE CREATION


-- TABLE 1: DEPARTMENTS

CREATE TABLE departments (
  departmentID INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50)  NOT NULL
);

-- TABLE 2: DOCTORS

CREATE TABLE doctors (
  doctorID       INT          AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(50),
  specialization VARCHAR(100),
  role           VARCHAR(50),
  departmentID   INT,
  FOREIGN KEY (departmentID) REFERENCES departments(departmentID)
);

-- TABLE 3: PATIENTS

CREATE TABLE patients (
  patientID   INT         AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(50),
  dateOfBirth DATE,
  gender      CHAR(1),
  phone       VARCHAR(15),
  CHECK (UPPER(gender) IN ('M', 'F', 'O'))
);

-- TABLE 4: APPOINTMENTS
-- Depends on: patients (FK), doctors (FK)
CREATE TABLE appointments (
  appointmentID   INT         AUTO_INCREMENT PRIMARY KEY,
  patientID       INT,
  doctorID        INT,
  appointmentTime DATETIME,
  status          VARCHAR(50),
  FOREIGN KEY (patientID) REFERENCES patients(patientID),
  FOREIGN KEY (doctorID)  REFERENCES doctors(doctorID),
  CHECK (status IN ('Scheduled', 'Completed', 'Cancelled'))
);

-- TABLE 5: PRESCRIPTIONS
-- Depends on: appointments (FK)
CREATE TABLE prescriptions (
  prescriptionID INT          AUTO_INCREMENT PRIMARY KEY,
  appointmentID  INT,
  medication     VARCHAR(100),
  dosage         VARCHAR(100),
  FOREIGN KEY (appointmentID) REFERENCES appointments(appointmentID)
);

-- TABLE 6: BILLS
-- Depends on: appointments (FK)
CREATE TABLE bills (
  billID        INT           AUTO_INCREMENT PRIMARY KEY,
  appointmentID INT,
  amount        DECIMAL(10,2),
  paid          TINYINT(1),
  billDate      DATETIME      DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointmentID) REFERENCES appointments(appointmentID)
);

-- TABLE 7: LABREPORTS
-- Depends on: appointments (FK)
CREATE TABLE labreports (
  reportID      INT      AUTO_INCREMENT PRIMARY KEY,
  appointmentID INT,
  reportData    TEXT,
  createdAt     DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointmentID) REFERENCES appointments(appointmentID)
);

-- TABLE 8: DOCTOR_CREDENTIALS
-- Depends on: doctors (FK)
CREATE TABLE doctor_credentials (
  credentialID INT          AUTO_INCREMENT PRIMARY KEY,
  doctorID     INT,
  userName     VARCHAR(100),
  password     VARCHAR(100),
  FOREIGN KEY (doctorID) REFERENCES doctors(doctorID)
);

-- TABLE 9: AUDIT_LOG
--  every INSERT/UPDATE/DELETE on appointments
CREATE TABLE audit_log (
  logID       INT          AUTO_INCREMENT PRIMARY KEY,
  tableName   VARCHAR(50),
  action      VARCHAR(10),
  recordID    INT,
  changedAt   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  changedBy   VARCHAR(100) 
);
-- ============================================================
-- SECTION 3: DATA MIGRATION

-- MIGRATE: DEPARTMENTS
SELECT CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')), ' FROM hospital_data')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'hospital_db'
AND   TABLE_NAME   = 'hospital_data'
AND   COLUMN_NAME  LIKE 'Departments.%';

INSERT INTO departments (departmentID, name)
SELECT
  `Departments.DepartmentID`,
  `Departments.Name`
FROM hospital_data
WHERE `Departments.DepartmentID` <> ''
AND   `Departments.DepartmentID` IS NOT NULL;

SELECT * FROM departments;

-- MIGRATE: DOCTORS
SELECT CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')), ' FROM hospital_data')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'hospital_db'
AND   TABLE_NAME   = 'hospital_data'
AND   COLUMN_NAME  LIKE 'Doctors.%';

INSERT INTO doctors (doctorID, name, specialization, role, departmentID)
SELECT
  `Doctors.DoctorID`,
  `Doctors.Name`,
  `Doctors.Specialization`,
  `Doctors.Role`,
  `Doctors.DepartmentID`
FROM hospital_data
WHERE `Doctors.DoctorID` <> ''
AND   `Doctors.DoctorID` IS NOT NULL;

SELECT * FROM doctors;

-- MIGRATE: PATIENTS
SELECT CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')), ' FROM hospital_data')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'hospital_db'
AND   TABLE_NAME   = 'hospital_data'
AND   COLUMN_NAME  LIKE 'Patients.%';

INSERT INTO patients (patientID, name, dateOfBirth, gender, phone)
SELECT
  `Patients.PatientID`,
  `Patients.Name`,
  STR_TO_DATE(`Patients.DateOfBirth`, '%d-%m-%Y'),
  `Patients.Gender`,
  `Patients.Phone`
FROM hospital_data
WHERE `Patients.PatientID` <> ''
AND   `Patients.PatientID` IS NOT NULL;

SELECT * FROM patients;

-- MIGRATE: APPOINTMENTS
SELECT CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')), ' FROM hospital_data')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'hospital_db'
AND   TABLE_NAME   = 'hospital_data'
AND   COLUMN_NAME  LIKE 'Appointments.%';

INSERT INTO appointments (appointmentID, patientID, doctorID, appointmentTime, status)
SELECT
  `Appointments.AppointmentID`,
  `Appointments.PatientID`,
  `Appointments.DoctorID`,
  STR_TO_DATE(`Appointments.AppointmentTime`, '%d-%m-%Y %H:%i'),
  `Appointments.Status`
FROM hospital_data
WHERE `Appointments.AppointmentID` <> ''
AND   `Appointments.AppointmentID` IS NOT NULL;

SELECT * FROM appointments;

-- MIGRATE: PRESCRIPTIONS
SELECT CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')), ' FROM hospital_data')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'hospital_db'
AND   TABLE_NAME   = 'hospital_data'
AND   COLUMN_NAME  LIKE 'Prescriptions.%';

INSERT INTO prescriptions (prescriptionID, appointmentID, medication, dosage)
SELECT
  `Prescriptions.PrescriptionID`,
  `Prescriptions.AppointmentID`,
  `Prescriptions.Medication`,
  `Prescriptions.Dosage`
FROM hospital_data
WHERE `Prescriptions.PrescriptionID` <> ''
AND   `Prescriptions.PrescriptionID` IS NOT NULL;

SELECT * FROM prescriptions;


-- MIGRATE: LABREPORTS
SELECT CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')), ' FROM hospital_data')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'hospital_db'
AND   TABLE_NAME   = 'hospital_data'
AND   COLUMN_NAME  LIKE 'LabReports.%';

INSERT INTO labreports (reportID, appointmentID, reportData, createdAt)
SELECT
  `LabReports.ReportID`,
  `LabReports.AppointmentID`,
  `LabReports.ReportData`,
  `LabReports.CreatedAt`
FROM hospital_data
WHERE `LabReports.ReportID` <> ''
AND   `LabReports.ReportID` IS NOT NULL;

SELECT * FROM labreports;


-- MIGRATE: BILLS
SELECT CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')), ' FROM hospital_data')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'hospital_db'
AND   TABLE_NAME   = 'hospital_data'
AND   COLUMN_NAME  LIKE 'Bills.%';

INSERT INTO bills (billID, appointmentID, amount, paid, billDate)
SELECT
  `Bills.BillID`,
  `Bills.AppointmentID`,
  `Bills.Amount`,
  `Bills.Paid`,
  `Bills.BillDate`
FROM hospital_data
WHERE `Bills.BillID` <> ''
AND   `Bills.BillID` IS NOT NULL;

SELECT * FROM bills;

-- DOCTOR CREDENTIALS 
INSERT INTO doctor_credentials (doctorID, userName, password)
SELECT
  doctor_id,
  user_name,
  password
FROM doctor_credentials_staging
WHERE doctor_id IS NOT NULL
AND   doctor_id <> '';

-- ============================================================
-- SECTION 4: TRIGGER — APPOINTMENT VALIDATION

DROP TRIGGER IF EXISTS CHECK_NEW_APPOINMENT;

DELIMITER $$
CREATE TRIGGER CHECK_NEW_APPOINMENT
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN

  -- RULE 1: Block appointments scheduled in the past
  IF NEW.appointmentTime < NOW() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error: Appointment cannot be in the past.';
  END IF;

  -- RULE 2: Block double-booking same doctor at same time

  IF EXISTS (
    SELECT 1
    FROM appointments
    WHERE doctorID        = NEW.doctorID
    AND   appointmentTime = NEW.appointmentTime
    AND   status          = 'Scheduled'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error: Doctor already has an appointment at this time.';
  END IF;

END $$
DELIMITER ;


-- TEST 

INSERT INTO appointments (appointmentID, patientID, doctorID, appointmentTime, status)
VALUES (10001, 1, 1, '2023-01-01 10:00:00', 'Scheduled');

INSERT INTO appointments (appointmentID, patientID, doctorID, appointmentTime, status)
VALUES (10001, 1, 1, '2026-12-01 10:00:00', 'Scheduled');

INSERT INTO appointments (appointmentID, patientID, doctorID, appointmentTime, status)
VALUES (10002, 2, 1, '2026-12-11 10:00:00', 'Scheduled');

-- ============================================================
--  LOG TRIGGER

DROP TRIGGER IF EXISTS AUDIT_APPOINTMENT_INSERT;

DELIMITER $$
CREATE TRIGGER AUDIT_APPOINTMENT_INSERT
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (tableName, action, recordID, changedAt, changedBy)
  VALUES ('appointments', 'INSERT', NEW.appointmentID, NOW(), USER());
END $$
DELIMITER ;

-- ============================================================
-- SECTION 5: PROCEDURE

DROP PROCEDURE IF EXISTS VIEW_DOCTOR_DATA;

DELIMITER $$
CREATE PROCEDURE VIEW_DOCTOR_DATA(
  IN INPUT_USERNAME VARCHAR(100),
  IN INPUT_PASSWORD VARCHAR(100)
)
BEGIN
  DECLARE DOC_ROLE VARCHAR(100);
  DECLARE DOC_DEPT INT;
  DECLARE DOC_ID   INT;

  -- STEP 1: Verify credentials and get doctor ID
  SELECT doctorID INTO DOC_ID
  FROM   doctor_credentials
  WHERE  userName = INPUT_USERNAME
  AND    password = INPUT_PASSWORD;

  -- STEP 2: Get role and department using the doctor ID
  SELECT role, departmentID
  INTO   DOC_ROLE, DOC_DEPT
  FROM   doctors
  WHERE  doctorID = DOC_ID;

  -- STEP 3: Show data based on role
  IF LOWER(DOC_ROLE) = 'senior' THEN

    -- Senior doctor: sees ALL patients in their department
    SELECT
      D.doctorID,
      P.patientID,
      P.name          AS patient_name,
      P.gender,
      A.appointmentTime,
      PR.medication,
      LR.reportData
    FROM       patients      AS P
    INNER JOIN appointments  AS A  ON A.patientID     = P.patientID
    JOIN       doctors       AS D  ON D.doctorID      = A.doctorID
    LEFT JOIN  prescriptions AS PR ON PR.appointmentID = A.appointmentID
    LEFT JOIN  labreports    AS LR ON LR.appointmentID = A.appointmentID
    WHERE D.departmentID = DOC_DEPT;

  ELSE

    -- Junior/Resident/Consultant: sees ONLY their own patients
    SELECT
      A.doctorID,
      P.patientID,
      P.name          AS patient_name,
      P.gender,
      A.appointmentTime,
      PR.medication,
      LR.reportData
    FROM       patients      AS P
    INNER JOIN appointments  AS A  ON A.patientID     = P.patientID
    LEFT JOIN  prescriptions AS PR ON PR.appointmentID = A.appointmentID
    LEFT JOIN  labreports    AS LR ON LR.appointmentID = A.appointmentID
    WHERE A.doctorID = DOC_ID;

  END IF;

END $$
DELIMITER ;

CALL VIEW_DOCTOR_DATA('doctor1', 'W3jzIANG');
CALL VIEW_DOCTOR_DATA('doctor4', 'ic0pFSn0');

-- ============================================================
-- SECTION 6: PROCEDURES — REPORTING

DROP PROCEDURE IF EXISTS SP_MONTHLYREVENUE;

DELIMITER $$
CREATE PROCEDURE SP_MONTHLYREVENUE(
  IN P_YEAR  INT,
  IN P_MONTH INT
)
BEGIN
  SELECT
    D1.name         AS department,
    COUNT(B.billID) AS total_bills,
    SUM(B.amount)   AS total_revenue,
    AVG(B.amount)   AS avg_bill_amount
  FROM       bills        AS B
  INNER JOIN appointments AS A  ON A.appointmentID = B.appointmentID
  INNER JOIN doctors      AS D  ON D.doctorID      = A.doctorID
  INNER JOIN departments  AS D1 ON D1.departmentID = D.departmentID
  WHERE  MONTH(B.billDate) = P_MONTH
  AND    YEAR(B.billDate)  = P_YEAR
  GROUP  BY D1.name
  ORDER  BY total_revenue DESC;
END $$
DELIMITER ;

-- Test with months that have data
CALL SP_MONTHLYREVENUE(2025, 5);
CALL SP_MONTHLYREVENUE(2025, 3);
CALL SP_MONTHLYREVENUE(2024, 7);


-- PROCEDURE 2: DOCTOR PERFORMANCE
-- Revenue, cancellations and unpaid bills per doctor

DROP PROCEDURE IF EXISTS SP_DOCTOR_PERFORMANCE;

DELIMITER $$
CREATE PROCEDURE SP_DOCTOR_PERFORMANCE(
  IN P_YEAR INT
)
BEGIN
  SELECT
    D.name                                                   AS doctor_name,
    D.role,
    D1.name                                                  AS department,
    COUNT(A.appointmentID)                                   AS total_appointments,
    SUM(B.amount)                                            AS total_revenue,
    ROUND(AVG(B.amount), 2)                                  AS avg_bill_per_appointment,
    SUM(CASE WHEN B.paid = 1 THEN 1 ELSE 0 END)             AS paid_count,
    SUM(CASE WHEN B.paid = 0 THEN 1 ELSE 0 END)             AS unpaid_count,
    SUM(CASE WHEN A.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations
  FROM       doctors      AS D
  JOIN       departments  AS D1 ON D1.departmentID = D.departmentID
  JOIN       appointments AS A  ON A.doctorID      = D.doctorID
  JOIN       bills        AS B  ON B.appointmentID = A.appointmentID
  WHERE YEAR(A.appointmentTime) = P_YEAR
  GROUP BY D.doctorID, D.name, D.role, D1.name
  ORDER BY total_revenue DESC;
END $$
DELIMITER ;

CALL SP_DOCTOR_PERFORMANCE(2025);


-- ── PROCEDURE 3: UNPAID BILLS REPORT
-- Shows uncollected revenue per department

DROP PROCEDURE IF EXISTS SP_UNPAID_BILLS_REPORT;

DELIMITER $$
CREATE PROCEDURE SP_UNPAID_BILLS_REPORT()
BEGIN
  SELECT
    D1.name                                              AS department,
    COUNT(B.billID)                                      AS unpaid_bill_count,
    SUM(B.amount)                                        AS unpaid_amount,
    ROUND(
      SUM(B.amount) / (SELECT SUM(amount) FROM bills) * 100
    , 1)                                                 AS pct_of_total_revenue
  FROM       bills        AS B
  JOIN       appointments AS A  ON A.appointmentID = B.appointmentID
  JOIN       doctors      AS D  ON D.doctorID      = A.doctorID
  JOIN       departments  AS D1 ON D1.departmentID = D.departmentID
  WHERE B.paid = 0
  GROUP BY D1.name
  ORDER BY unpaid_amount DESC;
END $$
DELIMITER ;

CALL SP_UNPAID_BILLS_REPORT();

-- SECTION 7: FINAL VERIFICATION


-- Row counts for all tables
SELECT 'departments'        AS table_name, COUNT(*) AS row_count FROM departments
UNION ALL
SELECT 'doctors',            COUNT(*) FROM doctors
UNION ALL
SELECT 'patients',           COUNT(*) FROM patients
UNION ALL
SELECT 'appointments',       COUNT(*) FROM appointments
UNION ALL
SELECT 'prescriptions',      COUNT(*) FROM prescriptions
UNION ALL
SELECT 'bills',              COUNT(*) FROM bills
UNION ALL
SELECT 'labreports',         COUNT(*) FROM labreports
UNION ALL
SELECT 'doctor_credentials', COUNT(*) FROM doctor_credentials
UNION ALL
SELECT 'audit_log',          COUNT(*) FROM audit_log;


-- Check no NULL IDs slipped through
SELECT 'NULL patientIDs'     AS issue, COUNT(*) AS count FROM patients     WHERE patientID    IS NULL
UNION ALL
SELECT 'NULL doctorIDs',      COUNT(*) FROM doctors      WHERE doctorID     IS NULL
UNION ALL
SELECT 'NULL appointmentIDs', COUNT(*) FROM appointments WHERE appointmentID IS NULL
UNION ALL
SELECT 'NULL billIDs',        COUNT(*) FROM bills        WHERE billID       IS NULL
UNION ALL
SELECT 'NULL credentialIDs',  COUNT(*) FROM doctor_credentials WHERE credentialID IS NULL;

-- Check only valid gender values exist
SELECT DISTINCT gender FROM patients;

-- Check only valid status values exist
SELECT DISTINCT status FROM appointments;

-- Check audit log
SELECT * FROM audit_log ORDER BY changedAt DESC;





































































































































































































































