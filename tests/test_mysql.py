import mysql.connector

mydb = mysql.connector.connect(
  host="127.0.0.1",
  user="root",
  password="sushant@1997",
  database="student_management_adv"
)

print(mydb)

mycursor = mydb.cursor()
query = """
SELECT
    exam_id,
    COUNT(DISTINCT CASE WHEN marks < 33 THEN student_id END) as failed_students
FROM exam_results er
WHERE exam_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 WEEK) AND exam_date <= CURRENT_DATE
GROUP BY exam_id;
"""

mycursor.execute("SELECT * FROM exam_results")
myresult = mycursor.fetchall()
print(myresult)
columns = mycursor.description
columns = [desc[0] for desc in mycursor.description]
print(columns)