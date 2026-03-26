```markdown
# Setup Instructions and implementation process
```
**Note : Make sure all the code is stored in s3 bucket and copied to webservers**

## Clone the Git Repository
Download the code from the Git repository:

```bash
git clone https://github.com/Saahiti-Korlam/AWS-Three-tier-Architecture-Using-Terraform.git
```
## App Server Setup: Launch an ec2 instance in APP subnet of Custom VPC 
## Go through the terraform script 
## You can also modify the script accordingly

On the app server, install MySQL:

```bash
sudo dnf install https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm -y 
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf install mysql-community-server -y
```
### Configure MySQL Database

Connect to the database and perform basic configuration: Replace below info with your DB information

```bash
mysql -h three-tier-db.cbiwg06msjh5.ap-south-2.rds.amazonaws.com -u dbadmin -p 
```

In the MySQL shell, execute the following commands:

```sql
CREATE DATABASE webappdb;
SHOW DATABASES;
USE webappdb;

CREATE TABLE IF NOT EXISTS transactions(
  id INT NOT NULL AUTO_INCREMENT, 
  amount DECIMAL(10,2), 
  description VARCHAR(100), 
  PRIMARY KEY(id)
);

SHOW TABLES;
INSERT INTO transactions (amount, description) VALUES ('400', 'groceries');
SELECT * FROM transactions;
```

### Update Application Configuration to with DB information

Update the `**application-code/app-tier/DbConfig.js**` file with your database credentials.

# Install and Configure Node.js and PM2
### To fetch the database , we have to install some requisites like nvm(node version manager , pm2 (to run the node as service) etc 
## Install Node.js and PM2:

```bash
curl -o- https://raw.githubusercontent.com/avizway1/aws_3tier_architecture/main/install.sh | bash
source ~/.bashrc

nvm install 16
nvm use 16
npm install -g pm2
```
Download application code from S3 and start the application:

```bash
cd ~/
aws s3 cp s3://rukia-3tier-project-demo/application-code/app-tier/ app-tier --recursive

cd ~/app-tier
npm install
pm2 start index.js

pm2 list
pm2 logs
pm2 startup
pm2 save
```

Verify that the application is running by executing:

```bash
curl http://localhost:4000/health
```

It should return: `This is the health check`.
## Internal Load Balancer

Create an internal load balancer and update the Nginx configuration with the internal load balancer IP. 

```text
internal-app-alb-574972862.ap-south-1.elb.amazonaws.com
```

## Web Tier Setup: Launch EC2 Instance in Web Subnets we have created in Custom VPC

### Web Tier Installation. 

Install Node.js and Nginx on the web tier:

```bash
curl -o- https://raw.githubusercontent.com/avizway1/aws_3tier_architecture/main/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16
sudo dnf update -y
sudo dnf install nginx -y

cd ~/
aws s3 cp s3://rukia-3tier-project-demo/application-code/web-tier/web-tier --recursive


cd ~/web-tier
npm install
npm run build

sudo amazon-linux-extras install nginx1 -y
```

Update Nginx configuration:

```bash
cd /etc/nginx
ls

sudo rm nginx.conf
sudo aws s3 cp s3://rukia-3tier-project-demo/application-code/nginx.conf .
sudo service nginx restart

chmod -R 755 /home/ec2-user

sudo chkconfig nginx on
```
```



