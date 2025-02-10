# schema changes 

# add standard in exams table
# add data consistency trigger  to check for standard while adding to exam_results

-- 1
SELECT 
    COUNT(DISTINCT student_id) AS unique_failed_students
FROM 
    exam_results
WHERE 
    pass_status = 'Fail';

SELECT school_id, COUNT(student_id)
FROM students
GROUP BY school_id;

-- 2
SELECT 
    s.school_name,
    SUM(CASE WHEN er.pass_status = 'Fail' THEN 1  ELSE 0 END) AS failed_status
FROM 
    exam_results er
JOIN 
    students st ON er.student_id = st.student_id
JOIN 
    schools s ON st.school_id = s.school_id
WHERE 
    er.pass_status = 'Fail'
GROUP BY 
    s.school_name;
    
    
-- 3 Failures by Standard and Subject:
SELECT 
    e.standard,
    s.subject_name,
    COUNT(*) as failure_count
FROM exam_results er
JOIN exams e ON er.exam_id = e.exam_id
JOIN subjects s ON e.subject_id = s.subject_id
WHERE er.pass_status = 'Fail'
GROUP BY e.standard, s.subject_name
ORDER BY e.standard, s.subject_name;

-- 4 Failures by School, Standard and Subject:
SELECT 
    sch.school_name,
    e.standard,
    s.subject_name,
    COUNT(*) as failure_count
FROM exam_results er
JOIN exams e ON er.exam_id = e.exam_id
JOIN subjects s ON e.subject_id = s.subject_id
JOIN students st ON er.student_id = st.student_id
JOIN schools sch ON st.school_id = sch.school_id
WHERE er.pass_status = 'Fail'
GROUP BY sch.school_name, e.standard, s.subject_name
ORDER BY sch.school_name, e.standard, s.subject_name;
