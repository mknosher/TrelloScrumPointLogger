https = require "https"

module.exports = (options, callback) ->
  strResponse = ""

  req = https.request options, (res) ->
    res.on "data", (data) ->
      strResponse += data

    res.on "end", () ->
      jsonResponse = JSON.parse strResponse
      callback jsonResponse

  req.end()
