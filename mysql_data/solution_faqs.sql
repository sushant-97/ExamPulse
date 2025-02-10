USE student_management_adv;
SELECT COUNT(student_id) as count_student FROM students;

-- 1. Find the students that have topped any subject in their grade
WITH RankedScores AS (
    SELECT
        s.student_id,
        s.student_name,
        s.standard,
        sub.subject_name,
        e.exam_type,
        er.marks,

        RANK() OVER (
            PARTITION BY s.standard, e.subject_id
            ORDER BY er.marks DESC
        ) as rank_in_subject
    FROM students s
    JOIN exam_results er ON s.student_id = er.student_id
    JOIN exams e ON er.exam_id = e.exam_id
    JOIN subjects sub ON e.subject_id = sub.subject_id
)
SELECT
    student_name,
    standard,
    subject_name,
    exam_type,
    marks
FROM RankedScores
WHERE rank_in_subject = 1
ORDER BY standard, subject_name;


-- 2. Find the number of students that have passed (marks >= 33)
-- SELECT * FROM exams ORDER BY exam_date;
-- SELECT er.exam_id, er.student_id, e.subject_id, er.pass_status, er.exam_date
-- FROM exam_results er
-- JOIN exams e ON er.exam_id = e.exam_id
-- WHERE
--     er.exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
--     AND er.exam_date <= CURRENT_DATE
-- ORDER BY exam_date DESC;

-- Extracts the number of students who failed in tests over the last week.
-- This is calucalted per exam_id as there might be repeatition of the number of students

SELECT
    e.exam_id,
    COUNT(DISTINCT er.student_id) as passed_students
FROM
    exam_results er
JOIN
    exams e ON er.exam_id = e.exam_id
WHERE
    marks >= 33
    AND er.exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND er.exam_date <= CURRENT_DATE
GROUP BY
    e.exam_id;

-- -----------------------------------------------------------------------------------------------------------------------------
-- 3. How many more students will pass if passing marks changed to 25

SELECT
    s.subject_name,
    s.subject_id,
    COUNT(DISTINCT CASE WHEN er.marks >= 33 THEN er.student_id END) as current_passing,
    COUNT(DISTINCT CASE WHEN er.marks >= 25 THEN er.student_id END) as would_pass,
    COUNT(DISTINCT CASE WHEN er.marks >= 25 AND er.marks < 33 THEN er.student_id END) as additional_pass
FROM
	exam_results er
JOIN exams e ON er.exam_id = e.exam_id
JOIN subjects s ON e.subject_id = s.subject_id
WHERE
	er.exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
	AND er.exam_date <= CURRENT_DATE
GROUP BY
	s.subject_id
ORDER BY
	additional_pass DESC;

-- -----------------------------------------------------------------------------------------------------------------------------
-- Report Generation
-- -----------------------------------------------------------------------------------------------------------------------------
-- Extract the number of students who failed in tests over the last week.
-- SELECT *
-- FROM exam_results
-- WHERE exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 2 WEEK) AND exam_date <= CURRENT_DATE AND pass_status = 'Fail';

SELECT
	exam_id,
	COUNT(DISTINCT CASE WHEN marks < 33 THEN student_id END) as failed_students
FROM exam_results er
WHERE exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK) AND exam_date <= CURRENT_DATE
GROUP BY exam_id;

-- -----------------------------------------------------------------------------------------------------------------------------
-- Categorizes failures by:
-- Standard
SELECT
	exam_id,
	COUNT(DISTINCT CASE WHEN marks < 33 THEN student_id END) as failed_students
FROM exam_results er
WHERE exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK) AND exam_date <= CURRENT_DATE
GROUP BY exam_id;

-- Subject wise
-- SELECT * FROM students;
-- SELECT * FROM exam_results;

-- exam_resulst -> res_id, exam_id, student_id
-- exams -> exam_id, subject_id
-- students -> studnet_id, standard, school

SELECT
	sub.subject_name,
	COUNT(DISTINCT CASE WHEN er.marks < 33 THEN er.student_id END) as failed_students,
    COUNT(DISTINCT er.student_id) as total_students,
    ROUND(
        COUNT(DISTINCT CASE WHEN er.marks < 33 THEN er.student_id END) * 100.0 /
        COUNT(DISTINCT er.student_id)
    , 2) as failure_percentage
FROM
	exam_results er
JOIN exams e ON er.exam_id = e.exam_id
JOIN subjects sub ON e.subject_id = sub.subject_id
WHERE er.exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH) AND er.exam_date <= CURRENT_DATE
GROUP BY sub.subject_id;
-- -----------------------------------------------------------------------------------------------------------------------------
-- Grade wise
SELECT
	s.standard,
	COUNT(DISTINCT CASE WHEN er.marks < 33 THEN er.student_id END) as failed_students,
    COUNT(DISTINCT er.student_id) as total_students,
    ROUND(
        COUNT(DISTINCT CASE WHEN er.marks < 33 THEN er.student_id END) * 100.0 /
        COUNT(DISTINCT er.student_id)
    , 2) as failure_percentage
