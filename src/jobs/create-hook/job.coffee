http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class CreateHook
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.url is required') unless data.url?
    return callback @_userError(422, 'data.event_type is required') unless data.event_type?

    path = "/hook/#{data.ref_type}/#{data.ref_id}/"
    body = {
      url: data.url
      type: data.event_type
    }

    @podio.request 'POST', path, null, body, (error, body) =>
      return callback @_userError(401, error) if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: body
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = CreateHook
