http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class ExportItems
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.app_id is required') unless data.app_id?
    return callback @_userError(422, 'data.exporter is required') unless data.exporter?
    { app_id, exporter, limit, offset, view_id } = data
    { sort_by, sort_desc, filters, split_email_by_type, split_phone_by_type } = data

    body = {
      limit: limit
      offset: offset
      sort_by: sort_by
      sort_desc: sort_desc
      filters: filters
      split_email_by_type: split_email_by_type
      split_phone_by_type: split_phone_by_type
    }

    @podio.request 'POST', "item/app/#{app_id}/export/#{exporter}", null, body, (error, body) =>
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

module.exports = ExportItems
