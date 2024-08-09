-- Open Data

SELECT *
FROM dbo.Nashville

-- Standardize SaleDate
SELECT SaleDate
FROM dbo.Nashville
-- CONVERT TO DATE

SELECT *
FROM dbo.Nashville

-- CONVERT SaleDate Column To Date Only, RUN CODES ONE AT A TIME 
SELECT CONVERT(DATE, SaleDate) AS date_only
FROM dbo.Nashville

ALTER TABLE dbo.Nashville
Add date_only Date;

UPDATE dbo.Nashville
SET date_only = CAST(SaleDate AS DATE);

SELECT*
FROM dbo.Nashville

-- POPULATE PROPERTY ADDRESS DATA
SELECT *
FROM dbo.Nashville
--Where PropertyAddress is null
ORDER BY ParcelID

-- CHECK EMPTY PROPRETY ID THEN REPLACE WITH THE PROPERTY ADDRESS WITH PROPERTY ADDRESS FROM THE SAME DUPLICATE PARCEL ID 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.Nashville a
JOIN dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.Nashville a
JOIN dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT *
FROM dbo.Nashville
WHERE PropertyAddress is null

--Breaking address into adress and city

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From dbo.Nashville


ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Nashville
Add PropertyCity Nvarchar(255);

Update Nashville
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From dbo.Nashville

--CAN ALSO USE PARSENAME TO PERFORM THE OPERATION

-- SELECT  
--   PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2) AS NEW_Address,  
--   PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1) AS City  
--FROM dbo.Nashville;

--ALTER TABLE YourTable  
--ADD NEW_Address NVARCHAR(50),  
--   City NVARCHAR(50);  
  
--UPDATE dbo.Nashville 
--SET NEW_Address = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),  
--   City = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1);

Select OwnerAddress
From dbo.Nashville


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.Nashville

ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From dbo.Nashville

-- CHECK DISTINCT SOLDASVACANT COLUMN
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.Nashville
Group by SoldAsVacant
order by 2

--REPLACE ALL N AND Y WITH NO AND YES RESPECTIVELY 
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From dbo.Nashville

Update Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

	   --TO REMOVE DUPLICATES
	--FIRST DELETE   
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.Nashville
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--CHECK IF DELETED
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.Nashville
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From dbo.Nashville

-- Delete Unused Columns
Select *
From dbo.Nashville

ALTER TABLE dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
