COPY layoffs
FROM 'C:\Users\moniq\OneDrive\Documents\Data Analyst\Data Cleaning Project\layoffs.csv'
DELIMITER ',' CSV HEADER;

/* ISSUE when it came to having permissions access
\copy layoffs FROM 'C:\Users\moniq\OneDrive\Documents\Data Analyst\Data Cleaning Project\layoffs.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
*/