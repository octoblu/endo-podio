request = require 'request'

class PodioRequest
  constructor: (access_token) ->
    @base_uri = 'https://api.podio.com/'
    @access_token = access_token

  request: (method, path, qs, body, callback) =>
    options = {
      uri: 'https://api.podio.com/' + path
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
