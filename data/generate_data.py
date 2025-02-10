import random
from datetime import datetime, timedelta

# Helper functions
def random_int(min_val, max_val):
    return random.randint(min_val, max_val)

def random_date(start, end):
    return start + timedelta(seconds=random.randint(0, int((end - start).total_seconds())))

# Generate school data
schools = [
    {"name": "Zp1", "location": "Dharashiv"},   # !Zp is for Zilla Parishad
    {"name": "Zp2", "location": "Latur"},
    {"name": "Zp3", "location": "Beed"}
]

# Generate subject data
subjects = [
    {"name": "Mathematics", "code": "MATH01"},
    {"name": "Science", "code": "SCI01"},
    {"name": "English", "code": "ENG01"},
    {"name": "Social Studies", "code": "SOC01"},
    {"name": "Computer Science", "code": "CS01"}
]

# Generate SQL for schools
schools_sql = "INSERT INTO schools (school_name, location) VALUES\n"
schools_sql += ",\n".join([f"('{school['name']}', '{school['location']}')" for school in schools]) + ";\n"

# Generate SQL for subjects
subjects_sql = "INSERT INTO subjects (subject_name, subject_code, is_active) VALUES\n"
subjects_sql += ",\n".join([f"('{subject['name']}', '{subject['code']}', 1)" for subject in subjects]) + ";\n"

# print("-- Schools Data")
# print(schools_sql)
# print("\n-- Subjects Data")
# print(subjects_sql)

# Generate student names for dummy data
first_names = ["Aditya", "Tanvi", "Mihir", "Rutuja", "Chinmay", "Ketaki", "Yash", "Samruddhi", "Tejas", "Mrunal"]
last_names = ["Bhonsale", "Karnik", "Lonkar", "Sathe", "Dani", "Kale", "Garge", "Puranik", "Ingle", "Modak"]

# Generate students SQL
students_sql = "INSERT INTO students (student_name, school_id, standard) VALUES\n"
students = []
student_count = 0

temp_sql = []
# standard_student_mapping = {}
school_student_mapping = {}
student_id = 1
student_count = 0

for school_idx, _ in enumerate(schools):
    student_ids_school = []
    standard_student_mapping = {}

    for standard in [8, 9, 10]:
        student_ids_ = []

        for _ in range(25):
            first_name = random.choice(first_names)
            last_name = random.choice(last_names)
            student_count += 1
            students.append({
                "id": student_count,
                "name": f"{first_name} {last_name}",
                "school_id": school_idx + 1,
                "standard": standard
            })
            student_ids_.append(student_id)
            student_ids_school.append(student_id)
            student_id += 1
            temp_sql.append(f"('{first_name} {last_name}', {school_idx + 1}, {standard})")

        standard_student_mapping[standard] = student_ids_

    school_student_mapping[school_idx + 1] = standard_student_mapping

students_sql += ",\n".join(temp_sql) + ";\n"

# print(standard_student_mapping)
print("*******")
# print(school_student_mapping)
for key, value in school_student_mapping.items():
    print(key)
    print(value)
    print("*")
# print("\n-- Students Data")
# print(students_sql)

# Generate exams for last 4 months
exam_types = ["Unit Test"]

date_cursor = datetime(2024, 11, 4) # First Monday of Nov.
exam_end_date = datetime(2025, 2, 7)    # Current Date

# This will be exam data, this can be consider as exam time table.
# That is lets assume exam are planned a month ahead
# but here we will generate random data for last 4 month with a probability of exam being in this week is 0.7
exams = []
exam_sql = "INSERT INTO exams (subject_id, exam_type, standard, exam_date) VALUES\n"
temp_exam_sql = []
exam_id = 1

# Exam results data for each student across schools based on standard they are in.
exam_results = []
exam_results_sql = "INSERT INTO exam_results (exam_id, student_id, marks) VALUES\n"
temp_results_sql = []
res_id = 1

# generate data for standard 8
for standard in [8, 9, 10]:
    date_cursor = datetime(2024, 11, 4)
    while date_cursor <= exam_end_date:
        # Generate exam_data for this week
        for subject_idx, _ in enumerate(subjects, start=1):
            for exam_type in exam_types:
                if random.random() < 0.7:
                    # 70% chance of exam occurring
                    exams.append({"exam_id": exam_id, "subject_id": subject_idx, "standard": standard, "date": date_cursor})
                    temp_exam_sql.append(f"({subject_idx}, '{exam_type}', {standard}, '{date_cursor.date()}')")

                    # school_student_mapping
                    # Now assign if this exam to students of this standard
                    for school_idx, _ in enumerate(schools):

                        students_for_this_school = school_student_mapping[school_idx + 1]
                        students_for_this_standard = students_for_this_school[standard]

                        print(students_for_this_standard)
                        # this_std_students = standard_student_mapping[standard]
                        # print("*"*100)
                        # print(exam_id)
                        # print("*"*100)
                        for stu_id in students_for_this_standard:
                            # print(stu_id)

                            if random.random() < 0.6:
                                # 60% chance of student giving this exam

                                marks = int(round(random.uniform(0, 100), 0))
                                exam_results.append({"result_id": res_id, "exam_id": exam_id, "student_id": stu_id, "exam_date": date_cursor, "marks": marks})
                                temp_results_sql.append(f"({exam_id}, {stu_id}, {marks})")

                                res_id += 1
                    exam_id += 1
        # go to next week
        date_cursor += timedelta(days=7)
exam_sql += ",\n".join(temp_exam_sql) + ";\n"
exam_results_sql += ",\n".join(temp_results_sql) + ";\n"

# print("\n-- Exams Data")
# print(exam_sql)

# # Generate exam results
# exam_results_sql = "INSERT INTO exam_results (exam_id, student_id, exam_date, marks, pass_status, archive_status) VALUES\n"
# temp_results_sql = []
# for student in students:
#     for exam in exams:
#         if student["standard"] == exam["standard"] and random.random() < 0.7:  # 70% chance student attempts exam
#             marks = round(random.uniform(0, 100), 2)
#             pass_status = "Pass" if marks >= 33 else "Fail"
#             temp_results_sql.append(f"({exam['id']}, {student['id']}, '{exam['date'].date()}', {marks})")
# exam_results_sql += ",\n".join(temp_results_sql) + ";\n"

# print("\n-- Exam Results Data")
# print(exam_results_sql)


#writing exam data in file
with open("./data/insert_to_sql.txt", "w") as file:
    file.write("-- Schools Data\n")
    file.write(schools_sql)
    file.write("\n\n")
    file.write("-- Subjects Data\n")
    file.write(subjects_sql)
    file.write("\n\n")
    file.write("-- Students Data\n")
    file.write(students_sql)
    file.write("\n\n")
    file.write("-- Exams Data\n")
    file.write(exam_sql)
    file.write("\n\n")
    file.write(exam_results_sql)
    file.write("\n\n")