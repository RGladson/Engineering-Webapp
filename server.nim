import jester, asyncdispatch, htmlgen, bcrypt, json, os, strutils

settings:
  port = Port(8080)
  bindAddr = "0.0.0.0"

routes:
  get "/":
    resp h1("WNCN Engineering Portal") & 
         p("System is Online.") &
         a(href="/login", "Login Here")

  get "/login":
    resp h1("Staff Login") &
         form(action="/login", `method`="POST",
           p("Username: ", input(type="text", name="username")),
           p("Password: ", input(type="password", name="password")),
           input(type="submit", value="Login")
         )

  post "/login":
    let username = @"username"
    let password = @"password"
    let dbPath = "db/users.json"

    if not fileExists(dbPath):
      resp "Error: User database not found. Admin needs to run add_user tool."

    let users = parseFile(dbPath)

    if users.hasKey(username):
      let storedHash = users[username].getStr()
      
      # FIX: Using 'compare' instead of 'verify'
      # This matches the runarcn/nim-bcrypt library API
      if compare(password, storedHash):
        setCookie("user", username, daysForward(1))
        redirect "/report"
      else:
        resp "Invalid password."
    else:
      resp "User not found."

  get "/report":
    if not request.cookies.hasKey("user"):
      redirect "/login"
    
    let currentUser = request.cookies["user"]
    
    resp h1("Daily Report: " & currentUser) &
         p("Fill out your engineering log below.") &
         form(action="/submit", `method`="POST",
           textarea(name="content", rows="10", cols="50", placeholder="Transmitter readings, bitrates, etc..."),
           br(),
           input(type="submit", value="Submit Log")
         )
         
  get "/logout":
    setCookie("user", "", daysForward(-1))
    redirect "/"

runForever()