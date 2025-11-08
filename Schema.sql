CREATE DATABASE studentdb;

-- Use the database
USE studentdb;

-- Create students table
create table students(id int primary key auto_increment, fullname varchar(50),
email varchar(50), phone bigint, course varchar(20));

-- Verify table creation
SHOW TABLES;

-- View table structure
DESCRIBE students;

-- After submiting successfully using submit.php then use below 
select * from students

