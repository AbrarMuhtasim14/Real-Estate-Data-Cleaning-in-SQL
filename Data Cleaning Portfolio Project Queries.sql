SELECT * FROM nv.mytable;

-- standardize date format
SELECT saleDateConverted, DATE(SaleDate)
FROM mytable;
UPDATE mytable
SET SaleDate = DATE(SaleDate);

UPDATE mytable
SET SaleDateConverted = STR_TO_DATE('24-Jan-13', '%d-%b-%y');




-- Populate Property Address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)    
FROM mytable a
join mytable b on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where  a.PropertyAddress is null;


update mytable a
join mytable b on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
set a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
where  a.PropertyAddress is null;

--------
Select PropertyAddress
From mytable;

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , CHAR_LENGTH(PropertyAddress)) as Address

From mytable;

 ALTER TABLE mytable
Add PropertySplitAddress varchar(255);

Update mytable
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) ;
ALTER TABLE mytable
Add PropertySplitcity varchar(255);
Update mytable
SET PropertySplitcity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , CHAR_LENGTH(PropertyAddress));

select * from mytable;

select SUBSTRING_INDEX(OwnerAddress, ',' , 1) as address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',' , 2),',',-1) as city,
SUBSTRING_INDEX(OwnerAddress, ',' , -1) as state 
From mytable;
---------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)

From mytable
Group by SoldAsVacant;

select SoldAsVacant,
  CASE WHEN SoldAsVacant = 'N' then 'NO' 
		WHEN SoldAsVacant  = 'Y' then 'YES' 
		ELSE SoldAsVacant 
		END
FROM mytable;


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From mytable;

Update mytable
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
       
       
-- Remove Duplicates
with Rownumcte as (
select *, row_number() OVER  ( partition by    ParcelID,  PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from mytable)

SELECT * From Rownumcte
Where row_num > 1
Order by PropertyAddress;


-- Delete Unused Columns



Select *
From mytable;


ALTER TABLE mytable
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;



