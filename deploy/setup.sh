#!/usr/bin/env bash

set -e

PROJECT_GIT_URL='https://github.com/andrei-sili/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

locale-gen en_GB.UTF-8

echo "Installing dependencies..."
apt-get update
apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git

mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

python3 -m venv $PROJECT_BASE_PATH/env
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt gunicorn "Django>=4.2,<5.0"

$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/manage.py migrate
$PROJECT_BASE_PATH/env/bin/python $PROJECT_BASE_PATH/manage.py collectstatic --noinput

cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
rm -f /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx

echo "✅ Deployment complete!"
