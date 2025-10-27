sp_configure 'show advanced options', 1;
RECONFIGURE;
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;

SELECT *
INTO NewTableName
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\WIZ\Downloads\NashvilleHousingData.xlsx;HDR=YES',
    'SELECT * FROM [Sheet1$]');



--Standardize date format
Select * FROM PorfolioProject..NashvilleHousing
Alter Table PorfolioProject..NashvilleHousing
DROP column SaleDateConverted 
Select SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
FROM PorfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate=Convert(Date,SaleDate)

Alter Table NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted=CONVERT(Date, SaleDate)

Select * from porfolioproject..NashvilleHousing


--Populate Property Address
SELECT PropertyAddress, ParcelID
FROM PorfolioProject..NashvilleHousing
WHERE PropertyAddress is null
Order by ParcelID

Select * FROM PorfolioProject..NashvilleHousing a
JOIN PorfolioProject..NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]--Self Join

Update a
Set PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From PorfolioProject..NashvilleHousing a
JOIN PorfolioProject..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Separate String to substrings
SELECT PropertyAddress FROM PorfolioProject..NashvilleHousing 

SELECT OwnerAddress, 
	ParseName(REPLACE(OwnerAddress,',','.'),3),
	ParseName(REPLACE(OwnerAddress,',','.'),2),
	ParseName(Replace(OwnerAddress,',','.'),1)
From PorfolioProject..NashvilleHousing

Select * FROM PorfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSPlitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSPlitAddress= ParseName(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSPlitstate Nvarchar(255);
Update NashvilleHousing
Set OwnerSPlitstate= ParseName(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add wnerSPlitCity Nvarchar(255);
Update NashvilleHousing
Set OwnerSPlitCity= ParseName(REPLACE(OwnerAddress,',','.'),1)

Select *
FROM PorfolioProject..NashvilleHousing


--Delete duplicates
WITH RowNumCTE AS (
Select *,
		ROW_NUMBER() OVER(
		PaRtition By ParcelID,
		PropertyAddress,
		SaLePrice,
		SaleDate,
		LegalReference
		Order by UniqueID
        ) AS row_num
From PorfolioProject..NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 2


--REMOVE Unused Columns
Select * FROM PorfolioProject..NashvilleHousing


Alter Table PorfolioProject..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PorfolioProject..NashvilleHousing
DROP Column SaleDate

-- CHANGE Y and N to Yes and No in Sold as Vacant

Select Distinct(SoldasVacant), count(SoldasVacant)
From PorfolioProject..NashvilleHousing
Group by SoldasVacant
Order by 2
Select SoldAsVacant,
Case When SoldAsVacant='Y' Then 'Yes'
	 WHEN SoldasVacant='No' Then 'No'
	 ELSE SoldAsVacant
	 END
From PorfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant= Case When SoldAsVacant='Y' Then 'Yes'
						When SoldAsVacant='N' Then 'No'
						ELSE SoldAsVacant
						END