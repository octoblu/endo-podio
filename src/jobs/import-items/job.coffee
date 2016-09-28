http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class ImportItems
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.file_id is required') unless data.file_id?
    return callback @_userError(422, 'data.app_id is required') unless data.app_id?

    { file_id, app_id } = data
    { mappings, tags_column_id, app_item_id_column_id } = data

    body = {
      app_id: app_id
      mappings: @_filterArrays mappings
      tags_column_id: tags_column_id
      app_item_id_column_id: app_item_id_column_id
    }
    
    @podio.request 'POST', "importer/#{file_id}/item/app/#{app_id}", null, null, (error, body) =>
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

module.exports = ImportItems
