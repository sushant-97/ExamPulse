import os
import logging
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

class EmailService:
    """Automatic Email Generation of the report"""

    def __init__(self):
        self.email_sender = os.getenv('EMAIL_SENDER')
        self.email_password = os.getenv('EMAIL_PASSWORD')
        self.smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
        self.smtp_port = int(os.getenv('SMTP_PORT', '587'))

    def send_report(self, recipient_email, report_content, subject=None):

        if not subject:
            subject = f"Weekly Student Performance Report - {datetime.now().strftime('%Y-%m-%d')}"

        msg = MIMEMultipart()
        msg['From'] = self.email_sender
        msg['To'] = recipient_email
        msg['Subject'] = subject

        msg.attach(MIMEText(report_content, 'plain'))
        print("Sending email...")
        try:
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.email_sender, self.email_password)
                server.send_message(msg)
            logger.info(f"Email sent successfully to {recipient_email}")
        except Exception as e:
            logger.error(f"Email sending error: {str(e)}")
            raise

    def send_report_to_multiple(self, recipients, report_content, subject=None):
        """Send report to multiple recipients"""
        for recipient in recipients:
            try:
                self.send_report(recipient, report_content, subject)
            except Exception as e:
                logger.error(f"Failed to send email to {recipient}: {str(e)}")
                continue