
boardId = "505f979826ef554049b31f09"

express = require "express"
mw = require "./middleware"
Trello = require "./trello"

app = module.exports = express()

app.configure ->
  app.use express.logger()
  #app.use express.session {key:'tspl'}
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use mw.json.responses
  app.use app.router
  app.use mw.json.jsonSuccessHandler
  app.use mw.json.jsonErrorHandler
  app.use express.static __dirname + '/../public'
  app.use express.favicon()
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

trello = new Trello(apiKey, boardId)
require("./jsonRoutes").setup app, trello

app.listen 4000
console.log "Listening on port 4000"
