SELECT *
FROM nashville_housing

------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CAST(SaleDate AS date) AS new_date_cast, CONVERT(date, Saledate) AS new_date_convert
FROM nashville_housing

UPDATE nashville_housing
SET SaleDate = CAST(SaleDate AS date) -- Did not update ? 

ALTER TABLE nashville_housing
Add SaleDate1 DATE; -- Add column

UPDATE nashville_housing
SET SaleDate1 = CAST(SaleDate AS date) 

SELECT SaleDate, SaleDate1
FROM nashville_housing -- now it works

------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM nashville_housing AS a
JOIN nashville_housing AS b
     ON a.ParcelID = b.ParcelID
	 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL; -- SELF JOIN in order to take address from parcelID thats not missing, and fill in to missing addresses with the same parcelID

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM nashville_housing AS a
JOIN nashville_housing AS b
     ON a.ParcelID = b.ParcelID
	 AND a.UniqueID <> b.UniqueID

------------------------------------------------------------------------------------

--Seperating Address Into Different Columns (Address, City, State)

SELECT *
FROM nashville_housing;

SELECT PropertyAddress, 
       SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD Address NVARCHAR(255)

UPDATE nashville_housing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE nashville_housing
ADD City NVARCHAR(255)

UPDATE nashville_housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT OwnerAddress,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS owner_address,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS owner_city,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS owner_state
FROM nashville_housing

ALTER TABLE nashville_housing
ADD owner_address NVARCHAR(255)

ALTER TABLE nashville_housing
ADD owner_city NVARCHAR(255)

ALTER TABLE nashville_housing
ADD owner_state NVARCHAR(255)

UPDATE nashville_housing
SET owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE nashville_housing
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE nashville_housing
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

UPDATE nashville_housing
SET SaleDate = SaleDate1

------------------------------------------------------------------------------------

-- Change 'Y' to 'Yes' and 'N' to 'No'

SELECT CASE WHEN SoldAsVacant = 'N' THEN 'No'
            WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
			END 
FROM nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
            WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
			END 

------------------------------------------------------------------------------------

-- Remove Duplicates
WITH row_num_cte AS (
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
FROM nashville_housing
)

SELECT *
FROM row_num_cte
WHERE row_num > 1

------------------------------------------------------------------------------------

-- Delete Unwanted Columns

SELECT *
FROM nashville_housing

ALTER TABLE nashville_housing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict