/*
=====================================================================================================
Quality Checks
=====================================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardization across the 'silver' schemas. It includes checks for :
  -  Null or duplicate primary keys.
  -  Unwanted spaces in string fields.
  -  Data standardization and consistency.
  -  Invalid date ranges and orders.
  -  Data consistency between related fields.

Usage Notes:
  -  Run these checks after data loading Silver Layer.
  -  Invastigate and resolve any discrepancies found during the checks
=====================================================================================================
*/

--=====================================================================
--  Checking 'silver.crm_cust_info
--=====================================================================
-- CHECK FOR NULLS AND DUPLICATES IN PRIMARY KEY IN SILVER LAYER
-- EXPECTATION NO RESULT

SELECT
cst_id,
count(*)
 FROM silver.crm_cust_info
 GROUP BY cst_id
 HAVING COUNT(*) >1 OR cst_id IS NULL

-- CHECK FOR UNWANTED SPACES IN SILVER LAYER
-- EXPECTATION NO RESULT
SELECT * 
 FROM silver.crm_cust_info
 WHERE cst_firstname != LTRIM(cst_firstname) OR cst_firstname != RTRIM(cst_firstname)

 SELECT * 
 FROM silver.crm_cust_info
 WHERE cst_lastname != LTRIM(cst_lastname) OR cst_lastname != RTRIM(cst_lastname)

 SELECT * 
 FROM silver.crm_cust_info
 WHERE cst_gndr != LTRIM(cst_gndr) OR cst_gndr != RTRIM(cst_gndr)
  
 -- DATA STANDARDIZATION & CONSISTENCY IN SILVER LAYER
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info


SELECT * FROM silver.crm_cust_info

--=====================================================================
--  Checking 'silver.crm_prd_info
--=====================================================================

---Check For Nulls or Duplicates in Primary KeY
---Expectation: No Result

Select
Count(*),
prd_id
FROM 
silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL


-- CHECK FOR UNWANTED SPACES 
-- EXPECTATION NO RESULT

SELECT prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != RTRIM(LTRIM(prd_nm))

--CHECK FOR NULLS OR NEGATIVE NUMBERS
-- EXPECTATION NO RESULT

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--CHECK FOR STANDARDIZATION  & CONSISTENCY 
SELECT DISTINCT prd_line FROM silver.crm_prd_info

-- CHECK FOR INVALID DATE ORDERS

SELECT
*
FROM silver.crm_prd_info
WHERE  prd_end_dt < prd_start_dt

SELECT
*
FROM silver.crm_prd_info

--=====================================================================
--  Checking 'silver.crm_sales_details
--=====================================================================

--CHECK FOR INVALID DATES(FOR ALL DATES COLUMN CHECKING ONE BY ONE)

SELECT
NULLIF(sls_ship_dt,0) AS sls_ship_dt    --- convert 0 to null   ** no need to check bcoz dates are converted to DATE FORMAT FROM NUMBER FORMAT
FROM									-- SO GIVING ERROR
silver.crm_sales_details
WHERE sls_ship_dt<=0 
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

--CHECK WHETHER ORDER DATE IS HIGHER THAN SHIPPING DATE OR DUE DATE

	SELECT
	*
	FROM 
	silver.crm_sales_details
	where sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

---	CHECK FOR NUMBER COLUMNS 

	SELECT 	
		sls_sales,
		sls_quantity,
		sls_price
	FROM silver.crm_sales_details
		WHERE sls_sales != sls_quantity*sls_price
		OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
		OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0

SELECT * FROM silver.crm_sales_details



--=====================================================================
--  Checking 'silver.erp_cust_az12
--=====================================================================

-- CHECK FOR INTEGRITY FOR cid TO crm_cust_info COLUMN cst_key
--EXPECTATION : NO ROWS
SELECT
cid,
bdate,
gen
FROM silver.erp_cust_az12
WHERE cid like '___AW%';

--  IDENTIFY OUT OF RANGE DATES  ***SOLVED PARTIALLY ONLY
--  Expectation: Birthdates between 1924-01-01 and Today
-- Didn't change for the old customer only removed future bdate
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1925-01-01' OR bdate > GETDATE()
  

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT DISTINCT gen,
	CASE WHEN UPPER(RTRIM(LTRIM(gen))) IN  ('F','FEMALE') THEN 'Female'
		 WHEN UPPER(RTRIM(LTRIM(gen))) IN  ('M', 'MALE') THEN 'Male'
	ELSE 'n/a'
	END AS gen
FROM silver.erp_cust_az12

--=====================================================================
--  Checking 'silver.erp_loc_a101
--=====================================================================

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT distinct
	 cntry
FROM silver.erp_loc_a101

SELECT * FROM silver.erp_loc_a101

--=====================================================================
--  Checking 'silver.erp_px_cat_g1v2
--=====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Result
SELECT 
	* 
FROM bronze.erp_px_cat_g1v2
WHERE cat != RTRIM(LTRIM(cat)) 
	  OR subcat != RTRIM(LTRIM(subcat)) 
	  OR maintenance != RTRIM(LTRIM(maintenance))

-- DATA STANDARDIZATION & CONSISTENCY

SELECT DISTINCT cat 
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat 
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance 
FROM bronze.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2
