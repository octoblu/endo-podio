PodioRequest = require './podio-request'
moment    = require 'moment'
_ = require 'lodash'

class RefreshTokenHandler
  constructor: () ->
    @podio = new PodioRequest

  isTokenValid: ({credentials}, callback) =>
    expires_in = _.get credentials, 'expires_in', false
    timestamp = _.get credentials, 'timestamp', false

    return callback null, false if !timestamp || !expires_in

    now = moment().utc()
    expiration = moment(timestamp).add(expires_in, 's')
    isValid = now.isBefore(expiration)
    callback null, isValid

  refreshToken: (secrets, callback) =>
    refresh_token = _.get secrets, 'credentials.refreshToken', false
    return callback @_userError 'Missing refreshToken, re-auth Podio', 422 if !refresh_token
    @podio.refreshToken refresh_token, (error, body) =>
      return callback error if error?
      return callback error if !body.access_token

      credentials = {
        secret: body.access_token
        refreshToken: body.refresh_token
        expires_in: body.expires_in
        timestamp: moment().utc().format()
      }
      secrets.credentials = credentials
      return callback null, secrets

   _userError: (message, code) =>
      error = new Error message
      error.code = code if code?
      return error

module.exports = RefreshTokenHandler
