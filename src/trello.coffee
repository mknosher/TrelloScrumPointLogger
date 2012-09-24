jsonRequest = require "./httpsJsonRequest"
_ = require "underscore"

getTrelloLists = (apiKey, boardId, callback) ->
  options = {
    hostname : "api.trello.com"
    path : "/1/boards/#{boardId}/lists?key=#{apiKey}&fields=name"
  }
  jsonRequest options, (res) ->
    callback res

getTrelloCards = (apiKey, boardId, callback) ->
  options = {
    hostname : "api.trello.com"
    path : "/1/boards/#{boardId}/cards?key=#{apiKey}&fields=name,idList"
  }
  jsonRequest options, (res) ->
    callback res

parseCardNames = (cards) ->
  parsedCards = []
  _.each cards, (card) ->
    parsedCardName = card.name.match /\((\x3f|\d*\.?\d+)\)\s?(.*$)/m
    card.originalName = parsedCardName[0]
    card.points = parseFloat parsedCardName[1]
    card.points = 0 if isNaN(card.points)
    card.name = parsedCardName[2]
    parsedCards.push card
  return parsedCards

class Trello
  constructor: (@apiKey, @boardId) ->
    getTrelloLists @apiKey, @boardId, (lists) =>
      console.log "Retrieved lists from trello..."
      console.log lists
      @lists = lists
    getTrelloCards @apiKey, @boardId, (cards) =>
      console.log "Retrieved cards from trello..."
      @cards = parseCardNames cards
      console.log @cards

  getLists: () ->
    return @lists

  getCards: (listId) ->
    return _.filter @cards, (card) -> card.idList == listId

  getPoints: (listId) ->
    cardsForList = _.filter @cards, (card) -> card.idList == listId
    return _.reduce(
      cardsForList,
      (sum, card) -> sum + card.points,
      0
    )

module.exports = Trello