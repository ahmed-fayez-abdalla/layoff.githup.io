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

SELECT * FROM layoffs_stage1 WHERE row_num > 1;


# Standerize Data

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

# Dealing with null and empty cells

SELECT * FROM layoffs_stage1;

-- Dealing with null in industry column

SELECT * FROM layoffs_stage1 WHERE industry IS NULL OR industry = '';

-- Airbnb

SELECT * FROM layoffs_stage1 WHERE company = 'Airbnb';

UPDATE layoffs_stage1 SET industry = 'Travel' WHERE company = 'Airbnb';

SELECT * FROM layoffs_stage1 WHERE company = 'Airbnb';

-- Juul

SELECT * FROM layoffs_stage1 WHERE company = 'Juul';

UPDATE layoffs_stage1 SET industry = 'Consumer' WHERE company = 'Juul';

SELECT * FROM layoffs_stage1 WHERE company = 'Juul';

-- Carvana

SELECT * FROM layoffs_stage1 WHERE company = 'Carvana';

UPDATE layoffs_stage1 SET industry = 'Transportation' WHERE company = 'Carvana';

SELECT * FROM layoffs_stage1 WHERE company = 'Carvana';

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

# Removing columns OR rows

SELECT * FROM layoffs_stage1 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM layoffs_stage1 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_stage1 DROP COLUMN row_num;

SELECT * FROM layoffs_stage1;