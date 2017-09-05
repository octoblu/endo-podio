_ = require 'lodash'
moment = require 'moment'
PassportPodio = require('passport-podio').Strategy

class PodioStrategy extends PassportPodio
  constructor: (env) ->
    throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_CLIENT_ID')     if _.isEmpty process.env.ENDO_PODIO_PODIO_CLIENT_ID
    throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_CLIENT_SECRET') if _.isEmpty process.env.ENDO_PODIO_PODIO_CLIENT_SECRET
    throw new Error('Missing required environment variable: ENDO_PODIO_PODIO_CALLBACK_URL')  if _.isEmpty process.env.ENDO_PODIO_PODIO_CALLBACK_URL

    options = {
      clientID:     process.env.ENDO_PODIO_PODIO_CLIENT_ID
      clientSecret: process.env.ENDO_PODIO_PODIO_CLIENT_SECRET
      callbackURL:  process.env.ENDO_PODIO_PODIO_CALLBACK_URL
    }

    super options, @onAuthorization

  onAuthorization: (accessToken, refreshToken, profile, callback) =>

    callback null, {
      id: profile.id
      username: profile.displayName
      ref:
        type: profile._json.type
        id: profile._json.user_id
      secrets:
        credentials:
          secret: accessToken
          refreshToken: refreshToken
          expires_in: profile._json.push.expires_in
          timestamp: moment().utc().format()
    }

module.exports = PodioStrategy
