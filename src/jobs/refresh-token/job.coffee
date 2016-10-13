http   = require 'http'
_      = require 'lodash'
PodioRequest = require '../../podio-request.coffee'

class RefreshToken
  constructor: ({@encrypted}) ->
    @podio = new PodioRequest @encrypted.secrets.credentials.secret
    @refreshToken = @encrypted.secrets.credentials.refreshToken
    @clientId = process.env.ENDO_PODIO_PODIO_CLIENT_ID
    @clientSecret = process.env.ENDO_PODIO_PODIO_CLIENT_SECRET
  do: ({data}, callback) =>

    @podio.refreshToken @refreshToken, @clientId, @clientSecret, (error, encrypted) =>

      newAuth = {
        id: @encrypted.id
        username: @encrypted.username
        ref: @encrypted.ref
        expires_in: encrypted.expires_in
        secrets:
          credentials:
            secret: encrypted.access_token
            refreshToken: encrypted.refresh_token
      }

      # return callback @_userError(401, error) if error?
      return callback null, newAuth

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = RefreshToken
