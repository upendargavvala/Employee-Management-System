-- Creating Employement Manegement System Database
create database Employee_Management_System;
use Employee_Management_System;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- viewing the tables.
show tables;
-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
SELECT 
    COUNT(DISTINCT emp_id)
FROM
    employee;

-- Which departments have the highest number of employees?
SELECT 
    jd.jobdept, COUNT(e.emp_id) AS employee_count
FROM
    employee AS e
        JOIN
    jobdepartment AS jd ON e.job_id = jd.job_id
GROUP BY jd.jobdept
HAVING employee_count = (SELECT 
        MAX(emp_count)
    FROM
        (SELECT 
            COUNT(e1.emp_id) AS emp_count
        FROM
            employee AS e1
        JOIN jobdepartment AS jd1 ON e1.job_id = jd1.job_id
        GROUP BY jd1.jobdept) AS temp); 

-- What is the average salary per department?
SELECT 
    jd.jobdept, avg(sb.amount) AS avg_salary
FROM
    salarybonus AS sb
        JOIN
    jobdepartment AS jd ON sb.job_id = jd.job_id
GROUP BY jd.jobdept;

-- Who are the top 5 highest-paid employees?
SELECT 
    e.emp_id, e.firstname, e.lastname, sb.amount AS salary
FROM
    employee AS e
        JOIN
    salarybonus AS sb ON e.job_id = sb.job_id
ORDER BY salary DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT 
    SUM(total_amount) AS total_salary_expenditure
FROM
    payroll;
    
-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
select * from jobdepartment;
-- How many different job roles exist in each department?
SELECT 
    jobdept, COUNT(DISTINCT name) AS total_roles
FROM
    jobdepartment
GROUP BY jobdept;

-- What is the average salary range per department?
SELECT 
    jd.jobdept, AVG(sb.amount) AS avg_salary
FROM
    jobdepartment AS jd
        JOIN
    salarybonus AS sb ON jd.job_id = sb.job_id
GROUP BY jd.jobdept; 

-- Which job roles offer the highest salary?
SELECT 
    jd.name AS job_role, sb.amount AS highest_salary
FROM
    jobdepartment AS jd
        JOIN
    salarybonus AS sb ON jd.job_id = sb.job_id
WHERE
    sb.amount = (SELECT 
            MAX(amount)
        FROM
            salarybonus);

-- ●Which departments have the highest total salary allocation?
SELECT 
    jb.jobdept, SUM(sb.amount) AS Total_salary_allocaltion
FROM
    jobdepartment AS jb
        JOIN
    salarybonus AS sb ON jb.job_id = sb.job_id
GROUP BY jb.jobdept
HAVING SUM(sb.amount) = (SELECT 
        MAX(total_alloc)
    FROM
        (SELECT 
            SUM(sb1.amount) AS total_alloc
        FROM
            salarybonus AS sb1
        JOIN jobdepartment AS jd1 ON sb1.job_id = jd1.job_id
        GROUP BY jd1.jobdept) AS t);
        

-- 3. QUALIFICATION AND SKILLS ANALYSIS
select * from qualification;
select * from employee;
-- How many employees have at least one qualification listed?
SELECT 
    COUNT(*) AS employees_with_qualification
FROM
    Employee e
WHERE
    EXISTS( SELECT 
            1
        FROM
            Qualification q
        WHERE
            q.Emp_ID = e.emp_ID);
    
-- Which positions require the most qualifications?
-- Which positions require the most qualifications?
SELECT 
    q.position, COUNT(*) AS qualification_count
FROM
    qualification AS q
GROUP BY q.position
HAVING COUNT(*) = (SELECT 
        MAX(cnt)
    FROM
        (SELECT 
            COUNT(*) AS cnt
        FROM
            qualification
        GROUP BY position) AS t);

-- Which employees have the highest number of qualifications?
SELECT 
    e.emp_id,
    e.firstname,
    e.lastname,
    COUNT(*) AS qualification_count
