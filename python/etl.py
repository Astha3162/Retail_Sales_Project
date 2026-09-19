import pandas as pd
import json
from pathlib import Path


# ============================================================
# 1. PROJECT PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_DIR = BASE_DIR / "data"
CLEANED_DIR = DATA_DIR / "cleaned"

CLEANED_DIR.mkdir(exist_ok=True)


# ============================================================
# 2. SOURCE FILES
# ============================================================

sales_file = DATA_DIR / "sales 1.csv"
customers_file = DATA_DIR / "customers.json"
products_file = DATA_DIR / "products.csv"


# ============================================================
# 3. EXTRACT - READ SOURCE DATA
# ============================================================

print("=" * 60)
print("STEP 1: EXTRACTING SOURCE DATA")
print("=" * 60)

# Sales
sales = pd.read_csv(sales_file)

# Customers
with open(customers_file, "r", encoding="utf-8") as file:
    customers = pd.DataFrame(json.load(file))

# Products
products = pd.read_csv(products_file)


print(f"Sales records: {len(sales)}")
print(f"Customer records: {len(customers)}")
print(f"Product records: {len(products)}")


# ============================================================
# 4. TRANSFORM SALES DATA
# ============================================================

print("\n" + "=" * 60)
print("STEP 2: CLEANING SALES DATA")
print("=" * 60)

# Remove duplicate SaleIDs
sales = sales.drop_duplicates(subset=["SaleID"])

# Convert important columns to numeric
sales["ProductID"] = pd.to_numeric(
    sales["ProductID"], errors="coerce"
)

sales["SalesAmount"] = pd.to_numeric(
    sales["SalesAmount"], errors="coerce"
)

sales["Quantity"] = pd.to_numeric(
    sales["Quantity"], errors="coerce"
)

# Convert Timestamp to datetime
sales["Timestamp"] = pd.to_datetime(
    sales["Timestamp"], errors="coerce"
)

# Remove records with missing critical values
sales = sales.dropna(
    subset=[
        "SaleID",
        "ProductID",
        "CustomerID",
        "SalesAmount",
        "Quantity",
        "Timestamp"
    ]
)

# Keep only valid business values
sales = sales[
    (sales["SalesAmount"] >= 0) &
    (sales["Quantity"] > 0)
]

# Convert IDs and quantity to appropriate types
sales["ProductID"] = sales["ProductID"].astype(int)
sales["Quantity"] = sales["Quantity"].astype(int)


print(f"Clean sales records: {len(sales)}")


# ============================================================
# 5. TRANSFORM CUSTOMER DATA
# ============================================================

print("\n" + "=" * 60)
print("STEP 3: CLEANING CUSTOMER DATA")
print("=" * 60)


# Keep only fields needed for analytics
customers = customers[
    [
        "CustomerID",
        "FirstName",
        "LastName",
        "Gender",
        "Region"
    ]
].copy()


# ------------------------------------------------------------
# Clean names
# ------------------------------------------------------------

customers["FirstName"] = (
    customers["FirstName"]
    .fillna("Unknown")
    .astype(str)
    .str.strip()
)

customers["LastName"] = (
    customers["LastName"]
    .fillna("Unknown")
    .astype(str)
    .str.strip()
)


# ------------------------------------------------------------
# Clean Gender
# ------------------------------------------------------------

customers["Gender"] = (
    customers["Gender"]
    .fillna("Unknown")
    .astype(str)
    .str.strip()
    .str.lower()
)

gender_mapping = {
    "m": "Male",
    "male": "Male",
    "f": "Female",
    "female": "Female"
}

customers["Gender"] = customers["Gender"].replace(gender_mapping)

customers.loc[
    ~customers["Gender"].isin(["Male", "Female"]),
    "Gender"
] = "Unknown"


# ------------------------------------------------------------
# Clean Region
# ------------------------------------------------------------

customers["Region"] = (
    customers["Region"]
    .fillna("Unknown")
    .astype(str)
    .str.strip()
    .str.lower()
)

region_mapping = {
    "ohio": "Ohio",
    "ohho": "Ohio",

    "new york": "New York",
    "new yorkk": "New York",
    "ny": "New York",
    "nw york": "New York",

    "california": "California",
    "californiya": "California",

    "texas": "Texas",
    "texaz": "Texas"
}

customers["Region"] = customers["Region"].replace(region_mapping)

# Convert any remaining unknown values
customers.loc[
    customers["Region"].isin(["nan", "none", ""]),
    "Region"
] = "Unknown"


# Remove duplicate customers
customers = customers.drop_duplicates(
    subset=["CustomerID"]
)


print(f"Clean customer records: {len(customers)}")


# ============================================================
# 6. TRANSFORM PRODUCT DATA
# ============================================================

print("\n" + "=" * 60)
print("STEP 4: CLEANING PRODUCT DATA")
print("=" * 60)


products["ProductID"] = pd.to_numeric(
    products["ProductID"],
    errors="coerce"
)

products["ProductName"] = (
    products["ProductName"]
    .fillna("Unknown Product")
    .astype(str)
    .str.strip()
)

products["Category"] = (
    products["Category"]
    .fillna("Unknown")
    .astype(str)
    .str.strip()
)

# Remove invalid product IDs
products = products.dropna(
    subset=["ProductID"]
)

products["ProductID"] = products["ProductID"].astype(int)

# Remove duplicate products
products = products.drop_duplicates(
    subset=["ProductID"]
)


print(f"Clean product records: {len(products)}")


# ============================================================
# 7. DATA QUALITY / REFERENTIAL INTEGRITY CHECK
# ============================================================

