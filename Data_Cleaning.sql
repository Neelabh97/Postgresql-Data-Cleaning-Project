create TABLE sales_tbl(
full_name varchar(50),
age	int, 
martial_status	varchar(15),
email	varchar(50),
phone	varchar(30),
full_address	varchar(255),
job_title	varchar(50),
membership_date date
)

alter table sales_tbl rename to club_members;

select * from club_members;

--- Probelem 1 : We have observed that there is no primary key in the orignal table, hence 
-- We will create a new column 'Member_ID' with primary key for the table.

Alter table club_members     
add column Member_ID UUID PRIMARY KEY DEFAULT gen_random_uuid ();

select * from club_members;

-- Cleaning column 1, full_name where we have found that some entries in colum 1 has question marks 
-- random spaces in the name.

-- We are checking if there are any null enteris in the full_name column.

select full_name 
from club_members
where full_name = ' '
-- No entry with null values found

-- Now we will write command to remove unwanted characters from full_name column
-- and rename it as clean_full_name

select full_name,
trim(regexp_replace(full_name, '[^a-zA-Z ]', '', 'g')) as Clean_full_name
from club_members


-- Column 2, Age. 
-- Now we will clean the age column. 
-- Issues in age ( correct 3 digits from age ex: 311 and null values)

select 
case 
    when age = 0 then Null
    when length(cast(age as char)) > 2 then CAST(SUBSTRING(CAST(age AS CHAR), 1, 2) AS INT)
	else age
	end as age
from club_members;

-- Column 3, Marital Status.
-- Extracting coluMN Marital Status
-- to small letter
-- "Null" to null

select martial_status
from club_members
select 
   CASE 
	
	WHEN martial_status is not null then
	-- Checking for null values in marital status column.
	concat(UPPER(SUBSTRING(martial_status,1,1)) , TRIM(SUBSTRING(martial_status,2,LENGTH(martial_status))))
	-- First function extracts the first character from the column
	-- Upper function converts that to upper case
	-- We then extract character from 2 character till the end of the string and trim it.
	-- Then we use concat function and have joined them both.
	WHEN martial_status = '' THEN  COALESCE(martial_status, Null)
	-- we check for empty values, if empty Values found we make it null.
	ELSE martial_status 
	--  Else we display martial status as it is.
	end as Martial_status
from club_members

select * from club_members


-- Column 4, EMAIL.
-- We just need to remove extra spaces from staring and  ending of the string 
-- Then covert it to the lower case.


Select  lower(trim(email)) as trimmed_email
from club_members



-- Column 5, Phone. ''

select 
case when length(trim(phone))< 12 or length(trim(phone)) > 12 then Null
-- We first trim the phone number by removing extra spaces and then look for number more than 12 digits
-- Then we convert it to null.
when trim(phone) = '' then null
-- If empty values in the phone column then return Null.
else trim(phone)
-- Eelse only remove the extra spaces from the phone number
end as phone
from club_members


--column 6, Address.
select * from club_members

select lower(trim(split_part(full_address, ',', 1))) as street,
-- We Extract street from adress by using split_part by taking part of string before 1st comma.
-- Then we trim the string to remove extra spaces from before and after the string
--Then we convert the whole thing to lower case.
lower(trim(split_part(full_address, ',', 2))) as city,
-- We Extract city from adress by using split_part by taking part of string before 2nd comma.
lower(trim(split_part(full_address, ',', 3))) as State
---- We Extract state from adress by using split_part by taking part of string before 3rd comma.
from club_members

select * from club_members

-- Column 7, Job_Tile

-- JOB _title: Some job titles define a level in roman numerals (I, II, III, IV). 
--  So there for it needs to be Converted to numbers and add descriptor (ex. Level 3).
--  Trim whitespace from job title, rename to occupation and if empty convert to null type.


Select job_title, case
when trim(job_title) = '' then Null
-- Checking empty values in jobtitle after trimming and coverting that to null
	 WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND 
             LOWER(split_part(job_title, ' ', -1)) = 'i'
-- First we have checked if each entry has space, if there is a space then we check for roman numeral.
-- if we don't have space then we skip that entry.
-- 
			 THEN REPLACE(LOWER(job_title), ' i', ', level 1')
-- If roman numeral found and if roman numeral is 'i' then repalce it with " , Level 1"
-- Similaryl we have done for all the when and then cases below.
	  WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND 
             LOWER(split_part(job_title, ' ', -1)) = 'ii'
			 THEN REPLACE(LOWER(job_title), ' ii', ', level 2')
	  WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND 
             LOWER(split_part(job_title, ' ', -1)) = 'iii'
			 THEN REPLACE(LOWER(job_title), ' iii', ', level 3')
	  WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND 
             LOWER(split_part(job_title, ' ', -1)) = 'iv'
			 THEN REPLACE(LOWER(job_title), ' iv', ', level 4')
	 ELSE TRIM(job_title)
