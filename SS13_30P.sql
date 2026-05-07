	CREATE DATABASE StudentDB;
USE StudentDB;

-- 1. Bảng Khoa
CREATE TABLE Department (
    DeptID VARCHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

-- 2. Bảng SinhVien
CREATE TABLE Student (
    StudentID VARCHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID VARCHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 3. Bảng MonHoc
CREATE TABLE Course (
    CourseID VARCHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

-- 4. Bảng DangKy
CREATE TABLE Enrollment (
    StudentID VARCHAR(6),
    CourseID VARCHAR(6),
    Score DECIMAL(4,2), 
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Chèn dữ liệu mẫu
INSERT INTO Department VALUES
('IT','Information Technology'),
('BA','Business Administration'),
('ACC','Accounting');

INSERT INTO Student VALUES
('S00001','Nguyen An','Male','2003-05-10','IT'),
('S00002','Tran Binh','Male','2003-06-15','IT'),
('S00003','Le Hoa','Female','2003-08-20','BA'),
('S00004','Pham Minh','Male','2002-12-12','ACC'),
('S00005','Vo Lan','Female','2003-03-01','IT'),
('S00006','Do Hung','Male','2002-11-11','BA'),
('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
('S00008','Tran Phuc','Male','2003-09-09','IT');
#1
CREATE VIEW ViewStudentBasic AS
SELECT s.StudentID, s.FullName, d.DeptName
FROM Student s
JOIN Department d ON s.DeptID = d.DeptID;

SELECT * FROM ViewStudentBasic;
#2
CREATE INDEX idxFullName ON Student(FullName);
#3
DELIMITER //
CREATE PROCEDURE GetStudentsIT()
BEGIN
    SELECT s.*, d.DeptName
    FROM Student s
    JOIN Department d ON s.DeptID = d.DeptID
    WHERE d.DeptName = 'Information Technology';
END //
DELIMITER ;

CALL GetStudentsIT();
#4
CREATE VIEW ViewStudentCountByDept AS
SELECT d.DeptName, COUNT(s.StudentID) AS TotalStudents
FROM Department d
LEFT JOIN Student s ON d.DeptID = s.DeptID
GROUP BY d.DeptID, d.DeptName;

SELECT DeptName, TotalStudents
FROM ViewStudentCountByDept
WHERE TotalStudents = (SELECT MAX(TotalStudents) FROM ViewStudentCountByDept);
#5
DELIMITER //
CREATE PROCEDURE GetTopScoreStudent(IN varCourseID VARCHAR(6))
BEGIN
    SELECT s.StudentID, s.FullName, e.Score
    FROM Student s
    JOIN Enrollment e ON s.StudentID = e.StudentID
    WHERE e.CourseID = varCourseID
    ORDER BY e.Score DESC
    LIMIT 1;
END //
DELIMITER ;

CALL GetTopScoreStudent('C00001');
#6
CREATE VIEW ViewITEnrollmentDB AS
    SELECT 
        e.StudentID, e.CourseID, e.Score
    FROM
        Enrollment e
            JOIN
        Student s ON e.StudentID = s.StudentID
            JOIN
        Department d ON s.DeptID = d.DeptID
    WHERE
        e.CourseID = 'C00001'
            AND d.DeptName = 'Information Technology' WITH CHECK OPTION;
#7
DELIMITER //
CREATE PROCEDURE UpdateScoreITDB(
    IN varStudentID VARCHAR(6),
    INOUT inoutNewScore DECIMAL(4,2)
)
BEGIN
    IF inoutNewScore > 10 THEN
        SET inoutNewScore = 10.00;
    END IF;

    UPDATE ViewITEnrollmentDB
    SET Score = inoutNewScore
    WHERE StudentID = varStudentID;
END //
DELIMITER ;

SET @new_score = 12.50;
CALL UpdateScoreITDB('S00001', @new_score);

SELECT @new_score;
SELECT * FROM ViewITEnrollmentDB WHERE StudentID = 'S00001';
