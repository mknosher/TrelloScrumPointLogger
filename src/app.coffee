fs = require "fs"
express = require "express"
https = require "https"
mw = require "./middleware"
Trello = require "./trello"

app = module.exports = express()

appSettings = JSON.parse fs.readFileSync "./appSettings.json"

trelloOAuth = require("./trelloOAuth")(appSettings)
trelloOAuth.loadToken()
trello = require("./trello")(appSettings, trelloOAuth)

trelloOAuthRoutes = require "./trelloOAuthRoutes"

app.configure ->
  app.use express.logger()
  app.use express.cookieParser()
  app.use express.session { key : "tspl", secret : "239sdlkjf34epmcndf46gl023989jfksl" }
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use mw.checkTrelloLogin trelloOAuth, trelloOAuthRoutes
  app.use mw.json.responses
  app.use app.router
  app.use mw.json.jsonSuccessHandler
  app.use mw.json.jsonErrorHandler
  app.use express.static __dirname + '/../public'
  app.use express.favicon()
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

trelloOAuthRoutes.setup(app, appSettings, trelloOAuth, trello)
require("./jsonRoutes").setup app, trello

app.listen appSettings.port, appSettings.domain
#https.createServer(options, app).
console.log "Listening on port #{appSettings.port}"
