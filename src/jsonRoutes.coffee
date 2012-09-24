@setup = (app, trello) ->
  app.get "/lists", require("./getLists")(trello)
  app.get "/lists/:listId/cards", require("./getCards")(trello)
  app.get "/lists/:listId/points", require("./getPointsForList")(trello)