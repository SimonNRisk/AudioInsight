import openpyxl
import os

def create_excel_file(folder_path):
    # Create a new workbook
    wb = openpyxl.Workbook()
    # Save the workbook to the specified folder path
    file_path = os.path.join(folder_path, 'blank_excel.xlsx')
    wb.save(file_path)
    print(f"Blank Excel file created: {file_path}")

if __name__ == "__main__":
    # Example usage if run directly
    create_excel_file("/Users/simonrisk/Documents/AudioInsight1/AudioInsight1/files")
