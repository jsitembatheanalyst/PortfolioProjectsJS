-- CLEANING DATA IN SQL QUERIES

SELECT *
FROM Portfolio_Project..Nashville_Housing

-- Standardize  Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio_Project..Nashville_Housing

Update Nashville_Housing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date

 Update Nashville_Housing
SET SaleDateConverted=CONVERT(Date,SaleDate)


-- POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM Portfolio_Project..Nashville_Housing
WHERE PropertyAddress is NULL

SELECT *
FROM Portfolio_Project..Nashville_Housing
--WHERE PropertyAddress is NULL
-- PA notes. Property address never changes even when owners change. we need a reference point to fix the address
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..Nashville_Housing a
JOIN Portfolio_Project..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[uniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
-- can be replaced with ('NO ADDRESS')
FROM Portfolio_Project..Nashville_Housing a
JOIN Portfolio_Project..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[uniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


--Breaking out Address into individual columns (Adress, City, State)

SELECT PropertyAddress
FROM Portfolio_Project..Nashville_Housing

--use substring and character index

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address

-- searches for a specific value: -1 to remove the comma

FROM Portfolio_Project.dbo.Nashville_Housing

ALTER TABLE Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE Nashville_Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

SELECT *
FROM Portfolio_Project..Nashville_Housing


-- Separate owner address

SELECT OwnerAddress
FROM Portfolio_Project..Nashville_Housing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project..Nashville_Housing

ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Portfolio_Project..Nashville_Housing


--Change Y and N to Yes and No in 'Sold as Vacant Field'

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM Portfolio_Project..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Portfolio_Project..Nashville_Housing

Update Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove duplicates 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) RowNUm

FROM Portfolio_Project..Nashville_Housing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE RowNum > 1
--ORDER BY PropertyAddress

SELECT *
FROM Portfolio_Project..Nashville_Housing


-- Delete Unused Columns

SELECT *
FROM Portfolio_Project..Nashville_Housing

ALTER TABLE Portfolio_Project..Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE Portfolio_Project..Nashville_Housing
DROP COLUMN SaleDate
