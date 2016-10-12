http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class DownloadFile
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.file_id is required') unless data.file_id?

    @podio.request 'GET', "file/#{data.file_id}/raw", data, null, (error, body) =>
      return callback @_userError(401, error) if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data:
          raw: body
      }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = DownloadFile
