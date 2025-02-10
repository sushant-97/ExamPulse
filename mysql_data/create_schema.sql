-- CREATE DATABASE student_management_4;
USE student_management_4;

CREATE TABLE schools (
	school_id INT AUTO_INCREMENT,
    school_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (school_id)
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    subject_code VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_subject_code (subject_code)
);

CREATE TABLE students (
    student_id BIGINT AUTO_INCREMENT,
    student_name VARCHAR(200) NOT NULL,
    school_id INT NOT NULL,
    standard INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id),
    FOREIGN KEY (school_id) REFERENCES schools(school_id),
    INDEX idx_student_standard (standard, student_id)
);


CREATE TABLE exams (
    exam_id BIGINT AUTO_INCREMENT,
    subject_id INT NOT NULL,
    exam_type VARCHAR(50) NOT NULL,
    standard INT NOT NULL,
    exam_date DATE NOT NULL,
    archive_status VARCHAR(20) DEFAULT 'current',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (exam_id),
	FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    
    INDEX idx_exam_id_subject_id (exam_id, subject_id),
    INDEX idx_archive_status (archive_status),
    
    CHECK (archive_status IN ('current', 'intermediate', 'long_term'))
);


CREATE TABLE exam_results (
    result_id BIGINT AUTO_INCREMENT,
    exam_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    exam_date DATE,
    marks DECIMAL(5,2) NOT NULL,
    pass_status VARCHAR(4),
    archive_status VARCHAR(20) DEFAULT 'current',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (result_id),
	FOREIGN KEY (exam_id) REFERENCES exams(exam_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    
    INDEX idx_exam_id_student_id (exam_id, student_id),
--     INDEX idx_exam_date (exam_date),
    
    CHECK (marks >= 0 AND marks <= 100),
    CHECK (pass_status IN ('Pass', 'Fail')),
    CHECK (archive_status IN ('current', 'intermediate', 'long_term'))
);

-- The triggers
DELIMITER //
CREATE TRIGGER set_exam_date
BEFORE INSERT ON exam_results
FOR EACH ROW
BEGIN
    SET NEW.exam_date = (SELECT exam_date FROM exams WHERE exam_id = NEW.exam_id);
END//

CREATE TRIGGER set_exam_status
BEFORE INSERT ON exam_results
FOR EACH ROW
BEGIN
    SET NEW.pass_status = CASE
        WHEN NEW.marks >= 33 THEN 'Pass'
        ELSE 'Fail'
    END;
END//

CREATE TRIGGER update_exam_status
BEFORE UPDATE ON exam_results
FOR EACH ROW
BEGIN
    SET NEW.pass_status = CASE
        WHEN NEW.marks >= 33 THEN 'Pass'
        ELSE 'Fail'
    END;
END//
DELIMITER ;

-- Archive management procedure
DELIMITER //

CREATE PROCEDURE manage_exam_archives()
BEGIN
    -- Update exam statuses - this will automatically move data between partitions
    UPDATE exams 
    SET archive_status = 'long_term'
    WHERE exam_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    AND archive_status = 'intermediate';

    UPDATE exams 
    SET archive_status = 'intermediate'
    WHERE exam_date < DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND archive_status = 'current';

    -- Update exam results statuses based on their exam's status
    UPDATE exam_results er
    JOIN exams e ON er.exam_id = e.exam_id
    SET er.archive_status = e.archive_status
    WHERE er.archive_status != e.archive_status;
END //

DELIMITER //
CREATE EVENT event_weekly_archive
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP + INTERVAL (8 - DAYOFWEEK(CURRENT_TIMESTAMP)) DAY
DO
    CALL manage_exam_archives()//
DELIMITER ;

-- Archive
-- Create archived tables
CREATE TABLE archived_exams LIKE exams;
CREATE TABLE archived_exam_results LIKE exam_results;

DELIMITER //
CREATE PROCEDURE archive_old_exam_data()
BEGIN
	-- move old exams to archive table
    INSERT INTO archived_exams
    SELECT * FROM exams
    WHERE exam_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

    -- Move corresponding exam results to archived table
    INSERT INTO archived_exam_results
    SELECT er.* 
    FROM exam_results er
    JOIN exams e ON er.exam_id = e.exam_id
    WHERE e.exam_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
    
    -- Delete moved record from main tables
    DELETE FROM exam_results
    WHERE exam_id IN (
		SELECT exam_id
        FROM exams
        WHERE exam_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
        );
	
    DELETE FROM exams
    WHERE exam_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
END //

DELIMITER ;

-- Create monthly event for archiving old data
DELIMITER //
CREATE EVENT event_monthly_data_archive
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
    CALL archive_old_exam_data()//
DELIMITER ;