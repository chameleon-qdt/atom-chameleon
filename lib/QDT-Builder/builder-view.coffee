{$, ScrollView} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require '../utils/text-description'
util = require '../utils/util'
_ = require 'underscore-plus'

module.exports =
class ChameleonBuilderView extends ScrollView
  @content: ->
    @iframe class: 'builder-iframe'

  getURI: -> @uri

  getTitle: ->
    @uri.replace('atom://', '')

  initialize: (options) ->
    @uri = options.uri
    @appConfig = options.appConfig
    @eventEmitter = util.eventEmitter()
    console.log @appConfig


  attached: ->

    frames = window.frames
    eventEmitter = @eventEmitter.on 'server_on', (e)=>
      @serverURI = e
      @.attr {'src': @serverURI}
       .on 'load', ()=>
        _.each frames, (frame)=>
          if frame.location.href is e + '/'
            frame.postMessage JSON.stringify(@appConfig), @serverURI

        @eventEmitter.emit 'getPort', e
        eventEmitter.dispose()

    

  
