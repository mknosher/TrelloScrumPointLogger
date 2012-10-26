url = require "url"

@setup = (app, appSettings, trelloOAuth, trello) ->
  app.get "/login", (req, res) ->
    trelloOAuth.requestOAuthAccess (token) ->
      redirectUrl = "#{trelloOAuth.authorizeURL}?oauth_token=#{token}&name=#{trelloOAuth.appName}"
      console.log "Redirecting to #{redirectUrl}"
      res.writeHead(302, { Location : redirectUrl })
      res.end()

  app.get "/trello_oauth_callback", (req, res) ->
    query = url.parse(req.url, true).query

    trelloOAuth.verifier = query.oauth_verifier

    trelloOAuth.finalizeOAuthAccess () ->
      trelloOAuth.saveToken()
      res.end JSON.stringify { message : "oauth access granted!" }

      trello.loadBoard () ->
        console.log "board loaded successfully!"

  app.get "/relogin", (req, res) ->
    trelloOAuth.finalizeOAuthAccess () ->
      if trelloOAuth.hasAccess == true
        res.end JSON.stringify { message : "oauth relogin successful!" }

        trello.loadBoard () ->
          console.log "board loaded successfully"
      else
        res.end JSON.stringify { message : "oauth relogin failed!" }

@isLoginRoute = (route) ->
  return route == "/login" or route == "/relogin" or route == "/trello_oauth_callback"