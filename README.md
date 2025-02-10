# Student Performance Report Generator

An automated system for generating weekly student performance reports with LLM-powered analysis and email capabilities.

## Project Structure
```
data/
└── generate_dataset.py      # Utility function for dummy dataset generation

my_sql_data/
├── create_schema.sql
├── delete_schema.sql
├── insert_data.sql         # Dummy data for database
├── solution_faqs.sql       # Queries to answer FAQs given in the assignment
└── report_analysis.sql     # Queries for analysis done for report generation

sharding/
└── sharding.py             # Application-level interface for sharding, not implemented at the database level

src/
├── student_report.py      # Main module
├── llm_service.py        # LLM operations
├── email_service.py      # Email functionality
├── database.py          # Database operations
├── config.yaml          # SQL queries and model configs
├── .env                # Environment variables
├── requirements.txt    # Python dependencies
└── student_report.log  # Log file

test/
├── test_email.py         # Testing email sending function
├── test_gemini.py        # Testing connection to LLM and generation
└── test_mysql.py         # Testing connection to DB and data retrieval

output/            # Report output directory

```

## Prerequisites

1. Python 3.8 or higher
2. MySQL Database
3. Gmail account (for sending emails)
4. Gemini API key

## Installation

1. Clone the repository:
```bash
git clone https://github.com/sushant-97/ExamPulse.git
cd ExamPulse
```

2. Create and activate virtual environment:
```bash
conda create --name myenv python
conda activate myenv
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create `.env` file with required credentials:
```env
DB_HOST=your_host
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=your_database
GEMINI_API_KEY=your_gemini_api_key
EMAIL_SENDER=your_email@gmail.com
EMAIL_PASSWORD=your_app_specific_password
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
```

## Usage

### Basic Usage
Generate report and save to default location:
```bash
python student_report.py
```

### Complete Example
```bash
python student_report.py --email --recipients admin@school.com teacher@school.com --output ./reports/custom_report.md
```

## Automated Weekly Execution

### Setting up Crontab (Linux/Mac)

1. Open crontab editor:
```bash
crontab -e
```

2. Add the following line to run every Monday at 6 AM:
```bash
0 6 * * 1 cd /path/to/project && /path/to/venv/bin/python student_report.py --email --recipients admin@school.com >> /path/to/project/cron.log 2>&1
```