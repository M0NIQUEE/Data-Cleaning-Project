## Introduction
Learning to clean data from layoffs dataset. Data imported from kaggle that collected layoff data from different companies.

## Background
Determined to learn how to clean raw data, this project will show my understandings on how to clean up raw data to be easier to read.

### What I Was Trying to Achieve
1. Remove duplicate data
2. Standardize the data
3. Deal with Null values and blank data
4. Remove any un-needed data

## Tools I Used
To help create this project these are the tools I used:
- **SQL**: Allowed me to write queries to remove, standardize and deal with Null values found in raw data.
- **PostgreSQL**: Chosen database to handle the layoffs.csv imported from kaggle.
- **VS Code**: IDE used to write my queries.
- **Git/GitHub**: Tool that helped organization and project tracking.

## The Analysis
Here is how I approached each step to cleaning the raw data:

### 1. Identifying & Removing Duplicates
Duplicate records were identified within the layoffs dataset. These duplicates represented identical layoff event records that were recorded more than twice. To ensure data accuracy and reliability, duplicates were identified and removed, perserving one valid record per event.
```sql
-- We are going to select from layoff_staging and look for duplicates
--      and display them so we can see which companies are dupes of one another to be able to delete
SELECT company,
    location,
    industry,
    total_laid_off,
    date,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layoffs_staging
GROUP BY company,
    location,
    industry,
    total_laid_off,
    date,
    stage,
    country,
    funds_raised_millions
HAVING COUNT(*) > 1;

-- Confirming that we do indeed have duplicates in our data, our next goal is to delete the duplicates
--   but making sure we are still keeping one row and not deleting both
DELETE FROM layoffs_staging
WHERE ctid NOT IN (
        SELECT MIN(ctid)
        FROM layoffs_staging
        GROUP BY company,
            location,
            industry,
            total_laid_off,
            date,
            stage,
            country,
            funds_raised_millions
    );
    
-- After success it should be able to return no data, meaning we have deleted
--      all the found duplicates.
-- Rows went from 2361 to 2356
SELECT *
FROM layoffs_staging;
```
Breakdown of removing the duplicates:

- Validated the clean up by confirming no duplicate groups remained by verifying the row count decreasing from 2,361 to 2,356.

## 2. Standardizing the Data
The dataset was standardized by correcting formatting issues across different fields. This step focused on normalizing text values, consolidating industry labels, correcting formatting and convering date fields into their appropriate data type.

```sql
-- Standardizing data by finding issues in our data and fixing them so data looks more uniformed.
-- Checking for leading or trailing spaces in company names
SELECT company,
    LENGTH(company) AS orig_length,
    LENGTH(TRIM(company)) AS trimmed_length
FROM layoffs_staging
WHERE company <> TRIM(company);

-- Once verifying which companies have leading or trailing spaces,
--      we are going to make sure to update the layoffs_stating table
--      to accept the newly trimmed company names
UPDATE layoffs_staging
SET company = TRIM(company);

-- This should verify the count of companies with leading or trailing spaces,
--      if done correctly there should be no data meaning all companies with leading/trailing spaces are updated.
SELECT COUNT(*)
FROM layoffs_staging
WHERE company <> TRIM(company);

-- When we look at industries we notice that there are repitions of industries but in different names
--      For exmaple for Crypto, there are 2 industries for Crypto and CryptoCurrency, we want to be able to
--      link those two together, because they are supposed to be a part of the same indsutry.
SELECT DISTINCT industry
FROM layoffs_staging;
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Noticed that there was a period after a country, like United States
--      Making sure to fix that
SELECT DISTINCT country,
    TRIM(
        TRAILING '.'
        FROM country
    )
FROM layoffs_staging
ORDER BY 1;

-- Fix trailing periods in country names
UPDATE layoffs_staging
SET country = TRIM(
        TRAILING '.'
        FROM country
    )
WHERE country LIKE 'United States%';

-- When setting our database our date was set as TEXT and not as DATE, we must convert
--      the valid date strings to DATE
UPDATE layoffs_staging
SET date = TO_DATE(date, 'MM/DD/YYYY')
WHERE date ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';

-- Cleaning fake NULL dates
SET date = NULL
WHERE date = 'NULL'
    OR date = '';
    
-- Altering the table for date conversion
ALTER TABLE layoffs_staging
ALTER COLUMN date TYPE DATE USING date::DATE;
SELECT *
FROM layoffs_staging;
```

