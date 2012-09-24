module.exports = (trello) ->
  (req, res, next) ->
    next res.jsonSuccess { cards : trello.getCards(req.params.listId) }