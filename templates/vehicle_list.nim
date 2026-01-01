# src/nim/webapp/templates/vehicle_list.nim
import std/[strutils, strformat]
import db_connector/db_sqlite

proc renderVehicleList*(rows: seq[Row]): string =
  result = """
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WNCN Vehicle Fleet</title>
    <style>
      :root {
        --font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
        --font-size: 14px;
        --page-bg: #dc8a78;
        --text: #111;
        --panel-bg: #179299;
        --table-head-bg: #0f0f0f;
        --table-head-text: #fff;
        --table-border: rgba(0,0,0,0.25);

        --row-in-bg: rgba(255,255,255,0.35);
        --row-out-bg: #fff3cd;
        --row-retired-bg: #f2f2f2;
        --row-retired-opacity: 0.6;

        --badge-in-bg: #a6d189;
        --badge-out-bg: #e78284;
        --badge-retired-bg: #e78284;
      }

      body {
        font-family: var(--font-family);
        font-size: var(--font-size);
        background: var(--page-bg);
        padding: 20px;
        color: var(--text);
      }

      .table-container {
        background: var(--panel-bg);
        padding: 20px;
        border-radius: 8px;
      }

      table {
        width: 100%;
        border-collapse: collapse;
      }

      thead tr {
        background: var(--table-head-bg);
        color: var(--table-head-text);
      }

      th, td {
        border: 1px solid var(--table-border);
        padding: 6px 8px;
        white-space: nowrap;
      }

      .status-in { background: var(--row-in-bg); }
      .status-out { background: var(--row-out-bg); }
      .status-retired {
        background: var(--row-retired-bg);
        opacity: var(--row-retired-opacity);
      }

      .badge {
        padding: 3px 8px;
        border-radius: 999px;
        font-weight: 600;
        font-size: 0.8em;
      }

      .badge-in { background: var(--badge-in-bg); }
      .badge-out { background: var(--badge-out-bg); }
      .badge-retired { background: var(--badge-retired-bg); }
    </style>
  </head>
  <body>

  <div class="table-container">
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Unit</th>
          <th>Status</th>
          <th>In Use By</th>
        </tr>
      </thead>
      <tbody>
  """

  for row in rows:
    let id              = row[0]
    let unit            = row[1]
    let make            = row[2]
    let model           = row[3]
    let year            = row[4]
    let vin             = row[5]
    let titleNum        = row[6]
    let plate           = row[7]
    let policy          = row[8]
    let driver          = row[9]
    let cardLast4       = row[10]
    let miles           = row[11]
    let purchaseDate    = row[12]
    let oilDate         = row[13]
    let oilMiles        = row[14]
    let inspectionDate  = row[15]
    let registration    = row[16]
    let cleanedEng      = row[17]
    let cleanedNews     = row[18]
    let notes           = row[19]
    let inService       = row[20]
    let inUse           = row[21]
    let inUseBy         = row[22]

    var statusBadge = ""
    var rowClass = ""

    if inService == "0" or inService == "false":
      statusBadge = "<span class='badge badge-retired'>OUT OF SERVICE</span>"
      rowClass = "status-retired"
    elif inUse == "1" or inUse == "true":
      statusBadge = fmt"<span class='badge badge-out'>OUT</span>"
      rowClass = "status-out"
    else:
      statusBadge = "<span class='badge badge-in'>AVAILABLE</span>"
      rowClass = "status-in"

    result.add fmt"""
        <tr class="{rowClass}">
          <td>{id}</td>
          <td>{unit}</td>
          <td>{statusBadge}</td>
          <td>{inUseBy}</td>
        </tr>
    """

  result.add """
      </tbody>
    </table>
  </div>
  </body>
  </html>
  """
