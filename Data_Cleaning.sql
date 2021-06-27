--DATA CLEANING PROJECT


-- Converting and Updating Data types
Select SaleDate, Convert(Date,Saledate)
From Housing..Housing

Update Housing..Housing
SET SaleDate= Convert(Date,Saledate)

Select SaleDate2
From Housing..Housing

Alter Table Housing..Housing
Add SaleDate2 Date

Update Housing..Housing
SET SaleDate2=Saledate

-- Populating NUll Values

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
From Housing..Housing a
Join Housing..Housing b
	 on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housing..Housing a
Join Housing..Housing b
	 on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]

--Splitting Address and City

Select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From Housing..Housing

Alter Table Housing
add Property_Address nvarchar(250)

Update Housing
Set Property_Address= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
From Housing..Housing

Alter Table Housing
add Property_City nvarchar(250)

Update Housing
Set Property_City= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From Housing..Housing

Select *
From Housing..Housing

-- Alternative way of Splitting Strings

Select PARSENAME(Replace(OwnerAddress,',','.'),3),
	   PARSENAME(Replace(OwnerAddress,',','.'),2),
	   PARSENAME(Replace(OwnerAddress,',','.'),1)
From Housing..Housing

Alter Table Housing
Add Owner_Address nvarchar(250)

Update Housing
Set Owner_Address= PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table Housing
Add Owner_City nvarchar(250)

Update Housing
Set Owner_City= PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table Housing
Add Owner_State nvarchar(250)

Update Housing
Set Owner_State= PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From Housing

-- Change data by CASE
Select SoldasVacant, 
	   Case When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
			END
From Housing..Housing
Where SoldAsVacant Like 'N'
or   SoldAsVacant Like 'Y'

Update Housing
Set SoldAsVacant =  Case When SoldAsVacant = 'Y' Then 'Yes'
			When SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
			END
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From Housing
Group by SoldAsVacant

-- Removing Duplicates

With RownumCTE as(
Select *, ROW_NUMBER() Over(Partition by ParcelID,LandUse,PropertyAddress,SaleDate,OwnerName Order by UniqueID) as Rownum
From Housing
)
Select *
From RownumCTE
where Rownum >1

-- Removing Unused Columns, Preferably on views

Alter Table Housing
drop column Tax_District,PropertyAddress

Select *
From Housing

