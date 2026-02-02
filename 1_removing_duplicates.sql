-- We are going to select from layoff_staging and look for duplicates
--      and display them so we can see which companies are dupes of one another to be able to delete
SELECT
    company,
    location,
    industry,
    total_laid_off,
    date,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layoffs_staging
GROUP BY
    company,
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
    GROUP BY
        company,
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