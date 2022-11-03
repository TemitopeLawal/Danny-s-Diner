Use PortfolioProject
go

Select *
From NashvilleHousing;

--Standardize date format

Select SalesDateConverted, Convert(Date, SaleDate)
From NashvilleHousing;

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate);


ALTER TABLE NashvilleHousing
Add SalesDateConverted Date;

UPDATE NashvilleHousing
SET SalesDateConverted = Convert(Date, SaleDate);

--Populate Property Address Data

Select *
From NashvilleHousing
--WHERE PropertyAddress is null;
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousing a
Join NashvilleHousing b
on  a.ParcelID= b.ParcelID
And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null;


Update a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
on  a.ParcelID= b.ParcelID
And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null;

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

Select SoldAsVacant
From NashvilleHousing;




Select OwnerAddress
From NashvilleHousing;


Select 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing;

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress=PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity=PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState= PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1);


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant,
CASE When SoldAsVacant ='Y' THEN 'Yes'
	When SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
From NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant= CASE When SoldAsVacant ='Y' THEN 'Yes'
	When SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END 


--Remove Duplicates
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
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID;
)

Select *
FROM RowNumCTE
Where row_num>1


--Delete unused Columns

ALter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

Select *
From NashvilleHousing;