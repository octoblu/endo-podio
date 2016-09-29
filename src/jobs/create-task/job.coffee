http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class CreateTask
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    # return callback @_userError(422, 'data.username is required') unless data.username?
    qs = {
      hook: data.hook
      silent: data.silent
    }

    body = {
      text: data.text
      description: data.task_description
      private: data.private
      due_on: data.due_on
      responsible: data.responsible
      reminder:
        remind_delta: data.reminder
    }


    body.ref_type = data.ref_type if data.ref_type?
    body.ref_id = data.ref_id if data.ref_id?
    body.labels = @_filterArrays data.labels
    body.label_ids = @_filterArrays data.label_ids
    body.file_ids = @_filterArrays data.file_ids


    @podio.request 'POST', 'task/', qs, body, (error, body) =>
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

module.exports = CreateTask
