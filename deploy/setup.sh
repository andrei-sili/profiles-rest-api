#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# Set Git repo and app path
PROJECT_GIT_URL='https://github.com/andrei-sili/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Set locale
locale-gen en_GB.UTF-8

# Install dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git

# Clone the project
mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

# Create virtual environment
python3 -m venv $PROJECT_BASE_PATH/env

# Install requirements and Gunicorn
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt gunicorn

# Run database migrations
$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/manage.py migrate

# Configure Supervisor to run Gunicorn
cat > /etc/supervisor/conf.d/profiles_api.conf << EOF
[program:profiles_api]
command=$PROJECT_BASE_PATH/env/bin/gunicorn profiles_project.wsgi:application --bind 0.0.0.0:8000
directory=$PROJECT_BASE_PATH
user=www-data
autostart=true
autorestart=true
stderr_logfile=/var/log/profiles_api.err.log
stdout_logfile=/var/log/profiles_api.out.log
EOF

supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Configure Nginx
cat > /etc/nginx/sites-available/profiles_api.conf << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx

echo "✅ Deployment complete using Gunicorn + Nginx!"
