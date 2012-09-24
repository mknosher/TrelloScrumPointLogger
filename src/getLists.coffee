module.exports = (trello) ->
  (req, res, next) ->
    console.log trello
    next res.jsonSuccess { lists : trello.lists }