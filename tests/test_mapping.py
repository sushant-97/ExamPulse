import random

temp_sql = []
school_student_mapping = {}
student_id = 1
students = []
student_count = 0

first_names = ["John", "Jane", "Alex", "Emily"]
last_names = ["Smith", "Doe", "Brown", "Johnson"]
schools = ["School A", "School B", "School C"]
students_sql = "INSERT INTO students (name, school_id, standard) VALUES\n"

for school_idx, _ in enumerate(schools):
    student_ids_school = []
    standard_student_mapping = {}  # Initialize for each school

    for standard in [8, 9, 10]:
        student_ids_ = []

        for _ in range(5):
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

    school_student_mapping[school_idx + 1] = standard_student_mapping  # Ensure keys are school IDs

students_sql += ",\n".join(temp_sql) + ";\n"

# Output example of mapping
# print(school_student_mapping)
for key, value in school_student_mapping.items():
    print(key)
    print(value)
    print("*")
