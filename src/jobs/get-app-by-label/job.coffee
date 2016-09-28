http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class GetAppByLabel
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.org_label is required') unless data.org_label?

    { org_label, space_label, app_label } = data

    @podio.request 'GET', "app/org/#{org_label}/space/#{space_label}/#{app_label}", null, null, (error, body) =>
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

module.exports = GetAppByLabel
