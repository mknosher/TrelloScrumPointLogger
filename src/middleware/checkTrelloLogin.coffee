module.exports = (trelloOAuth, trelloOAuthRoutes) ->
  (req, res, next) ->
    if trelloOAuth.hasAccess == false and trelloOAuthRoutes.isLoginRoute(req.path) == false
      if trelloOAuth.token?
        console.log "Redirecting to /relogin"
        res.writeHead 302, { Location : "/relogin" }
      else
        console.log "Redirecting to /login"
        res.writeHead 302, { Location : "/login" }
      res.end()
    else
      next()
