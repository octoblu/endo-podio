http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class AddStatus
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.space_id is required') unless data.space_id?
    return callback @_userError(422, 'data.value is required') unless data.value?

    path = 'status/space/' + data.space_id
    qs = {
      alert_invite: data.alert_invite
    }

    body = {
      value: data.value
    }

    data.question.options = @_filterArrays data.question.options
    body.file_ids = @_filterArrays data.file_ids
    body.embed_url = data.embed_url if data.embed_url? && data.embed_url != ''
    body.question = data.question if !_.isEmpty(data.question) && data.question.text?

    @podio.request 'POST', path, qs, body, (error, body) =>
      return callback @_userError(401, error) if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: body
      }

  _filterArrays: (items) =>
    items = _.filter items, (item) => !_.isNull item

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = AddStatus
