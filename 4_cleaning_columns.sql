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