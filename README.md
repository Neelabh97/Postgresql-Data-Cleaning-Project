# Postgresql-Data-Cleaning-Project
This PostgreSQL project involves comprehensive data cleaning and transformation of a club member table, leveraging regular expressions, string manipulation, date extraction, and case statements to handle null values, format data consistently, and extract meaningful information from composite columns.

## What this repository have:
This repository contains SQL scripts to clean and enhance the data stored in a PostgreSQL database. The database schema consists of a table named `club_members` initially without a primary key and with some data quality issues. The provided scripts address these issues and perform necessary data cleaning and transformation tasks.

## Table of Contents

- [Setup](#setup)
- [Data Cleaning and Transformation](#data-cleaning-and-transformation)
  - [Problem 1: Adding Primary Key](#problem-1-adding-primary-key)
  - [Cleaning Columns](#cleaning-columns)
    - [Full Name](#full-name)
    - [Age](#age)
    - [Marital Status](#marital-status)
    - [Email](#email)
    - [Phone](#phone)
    - [Address](#address)
    - [Job Title](#job-title)
    - [Membership Date](#membership-date)
- [Queries](#queries)
- [Contributing](#contributing)

## Setup

To use these scripts:

1. Ensure you have access to a PostgreSQL database.
2. Copy and execute the SQL commands provided in the `clean_up.sql` script in your PostgreSQL environment.

## Data Cleaning and Transformation

### Problem 1: Adding Primary Key

The initial table `club_members` lacked a primary key, which is essential for data integrity and efficient querying. To address this issue, a new column named `Member_ID` with a UUID primary key constraint was added using the following SQL command:

```sql
ALTER TABLE club_members
ADD COLUMN Member_ID UUID PRIMARY KEY DEFAULT gen_random_uuid();
```

### Cleaning Columns

Several columns required cleaning due to data quality issues:

#### Full Name

The `full_name` column contained entries with random characters and extra spaces. To clean this column, unwanted characters were removed, and the column was renamed to `clean_full_name`. The following SQL query demonstrates this:

```sql
SELECT full_name,
       TRIM(regexp_replace(full_name, '[^a-zA-Z ]', '', 'g')) AS clean_full_name
FROM club_members;
```

#### Age

The `age` column needed cleaning to ensure it contains valid ages. Invalid entries with more than three digits were truncated, and entries with zero values were converted to NULL. The SQL query used for cleaning age is as follows:

```sql
SELECT CASE 
         WHEN age = 0 THEN NULL
         WHEN LENGTH(CAST(age AS CHAR)) > 2 THEN CAST(SUBSTRING(CAST(age AS CHAR), 1, 2) AS INT)
         ELSE age
       END AS age
FROM club_members;
```

#### Marital Status

The `martial_status` column values were standardized to lowercase and capitalized the first letter of each word. Additionally, empty values were converted to NULL. The following SQL query demonstrates this:

```sql
SELECT CASE 
         WHEN martial_status IS NOT NULL THEN CONCAT(UPPER(SUBSTRING(martial_status,1,1)), TRIM(SUBSTRING(martial_status,2,LENGTH(martial_status))))
         WHEN martial_status = '' THEN NULL
         ELSE martial_status 
       END AS marital_status
FROM club_members;
```


### Email

The `email` column entries had extra spaces at the beginning or end, and the emails were not standardized. To clean this column, extra spaces were trimmed, and all email addresses were converted to lowercase. The following SQL query demonstrates this:

```sql
SELECT LOWER(TRIM(email)) AS trimmed_email
FROM club_members;
```

### Phone

The `phone` column required validation to ensure it contained valid phone numbers. Invalid entries, including those with fewer or more than 12 digits, were converted to NULL. Additionally, empty values were converted to NULL. The SQL query used for cleaning the phone column is as follows:

```sql
SELECT CASE 
         WHEN LENGTH(TRIM(phone)) < 12 OR LENGTH(TRIM(phone)) > 12 THEN NULL
         WHEN TRIM(phone) = '' THEN NULL
         ELSE TRIM(phone)
       END AS phone
FROM club_members;
```

### Address

The `full_address` column contained complete addresses with street, city, and state information. To extract and standardize this information, the address was split into separate components (street, city, and state), and extra spaces were trimmed. Additionally, all components were converted to lowercase. The following SQL query demonstrates this:

```sql
SELECT LOWER(TRIM(split_part(full_address, ',', 1))) AS street,
       LOWER(TRIM(split_part(full_address, ',', 2))) AS city,
       LOWER(TRIM(split_part(full_address, ',', 3))) AS state
FROM club_members;
```

### Job Title

The `job_title` column contained various job titles, some of which included level descriptors in Roman numerals (I, II, III, IV). To standardize these titles, Roman numerals were converted to numeric values, and level descriptors were added. Additionally, extra spaces were trimmed, and empty values were converted to NULL. The SQL query used for cleaning the job title column is as follows:

```sql
SELECT job_title, CASE
                      WHEN TRIM(job_title) = '' THEN NULL
                      WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND LOWER(split_part(job_title, ' ', -1)) = 'i' THEN REPLACE(LOWER(job_title), ' i', ', level 1')
                      WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND LOWER(split_part(job_title, ' ', -1)) = 'ii' THEN REPLACE(LOWER(job_title), ' ii', ', level 2')
                      WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND LOWER(split_part(job_title, ' ', -1)) = 'iii' THEN REPLACE(LOWER(job_title), ' iii', ', level 3')
                      WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND LOWER(split_part(job_title, ' ', -1)) = 'iv' THEN REPLACE(LOWER(job_title), ' iv', ', level 4')
                      ELSE TRIM(job_title)
                   END AS occupation
FROM club_members;
```

### Membership Date

The `membership_date` column contained dates, some of which were from the last century. To standardize these dates to the present century, a check was performed, and dates from before the year 2000 were updated. The following SQL query demonstrates this:

```sql
SELECT membership_date, 
       CASE
           WHEN EXTRACT(YEAR FROM membership_date) < 2000 THEN TO_DATE(CONCAT(CONCAT(REPLACE(SUBSTRING(CAST (EXTRACT(YEAR FROM membership_date) AS VARCHAR),1,2),'19','20'), SUBSTRING(CAST (EXTRACT(YEAR FROM membership_date) AS VARCHAR), 3,2)),'-', CAST(EXTRACT(MONTH FROM membership_date) AS VARCHAR),'-', CAST(EXTRACT(DAY FROM membership_date) AS VARCHAR)),'YYYY-MM-DD')
           ELSE membership_date
       END
FROM club_members;
```


### Membership Date

The `membership_date` column contained dates, some of which were from the last century. To standardize these dates to the present century, a check was performed, and dates from before the year 2000 were updated. The following SQL query demonstrates this:

```sql
SELECT membership_date, 
       CASE
           WHEN EXTRACT(YEAR FROM membership_date) < 2000 THEN TO_DATE(CONCAT(CONCAT(REPLACE(SUBSTRING(CAST (EXTRACT(YEAR FROM membership_date) AS VARCHAR),1,2),'19','20'), SUBSTRING(CAST (EXTRACT(YEAR FROM membership_date) AS VARCHAR), 3,2)),'-', CAST(EXTRACT(MONTH FROM membership_date) AS VARCHAR),'-', CAST(EXTRACT(DAY FROM membership_date) AS VARCHAR)),'YYYY-MM-DD')
           ELSE membership_date
       END
FROM club_members;
```

### Queries

Several queries were executed to clean and transform the data. These include cleaning full name, age, marital status, email, phone, address, job title, and membership date.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve this repository.


