http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class CopyItemToApp
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.app_id is required') unless data.app_id?
    return callback @_userError(422, 'data.item_id is required') unless data.item_id?
    @podio.request 'GET', "item/#{data.item_id}/clone", null, null, (error, responseData) =>
      @podio.request 'GET', "app/#{data.app_id}", null, null, (error, app) =>
        console.log responseData
        body = {
          fields: @_removeNullKeys responseData.values
        }

        body.file_ids = responseData.files if !_.isEmpty responseData.files
        body.tags = responseData.tags if !_.isEmpty responseData.tags?
        body.linked_account_id = responseData.linked_account_id if responseData.linked_account_id?
        body.reminder = responseData.reminder if responseData.reminder?
        body.recurrence = responseData.recurrence if responseData.recurrence?

        console.log body
        @podio.request 'POST', "item/app/#{data.app_id}/", { hook: true, silent: false }, body, (error, response) =>
          return callback @_userError(401, error) if error?
          return callback null, {
            metadata:
              code: 200
              status: http.STATUS_CODES[200]
            data: response
          }

  _getFieldIds: (fields) =>
    ids = []
    _.forEach fields, (field) =>
      ids.push field.external_id
    return ids

  _checkSubFieldType: (field) =>
    types = [
      'embed'
      'duration'
      'video'
      'location'
      'progress'
      'money'
      'contact'
      'member'
      'app'
      'date'
      'image'
      'state'
      'number'
      'text'
      'question'
      'category'
      'email'
    ]
    keys = _.keysIn field
    _.intersection keys, types

  _removeNullKeys: (fields) =>
    newFields = fields
    _.forEach fields, (field, field_key) =>
      if _.isArray field
        newFields[field_key] = []
        _.forEach field, (value, index) =>
          newFields[field_key][index] = { "#{value.id}": @_removeNullKeys value[@_checkSubFieldType value]}
      if _.isObject field
        newFields[field_key] = [] if field.id?
        newFields[field_key].push { "#{field.id}": field[@_checkSubFieldType field]} if field.id?
        _.forEach field, (value, key) =>
          delete newFields[field_key][key] if !value?
    return newFields

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = CopyItemToApp
