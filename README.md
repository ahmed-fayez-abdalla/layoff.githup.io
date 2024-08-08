# Cleaning Layoff Dataset With SQL


## Introduction


In recent years, layoffs have become a significant topic of concern in the business world, impacting employees and employers alike. Understanding the patterns and causes of layoffs can provide valuable insights for organizations and policymakers to mitigate their negative effects.
The purpose of this document is to show how to clean and prepare a layoff dataset using SQL, ensuring that the analysis is based on accurate and reliable data.
The Four Steps to Clean the Data


### Removing Duplicates


An essential part of the data preparation involved removing duplicate entries to ensure data accuracy. This was achieved using the ROW_NUMBER window function in SQL. By assigning a unique sequential integer to rows within a partition of the dataset, duplicates were identified and removed effectively. This process ensured that only the most relevant and distinct records were retained for analysis.





```sql

# Removing Dublicates

CREATE TABLE layoffs_stage LIKE layoffs;



INSERT INTO layoffs_stage SELECT * FROM layoffs;



WITH duplicate_cte AS
(
	SELECT *, ROW_NUMBER() 
	OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions) AS row_num 
	FROM layoffs_stage
)
SELECT * FROM duplicate_cte WHERE row_num > 1;



CREATE TABLE `layoffs_stage1` (
  `company` text DEFAULT NULL,
  `location` text DEFAULT NULL,
  `industry` text DEFAULT NULL,
  `total_laid_off` int(11) DEFAULT NULL,
  `percentage_laid_off` text DEFAULT NULL,
  `date` text DEFAULT NULL,
  `stage` text DEFAULT NULL,
  `country` text DEFAULT NULL,
  `funds_raised_millions` int(11) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



INSERT INTO layoffs_stage1 
SELECT *, ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_stage;



SELECT * FROM layoffs_stage1 WHERE row_num > 1;


DELETE FROM layoffs_stage1 WHERE row_num > 1;

```




### Standardize Data


As part of the data preparation, standardization was a key focus to ensure consistency and accuracy across the dataset. The TRIM function was used to remove any leading or trailing whitespace in the necessary columns, preventing formatting inconsistencies. Additionally, efforts were made to ensure that words with the same meaning were written uniformly, enhancing the dataset's coherence.
Another important step in the data cleaning process was converting the date column from a string format to a proper date format. This conversion facilitated more accurate date-based analyses and allowed for easier integration with analytical tools that rely on date data types.
This analysis aims to identify key trends and factors associated with layoffs, such as industry-specific risks, economic conditions, and organizational changes. By exploring these factors, we hope to uncover insights that can inform decision-making processes and strategies to better manage workforce reductions.





```sql

-- FIX company column

UPDATE layoffs_stage1 SET company = TRIM(company);



-- Fix industry column

SELECT DISTINCT industry FROM layoffs_stage1 ORDER BY industry;


UPDATE layoffs_stage1 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';


SELECT * FROM layoffs_stage1 WHERE industry LIKE 'Crypto%';




-- Fix country column

SELECT DISTINCT country FROM layoffs_stage1 ORDER BY country;


 
UPDATE layoffs_stage1 SET country = 'United States' WHERE country LIKE 'United States%';


-- TRIM(TRAILING '.' FROM country) another way to fix country coulmn




-- Change date column from string to date

SELECT `date`, str_to_date(`date`, '%m/%d/%Y') FROM layoffs_stage1;



UPDATE layoffs_stage1 SET `date` = str_to_date(`date`, '%m/%d/%Y');



SELECT `date` FROM layoffs_stage1;



ALTER TABLE layoffs_stage1 MODIFY COLUMN `date` DATE;


```



### Dealing with null and empty cells


Sometimes we need to change the empty cells to null values, in the other hand maybe we need to remove some null records from the dataset.





```sql


SELECT * FROM layoffs_stage1;



-- Dealing with null in industry column

SELECT * FROM layoffs_stage1 WHERE industry IS NULL OR industry = '';



-- Airbnb

SELECT * FROM layoffs_stage1 WHERE company = 'Airbnb';


UPDATE layoffs_stage1 SET industry = 'Travel' WHERE company = 'Airbnb';



-- Juul

SELECT * FROM layoffs_stage1 WHERE company = 'Juul';


UPDATE layoffs_stage1 SET industry = 'Consumer' WHERE company = 'Juul';



-- Carvana


SELECT * FROM layoffs_stage1 WHERE company = 'Carvana';


UPDATE layoffs_stage1 SET industry = 'Transportation' WHERE company = 'Carvana';



-- Bally's Interactive

SELECT * FROM layoffs_stage1 WHERE company = "Bally's Interactive";

UPDATE layoffs_stage1 SET industry = '' WHERE company = "Bally's Interactive";

SELECT * FROM layoffs_stage1 WHERE company = "Bally's Interactive";




-- OR Make this instead


UPDATE layoffs_stage1 SET company = NULL WHERE company = '';


SELECT t1.industry, t2.industry FROM layoffs_stage1 t1 JOIN layoffs_stage1 t2 
ON t1.company = t2.company WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;


UPDATE layoffs_stage1 t1 JOIN layoffs_stage1 t2 ON t1.company = t2.company
SET t1.industry = t2.industry WHERE  t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT * FROM layoffs_stage1 WHERE industry IS NULL;



```



### Removing columns OR rows


Sometimes we need to remove some columns which we don’t need to like the ROW_NUMBER column after using it in removing the duplicates, we need to remove the column after cleaning the data.





```sql



SELECT * FROM layoffs_stage1 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


DELETE FROM layoffs_stage1 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_stage1 DROP COLUMN row_num;



```





