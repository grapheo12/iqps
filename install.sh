echo -e

#Check if required commands are present or not
if (command -v python3) && (command -v docker) && (command -v docker-compose) && (command -v sed) && (command -v cp) && (command -v make) && (command -v g++); then
    echo "All commands exists"
else
    echo "Make sure python3, docker, docker-compose, cp, sed, make and g++ are in your PATH"
fi

#Check if credentials and token are present or not
CRED_FILE="iqps/conf/credentials.json"
TOKEN_FILE="iqps/conf/token.pickle"

if test -f "$CRED_FILE"; then
    echo "Credentials Found"
else
    echo "Get the credentials file from https://developers.google.com/drive/api/v3/quickstart/python. Set desktop application as credentials type and move the file to iqps/conf/"
    exit
fi

if test -f "$TOKEN_FILE"; then
    echo "Token File found"
else
    echo "Generating token file......"
    echo "  Creating Python environment"
    python3 -m pip install virtualenv
    python3 -m virtualenv mini_venv
    echo "  Installing dependencies"
    mini_venv/bin/pip3 install -r mini_requirements.txt
    echo "  Authorizing application."
    mini_venv/bin/python3 -c "import os; os.chdir('iqps'); from upload.google_connect import connect; connect()"
    echo "  Cleaning up"
    rm -rf mini_venv

    echo "You might want to run this script again to complete the installation once you have moved the files to the app server."
    echo "Just re-run here if you want to setup a localhost"
fi

echo "Building mariadb-udf image"

make -C ./mariadb-udf-docker/

echo "Generating docker-compose.yml and app.env"

cp docker-compose.yml.template docker-compose.yml
cp iqps/conf/app.env.template iqps/conf/app.env

sed -i '43,51d' docker-compose.yml
sed -i '17 a \ \ \ \ ports:' docker-compose.yml
sed -i '18 a \ \ \ \ \ \ - 8000:80' docker-compose.yml

CONF_PATH="iqps/conf/app.env"

echo -n "App mode? (dev|prod): "
read APP_MODE

sed -i "s/mode/$APP_MODE/" $CONF_PATH

echo -n "Secret Key for the app? (Random long cryptographically secure string): "
read APP_SECRET_KEY

sed -i "s/secret_key/$APP_SECRET_KEY/" $CONF_PATH

echo "Database will be connected as user: 'iqps_admin'"
echo -n "Password for iqps_admin? : "
read APP_DB_USER_PWD
echo -e

sed -i "s/DB_PWD/$APP_DB_USER_PWD/" $CONF_PATH
sed -i "s/DB_PWD/$APP_DB_USER_PWD/g" docker-compose.yml

echo -n "Database root user password? : "
read APP_DB_PWD
echo -e

sed -i "s/DB_ROOT_PWD/$APP_DB_PWD/g" docker-compose.yml

echo -n "Google Drive Directory name for storing uploaded data? (Be sure to make the directory at a root level in the account of who authorized this app): "
read APP_GDRIVE_DIR

sed -i "s/iqps_static/$APP_GDRIVE_DIR/" $CONF_PATH

echo -n "Local path to store static files? (Give absolute path and make sure current user has write access to it): "
read APP_STATIC_ROOT

mkdir -p $APP_STATIC_ROOT
sed -i "s+local_static_root_path+$APP_STATIC_ROOT+g" docker-compose.yml

echo -n "Local path to store logs? (Give absolute path and make sure current user has write access to it): "
read APP_LOG_PATH

mkdir -p $APP_LOG_PATH
sed -i "s+local_log_path+$APP_LOG_PATH+" docker-compose.yml

echo -n "Local path to store data from database? (Give absolute path and make sure current user has write access to it): "
read APP_DATA_DB_PATH

mkdir -p $APP_DATA_DB_PATH
sed -i "s+local_db_data_path+$APP_DATA_DB_PATH+" docker-compose.yml

echo -n "Do you want Dropbox backup?(y|n)"
read BACKUP_CONSENT

if [ $BACKUP_CONSENT = "y" ]
then
    echo -n "Dropbox access token? "
    read APP_DROPBOX_ACCESS_TOKEN
    sed -i "s/DROPBOX_TOKEN/$APP_DROPBOX_ACCESS_TOKEN/" docker-compose.yml
else
    echo "Please delete the last 10 lines (backup section) from docker-compose.yml"
fi

# echo "Attempting to start docker service.... (Requires sudo)"
# sudo systemctl restart docker

echo "Building Container"

docker-compose build

echo "Running for the first time... Creates all required volumes"
echo "Takes 5-10 minutes... Have patience :-)"
echo "When output says DB is ready to receive connections, hit CTRL+C and move on to run init.sh"

sleep 5 #So that user reads the above lines properly

gnome-terminal -- docker-compose up

if test -f ".log.txt"; then
    sed -i 's/mysqld: ready for connections/mysqld: was ready for connections/gI' .log.txt
else
    docker-compose logs --no-color > ".log.txt";
    sed -i 's/mysqld: ready for connections/mysqld: was ready for connections/gI' .log.txt
fi

lines=0
seen=0
while [ $seen -eq 0 ]
do
    sleep 5
    docker-compose logs --no-color > ".log.txt";
    input=".log.txt";
    STR="mysqld: ready for connections";
    while IFS= read -r line
    do
        if grep -q "$STR" <<< "$line"; then
            echo "It is there. You can exit!";
            seen=1
            break        
        fi
    done < "$input"
    if [ $seen -eq 1 ]; then
        break;
    fi
done

if [ $seen -eq 1 ]; then
    echo "Killing docker-compose!";
    docker-compose stop;
fi

echo "Starting app"
docker-compose up -d

echo "Running Database Migrations"

docker-compose run web python manage.py migrate --skip-checks

echo "Creating Django superuser"

docker-compose run web python manage.py createsuperuser

echo "Saving Static Files"

docker-compose run web python manage.py collectstatic

echo "Initiation completed successfully"
echo "Shutting down containers"

docker-compose down

echo "To run the app, run in this directory:"
echo 'docker-compose up -d'

rm .log.txt

