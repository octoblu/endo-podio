http   = require 'http'
_      = require 'lodash'
PodioJs = require 'podio-js'
Podio = PodioJs.api
request = require 'request'

class GetPersonalTasks
  constructor: ({@encrypted}) ->
    @podioConfig = {
      authType: 'password'
      clientId: @encrypted.secrets.clientId
      clientSecret: @encrypted.secrets.clientSecret
    }

    @username = @encrypted.secrets.credentials.username
    @password = @encrypted.secrets.credentials.password

  do: ({data}, callback) =>
    # return callback @_userError(422, 'data.username is required') unless data.username?
    podio = new Podio(@podioConfig)
    podio.authenticateWithCredentials @username, @password, (error, response) =>
      return callback @_userError(422, error) if error?

      options = {
        uri: 'https://api.podio.com/task/personal/summary'
        method: 'GET'
        json: true
        headers:
          Authorization: 'OAuth2 ' + response.access_token
      }

      request options, (error, res, body) =>
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

module.exports = GetPersonalTasks
