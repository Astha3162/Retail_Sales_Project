import pandas as pd
from pathlib import Path

# Location of cleaned files
CLEANED_PATH = Path("../data/cleaned")


def test_fact_sales_exists():
    file = CLEANED_PATH / "fact_sales.csv"
    assert file.exists(), "fact_sales.csv was not created"


def test_customer_dimension_exists():
    file = CLEANED_PATH / "dim_customer.csv"
    assert file.exists(), "dim_customer.csv was not created"


def test_product_dimension_exists():
    file = CLEANED_PATH / "dim_product.csv"
    assert file.exists(), "dim_product.csv was not created"


def test_date_dimension_exists():
    file = CLEANED_PATH / "dim_date.csv"
    assert file.exists(), "dim_date.csv was not created"


def test_fact_sales_has_records():
    df = pd.read_csv(CLEANED_PATH / "fact_sales.csv")
    assert len(df) > 0, "Fact sales table is empty"


def test_customer_ids_are_unique():
    df = pd.read_csv(CLEANED_PATH / "dim_customer.csv")
    assert df["CustomerID"].is_unique, "Duplicate CustomerID found"


def test_product_ids_are_unique():
    df = pd.read_csv(CLEANED_PATH / "dim_product.csv")
    assert df["ProductID"].is_unique, "Duplicate ProductID found"


def test_sales_amount_is_valid():
    df = pd.read_csv(CLEANED_PATH / "fact_sales.csv")
    assert (df["SalesAmount"] >= 0).all(), \
        "Negative SalesAmount found"


def test_quantity_is_valid():
    df = pd.read_csv(CLEANED_PATH / "fact_sales.csv")
    assert (df["Quantity"] > 0).all(), \
        "Invalid Quantity found"


def test_fact_sales_count():
    df = pd.read_csv(CLEANED_PATH / "fact_sales.csv")
    assert len(df) == 9397, \
        f"Expected 9397 records, found {len(df)}"


if __name__ == "__main__":
    print("Running ETL validation tests...\n")

    tests = [
        test_fact_sales_exists,
        test_customer_dimension_exists,
        test_product_dimension_exists,
        test_date_dimension_exists,
        test_fact_sales_has_records,
        test_customer_ids_are_unique,
        test_product_ids_are_unique,
        test_sales_amount_is_valid,
        test_quantity_is_valid,
        test_fact_sales_count
    ]

    passed = 0

    for test in tests:
        try:
            test()
            print(f"PASS: {test.__name__}")
            passed += 1
        except AssertionError as e:
            print(f"FAIL: {test.__name__} - {e}")

    print(f"\n{passed}/{len(tests)} tests passed.")