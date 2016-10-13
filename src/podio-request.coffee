request = require 'request'

class PodioRequest
  constructor: (access_token) ->
    @base_uri = 'https://api.podio.com/'
    @access_token = access_token

  request: (method, path, qs, body, callback) =>
    options = {
      uri: @base_uri + path
      method: method
      json: true
      headers:
        Authorization: 'OAuth2 ' + @access_token
    }

    options.qs = qs if qs?
    options.body = body if body?

    request options, (error, res, body) =>
      callback error, body

  refreshToken: (refreshToken, clientId, clientSecret, callback) =>
    options = {
      uri: 'https://podio.com/oauth/token'
      method: 'POST'
      json: true
      qs:
        refresh_token: refreshToken
        client_id: clientId
        client_secret: clientSecret
        grant_type: 'refresh_token'
    }

    request options, (error, res, body) =>
      return callback error, body

  downloadFile: (method, file_id, qs, body, callback) =>
    options = {
      uri: "https://files.podio.com/#{file_id}"
      method: method
      json: true
      headers:
        Authorization: 'OAuth2 ' + @access_token
    }

    options.qs = qs if qs?
    options.body = body if body?

    request options, (error, res, body) =>
      callback error, body

module.exports = PodioRequest
