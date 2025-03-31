#!/usr/bin/env bash

set -e  # Stop the script if any command fails

# URL of the Git repository
PROJECT_GIT_URL='https://github.com/andrei-sili/profiles-rest-api.git'

# Path where the project will be cloned
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Set system locale
locale-gen en_GB.UTF-8

# Install dependencies: Python, SQLite, pip, Supervisor, Nginx, Git
echo "Installing dependencies..."
apt-get update
apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git

# Create the project directory and clone the Git repository
mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

# Create a virtual environment
python3 -m venv $PROJECT_BASE_PATH/env

# Activate the virtual environment and install Python packages
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt uwsgi==2.0.21

# Run database migrations
$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/manage.py migrate

# Set up Supervisor to manage the uWSGI process
cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Configure Nginx to expose the app
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "DONE! :)"
