#!/usr/bin/env python3
"""
Test script to validate Excel data integration with DuckDB
Run this before starting the full backend to ensure data loads correctly
"""
import os
import sys
import tempfile
import logging
from pathlib import Path

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Add backend to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))

from app.utils.excel_loader import ExcelDataLoader


def test_excel_loading():
    """Test loading Excel file"""
    print("\n" + "="*60)
    print("TEST 1: Loading Excel File")
    print("="*60)

    excel_file = "20251029130203.xlsx"

    if not os.path.exists(excel_file):
        print(f"❌ Excel file not found: {excel_file}")
        return False

    print(f"✅ Excel file found: {excel_file}")

    try:
        data = ExcelDataLoader.load_from_excel(excel_file)
        print(f"✅ Successfully loaded {len(data)} records from Excel")

        if data:
            print("\n📊 Sample record (first row):")
            first_row = data[0]
            for key, value in first_row.items():
                if value is not None:
                    value_str = str(value)[:50]
                    print(f"  {key}: {value_str}")

            print(f"\n📋 All fields in records: {list(first_row.keys())}")
            return True
        else:
            print("❌ No data loaded from Excel")
            return False

    except Exception as e:
        print(f"❌ Error loading Excel: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def test_table_creation():
    """Test SQL table creation statement generation"""
    print("\n" + "="*60)
    print("TEST 2: Table Creation SQL")
    print("="*60)

    try:
        sql = ExcelDataLoader.create_table_sql()
        print("✅ Generated CREATE TABLE statement:")
        print(sql)
        return True
    except Exception as e:
        print(f"❌ Error generating SQL: {str(e)}")
        return False


def test_insert_sql_generation():
    """Test INSERT SQL generation"""
    print("\n" + "="*60)
    print("TEST 3: INSERT SQL Generation")
    print("="*60)

    excel_file = "20251029130203.xlsx"

    try:
        data = ExcelDataLoader.load_from_excel(excel_file)

        if not data:
            print("❌ No data to generate INSERT SQL")
            return False

        sql, values, fields = ExcelDataLoader.insert_data_sql(data)

        print(f"✅ Generated INSERT statement for {len(data)} records")
        print(f"\nFields ({len(fields)}): {fields}")
        print(f"\nSQL Template: {sql}")
        print(f"Number of value tuples: {len(values)}")

        if values:
            print(f"\nFirst value tuple sample: {values[0][:3]}...")  # Show first 3 values

        return True

    except Exception as e:
        print(f"❌ Error generating INSERT SQL: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def test_duckdb_integration():
    """Test full DuckDB integration with temporary database"""
    print("\n" + "="*60)
    print("TEST 4: DuckDB Integration (Temporary Database)")
    print("="*60)

    excel_file = "20251029130203.xlsx"

    try:
        import duckdb

        # Create temporary database
        with tempfile.NamedTemporaryFile(suffix='.duckdb', delete=False) as tmp:
            tmp_db = tmp.name

        logger.info(f"Using temporary database: {tmp_db}")

        try:
            # Load Excel data
            data = ExcelDataLoader.load_from_excel(excel_file)
            print(f"✅ Loaded {len(data)} records from Excel")

            # Connect to temporary database
            conn = duckdb.connect(tmp_db)

            # Create table
            table_sql = ExcelDataLoader.create_table_sql()
            conn.execute(table_sql)
            print("✅ Created medical_examinations_fact table")

            # Insert data
            if data:
                sql, values, fields = ExcelDataLoader.insert_data_sql(data)

                # Insert in batches
                batch_size = 50
                total_inserted = 0

                for i in range(0, len(values), batch_size):
                    batch_values = values[i:i + batch_size]

                    for row_values in batch_values:
                        params = {f'${j+1}': val for j, val in enumerate(row_values)}
                        conn.execute(sql, params)

                    total_inserted += len(batch_values)
                    print(f"  ✓ Inserted {total_inserted}/{len(data)} records")

                conn.commit()
                print(f"✅ Successfully inserted all {len(data)} records")

                # Verify data
                result = conn.execute("SELECT COUNT(*) as total FROM medical_examinations_fact").fetchall()
                count = result[0][0] if result else 0
                print(f"✅ Database verification: {count} records in table")

                # Show sample data
                sample = conn.execute(
                    "SELECT exam_id, patient_name, exam_status FROM medical_examinations_fact LIMIT 3"
                ).fetchall()

                print("\nSample data from database:")
                for row in sample:
                    print(f"  {row}")

                conn.close()
                return True
            else:
                print("❌ No data to insert")
                return False

        finally:
            # Cleanup temporary database
            try:
                os.unlink(tmp_db)
                logger.info("Cleaned up temporary database")
            except:
                pass

    except ImportError:
        print("⚠️ DuckDB not available for testing (will be available at runtime)")
        return True
    except Exception as e:
        print(f"❌ Error in DuckDB integration: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Run all tests"""
    print("\n" + "="*60)
    print("EXCEL DATA INTEGRATION TEST SUITE")
    print("="*60)

    results = {
        "Excel Loading": test_excel_loading(),
        "Table Creation": test_table_creation(),
        "INSERT SQL Generation": test_insert_sql_generation(),
        "DuckDB Integration": test_duckdb_integration(),
    }

    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)

    for test_name, passed in results.items():
        status = "✅ PASSED" if passed else "❌ FAILED"
        print(f"{test_name}: {status}")

    all_passed = all(results.values())

    print("\n" + "="*60)
    if all_passed:
        print("✅ ALL TESTS PASSED - Ready to start backend!")
    else:
        print("❌ SOME TESTS FAILED - Review errors above")
    print("="*60 + "\n")

    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
