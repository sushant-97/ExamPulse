#!/bin/bash

# Navigate to project directory
PROJECT_DIR="/path/to/project"
cd $PROJECT_DIR

# Activate virtual environment
conda activate mle-dev

# Run the report generator
python student_report.py --email --recipients admin@school.com teacher@school.com

# Deactivate virtual environment
deactivate