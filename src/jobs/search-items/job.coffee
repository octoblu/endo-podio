http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class SearchItems
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.field_id is required') unless data.field_id?
    return callback @_userError(422, 'data.text is required') unless data.text?
    return callback @_userError(422, 'data.limit is required') unless data.limit?

    { limit, not_item_id, text, field_id } = data
    
    path = 'item/field/' + field_id + '/find'
    qs = {
      limit: limit
      not_item_id: not_item_id,
      text: text
    }

    @podio.request 'GET', path, qs, null, (error, body) =>
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

module.exports = SearchItems
