## 🧠 Overview

This project demonstrates a **Two-Tier Architecture** on AWS that separates the web layer and database layer for better **scalability**, **security**, and **performance**.

### What is a Two-Tier Architecture?

- **Tier 1 (Presentation/Application Tier)**: EC2 instance running Nginx web server with PHP
- **Tier 2 (Data Tier)**: Amazon RDS instance running MariaDB/MySQL database

### Benefits

- ✅ **Scalability**: Web and database tiers can scale independently
- ✅ **Security**: Database is in a private subnet, not directly exposed to the internet
- ✅ **Performance**: Optimized for each tier's specific requirements
- ✅ **Maintainability**: Clear separation of concerns

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │   VPC (AWS)    │
                    └────────────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
        ▼                                         ▼
┌──────────────────┐                    ┌──────────────────┐
│  Public Subnet   │                    │  Private Subnet  │
│                  │                    │                  │
│  ┌────────────┐  │                    │  ┌────────────┐  │
│  │ EC2        │  │                    │  │ RDS        │  │
│  │ Instance   │──┼───────────────────►│  │ Instance   │  │
│  │            │  │                    │  │            │  │
│  │ Nginx      │  │                    │  │ MariaDB    │  │
│  │ PHP-FPM    │  │                    │  │ / MySQL    │  │
│  └────────────┘  │                    │  └────────────┘  │
│                  │                    │                  │
│  Security Group: │                    │  Security Group: │
│  - SSH (22)      │                    │  - MySQL (3306)  │
│  - HTTP (80)     │                    │    (from EC2 SG) │
│  - HTTPS (443)   │                    │                  │
└──────────────────┘                    └──────────────────┘
```

### Data Flow

1. **User** requests a web page via HTTP/HTTPS
2. **EC2 Instance** (Nginx) receives the request
3. **PHP-FPM** processes PHP scripts
4. **EC2 Instance** connects to **RDS** (private subnet) for database operations
5. **RDS** returns data to EC2
6. **EC2** sends the response back to the user

---

## ⚙️ Components Used

| Component | Description | Purpose |
|-----------|-------------|---------|
| **EC2 Instance** | Amazon Linux 2 running Nginx + PHP | Web/Application server |
| **RDS Instance** | Managed MariaDB/MySQL database | Database server |
| **VPC** | Virtual Private Cloud | Networking environment |
| **Security Groups** | Firewall rules | Control inbound/outbound traffic |
| **Subnets** | Network segments | Public (EC2) and Private (RDS) |
| **Internet Gateway** | Gateway to internet | Allows EC2 public access |
| **Route Tables** | Routing rules | Directs traffic between subnets |

---

## 📦 Prerequisites

Before starting, ensure you have:

- ✅ AWS Account with appropriate permissions
- ✅ AWS CLI configured (optional but recommended)
- ✅ SSH client (PuTTY, OpenSSH, or Windows Terminal)
- ✅ Basic knowledge of Linux commands
- ✅ Basic knowledge of PHP and SQL

### AWS Resources Needed

- EC2 Instance (t2.micro or larger)
- RDS Instance (db.t3.micro or larger)
- VPC with Public and Private subnets
- Security Groups configured
- Key Pair for EC2 access

---

## 🪜 Setup Instructions

### **Step 1: Launch EC2 Instance**

1. **Login to AWS Console** → Navigate to EC2
2. **Launch Instance** with the following settings:
   - **AMI**: Amazon Linux 2
   - **Instance Type**: t2.micro (Free Tier eligible)
   - **Key Pair**: Create or select an existing key pair
   - **Network Settings**: 
     - VPC: Select your VPC
     - Subnet: Public Subnet
     - Auto-assign Public IP: Enable
   - **Security Group**: Create new or use existing
     - **Inbound Rules**:
       - SSH (22) - Your IP
       - HTTP (80) - 0.0.0.0/0
       - HTTPS (443) - 0.0.0.0/0 (optional)
   - **Storage**: 8 GB (Free Tier)

3. **Launch Instance** and note the Public IP address

---

### **Step 2: Install Nginx, PHP, and MariaDB Client**

Connect to your EC2 instance via SSH:

# Windows (PowerShell)
ssh -i "C:\path\to\your-key.pem" ec2-user@<EC2-Public-IP>
```

Once connected, run the following commands:

```bash
# Update system packages
sudo yum update -y

# Install Nginx
sudo yum install nginx -y

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install PHP and MySQL (MariaDB) support
sudo yum install php php-mysqlnd php-fpm -y

# Start and enable PHP-FPM
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Install MariaDB client (for testing RDS connection)
sudo yum install mariadb -y
```

**Verify Installation:**

```bash
# Check Nginx status
sudo systemctl status nginx

# Check PHP-FPM status
sudo systemctl status php-fpm
```


**Test and restart services:**

```bash
# Test Nginx configuration
sudo nginx -t

# Restart Nginx and PHP-FPM
sudo systemctl restart nginx
sudo systemctl restart php-fpm
```

---

### **Step 4: Create Project Files**

Navigate to the Nginx web root:

