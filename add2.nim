import std/[os, strutils, strformat]
import db_connector/db_sqlite

# const DbPath = "/home/wncnadmin/Engineering/src/nim/webapp/db/vehicles.db"

type SeedRow = object
  unit: string
  plate: string
  policy: string
  titleNum: string
  vin: string
  yearMakeModel: string
  asset: string
  driver: string

proc cleanStars(s: string): string =
  result = s.replace("*", "").strip()

proc splitYearMakeModel(s: string): tuple[year: int, make: string, model: string] =
  let t = s.strip()
  let parts = t.split('-')
  if parts.len >= 3:
    try:
      result.year = parseInt(parts[0])
    except ValueError:
      result.year = 0
    result.make = parts[1].strip()
    result.model = parts[2 .. ^1].join("-").strip()
  else:
    result = (0, "", t)

proc main() =
  # Delete DB so we start clean
  if fileExists(DbPath):
    removeFile(DbPath)

  let db = open(DbPath, "", "", "")
  defer: db.close()

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

  let insertSql = sql"""
    INSERT INTO Vehicles (
      Unit, Make, Model, Year, VIN, TitleNumber, Plate, PolicyNumber,
      Driver, CardNumberLast4, Miles, PurchaseDate, OilDate, OilMiles, InspectionDate,
      RegistrationDate, CleanedDateEng, CleanedDateNews, Notes, InService, InUse, InUseBy
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  """

  let rows: seq[SeedRow] = @[
    SeedRow(unit:"12", plate:"CMM-1832", policy:"", titleNum:"**772453142933595**", vin:"1FMCU9GX2FUA46547", yearMakeModel:"2015-FORD-SUV", asset:"VEH000014631", driver:"N/A"),
    SeedRow(unit:"13", plate:"RJZ-8725", policy:"", titleNum:"", vin:"1J8FF28W07D392499", yearMakeModel:"2007-JEEP-SUV", asset:"VEH000014634", driver:"NOT ASSIGNED"),
    SeedRow(unit:"14", plate:"FKR9266", policy:"TCZJCAP152D663A", titleNum:"**771226183554107**", vin:"5N1AT2MV1JC838448", yearMakeModel:"2018-NISSAN-SUV", asset:"VEH000016669", driver:"Walter Dozier"),
    SeedRow(unit:"15", plate:"CMM-1833", policy:"", titleNum:"", vin:"1FMCU9GX0FUA46546", yearMakeModel:"2015-FORD-SUV", asset:"VEH000014630", driver:"NOT ASSIGNED"),
    SeedRow(unit:"16", plate:"PFF-2768", policy:"", titleNum:"", vin:"5J6RM4H47GL085965", yearMakeModel:"2016-HONDA-SUV", asset:"", driver:"Brandon Roberts"),
    SeedRow(unit:"19", plate:"PFF-2725", policy:"", titleNum:"", vin:"5J6RM4H41GL097173", yearMakeModel:"2016-HONDA-SUV", asset:"", driver:"Ethan Duvall"),
    SeedRow(unit:"20", plate:"LKX-6732", policy:"", titleNum:"**779699252673006**", vin:"KL77LHEP5SC269281", yearMakeModel:"2025-CHEVROLET-SUV", asset:"", driver:"Marketing"),
    SeedRow(unit:"21", plate:"ELL-4333", policy:"", titleNum:"", vin:"5J6RM4H40GL112830", yearMakeModel:"2016-HONDA-SUV", asset:"", driver:"Gibby"),
    SeedRow(unit:"22", plate:"FKR9268", policy:"TC2JCAP152D663A", titleNum:"**77128183552107**", vin:"KNMAT2MV6JP551863", yearMakeModel:"2018-NISSAN-SUV", asset:"VEH000016674", driver:"Justin Moore"),
    SeedRow(unit:"24", plate:"KBE-6533", policy:"", titleNum:"", vin:"1FMCU0G60MUB09824", yearMakeModel:"2020-FORD-SUV", asset:"", driver:"Dorez Wynn"),
    SeedRow(unit:"25", plate:"FKR9269", policy:"152D663ACAP", titleNum:"**771231183557107**", vin:"5N1AT2MV2JC775280", yearMakeModel:"2018-NISSAN-SUV", asset:"VEH000016671", driver:"Ben Bokum"),
    SeedRow(unit:"26", plate:"FKR9265", policy:"TC2JCAP152D663A", titleNum:"**771224183556107**", vin:"5N1AT2MV3JC775319", yearMakeModel:"2018-NISSAN-SUV", asset:"VEH000016670", driver:"Dan West"),
    SeedRow(unit:"29", plate:"FKS-1120", policy:"", titleNum:"", vin:"5N1AT2MV6JC775170", yearMakeModel:"2018-NISSAN-SUV", asset:"VEH000016673", driver:"NOT ASSIGNED"),
    SeedRow(unit:"30", plate:"FKR-9271", policy:"TC2JCAP152D663A", titleNum:"**771233183555107**", vin:"5N1AT2MV9JC774580", yearMakeModel:"2018-NISSAN-SUV", asset:"VEH000016672", driver:"Al Currie"),
    SeedRow(unit:"40", plate:"HKE-3852", policy:"", titleNum:"", vin:"3GNAXSEV2LS694419", yearMakeModel:"2020-CHEVROLET-SUV", asset:"VEH000019483", driver:"Dave Hattman"),
    SeedRow(unit:"42", plate:"CMM-1831", policy:"", titleNum:"", vin:"1FMCU9GX9FUA46545", yearMakeModel:"2015-FORD-SUV", asset:"VEH000014629", driver:"NOT ASSIGNED"),
    SeedRow(unit:"43", plate:"KBE-6534", policy:"", titleNum:"", vin:"1FMCU0G60MUB01738", yearMakeModel:"2020-FORD-SUV", asset:"VEH000021488", driver:"Terrence Evans"),
    SeedRow(unit:"44", plate:"HKE-3853", policy:"", titleNum:"", vin:"3GNAXSEV4LS686967", yearMakeModel:"2020-CHEVROLET-SUV", asset:"VEH000019482", driver:"Michael Barnard"),
    SeedRow(unit:"46", plate:"DLY-7199", policy:"", titleNum:"", vin:"1FMCU9GX0GUB29783", yearMakeModel:"2016-FORD-SUV", asset:"VEH000014674", driver:"NOT ASSIGNED"),
    SeedRow(unit:"48", plate:"DLY-7197", policy:"", titleNum:"", vin:"1FMCU9GX0GUB30268", yearMakeModel:"2016-FORD-SUV", asset:"VEH000014675", driver:"Daniel Terrero"),
    SeedRow(unit:"49", plate:"EFV-1198", policy:"", titleNum:"", vin:"1FMCU9GD3HUC18092", yearMakeModel:"2017-FORD-SUV", asset:"VEH000014677", driver:"Do not drive"),
    SeedRow(unit:"60", plate:"EH8920", policy:"TJCAP472M220313", titleNum:"**778695141336909**", vin:"WDYPF4CC2D5746876", yearMakeModel:"2013-FREIGHTLINER-VAN", asset:"VEH000014678", driver:"Sat Truck"),
    SeedRow(unit:"61", plate:"EX-1183", policy:"TJCAP472M220313", titleNum:"**776333143508909**", vin:"1N6AF0KX3DN113055", yearMakeModel:"2013-NISSAN-VAN", asset:"VEH000014665", driver:"Live Truck"),
    SeedRow(unit:"62", plate:"EX-1175", policy:"TJCAP472M220313", titleNum:"**771606143434909**", vin:"1N6AF0KY2EN104728", yearMakeModel:"2014-NISSAN-VAN", asset:"", driver:"Live Truck"),
    SeedRow(unit:"63", plate:"EH-8920", policy:"", titleNum:"", vin:"1N6AF0KYXEN104881", yearMakeModel:"2014-NISSAN-VAN", asset:"", driver:"Raymond Duffy"),
    SeedRow(unit:"64", plate:"EZ-7502", policy:"", titleNum:"", vin:"1N6AF0KY2EN104759", yearMakeModel:"2014-NISSAN-VAN", asset:"", driver:"NOT ASSIGNED"),
    SeedRow(unit:"65", plate:"JFK-6474", policy:"TKBAP152D6352IND", titleNum:"*778983213151274**", vin:"1GCWGAFG1K1342893", yearMakeModel:"2019-CHEVROLET-VAN", asset:"VEH000020368", driver:"Engineering Van"),
    SeedRow(unit:"WXB", plate:"17-BEAST", policy:"", titleNum:"", vin:"1GNSKAKC5KR131141", yearMakeModel:"2019-CHEVROLET-SUV", asset:"VEH000017268", driver:"Weather Veh")
  ]

  db.exec(sql"BEGIN")
  var inserted = 0

  for r in rows:
    let ym = splitYearMakeModel(r.yearMakeModel)

    let dbUnit = r.unit.strip()
    let dbMake = ym.make
    let dbModel = ym.model
    let dbYear = ym.year
    let dbVIN = r.vin.strip()
    let dbTitleNumber = cleanStars(r.titleNum)
    let dbPlate = r.plate.strip()
    let dbPolicyNumber = r.policy.strip()
    let dbDriver = r.driver.strip()

    let notes =
      if r.asset.strip().len > 0: fmt"Asset: {r.asset.strip()}"
      else: ""

    # Defaults
    let dbCardNumberLast4 = ""
    let dbMiles = 0
    let dbPurchaseDate = 0
    let dbOilDate = 0
    let dbNextOilMiles = 0
    let dbInspectionDate = 0
    let dbRegistrationDate = 0
    let dbCleanedDateEng = 0
    let dbCleanedDateNews = 0
    let dbInService = true
    let dbInUse = false
    let dbInUseBy = ""

    db.exec(insertSql,
      dbUnit, dbMake, dbModel, dbYear, dbVIN, dbTitleNumber, dbPlate, dbPolicyNumber,
      dbDriver, dbCardNumberLast4, dbMiles, dbPurchaseDate, dbOilDate, dbNextOilMiles, dbInspectionDate,
      dbRegistrationDate, dbCleanedDateEng, dbCleanedDateNews, notes, int(dbInService), int(dbInUse), dbInUseBy
    )

    inc inserted

  db.exec(sql"COMMIT")

  echo fmt"Created new DB: {DbPath}"
  echo fmt"Inserted rows: {inserted}"

when isMainModule:
  main()