print("\n" + "=" * 60)
print("STEP 5: DATA QUALITY CHECKS")
print("=" * 60)


valid_products = set(products["ProductID"])
valid_customers = set(customers["CustomerID"])


invalid_products = sales[
    ~sales["ProductID"].isin(valid_products)
]

invalid_customers = sales[
    ~sales["CustomerID"].isin(valid_customers)
]


print(
    f"Sales with invalid ProductID: "
    f"{len(invalid_products)}"
)

print(
    f"Sales with invalid CustomerID: "
    f"{len(invalid_customers)}"
)


# Remove records that don't have matching dimensions
sales = sales[
    sales["ProductID"].isin(valid_products) &
    sales["CustomerID"].isin(valid_customers)
].copy()


# ============================================================
# 8. CREATE DIMENSION DATE
# ============================================================

print("\n" + "=" * 60)
print("STEP 6: CREATING DATE DIMENSION")
print("=" * 60)


dates = pd.DataFrame({
    "Date": sales["Timestamp"].dt.date
}).drop_duplicates()

dates["Date"] = pd.to_datetime(dates["Date"])

dates = dates.sort_values("Date").reset_index(drop=True)

dates["DateKey"] = (
    dates["Date"].dt.year * 10000 +
    dates["Date"].dt.month * 100 +
    dates["Date"].dt.day
)

dates["Year"] = dates["Date"].dt.year

dates["Quarter"] = (
    "Q" + dates["Date"].dt.quarter.astype(str)
)

dates["Month"] = dates["Date"].dt.month

dates["MonthName"] = dates["Date"].dt.month_name()

dates["Day"] = dates["Date"].dt.day


dim_date = dates[
    [
        "DateKey",
        "Date",
        "Year",
        "Quarter",
        "Month",
        "MonthName",
        "Day"
    ]
]


print(f"Date dimension records: {len(dim_date)}")


# ============================================================
# 9. CREATE CUSTOMER SURROGATE KEY
# ============================================================

customers = customers.reset_index(drop=True)

customers["CustomerKey"] = (
    customers.index + 1
)

dim_customer = customers[
    [
        "CustomerKey",
        "CustomerID",
        "FirstName",
        "LastName",
        "Gender",
        "Region"
    ]
]


# ============================================================
# 10. CREATE PRODUCT SURROGATE KEY
# ============================================================

products = products.reset_index(drop=True)

products["ProductKey"] = (
    products.index + 1
)

dim_product = products[
    [
        "ProductKey",
        "ProductID",
        "ProductName",
        "Category"
    ]
]


# ============================================================
# 11. CREATE FACT SALES TABLE
# ============================================================

print("\n" + "=" * 60)
print("STEP 7: CREATING FACT SALES TABLE")
print("=" * 60)


fact_sales = sales.copy()


# Map ProductID → ProductKey
product_key_map = dim_product.set_index(
    "ProductID"
)["ProductKey"]

fact_sales["ProductKey"] = (
    fact_sales["ProductID"]
    .map(product_key_map)
)


# Map CustomerID → CustomerKey
customer_key_map = dim_customer.set_index(
    "CustomerID"
)["CustomerKey"]

fact_sales["CustomerKey"] = (
    fact_sales["CustomerID"]
    .map(customer_key_map)
)


# Map date → DateKey
date_key_map = dim_date.set_index(
    "Date"
)["DateKey"]

fact_sales["Date"] = pd.to_datetime(
    fact_sales["Timestamp"].dt.date
)

fact_sales["DateKey"] = (
    fact_sales["Date"]
    .map(date_key_map)
)


# Keep only warehouse columns
fact_sales = fact_sales[
    [
        "SaleID",
        "ProductKey",
        "CustomerKey",
        "DateKey",
        "SalesAmount",
        "Quantity",
        "Timestamp"
    ]
]


# Remove records where dimension mapping failed
fact_sales = fact_sales.dropna(
    subset=[
        "ProductKey",
        "CustomerKey",
        "DateKey"
    ]
)


fact_sales["ProductKey"] = (
    fact_sales["ProductKey"].astype(int)
)

fact_sales["CustomerKey"] = (
    fact_sales["CustomerKey"].astype(int)
)

fact_sales["DateKey"] = (
    fact_sales["DateKey"].astype(int)
)


print(f"Fact sales records: {len(fact_sales)}")


# ============================================================
# 12. SAVE CLEANED DATA
# ============================================================

print("\n" + "=" * 60)
print("STEP 8: SAVING CLEANED DATA")
print("=" * 60)


fact_sales.to_csv(
    CLEANED_DIR / "fact_sales.csv",
    index=False
)

dim_customer.to_csv(
    CLEANED_DIR / "dim_customer.csv",
    index=False
)

dim_product.to_csv(
    CLEANED_DIR / "dim_product.csv",
    index=False
)

dim_date.to_csv(
    CLEANED_DIR / "dim_date.csv",
    index=False
)


# ============================================================
# 13. FINAL SUMMARY
# ============================================================

print("\n" + "=" * 60)
print("ETL PROCESS COMPLETED SUCCESSFULLY")
print("=" * 60)

print("\nFiles created:")

print("1. fact_sales.csv")
print("2. dim_customer.csv")
print("3. dim_product.csv")
print("4. dim_date.csv")

print("\nLocation:")
print(CLEANED_DIR)

print("\nFinal record counts:")
print(f"Fact Sales   : {len(fact_sales)}")
print(f"Customers    : {len(dim_customer)}")
print(f"Products     : {len(dim_product)}")
print(f"Date records : {len(dim_date)}")

print("\n" + "=" * 60)
print("NEXT STEP: LOAD DATA INTO MYSQL")
print("=" * 60)