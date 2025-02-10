-- USE student_management;
USE student_management_4;
-- DROP TABLE exam_results;
DROP TABLE archived_exam_results;
DROP TABLE archived_exams;
DROP TABLE exam_results;
DROP TABLE exams;
DROP TABLE students;
DROP TABLE subjects;
DROP TABLE schools;

DROP PROCEDURE archive_old_exam_data;
DROP PROCEDURE manage_exam_archives;
-- show procedure status;

DROP EVENT IF EXISTS archive_old_exam_data;
DROP EVENT IF EXISTS event_weekly_archive;
DROP EVENT IF EXISTS event_monthly_data_archive;