Breakdown of standardizing:
- Identified and removed leading and trailing whitespace from company names to prevent inconsistencies.
- Converted valid date strings from TEXT to DATE format.
-Verified that all transformations were applied successfully, resulting in a more uniform and analysis-ready dataset.

## 3. Dealing With Null or Blank Values
Missing and invalid values were identified across the fields due to raw data being imported entirely as TEXT. To ensure accurate analysis, the missing data were standardized into correct SQL NULL valules. Additionally any missing industry values were populated using existing records with matching company and location information.

```sql
-- So originally my raw data tables were all set to TEXT, and wouldn't allow import unless INT tables were set to TEXT tables
--      I updated the tables that if there were blank or Null string values to convert it to the NULL value instead
UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL'
    OR total_laid_off = '';
UPDATE layoffs_staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL'
    OR funds_raised_millions = '';
UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL'
    OR percentage_laid_off = '';
SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- Now we need to check for other columns with NULL in them or blank spaces
--      From analyzing the data we saw that some industries also had NULL or blank spaces
--      Which is weird because from other data we know that AirBnB is a travel industry from a different
--      dataset, meaning we are going to try to populate airbnb to travel since its know and already registered as that
SELECT *
FROM layoffs_staging
WHERE industry IS NULL
    OR industry = 'NULL'
    OR industry = ' '
SELECT table1.company,
    table1.location,
    table1.industry AS missing_industry,
    table2.industry AS filled_industry
FROM layoffs_staging AS table1
    JOIN layoffs_staging AS table2 ON table1.company = table2.company
    AND table1.location = table2.location
WHERE (
        table1.industry IS NULL
        OR table1.industry = ' '
    )
    AND table2.industry IS NOT NULL;
UPDATE layoffs_staging AS table1
SET industry = table2.industry
FROM layoffs_staging AS table2
WHERE table1.company = table2.company
    AND table1.location = table2.location
    AND table1.industry IS NULL
    AND table2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging;
```
Breakdown of Null values and blank spaces:
- Converted string based NULL values and empty strings into proper SQL NULL values to enable correct handling.
- Investigated missing and invalid values in the industry column, including NULL values and blank entries.
- Updated missing industry values by filling values when other categories were matched well.

## 4. Cleaning Up Uncessary Data
During exploratory analysis, several recods were identified where both total_laid_off and percentage_laid_off returned NULL. Since these rows contained no meaningful insight, I thought it was best to remove them to not skew any data.

```sql
-- During the analysis of our data, we noticed that both total laid off and percentage laid off
--      were blank for some companies, which kinda opens the question to as why would we need to keep these
--      rows. It's not showing any data that would be useful for us

SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL AND
percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging
WHERE total_laid_off IS NULL AND
percentage_laid_off IS NULL;

-- So basically we deleted the rows where both total laid off and percentage laid off were NULL,
--      because it seemed like data that we really couldn't trust and if we were to analyze data we don't
--      want any skewed data.

SELECT *
FROM layoffs_staging;
```
Breakdown of removing data:
- Queried the dataset to identify rows where both total_laid_off and percentage_laid_off were NULL.
- Determined that the data proved to be untrustworthy to the layoff data, assuming it will skew the results.
- Removed the rows where both layoff metrics were NULL to ensure dataset was clean and reliable.

## What I Learned
Here are some key concepts I learned:
- Gained hands on experience cleaning raw data by identifying and resolving duplicates, inconsistent formatting and invalid values.
- Strengthened PostgreSQL skills, including self-joins, conditional updates, and using system indentifiers like ctid for removing duplicates.