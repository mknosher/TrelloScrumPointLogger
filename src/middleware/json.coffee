class JsonError
  constructor: (@message) ->

class JsonSuccess
  constructor: (@json) ->

@JsonError = JsonError
@JsonSuccess = JsonSuccess

@responses = (req, res, next) ->
  res.jsonError = (message) ->
    new JsonError message
  res.jsonSuccess = (result) ->
    result = result || {}
    new JsonSuccess result
  next()

@jsonSuccessHandler = (json, req, res, next) ->
  if json instanceof JsonSuccess
    res.json json.json, 200
  else
    next json

@jsonErrorHandler = (err, req, res, next) ->
  if err instanceof JsonError
    res.json {error: true, message: err.message }, 200
  else
    next err
