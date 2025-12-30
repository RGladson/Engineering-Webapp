# src/nim/webapp/templates/vehicle_list.nim
import std/[strutils, strformat]
import db_connector/db_sqlite

# We define a public proc (*) that takes the DB rows and returns HTML string
proc renderVehicleList*(rows: seq[Row]): string =
  # 1. Start the HTML string (Header)
  result = """
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WNCN Vehicle Fleet</title>
    <style>
      body { padding: 20px; background-color: #dc8a78; }
      .table-container { background: #179299; padding: 20px; border-radius: 8px; box-shadow: 1 2px 4px rgba(0,0,0,0.1); }
      .header-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
      .status-out { background-color: #fff3cd !important; }
      .status-retired { opacity: 0.6; background-color: #f2f2f2 !important; }
      .badge-out { background-color: #e78284; color: #000; }
      .badge-in { background-color: #a6d189; }
      .badge-retired { background-color: #e78284; }
    </style>
  </head>
  <body>
    <div class="container-fluid">
      <div class="header-row">
        <h1>Vehicles</h1>
        <span class="text-muted">NEWS</span>
      </div>

      <div class="table-container">
        <table class="table table-hover table-bordered align-middle">
          <thead class="table-dark">
            <tr>
              <th>Unit</th>
              <th>Vehicle</th>
              <th>Assigned To</th>
              <th>Status</th>
              <th>Details</th>
              <th>Maintenance Due</th>
              <th>Notes</th>
            </tr>
          </thead>
          <tbody>
  """

  # 2. Loop through the rows and append to result
  for row in rows:
    # Safely get columns (defaults to empty string if index issues, though unlikely with SELECT *)
    let unit = row[1]
    let make = row[2]
    let model = row[3]
    let year = row[4]
    let vin = row[5]
    let plate = row[7]
    let driver = row[9]
    let miles = row[11]
    let oilDate = row[13]
    let regDate = row[15]
    let notes = row[18]
    let inService = row[19]
    let inUse = row[20]
    let inUseBy = row[21]

    let vehicleStr = fmt"{year} {make} {model}"
    
    var statusBadge = ""
    var rowClass = ""
    
    if inService == "0" or inService == "false":
      statusBadge = "<span class='badge badge-retired'>Out Of Service</span>"
      rowClass = "status-retired"
    elif inUse == "1" or inUse == "true":
      statusBadge = fmt"<span class='badge badge-out'>OUT: {inUseBy}</span>"
      rowClass = "status-out"
    else:
      statusBadge = "<span class='badge badge-in'>AVAILABLE</span>"

    # Add the specific row HTML
    result.add fmt"""
            <tr class="{rowClass}">
              <td class="fw-bold">{unit}</td>
              <td>{vehicleStr}</td>
              <td>{driver}</td>
              <td>{statusBadge}</td>
              <td>
                <small>
                  <strong>VIN:</strong> {vin}<br>
                  <strong>Plate:</strong> {plate}
                </small>
              </td>
              <td>
                <small>
                  <strong>Oil:</strong> {oilDate}<br>
                  <strong>Reg:</strong> {regDate}<br>
                  <strong>Miles:</strong> {miles}
                </small>
              </td>
              <td>{notes}</td>
            </tr>
    """

  # 3. Close the HTML tags (Footer)
  result.add """
          </tbody>
        </table>
      </div>
    </div>
  </body>
  </html>
  """