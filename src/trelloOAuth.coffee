OAuth = require("oauth").OAuth
fs = require "fs"

requestURL = "https://trello.com/1/OAuthGetRequestToken"
accessURL = "https://trello.com/1/OAuthGetAccessToken"
authorizeURL = "https://trello.com/1/OAuthAuthorizeToken"
appName = "TrelloScrumPointLogger"

tokenFileName = "token.json"

class TrelloOAuth
  constructor: (appSettings) ->
    #Trello redirects the user here after authentication
    loginCallback = "http://#{appSettings.domain}:#{appSettings.port}/trello_oauth_callback"
    @oauth = new OAuth(requestURL, accessURL, appSettings.apiKey, appSettings.oAuthSecret, "1.0", loginCallback, "HMAC-SHA1")

    @authorizeURL = authorizeURL
    @appName = appName

    @hasAccess = false

  requestOAuthAccess: (callback) ->
    @oauth.getOAuthRequestToken (err, token, tokenSecret, results) =>
      if err?
        console.log "Error requesting token: #{JSON.stringify(err)}"
        callback null
        return

      @token = token
      @tokenSecret = tokenSecret

      callback token

  finalizeOAuthAccess: (callback) ->
    console.log "Unknown token" unless @token?
    console.log "Unknown token secret" unless @tokenSecret?
    console.log "Unknown verifier" unless @verifier?

    unless @token? and @tokenSecret? and @verifier?
      callback()
      return

    @oauth.getOAuthAccessToken @token, @tokenSecret, @verifier, (err, accessToken, accessTokenSecret, results) =>
      if err?
        console.log "Error getting oAuth access token: #{JSON.stringify(err)}"
      else
        @accessToken = accessToken
        @accessTokenSecret = accessTokenSecret
        @hasAccess = true

      callback()

  loadToken: (callback) ->
    fs.exists tokenFileName, (exists) =>
      if not exists
        callback(false) if callback?
        return

      fs.stat tokenFileName, (err, stats) =>
        if err?
          callback(false) if callback?
          return

        # Trello oauth tokens last 30 days
        days = 30
        if (stats.mtime.getTime() + days * 24 * 60 * 60 * 1000) < Date.now()
          console.log "Error loading token from #{tokenFileName}: token expired"
          callback(false) if callback?
          return

        fs.readFile tokenFileName, (err, data) =>
          if err?
            console.log "Error loading token from #{tokenFileName}: #{JSON.stringify(err)}"
            return callback(false) if callback?

          { @token, @tokenSecret, @verifier } = JSON.parse data

          console.log "Token read from #{tokenFileName}"
          callback(true) if callback?

  saveToken: (callback) ->
    fileData = JSON.stringify({
      token : @token
      tokenSecret: @tokenSecret
      verifier: @verifier
    })
    fs.writeFile tokenFileName, fileData, (err) ->
      if err?
        console.log "Error saving token to #{tokenFileName}"
      else
        console.log "Token written to #{tokenFileName}"

      callback() if callback?

  get: (url, callback) ->
    @oauth.getProtectedResource url, "GET", @accessToken, @accessTokenSecret, callback


module.exports = (appSettings) ->
  return new TrelloOAuth(appSettings)