end as occupation
FROM club_members;

-- -- Column 8, membership_Date

select * from club_members

-- 
-- 10) membership_date: some dates are from last century it needs to be fixed to present century.


						 	
select membership_date, 
	case
		when  extract(year from membership_date) < 2000
-- We are checking for dates only after year 2000 here.
-- If date with year after 2000 found then -->
		Then  
			 to_date(CONCAT(
			CONCAT(REPLACE(SUBSTRING(CAST (extract(year from membership_date) as varchar),1,2),'19','20'),
			  SUBSTRING(CAST (extract(year from membership_date) as varchar), 3,2)),'-',
			  cast(extract(month from membership_date) as varchar),'-' ,
	cast(extract(day from membership_date) as varchar)),'YYYY-MM-DD')
-- Then, 
-- first we extracted year from date, then covert the datatype to varchar() then took the substring
-- from 1st chaarcter to 2nd and replaced 19 with 20 (example converted 1920 to 2020)
-- Then in next command we extracted year from date and again converted the datatype to varchar()
-- and extract the last two characters from substring we took 2 character from 3rd chaarcter (example from 2018 we extract 18)
-- Then we concatenated inital two digits and last to digits of year (example 2019 - splitting into  20 and 19 then concatenate (20 + 19 = 2019) )
-- then we extracted month from the date.
-- then we extracted year from the date.
-- then we concatenated the whole command as in (Aggregating day, year and month after extarcting each individually)
-- Then we use to_date to covert back the datatype of whole command to date from varchar().

		else membership_date
	end
from club_members
select member_id as "Member Id"
from club_members;
--------------------------------------------------
------------ final combined query --------
SELECT 
    Member_id AS "Member ID",
    Lower(trim(regexp_replace(full_name, '[^a-zA-Z ]', '', 'g'))) AS "Full Name",
    CASE
        WHEN age = 0 THEN NULL
        WHEN length(cast(age AS char)) > 2 THEN CAST(SUBSTRING(CAST(age AS CHAR), 1, 2) AS INT)
        ELSE age
    END AS Age,
    CASE
        WHEN martial_status IS NOT NULL THEN
            concat(UPPER(SUBSTRING(martial_status, 1, 1)), TRIM(SUBSTRING(martial_status, 2, LENGTH(martial_status))))
        WHEN martial_status = '' THEN COALESCE(martial_status, NULL)
        ELSE martial_status
    END AS "Marital Status",
    lower(trim(email)) AS "Email",
    CASE
        WHEN length(trim(phone)) < 12 OR length(trim(phone)) > 12 THEN NULL
        WHEN trim(phone) = '' THEN NULL
        ELSE trim(phone)
    END AS Phone,
    lower(trim(split_part(full_address, ',', 1))) AS Street,
    lower(trim(split_part(full_address, ',', 2))) AS City,
    lower(trim(split_part(full_address, ',', 3))) AS State,
    CASE
        WHEN trim(job_title) = '' THEN NULL
        WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND
             LOWER(split_part(job_title, ' ', -1)) = 'i'
            THEN REPLACE(LOWER(job_title), ' i', ', level 1')
        WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND
             LOWER(split_part(job_title, ' ', -1)) = 'ii'
            THEN REPLACE(LOWER(job_title), ' ii', ', level 2')
        WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND
             LOWER(split_part(job_title, ' ', -1)) = 'iii'
            THEN REPLACE(LOWER(job_title), ' iii', ', level 3')
        WHEN CHAR_LENGTH(TRIM(job_title)) - CHAR_LENGTH(REPLACE(TRIM(job_title), ' ', '')) > 0 AND
             LOWER(split_part(job_title, ' ', -1)) = 'iv'
            THEN REPLACE(LOWER(job_title), ' iv', ', level 4')
        ELSE TRIM(job_title)
    END AS Occupation,
    CASE
        WHEN extract(year FROM membership_date) < 2000
            THEN to_date(CONCAT(
                    CONCAT(REPLACE(SUBSTRING(CAST(extract(year FROM membership_date) AS varchar), 1, 2), '19', '20'),
                           SUBSTRING(CAST(extract(year FROM membership_date) AS varchar), 3, 2)), '-',
                    cast(extract(month FROM membership_date) AS varchar), '-',
                    cast(extract(day FROM membership_date) AS varchar)),
                 'YYYY-MM-DD')
        ELSE membership_date
    END AS "Membership Date"
FROM club_members;


	