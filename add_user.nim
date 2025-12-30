import bcrypt, json, os, strutils, std/times

# Path to your database file
let dbPath = "db/users.json"

echo "User Generator"
echo "Enter Username:"
let username = stdin.readLine().strip()

if username.len == 0:
  quit("Username cannot be empty.")

echo "Enter password:"
let password = stdin.readLine().strip()

if password.len <= 7:
  quit("Password must be at least 8 characters long.")

# 1. Generate the Hash (Cost 12 is standard for 2025 security)
let salt = genSalt(12)
let hashedFn = hash(password, salt)

# 2. Load existing DB or create a new one
var users = newJObject()
if fileExists(dbPath):
  try:
    users = parseFile(dbPath)
  except:
    echo "Warning: db/users.json was corrupt. Starting fresh."

# 3. Add/Update the user
users[username] = %hashedFn

# 4. Save to disk
writeFile(dbPath, users.pretty())
echo "Success! User '", username, "' added to ", dbPath
sleep(1000)
quit()