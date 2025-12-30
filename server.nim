import jester
import std/[os, strutils, times]
import db_connector/db_sqlite

# Import our new view file
# Note: we use "include" here to easily share the Row type, 
# but "import" works if you fix paths. Include is simplest for single-file splits.
include templates/vehicle_list

# Configuration
const dbPath = "db/vehicles.db" 

settings:
  port = Port(5000)
  bindAddr = "0.0.0.0"

routes:
  get "/":
    redirect "/vehicles"

  get "/vehicles":
    if not fileExists(dbPath):
      resp "Error: Database file not found."

    let db = open(dbPath, "", "", "")
    
    # 1. Fetch Data
    let rows = db.getAllRows(sql"SELECT * FROM Vehicles ORDER BY Unit")
    db.close()

    # 2. Render HTML using our external template file
    resp renderVehicleList(rows)