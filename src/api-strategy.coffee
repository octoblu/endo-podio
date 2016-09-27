_ = require 'lodash'
PassportStrategy = require 'passport-strategy'
url = require 'url'
Podio = require('podio-js').api

class PodioStrategy extends PassportStrategy
  constructor: (env) ->
    env ?= process.env
    if _.isEmpty env.ENDO_PODIO_PODIO_CALLBACK_URL
      throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_CALLBACK_URL')
    if _.isEmpty env.ENDO_PODIO_PODIO_AUTH_URL
      throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_AUTH_URL')
    if _.isEmpty env.ENDO_PODIO_PODIO_SCHEMA_URL
      throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_SCHEMA_URL')
    if _.isEmpty env.ENDO_PODIO_PODIO_FORM_SCHEMA_URL
      throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_FORM_SCHEMA_URL')
    if _.isEmpty env.ENDO_PODIO_PODIO_CLIENT_ID
      throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_CLIENT_ID')
    if _.isEmpty env.ENDO_PODIO_PODIO_CLIENT_SECRET
      throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_CLIENT_SECRET')

    @_authorizationUrl = env.ENDO_PODIO_PODIO_AUTH_URL
    @_callbackUrl      = env.ENDO_PODIO_PODIO_CALLBACK_URL
    @_schemaUrl        = env.ENDO_PODIO_PODIO_SCHEMA_URL
    @_formSchemaUrl    = env.ENDO_PODIO_PODIO_FORM_SCHEMA_URL
    @_clientId         = env.ENDO_PODIO_PODIO_CLIENT_ID
    @_clientSecret     = env.ENDO_PODIO_PODIO_CLIENT_SECRET

    super

  authenticate: (req) -> # keep this skinny
    {bearerToken} = req.meshbluAuth
    {username, password} = req.body
    return @redirect @authorizationUrl({bearerToken}) unless password?
    @getUserFromPodio {username, password}, (error, auth) =>
      return @error error if error?
      return @fail 404 unless auth?
      @success {
        id:       auth.ref.id
        username: username
        secrets:
          clientId: @_clientId
          clientSecret: @_clientSecret
          credentials:
            username: username
            password: password
      }

  authorizationUrl: ({bearerToken}) ->
    {protocol, hostname, port, pathname} = url.parse @_authorizationUrl
    query = {
      postUrl: @postUrl()
      schemaUrl: @schemaUrl()
      formSchemaUrl: @formSchemaUrl()
      bearerToken: bearerToken
    }
    return url.format {protocol, hostname, port, pathname, query}

  formSchemaUrl: ->
    @_formSchemaUrl

  getUserFromPodio: ({username, password}, callback) =>
    podio = new Podio({
      authType: 'password'
      clientId: @_clientId
      clientSecret: @_clientSecret
    })
    podio.isAuthenticated().then(->
    ).catch (err) ->
      podio.authenticateWithCredentials username, password, (error, response)->
        callback error, response

  postUrl: ->
    {protocol, hostname, port} = url.parse @_callbackUrl
    return url.format {protocol, hostname, port, pathname: '/auth/api/callback'}

  schemaUrl: ->
    @_schemaUrl

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = PodioStrategy
