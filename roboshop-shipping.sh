#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
C="\e[1;36m"

mkdir -p $logs_folder

echo "Script started execution at $(date +"%F %T")" &>> $logs_file

if [ $user_id -ne  0 ];
 then
 echo "Please  executing file with sudo access"
 exit 1
fi

validate(){
    if [ $1 -eq 0 ];
    then
    echo -e "$2 .....${G}Success${N}"| tee -a  $logs_file
    else
    echo -e "$2 .....${R}failed${N}" | tee -a  $logs_file
    fi
}

timestamp(){
    date "+%F %T"
}

echo -e "$(timestamp)  [INFO]  ${R}========== ${C}Script Execution Started${R} ==========>${N}" | tee -a  $logs_file
 

dnf module enable maven:3.9 -y &>> $logs_file
validate $? "Enabling maven:3.9  " | tee -a  $logs_file

dnf install maven java-25-openjdk-devel -y &>> $logs_file
validate $? "Installing maven java-25-openjdk-devel " | tee -a  $logs_file


alternatives --set java /usr/lib/jvm/java-25-openjdk/bin/java &>> $logs_file
validate $? "setting up java-25 as default " | tee -a  $logs_file


echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
validate $? "setting JAVA_HOME for maven " | tee -a  $logs_file


java -version &>> $logs_file
mvn -v &>> $logs_file

if grep -q "^roboshop:" /etc/passwd;
then
 echo -e "roboshop user already created ....${Y}SKIPPING${N}"
else
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Creating user roboshop " | tee -a  $logs_file
fi

mkdir -p /app &>> $logs_file
curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip


unzip -o /tmp/shipping.zip -d /app &>> "$logs_file"
validate $? "Unzipping application files to /app" | tee -a "$logs_file"

cd /app

mvn clean package &>> $logs_file
validate $? "Running mvn clean package is " | tee -a  $logs_file

mv target/shipping.jar shipping.jar &>> $logs_file
validate $? "Running mvn clean package is " | tee -a  $logs_file



echo "Load Master Data........."

dnf install mysql -y &>> $logs_file
validate $? "Installing mysql client package " | tee -a  $logs_file

echo "Checking cities data in MySQL"

city_data=$(mysql -h mysql.roboshop.anilkumarpatnana.online \
    -uroot -pRoboShop@1 -N -s \
    -e "SELECT COUNT(*) FROM cities.cities;")

if [ $? -ne 0 ]; then
    echo "Failed to check cities data in MySQL" | tee -a "$logs_file"
    exit 1
fi

if [ "$city_data" -gt 0 ]; then
    echo -e "City data already added ....${Ye}SKIPPING${N}" | tee -a "$logs_file"
else
    mysql -h mysql.roboshop.anilkumarpatnana.online \
        -uroot -pRoboShop@1 \
        < /app/db/master-data.sql &>> "$logs_file"

    validate $? "Loading cities data to MySQL server" | tee -a "$logs_file"
fi

mysql -h mysql.roboshop.anilkumarpatnana.online -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $logs_file
validate $? "creating shipping user in mysql db for application access " | tee -a  $logs_file


cp /home/ec2-user/repo/roboshop-v1/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload &>> $logs_file
validate $? "Reloading the daemon service systemd " | tee -a  $logs_file

systemctl enable shipping &>> $logs_file
validate $? "Enabling shipping service  " | tee -a  $logs_file


systemctl start shipping &>> $logs_file
validate $? "Starting shipping service " | tee -a  $logs_file


echo -e "${Y}==========> VERIFICATION${N}"

systemctl status shipping &>> $logs_file
validate $? "shipping service is running " | tee -a  $logs_file

curl http://localhost:8080/actuator/health | tee -a  $logs_file
curl http://localhost:8080/count | tee -a  $logs_file

curl http://localhost:8080/codes &>> $logs_file
validate $? "able to access city codes " | tee -a  $logs_file



echo "$(timestamp)  [INFO] Time taken  $SECONDS" | tee -a  $logs_file

echo -e "$(timestamp)  [INFO]  ${R}========== ${C}Script Execution Completed${R} ==========>${N}" | tee -a  $logs_file

