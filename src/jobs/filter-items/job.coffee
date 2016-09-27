http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class FilterItems
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.app_id is required') unless data.app_id?

    @podio.request 'POST', "item/app/#{data.app_id}/filter/", null, null, (error, body) =>
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

module.exports = FilterItems
