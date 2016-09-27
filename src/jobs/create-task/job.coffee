http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class CreateTask
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret

  do: ({data}, callback) =>
    # return callback @_userError(422, 'data.username is required') unless data.username?
    qs = {
      hook: hook
      silent: silent
    }

    body = {
      text: data.text
      description: data.task_description
      private: data.private
      due_on: data.due_on
      ref_type: data.ref_type
      ref_id: data.ref_id
      responsible: data.responsible
      file_ids: data.file_ids
      labels: data.label
      label_ids: data.label_ids
      reminder:
        remind_delta: data.reminder
    }
    
    @podio.request 'POST', 'task/', qs, body, (error, body) =>
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

module.exports = CreateTask
