import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


import smtplib

obj = smtplib.SMTP('smtp.gmail.com', 587)
obj.starttls()


subject = "Email Subject"
body = "This is the body of the text message"
sender = "sushant.pargaonkar97@gmail.com"
recipients = ["sush5923@gmail.com"]
password =""

obj.login(sender, password)
obj.sendmail(sender, recipients[0], "HIIIII")