/*

Data Cleaning in SQL

*/

Select *
From PortfolioProject..NashvilleHousing

-- Standardising Date format

Select SaleDateConverted
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted=CONVERT(date,SaleDate)


--Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
Order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID=b.ParcelID
  AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null



Update a
Set PropertyAddress=ISNULL (a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID=b.ParcelID
  AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--Seperating address column into multiple columns(Address,City,State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))


--Splitting owner address using Pars(Name)
Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..NashvilleHousing

--Changing Y and N to Yes and No in 'Sold as Vacant' column

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant='Y' Then 'Yes'
     When SoldAsVacant='N' Then 'No'
     Else SoldAsVacant
     End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant=Case When SoldAsVacant='Y' Then 'Yes'
     When SoldAsVacant='N' Then 'No'
     Else SoldAsVacant
     End

--Remove duplicates

With RowNumCTE AS (
Select *,
     ROW_NUMBER() OVER (
     Partition by ParcelID,
                  PropertyAddress,
				  SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				     UniqueID
					 ) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
Where row_num>1
--Order by PropertyAddress

Select *
From PortfolioProject..NashvilleHousing

--Delete unused columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,SaleDate