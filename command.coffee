_               = require 'lodash'
MeshbluConfig   = require 'meshblu-config'
path            = require 'path'
Endo            = require 'endo-core'
OctobluStrategy = require 'endo-core/octoblu-strategy'
MessageHandler  = require 'endo-core/message-handler'
ApiStrategy     = require './src/api-strategy'
RefreshTokenHandler = require './src/refresh-token-handler'

MISSING_SERVICE_URL = 'Missing required environment variable: ENDO_PODIO_SERVICE_URL'
MISSING_MANAGER_URL = 'Missing required environment variable: ENDO_PODIO_MANAGER_URL'
MISSING_APP_OCTOBLU_HOST = 'Missing required environment variable: APP_OCTOBLU_HOST'

class Command
  getOptions: =>
    throw new Error MISSING_SERVICE_URL if _.isEmpty process.env.ENDO_PODIO_SERVICE_URL
    throw new Error MISSING_MANAGER_URL if _.isEmpty process.env.ENDO_PODIO_MANAGER_URL
    throw new Error MISSING_APP_OCTOBLU_HOST if _.isEmpty process.env.APP_OCTOBLU_HOST

    meshbluConfig   = new MeshbluConfig().toJSON()
    apiStrategy     = new ApiStrategy process.env
    octobluStrategy = new OctobluStrategy process.env, meshbluConfig
    refreshTokenHandler = new RefreshTokenHandler

    jobsPath = path.join __dirname, 'src/jobs'

    return {
      apiStrategy:     apiStrategy
      deviceType:      'endo:podio'
      disableLogging:  process.env.DISABLE_LOGGING == "true"
      meshbluConfig:   meshbluConfig
      messageHandler:  new MessageHandler {jobsPath}
      octobluStrategy: octobluStrategy
      port:            process.env.PORT || 80
      appOctobluHost:  process.env.APP_OCTOBLU_HOST
      serviceUrl:      process.env.ENDO_PODIO_SERVICE_URL
      userDeviceManagerUrl: process.env.ENDO_PODIO_MANAGER_URL
      staticSchemasPath: process.env.ENDO_PODIO_STATIC_SCHEMAS_PATH
      healthcheckService: healthcheck: (callback) => callback(null, healthy: true)
      refreshTokenHandler: refreshTokenHandler
    }

  run: =>
    server = new Endo @getOptions()
    server.run (error) =>
      throw error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
