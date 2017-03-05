http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class CreateItem
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    # return callback @_userError(422, 'data.username is required') unless data.username?

    body = {}
    qs = {
      hook: data.hook
      silent: data.silent
    }
    body.fields =  @_formatFields @_filterArrays data.field_collection if data.field_collection?
    body.external_id = data.external_id if data.external_id?
    body.file_ids = @_filterArrays data.file_ids
    body.tags = @_filterArrays data.tags
    body.reminder = { reminder_delta: data.reminder } if data.reminder?
    body.linked_account_id = data.linked_account_id if data.linked_account_id?
    body.ref = { type: data.ref.ref_type, id: data.ref.ref_id } if data.ref?

    @podio.request 'POST', "item/#{data.item_id}/", qs, body, (error, body) =>
      return callback @_userError(401, error) if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: body
      }

  _formatFields: (field_collection) =>
    newCollection = {}
    _.forEach field_collection, (field) =>
      newCollection[field.key] = []
      subFieldSet = {}
      _.forEach field.sub_fields, (sub_field) =>
        subFieldSet[sub_field.sub_id] = sub_field.value
      newCollection[field.key].push subFieldSet
    return newCollection

  _filterArrays: (items) =>
    items = _.filter items, (item) => !_.isNull item

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = CreateItem
