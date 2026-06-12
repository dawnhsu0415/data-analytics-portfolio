-- ====================================================================
-- PROJECT: Relational Database Design - Driving School Management
-- DBMS: Oracle SQL
-- ====================================================================

-- 1. DROP TABLES (Ensures script can be re-run cleanly)
DROP TABLE Payment CASCADE CONSTRAINTS;
DROP TABLE StudentLesson CASCADE CONSTRAINTS;
DROP TABLE Vehicle CASCADE CONSTRAINTS;
DROP TABLE Lesson CASCADE CONSTRAINTS;
DROP TABLE Instructor CASCADE CONSTRAINTS;
DROP TABLE Student CASCADE CONSTRAINTS;

-- 2. CREATE TABLES (DDL - Clean & Enforced Constraints)
CREATE TABLE Student(
    studentID          CHAR(6) PRIMARY KEY,
    stuFirstName       VARCHAR2(15) NOT NULL,
    stuLastName        VARCHAR2(15) NOT NULL,
    stuPhoneNo         VARCHAR2(10),
    stuPickUpPoint     VARCHAR2(255) NOT NULL,
    stuDropOffPoint    VARCHAR2(255) NOT NULL
);

CREATE TABLE Instructor(
    instructorID       CHAR(7) PRIMARY KEY,
    insFirstName       VARCHAR2(15) NOT NULL,
    insLastName        VARCHAR2(15) NOT NULL,
    insPhoneNo         VARCHAR2(10)
);

CREATE TABLE Lesson(
    lessonID           CHAR(6) PRIMARY KEY,
    lesType            VARCHAR2(15) NOT NULL,
    lesDuration        VARCHAR2(7) NOT NULL,
    lesPrice           NUMBER(6,2) NOT NULL
);

CREATE TABLE Vehicle(
    vehicleID          CHAR(6) PRIMARY KEY,
    make               VARCHAR2(10),
    model              VARCHAR2(15),
    transmission       VARCHAR2(10)
);

CREATE TABLE StudentLesson(
    studentlessonID    CHAR(5) PRIMARY KEY,
    slDate             DATE NOT NULL,
    slStartTime        VARCHAR2(5) NOT NULL,
    slEndTime          VARCHAR2(5) NOT NULL,
    slStatus           VARCHAR2(10) NOT NULL,
    vehicleID          CHAR(6) NOT NULL,
    lessonID           CHAR(6) NOT NULL,
    studentID          CHAR(6) NOT NULL,
    instructorID       CHAR(7) NOT NULL,
    CONSTRAINT fk_sl_vehicle FOREIGN KEY (vehicleID) REFERENCES Vehicle(vehicleID),
    CONSTRAINT fk_sl_lesson FOREIGN KEY (lessonID) REFERENCES Lesson(lessonID),
    CONSTRAINT fk_sl_student FOREIGN KEY (studentID) REFERENCES Student(studentID),
    CONSTRAINT fk_sl_instructor FOREIGN KEY (instructorID) REFERENCES Instructor(instructorID)
);

CREATE TABLE Payment(
    paymentID          CHAR(6) PRIMARY KEY,
    payDate            DATE NOT NULL,
    payAmount          NUMBER(6,2) NOT NULL,
    payMethod          VARCHAR2(15) NOT NULL,
    studentlessonID    CHAR(5) NOT NULL,
    CONSTRAINT fk_payment_sl FOREIGN KEY (studentlessonID) REFERENCES StudentLesson(studentlessonID)
);

-- 3. INSERT MOCK DATA (DML Sample)
INSERT INTO Student VALUES ('st0001', 'Fang-Ting', 'Hsu', '0412345678', 'Midland', 'Midland');
INSERT INTO Instructor VALUES ('ins0001', 'Kath', 'Brussels', '0487654321');
INSERT INTO Lesson VALUES ('les001', 'Standard-PLUS', '1 hour', 75.00);
INSERT INTO Vehicle VALUES ('veh001', 'Hyundai', 'i30', 'Manual');
INSERT INTO StudentLesson VALUES ('sl001', TO_DATE('2024-11-05', 'YYYY-MM-DD'), '13:00', '14:00', 'Completed', 'veh001', 'les001', 'st0001', 'ins0001');
INSERT INTO Payment VALUES ('pay001', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 75.00, 'Bank Transfer', 'sl001');

-- 4. PERFORMANCE TUNING INDEXES
CREATE INDEX idx_studentlesson_student ON StudentLesson(studentID);
CREATE INDEX idx_studentlesson_date ON StudentLesson(slDate);

-- 5. ADVANCED BI ANALYTICAL QUERY
-- Query: Revenue Contribution per Student by Lesson Type
SELECT
    les.lesType AS "Lesson Type",
    st.studentID AS "Student ID",
    st.stuFirstName || ' ' || st.stuLastName AS "Student Name",
    COUNT(*) AS "Number of Lessons",
    SUM(les.lesPrice) AS "Total Paid"
FROM STUDENTLESSON sl
JOIN STUDENT st ON sl.studentID = st.studentID
JOIN LESSON les ON sl.lessonID = les.lessonID
GROUP BY les.lesType, st.studentID, st.stuFirstName, st.stuLastName
ORDER BY "Total Paid" DESC, les.lesType;
