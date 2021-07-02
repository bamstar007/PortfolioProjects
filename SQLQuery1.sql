SELECT *
FROM NationalHousing;

SELECT SaleDate, CONVERT(date, saledate) AS Date
FROM portfolioProject..NationalHousing;

ALTER TABLE portfolioProject..NationalHousing
ADD SaledateConverted date;

UPDATE portfolioProject..NationalHousing
SET SaledateConverted = CONVERT (date, saledate);

--populate property address where the no adress exist
SELECT *
FROM NationalHousing
WHERE PropertyAddress IS NULL
ORDER BY [UniqueID ]

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
FROM NationalHousing a
JOIN NationalHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.propertyAddress, b.PropertyAddress)
FROM NationalHousing a
JOIN NationalHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Break the address into individual column
SELECT PropertyAddress
FROM NationalHousing;

SELECT 
SUBSTRING( propertyaddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING( propertyaddress, CHARINDEX(',', PropertyAddress) + 1, LEN(propertyaddress)) AS Address
FROM NationalHousing;

ALTER TABLE portfolioProject..NationalHousing
ADD propertySplitAdress nvarchar(255);

UPDATE portfolioProject..NationalHousing
SET propertySplitAdress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE portfolioProject..NationalHousing
ADD propertyAddressCity nvarchar(255);

UPDATE portfolioProject..NationalHousing
SET propertyAddressCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) + 1, LEN(propertyaddress));