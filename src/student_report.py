import os
import json
import logging
import argparse
from decimal import Decimal
import pandas as pd
import yaml
from typing import Dict
from datetime import datetime
from dotenv import load_dotenv

from database import DatabaseConnection
from llm_service import LLMService
from email_service import EmailService

load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    filename='./logging/student_report.log'
)
logger = logging.getLogger(__name__)

def decimal_converter(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Type {type(obj)} not serializable")

class StudentReportGenerator:
    """Generate student performance reports using database queries with LLM analysis"""

    def __init__(self):
        self.config = self._load_queries()
        # print(self.queries.keys())
        self.llm_service = LLMService()
        self.email_service = EmailService()

    def _load_queries(self):
        """Load SQL queries from config file"""
        with open("./common_configs/config.yaml", "r") as file:
            config = yaml.safe_load(file)
        return config

    def _execute_report_query(self, query_name):
        """Execute a named query and return results as DataFrame"""
        # queries = self.queries['queries']
        print(f"Fetching {query_name} details")
        logger.info(f"Fetching {query_name} details")

        if query_name not in self.config['queries'].keys():
            raise ValueError(f"Query '{query_name}' not found in config")

        try:
            with DatabaseConnection() as db:
                data, columns = db.execute_query(self.config['queries'][query_name])
                return pd.DataFrame(data, columns=columns)
        except Exception as e:
            logger.error(f"Database error in {query_name}: {str(e)}")
            raise

    def generate_report(self, send_email, recipients):
        """Generate the complete student performance report"""
        try:
            logger.info("Starting report generation")
            print("Starting Weekly Analysis")
            total_failures = self._execute_report_query("total_failures")
            failures_by_subjects = self._execute_report_query("subject_wise_failures")
            failure_by_grade = self._execute_report_query("grade_wise_failures")
            performance_report = self._execute_report_query("performance_comparison")

            analysis_data_ = {
                "summary": "Analysis of student performance over the last week.",
                "failures_per_exam": total_failures.to_dict(orient='records'),
                "failures_by_subject": failures_by_subjects.to_dict(orient='records'),
                "failure_by_grade": failure_by_grade.to_dict(orient='records'),
                "performance_analysis": performance_report.to_dict(orient='records'),
            }

            json_data = json.dumps(analysis_data_, indent=4, default=decimal_converter)
            print("Analysis Complete")
            print("Starting Report Generation")
            report_prompt = self.config['llm_config']['report_generation_prompt'].format(
                analysis_data = json_data
            )

            report_content = self.llm_service.generate_report(json_data)

            if send_email and recipients:
                print("Preparing to send email")
                self.email_service.send_report_to_multiple(
                    recipients=recipients,
                    report_content=report_content
                )

            logger.info("Report generation completed successfully")
            print("Report generation completed successfully")
            return report_content

        except Exception as e:
            logger.error(f"Error in report generation process: {str(e)}")
            raise

def parse_arguments():
    # Parse command line argumnets
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--email',
        action='store_true'
    )

    current_date = datetime.now()
    week_num = current_date.isocalendar()[1]
    # formatted_date = current_date.strftime('%Y%m%d')
    formatted_date = current_date.strftime('%Y%m%d_%H%M%S')
    parser.add_argument(
        '--output',
        default=f'./output/school_report_W{week_num}_{formatted_date}.md'
    )

    return parser.parse_args()

def main():
    """Main execution function"""
    try:
        args = parse_arguments()

        report_generator = StudentReportGenerator()

        # Generate report
        report_content = report_generator.generate_report(
            send_email=args.email,
            recipients=[os.getenv('RECIPIENT_EMAIL')]
        )

        # Save report to file
        print("Saving report to output directory")
        output_dir = os.path.dirname(args.output)
        os.makedirs(output_dir, exist_ok=True)

        with open(args.output, "w") as file:
            file.write(report_content)

        logger.info("Report saved successfully")
        print("Report generated and saved to ./output/school_report.md")

    except Exception as e:
        logger.error(f"Main execution error: {str(e)}")
        raise

if __name__ == "__main__":
    main()