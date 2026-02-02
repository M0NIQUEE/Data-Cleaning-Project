SELECT *
FROM layoffs;
CREATE TABLE layoffs_staging AS
SELECT *
FROM layoffs;
SELECT *
FROM layoffs_staging;

-- What we are trying to achieve in this project for data cleaning
-- 1. Remove duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any columns