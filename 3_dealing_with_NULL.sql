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