FROM
	exam_results er
JOIN exams e ON er.exam_id = e.exam_id
JOIN subjects sub ON e.subject_id = sub.subject_id
JOIN students s ON er.student_id = s.student_id
WHERE er.exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH) AND er.exam_date <= CURRENT_DATE
GROUP BY s.standard;

-- -----------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------
-- Comparison with Previous Week's Performance
-- weekly results
-- WITH CurrentWeekResults AS (
--     SELECT
--         er.student_id,
--         e.subject_id,
--         s.subject_name,
--         er.marks as current_marks,
--         er.exam_date
--     FROM exam_results er
--     JOIN exams e ON er.exam_id = e.exam_id
--     JOIN subjects s ON e.subject_id = s.subject_id
--     WHERE er.exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
--     AND er.exam_date <= CURRENT_DATE
-- ),
-- PreviousResults AS (
--     SELECT
--         er.student_id,
--         e.subject_id,
--         er.marks as previous_marks,
--         er.exam_date
--     FROM exam_results er
--     JOIN exams e ON er.exam_id = e.exam_id
--     WHERE er.exam_date >= DATE_SUB(DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK), INTERVAL 1 WEEK)
--     AND er.exam_date < DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
-- )
-- SELECT
--     cr.subject_name,
--     COUNT(DISTINCT cr.student_id) as total_students,
--     ROUND(AVG(cr.current_marks), 2) as avg_current_marks,
--     ROUND(AVG(pr.previous_marks), 2) as avg_previous_marks,
--     ROUND(AVG(cr.current_marks - pr.previous_marks), 2) as avg_change,
--     COUNT(DISTINCT CASE WHEN cr.current_marks > pr.previous_marks THEN cr.student_id END) as improved_count,
--     COUNT(DISTINCT CASE WHEN cr.current_marks < pr.previous_marks THEN cr.student_id END) as declined_count
-- FROM CurrentWeekResults cr
-- LEFT JOIN PreviousResults pr ON cr.student_id = pr.student_id
--     AND cr.subject_id = pr.subject_id
-- GROUP BY cr.subject_id, cr.subject_name
-- ORDER BY avg_change DESC;


WITH CurrentWeekResults AS (
    SELECT
        er.student_id,
        e.subject_id,
        s.subject_name,
        std.standard,
        er.marks as current_marks,
        er.exam_date
    FROM exam_results er
    JOIN exams e ON er.exam_id = e.exam_id
    JOIN subjects s ON e.subject_id = s.subject_id
    JOIN students std ON er.student_id = std.student_id
    WHERE er.exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK)
    AND er.exam_date <= CURRENT_DATE
),
LastExamResults AS (
    SELECT
        er.student_id,
        e.subject_id,
        std.standard,
        er.marks as previous_marks,
        er.exam_date
    FROM exam_results er
    JOIN exams e ON er.exam_id = e.exam_id
    JOIN students std ON er.student_id = std.student_id
    WHERE
        EXISTS (
            SELECT 1
            FROM CurrentWeekResults cr
            WHERE cr.subject_id = e.subject_id
            AND cr.standard = std.standard
        )
        AND er.exam_date < DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
        AND er.exam_date = (
            SELECT MAX(er2.exam_date)
            FROM exam_results er2
            JOIN exams e2 ON er2.exam_id = e2.exam_id
            JOIN students std2 ON er2.student_id = std2.student_id
            WHERE e2.subject_id = e.subject_id
            AND std2.standard = std.standard
            AND er2.exam_date < DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
        )
)
SELECT
    cr.subject_name,
    cr.standard,
    COUNT(DISTINCT cr.student_id) as total_students,
    ROUND(AVG(cr.current_marks), 2) as avg_current_marks,
    ROUND(AVG(lr.previous_marks), 2) as avg_previous_marks,
    ROUND(AVG(cr.current_marks - lr.previous_marks), 2) as avg_change,
    COUNT(DISTINCT CASE WHEN cr.current_marks > lr.previous_marks THEN cr.student_id END) as improved_count,
    COUNT(DISTINCT CASE WHEN cr.current_marks < lr.previous_marks THEN cr.student_id END) as declined_count
FROM CurrentWeekResults cr
LEFT JOIN LastExamResults lr ON cr.student_id = lr.student_id
    AND cr.subject_id = lr.subject_id
    AND cr.standard = lr.standard
GROUP BY cr.subject_id, cr.standard
ORDER BY cr.standard, avg_change DESC;