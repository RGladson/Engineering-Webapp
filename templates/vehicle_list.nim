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
      :root {
        /* ===== Global font controls ===== */
        --font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
        --font-size: 16px;
        --line-height: 1.35;
        --font-weight: 400;

        /* ===== Global color controls ===== */
        --page-bg: #dc8a78;
        --text: #111111;
        --muted: rgba(17, 17, 17, 0.70);
        --heading: #111111;

        /* ===== Container + table colors ===== */
        --panel-bg: #179299;
        --panel-shadow: 0 2px 4px rgba(0,0,0,0.12);

        --table-bg: transparent;
        --table-text: #111111;
        --table-head-bg: #0f0f0f;
        --table-head-text: #ffffff;
        --table-border: rgba(0,0,0,0.25);

        /* ===== Status row colors ===== */
        --row-in-bg: rgba(255, 255, 255, 0.35);  /* AVAILABLE rows */
        --row-out-bg: #fff3cd;                   /* OUT rows */
        --row-retired-bg: #f2f2f2;               /* Out Of Service rows */
        --row-retired-opacity: 0.60;

        /* Optional: if you want row-specific text colors later */
        --row-in-text: var(--table-text);
        --row-out-text: var(--table-text);
        --row-retired-text: var(--table-text);

        /* ===== Badge colors ===== */
        --badge-out-bg: #e78284;
        --badge-out-text: #000000;
        --badge-in-bg: #a6d189;
        --badge-in-text: #000000;
        --badge-retired-bg: #e78284;
        --badge-retired-text: #000000;
      }

      /* ===== Global typography ===== */
      html, body {
        font-family: var(--font-family);
        font-size: var(--font-size);
        line-height: var(--line-height);
        font-weight: var(--font-weight);
        color: var(--text);
      }

      body { padding: 20px; background-color: var(--page-bg); }

      h1, h2, h3, h4, h5, h6 {
        color: var(--heading);
        margin: 0;
      }

      small, .text-muted { color: var(--muted); }

      /* ===== Container ===== */
      .table-container {
        background: var(--panel-bg);
        padding: 20px;
        border-radius: 8px;
        box-shadow: var(--panel-shadow);
      }

      .header-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
      }

      /* ===== Table base ===== */
      table {
        width: 100%;
        border-collapse: collapse;
        background: var(--table-bg);
        color: var(--table-text);
      }

      thead tr {
        background: var(--table-head-bg);
        color: var(--table-head-text);
      }

      th, td {
        border: 1px solid var(--table-border);
        padding: 10px;
        vertical-align: top;
        color: inherit; /* ensures table cells inherit the theme color */
      }

      th { text-align: left; }

      /* ===== Row state styling ===== */
      .status-in {
        background-color: var(--row-in-bg) !important;
        color: var(--row-in-text);
      }

      .status-out {
        background-color: var(--row-out-bg) !important;
        color: var(--row-out-text);
      }

      .status-retired {
        opacity: var(--row-retired-opacity);
        background-color: var(--row-retired-bg) !important;
        color: var(--row-retired-text);
      }

      /* ===== Badge styling ===== */
      .badge {
        display: inline-block;
        padding: 4px 8px;
        border-radius: 999px;
        font-size: 0.85em;
        font-weight: 600;
      }

      .badge-out { background-color: var(--badge-out-bg); color: var(--badge-out-text); }
      .badge-in { background-color: var(--badge-in-bg); color: var(--badge-in-text); }
      .badge-retired { background-color: var(--badge-retired-bg); color: var(--badge-retired-text); }

      /* Optional: make the VIN/Plate labels a touch stronger */
      td small strong { color: inherit; }
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
      rowClass = "status-in"

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
