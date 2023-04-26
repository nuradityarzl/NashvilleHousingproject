-- Cleaning data

select *
from nashvillehousing

---------------------------------------------------------------------
-- standarize data format

select saledateconverted, try_cast(SaleDate as date)
from nashvillehousing

update nashvillehousing
set saledate = try_cast(SaleDate as date)

alter table nashvillehousing
add saledateconverted date;

update nashvillehousing
set saledateconverted = try_cast(SaleDate as date)


---------------------------------------------------------------------
-- populate property address data

select *
from nashvillehousing


--where propertyaddress is null
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from nashvillehousing a 
join nashvillehousing B
    on a.parcelid = b.parcelid
    and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from nashvillehousing a 
join nashvillehousing B
    on a.parcelid = b.parcelid
    and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


---------------------------------------------------------------------
-- breaking out address into individual columns (address, city, state)

select propertyaddress
from nashvillehousing

SELECT 
CASE 
    WHEN CHARINDEX(',', propertyaddress) > 0 
    THEN SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) 
    else ''
    END as address,
CASE 
    WHEN CHARINDEX(',', propertyaddress) > 0 
    THEN SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)-CHARINDEX(',', propertyaddress)) 
    ELSE ''
    END as address2
from nashvillehousing

alter table nashvillehousing
add propertysplitadress nvarchar(255);

update nashvillehousing
set propertysplitadress = 
    CASE 
        WHEN CHARINDEX(',', propertyaddress) > 0 
        THEN SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) 
        else ''
        END;

alter table nashvillehousing
add propertysplitcity nvarchar(255);

update nashvillehousing
set propertysplitcity = 
    CASE 
        WHEN CHARINDEX(',', propertyaddress) > 0 
        THEN SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)-CHARINDEX(',', propertyaddress)) 
        ELSE ''
        END

select *
from nashvillehousing

select 
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
from nashvillehousing

alter table nashvillehousing
add ownersplitaddress nvarchar(255);

update nashvillehousing
set ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

alter table nashvillehousing
add ownersplitcity nvarchar(255);

update nashvillehousing
set ownersplitcity = PARSENAME(REPLACE(owneraddress,',','.'),2)

alter table nashvillehousing
add ownersplitstate nvarchar(255);

update nashvillehousing
set ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'),1)


---------------------------------------------------------------------
-- change y and n into yes and no
SELECT distinct(SoldAsVacant), count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant , 
CASE
when SoldAsVacant = 'y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end
from nashvillehousing

update nashvillehousing
set SoldAsVacant = 
CASE
when SoldAsVacant = 'y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end
from nashvillehousing


---------------------------------------------------------------------
-- remove duplicate

with rownumcte as(
SELECT *,
row_number() over(
    partition by parcelid,
                 propertyaddress,
                 saleprice,
                 saledate,
                 LegalReference
                 order BY   
                   UNIQUEID 
                    ) row_num

from nashvillehousing
)

select *
from rownumcte
where row_num > 1

---------------------------------------------------------------------
-- delete unused columns

select *
from nashvillehousing

alter table nashvillehousing
drop column owneraddress, taxdistrict  

alter table nashvillehousing
drop column saledate 