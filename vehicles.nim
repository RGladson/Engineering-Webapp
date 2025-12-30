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
  dbTitleNumber = ""
  dbPlate = ""
  dbPolicyNumber = ""
  dbDriver = ""
  dbCardNumberLast4 = ""
  dbCleanedDateEng = 0
  dbCleanedDateNews = 0
  dbInUse = false
  dbInUseBy = ""
  dbMiles = 0
  dbPurchaseDate = 0
  dbOilDate = 0
  dbNextOilMiles = 0
  dbInspectionDate = 0
  dbRegistrationDate = 0
  dbNotes = ""
  dbInService = true 

# --- Table Setup ---
try:
  # Added new columns: CardNumberLast4, CleanedDateEng, CleanedDateNews, InUse, InUseBy
  db.exec(sql"""
      CREATE TABLE IF NOT EXISTS Vehicles (
        id INTEGER PRIMARY KEY,
        Unit VARCHAR(100) NOT NULL,
        Make VARCHAR(100),
        Model VARCHAR(100),
        Year INTEGER,
        VIN VARCHAR(100),
        TitleNumber VARCHAR(100),
        Plate VARCHAR(50),
        PolicyNumber VARCHAR(100),
        Driver VARCHAR(100),
        CardNumberLast4 VARCHAR(10),
        Miles INTEGER,
        PurchaseDate INTEGER,
        OilDate INTEGER,
        OilMiles INTEGER,
        InspectionDate INTEGER,
        RegistrationDate INTEGER,
        CleanedDateEng INTEGER,
        CleanedDateNews INTEGER,
        Notes VARCHAR(1000),
        InService BOOLEAN,
        InUse BOOLEAN,
        InUseBy VARCHAR(100)
      )
  """)
  echo "Database opened. Add Unit to Fleet? (y/n)"
  if readLine(stdin).normalize in ["y", "yes"]:
    edit_mode = true
except:
  echo "Database Error: " & getCurrentExceptionMsg()

# --- Helper Template for Inputs ---
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
  echo "\n--- New Vehicle Entry ---"
  
  echo "Enter Unit Number:"
  dbUnit = readLine(stdin)

  echo "Enter Primary Driver (or Dept):"
  dbDriver = readLine(stdin)
  
  echo "Enter Unit Make:"
  dbMake = readLine(stdin)
  
  echo "Enter Unit Model:"
  dbModel = readLine(stdin)
  getNumber("Enter Unit Year:", dbYear)
  
  echo "Enter Unit VIN:"
  dbVIN = readLine(stdin)

  # --- Paperwork Fields ---
  echo "Enter Title Number:"
  dbTitleNumber = readLine(stdin)

  echo "Enter License Plate:"
  dbPlate = readLine(stdin)

  echo "Enter Insurance Policy Number:"
  dbPolicyNumber = readLine(stdin)

  echo "Enter Gas Card Last 4:"
  dbCardNumberLast4 = readLine(stdin)
  # ----------------------------

  # --- Dates & Maintenance ---
  getNumber("Enter Unit Miles:", dbMiles)
  getNumber("Enter Purchase Date (YYYYMMDD):", dbPurchaseDate)
  getNumber("Enter Last Oil Change Date (YYYYMMDD):", dbOilDate)
  getNumber("Enter Last Inspection Date (YYYYMMDD):", dbInspectionDate)
  getNumber("Enter Registration Date (YYYYMMDD):", dbRegistrationDate)

  # --- Cleaning Logs ---
  getNumber("Enter Last Engineering Clean Date (YYYYMMDD):", dbCleanedDateEng)
  getNumber("Enter Last News Clean Date (YYYYMMDD):", dbCleanedDateNews)

  echo "Enter Notes:"
  dbNotes = readLine(stdin)

  # --- Status Checks ---
  echo "Is this unit currently In Service? (y/n):"
  let serviceInput = readLine(stdin).normalize
  dbInService = if serviceInput == "n" or serviceInput == "no": false else: true

  echo "Is this unit currently Checked Out / In Use? (y/n):"
  let useInput = readLine(stdin).normalize
  if useInput in ["y", "yes"]:
    dbInUse = true
    echo "Who is using it?"
    dbInUseBy = readLine(stdin)
  else:
    dbInUse = false
    dbInUseBy = ""

  # Review
  echo fmt"""
    ----------------------------
    REVIEW ENTRY:
    Unit: {dbUnit}
    Driver: {dbDriver}
    Make/Model: {dbMake} {dbModel} ({dbYear})
    VIN: {dbVIN}
    ----------------------------
    PAPERWORK:
    Title #: {dbTitleNumber} | Plate: {dbPlate}
    Policy:  {dbPolicyNumber}
    Gas Card Last 4: {dbCardNumberLast4}
    ----------------------------
    STATUS:
    Miles: {dbMiles} | Purchase: {dbPurchaseDate}
    Oil: {dbOilDate} | Insp: {dbInspectionDate} | Reg: {dbRegistrationDate}
    Last Clean (Eng):  {dbCleanedDateEng}
    Last Clean (News): {dbCleanedDateNews}
    
    In Service: {dbInService}
    Currently In Use: {dbInUse} (By: {dbInUseBy})
    
    Notes: {dbNotes}
    ----------------------------
    Save this unit? (y/n)
    """

  if readLine(stdin).normalize in ["y", "yes"]:
    # Updated INSERT statement with all new columns
    db.exec(sql"""
      INSERT INTO Vehicles (
        Unit, Make, Model, Year, VIN, TitleNumber, Plate, PolicyNumber, 
        Driver, CardNumberLast4, Miles, PurchaseDate, OilDate,  OilMiles, InspectionDate, 
        RegistrationDate, CleanedDateEng, CleanedDateNews, Notes, InService, InUse, InUseBy
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
      dbUnit, dbMake, dbModel, dbYear, dbVIN, dbTitleNumber, dbPlate, dbPolicyNumber, 
      dbDriver, dbCardNumberLast4, dbMiles, dbPurchaseDate, dbOilDate, dbNextOilMiles, dbInspectionDate, 
      dbRegistrationDate, dbCleanedDateEng, dbCleanedDateNews, dbNotes, int(dbInService), int(dbInUse), dbInUseBy)
    
    echo "Unit Added Successfully!"
  else:
    echo "Entry discarded."

  echo "Add another unit? (y/n)"
  if readLine(stdin).normalize notin ["y", "yes"]:
    edit_mode = false

db.close()