_ = require "underscore"
async = require "async"

getTrelloLists = (oauth, apiKey, boardId, callback) ->
  console.log "Retrieved lists from trello..."

  getUrl = "https://api.trello.com/1/boards/#{boardId}/lists?key=#{apiKey}&token=#{oauth.accessToken}&fields=name"
  oauth.get getUrl, (err, data, response) ->
    if err?
      console.log "Failed: #{JSON.stringify(err)}"
      callback null
    else
      lists = JSON.parse data
      console.log "Succeeded:"
      console.log lists
      callback lists

getTrelloCards = (oauth, apiKey, boardId, callback) ->
  console.log "Retrieved cards from trello..."

  getUrl = "https://api.trello.com/1/boards/#{boardId}/cards?key=#{apiKey}&token=#{oauth.accessToken}&fields=name,idList"
  oauth.get getUrl, (err, data, response) ->
    if err?
      console.log "Failed: #{JSON.stringify(err)}"
      callback null
    else
      cards = JSON.parse data
      console.log "Succeeded:"
      console.log cards
      callback cards

parseCardNames = (cards) ->
  parsedCards = []
  _.each cards, (card) ->
    parsedCardName = card.name.match /\((\x3f|\d*\.?\d+)\)\s?(.*$)/m
    if parsedCardName?
      card.originalName = parsedCardName[0]
      card.points = parseFloat parsedCardName[1]
      card.points = 0 if isNaN(card.points)
      card.name = parsedCardName[2]
    else
      card.points = 0
    parsedCards.push card
  return parsedCards

class Trello
  constructor: (@apiKey, @boardId, @oauth) ->

  loadBoard: (callback) ->
    async.auto({
      lists : (cb) =>
        getTrelloLists @oauth, @apiKey, @boardId, (lists) =>
          @lists = lists
          cb()
      cards : (cb) =>
        getTrelloCards @oauth, @apiKey, @boardId, (cards) =>
          @cards = parseCardNames cards
          cb()
      callcallback : ["lists", "cards", () ->
        callback()
      ]
    })

  getLists: () ->
    return @lists

  getCards: (listId) ->
    return _.filter @cards, (card) -> card.idList == listId

  getPoints: (listId) ->
    cardsForList = @getCards(listId)
    return _.reduce(
      cardsForList,
      (sum, card) -> sum + card.points,
      0
    )

module.exports = (appSettings, trelloOAuth) ->
  return new Trello(appSettings.apiKey, appSettings.boardId, trelloOAuth)