module.exports = (trello) ->
  (req, res, next) ->
    next res.jsonSuccess { points : trello.getPoints(req.params.listId) }