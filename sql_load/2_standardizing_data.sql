-- Standardizing data by finding issues in our data and fixing them so data looks more uniformed.

-- Checking for leading or trailing spaces in company names
SELECT
    company,
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
    TRIM(TRAILING '.' FROM country)
FROM layoffs_staging
ORDER BY 1;

-- Fix trailing periods in country names
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- When setting our database our date was set as TEXT and not as DATE, we must convert
--      the valid date strings to DATE
UPDATE layoffs_staging
SET date = TO_DATE(date, 'MM/DD/YYYY')
WHERE date ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';

-- Cleaning fake NULL dates
SET date = NULL
WHERE date = 'NULL' OR date = '';

-- Altering the table for date conversion
ALTER TABLE layoffs_staging
ALTER COLUMN date TYPE DATE
USING date::DATE;

SELECT * FROM
layoffs_staging;