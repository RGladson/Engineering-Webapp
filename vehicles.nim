import std/[strutils, strformat]
import db_connector/db_sqlite

# Connect to the DB
let db = open("/home/wncnadmin/Engineering/src/nim/webapp/db/vehicles.db", "", "", "")
var edit_mode = false

var
  dbUnit = ""
  dbMake = ""
  dbModel = ""
  dbYear = 0
  dbVIN = ""
  dbMiles = 0
  dbPurchaseDate = 0
  dbOilDate = 0
  dbInspectionDate = 0
  dbRegistrationDate = 0
  dbNotes = ""
  dbInService = true # Default to true for new adds?

# --- Table Setup ---
try:
  # Renamed table to 'Vehicles'
  db.exec(sql"""
      CREATE TABLE IF NOT EXISTS Vehicles (
        id INTEGER PRIMARY KEY,
        Unit VARCHAR(100) NOT NULL,
        Make VARCHAR(100),
        Model VARCHAR(100),
        Year INTEGER,
        VIN VARCHAR(100),
        Miles INTEGER,
        PurchaseDate INTEGER,
        OilDate INTEGER,
        InspectionDate INTEGER,
        RegistrationDate INTEGER,
        Notes VARCHAR(1000),
        InService BOOLEAN
      )
  """)
  # Check if we want to enter data immediately
  echo "Database opened. Add Unit to Fleet? (y/n)"
  if readLine(stdin).normalize in ["y", "yes"]:
    edit_mode = true
except:
  echo "Database Error: " & getCurrentExceptionMsg()

# --- Helper Template for Inputs ---
# This prevents the whole form from resetting if you type a letter in a number field
template getNumber(prompt, varName: untyped) =
  while true:
    echo prompt
    try:
      varName = parseInt(readLine(stdin))
      break
    except ValueError:
      echo "Invalid input. Please enter a number."

# --- Main Loop ---
while edit_mode:
  echo "--- New Vehicle Entry ---"
  
  echo "Enter Unit Number:"
  dbUnit = readLine(stdin)
  
  echo "Enter Unit Make:"
  dbMake = readLine(stdin)
  
  echo "Enter Unit Model:"
  dbModel = readLine(stdin)

  # Using the template to safely get numbers without restarting the whole loop
  getNumber("Enter Unit Year:", dbYear)
  
  echo "Enter Unit VIN:"
  dbVIN = readLine(stdin)

  getNumber("Enter Unit Miles:", dbMiles)
  getNumber("Enter Purchase Date (YYYYMMDD):", dbPurchaseDate)
  getNumber("Enter Last Oil Change Date (YYYYMMDD):", dbOilDate)
  getNumber("Enter Last Inspection Date (YYYYMMDD):", dbInspectionDate)
  getNumber("Enter Registration Date (YYYYMMDD):", dbRegistrationDate)

  echo "Enter Notes:"
  dbNotes = readLine(stdin)

  echo "Is this unit currently In Service? (y/n):"
  let serviceInput = readLine(stdin).normalize
  dbInService = if serviceInput == "n" or serviceInput == "no": false else: true

  # Review
  echo fmt"""
    ----------------------------
    REVIEW ENTRY:
    Unit: {dbUnit}
    Make/Model: {dbMake} {dbModel} ({dbYear})
    VIN: {dbVIN}
    Miles: {dbMiles}
    Purchase: {dbPurchaseDate}
    Oil: {dbOilDate} | Insp: {dbInspectionDate} | Reg: {dbRegistrationDate}
    In Service: {dbInService}
    Notes: {dbNotes}
    ----------------------------
    Save this unit? (y/n)
    """

  if readLine(stdin).normalize in ["y", "yes"]:
    # Insert into 'Vehicles' table
    # We cast dbInService to int (1 or 0) for SQLite compatibility
    db.exec(sql"INSERT INTO Vehicles (Unit, Make, Model, Year, VIN, Miles, PurchaseDate, OilDate, InspectionDate, RegistrationDate, Notes, InService) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      dbUnit, dbMake, dbModel, dbYear, dbVIN, dbMiles, dbPurchaseDate, dbOilDate, dbInspectionDate, dbRegistrationDate, dbNotes, int(dbInService))
    
    echo "Unit Added Successfully!"
  else:
    echo "Entry discarded."

  echo "Add another unit? (y/n)"
  if readLine(stdin).normalize notin ["y", "yes"]:
    edit_mode = false

db.close()