FROM
    qualification AS q
        JOIN
    employee AS e ON q.emp_id = e.emp_id
GROUP BY e.emp_id
HAVING COUNT(*) = (SELECT 
        MAX(cnt)
    FROM
        (SELECT 
            COUNT(*) AS cnt
        FROM
            qualification
        GROUP BY emp_id) t);
        
-- 4. LEAVE AND ABSENCE PATTERNS
select * from leaves;

-- Which year had the most employees taking leaves?
SELECT 
    YEAR(date) AS year, COUNT(DISTINCT emp_ID) AS employees_on_leave
FROM
    leaves
GROUP BY YEAR(date)
HAVING COUNT(DISTINCT emp_ID) = (SELECT 
        MAX(emp_count)
    FROM
        (SELECT 
            COUNT(DISTINCT emp_ID) AS emp_count
        FROM
            leaves
        GROUP BY YEAR(date)) t);
        
-- What is the average number of leave days taken by its employees per department?
SELECT 
    jd.jobdept, AVG(emp_leaves.leves_count) AS avg_leaves_count_per_employee
FROM
    (SELECT 
        emp_id, COUNT(*) AS leves_count
    FROM
        leaves
    GROUP BY emp_id) AS emp_leaves
        JOIN
    employee AS e ON emp_leaves.emp_id = e.emp_id
        JOIN
    jobdepartment AS jd ON e.job_id = jd.job_id
GROUP BY jd.jobdept;

-- Which employees have taken the most leaves?
SELECT 
    e.emp_ID, e.firstname, e.lastname, COUNT(*) AS leave_count
FROM
    Leaves l
        JOIN
    Employee e ON l.emp_ID = e.emp_ID
GROUP BY e.emp_ID
HAVING COUNT(*) = (SELECT 
        MAX(cnt)
    FROM
        (SELECT 
            COUNT(*) AS cnt
        FROM
            Leaves
        GROUP BY emp_ID) t);
        
-- What is the total number of leave days taken company-wide?
SELECT 
    COUNT(*) AS company_wide_leaves
FROM
    Leaves;
    
-- How do leave days correlate with payroll amounts?
SELECT 
    e.emp_id,e.firstname , e.lastname ,
    COUNT(l.leave_id) AS leave_days,
    AVG(p.total_amount) AS avg_payroll
FROM
    employee AS e
        LEFT JOIN
    leaves AS l ON e.emp_id = l.emp_id
        JOIN
    payroll AS p ON e.emp_id = p.emp_id
GROUP BY e.emp_id;

-- 5. PAYROLL AND COMPENSATION ANALYSIS
select * from payroll;

-- What is the total monthly payroll processed?
SELECT 
    MONTH(date) AS month, SUM(total_amount) AS total_monthly_pay
FROM
    payroll
GROUP BY MONTH(date)
ORDER BY month;

-- What is the average bonus given per department?
SELECT 
    jd.jobdept, AVG(sb.bonus) AS avg_bonus
FROM
    employee AS e
        JOIN
    jobdepartment AS jd
        JOIN
    salarybonus AS sb ON jd.job_id = sb.job_id
GROUP BY jd.jobdept;

-- Which department receives the highest total bonuses?
SELECT 
    jd.jobdept, SUM(sb.bonus) AS total_bonus
FROM
    jobdepartment AS jd
        JOIN
    salarybonus AS sb ON jd.job_id = sb.job_id
GROUP BY jd.jobdept
HAVING SUM(sb.bonus) = (SELECT 
        MAX(bonus_count)
    FROM
        (SELECT 
            SUM(sb1.bonus) AS bonus_count
        FROM
            salarybonus AS sb1
        JOIN jobdepartment AS jb1 ON sb1.job_id = jb1.job_id
        GROUP BY jb1.jobdept) AS t);
        
--  What is the average value of total_amount after considering leave deductions?
-- avg payroll per employee
select avg(total_amount) as avg_payroll from payroll;

-- leaves per employee
select emp_id , count(*) as leave_days
from leaves 
group by emp_id;

