--Cleaning Data in SQL Queries

Select *
from Portfolio_Project..[Nashville Housing]


-- Standardize Date format
Select SaleDateConverted, CONVERT(Date, SaleDate)
from Portfolio_Project..[Nashville Housing]

Update [Nashville Housing]
set SaleDate = CONVERT(Date, SaleDate)

Alter Table [Nashville Housing]
Add SaleDateConverted Date;

Update [Nashville Housing]
set SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address Data

Select *
from Portfolio_Project..[Nashville Housing]
where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..[Nashville Housing] a
join Portfolio_Project..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..[Nashville Housing] a
join Portfolio_Project..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into individual columns (Address, city, state)

Select PropertyAddress
from Portfolio_Project..[Nashville Housing]
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
from Portfolio_Project..[Nashville Housing]

Alter Table [Nashville Housing]
Add PropertySplitAddress nvarchar(255);

Update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table [Nashville Housing]
Add PropertySplitCity nvarchar(255);

Update [Nashville Housing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


select * 
from Portfolio_Project..[Nashville Housing]


--- Using Parsename to split a column
select OwnerAddress
from Portfolio_Project..[Nashville Housing]

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 
from Portfolio_Project..[Nashville Housing]


Alter Table [Nashville Housing]
Add OwnerSplitAddress nvarchar(255);

Update [Nashville Housing]
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table [Nashville Housing]
Add OwnerSplitCity nvarchar(255);

Update [Nashville Housing]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table [Nashville Housing]
Add OwnerSplitState nvarchar(255);

Update [Nashville Housing]
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

select *
from Portfolio_Project..[Nashville Housing]


-- Change Y and N to Yes and No in "Sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio_Project..[Nashville Housing] 
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
from Portfolio_Project..[Nashville Housing]


Update [Nashville Housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End


-- Removing Duplicates

With RowNumCTE As (
select *,
	ROW_NUMBER() Over(
		Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by
			UniqueID
			) row_num
from Portfolio_Project..[Nashville Housing]
)

Select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress




--Delete Unsued Columns

Select *
From Portfolio_Project..[Nashville Housing]


Alter Table Portfolio_Project..[Nashville Housing]
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio_Project..[Nashville Housing]
Drop Column SaleDate