```bash
cd /usr/share/nginx/html/

#### **Create test.php**

```bash
sudo nano test.php
```

Add the following content:

```php
<?php
echo"hello";;
?>
```

**Save and exit**

#### **Create form.html**

```bash
sudo nano form.html
```

Add the following content:

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Student Registration Form</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f4f7f8;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
    }
    .container {
      background: #fff;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 5px 10px rgba(0,0,0,0.1);
      width: 400px;
    }
    h2 {
      text-align: center;
      margin-bottom: 20px;
    }
    label {
      display: block;
      margin-top: 10px;
      font-weight: bold;
    }
    input, select {
      width: 100%;
      padding: 10px;
      margin-top: 5px;
      border-radius: 5px;
      border: 1px solid #ccc;
    }
    button {
      width: 100%;
      padding: 12px;
      background: #28a745;
      color: white;
      border: none;
      border-radius: 5px;
      margin-top: 15px;
      cursor: pointer;
      font-size: 16px;
    }
    button:hover {
      background: #218838;
    }
  </style>
</head>
<body>
  <div class="container">
    <h2>Student Registration</h2>
    <form action="submit.php" method="post">
      <label for="fullname">Full Name</label>
      <input type="text" name="fullname" required>
 
      <label for="email">Email</label>
      <input type="email" name="email" required>
 
      <label for="phone">Phone</label>
      <input type="text" name="phone" required>
 
      <label for="course">Course</label>
      <select name="course" required>
        <option value="">-- Select Course --</option>
        <option value="AWS">AWS</option>
        <option value="DevOps">DevOps</option>
        <option value="Python">Python</option>
        <option value="Data Science">Data Science</option>
      </select>
 
      <button type="submit">Register</button>
    </form>
  </div>
</body>
</html>
```

#### **Create submit.php**

```
<?php
$servername = "<endpoint>";  // Database host
$username = "Admin";         // Database username
$password = "Password";             // Database password
$dbname = "studentdb";      // Database name
 
// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
 
// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
 
// Collect form data
$fullname = $_POST['fullname'];
$email    = $_POST['email'];
$phone    = $_POST['phone'];
$course   = $_POST['course'];
 
// Insert into database
$sql = "INSERT INTO students (fullname, email, phone, course) 
        VALUES ('$fullname', '$email', '$phone', '$course')";
 
if ($conn->query($sql) === TRUE) {
  echo "<h2>Registration successful!</h2>";
  echo "<a href='index.html'>Go Back</a>";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}
 
$conn->close();
?>
```

### **Step 5: Create RDS Instance**

1. **Navigate to RDS** in AWS Console
2. **Create Database** with the following settings:
   - **Engine**: MariaDB 
   - **Template**: Free tier
   - **DB Instance Identifier**: `student-db`
   - **Master Username**: `admin`
   - **Master Password**: Create a strong password 
   - **VPC**: Select your VPC
   - **Subnet Group**: Private Subnet
     
### **Step 6: Configure RDS Security Group**

1. **Go to RDS** → Your Database → Connectivity & Security
2. **Click on Security Group**
3. **Edit Inbound Rules**:
   - **Type**: MySQL/Aurora
   - **Port**: 3306
   - **Source**: Select your EC2 Security Group (not IP address)

This ensures only your EC2 instance can access the database.

---

### **Step 7: Create Database and Table in RDS**

Connect to RDS from your EC2 instance:

```bash
mysql -h <RDS-ENDPOINT> -u admin -p
```

Enter your RDS password when prompted.

Once connected, run the following SQL commands:

```sql
-- Create database
CREATE DATABASE  studentdb;

-- Use the database
USE studentdb;

-- Create students table
create table students(id int primary key auto_increment, fullname varchar(50),
email varchar(50), phone bigint, course varchar(20));

-- Verify table creation
SHOW TABLES;

-- View table structure
DESCRIBE students;

-- Exit MySQL
EXIT;
```

---

### **Step 8: Update submit.php with RDS Endpoint**

Edit `submit.php` and replace `your-rds-endpoint` with your actual RDS endpoint:

```bash
sudo nano /usr/share/nginx/html/submit.php
```

Update the `$servername` variable:

```php
$servername = "student-db.xxxxx.region.rds.amazonaws.com";
```

Save and exit.

---

## 🧪 Testing

### **Test 1: PHP Configuration**

1. Open your browser and navigate to:
   ```
   http://<EC2-Public-IP>/test.php
   ```

### **Test 2: Web Form**

1. Navigate to:
   ```
   http://<EC2-Public-IP>/form.html
   ```

2. Fill in the form with test data:
   - **Name**: John Doe
   - **Email**: john.doe@example.com

3. Click **Submit**

**✅ Expected Result:** "Submitted successfully!" message

---

### **Test 3: Verify Database Entry**

Connect to RDS from EC2:

```bash
mysql -h <RDS-ENDPOINT> -u admin -p studentdb
```

Run the following query:

```sql
SELECT * FROM students;
```


## 👨‍💻 Author

**Sudarshan Mane**

- 🌩️ Cloud Computing & AWS Learner
- 📧 Email: manesudarshan3096@gmail.com
