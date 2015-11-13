ChameleonLoginOSCView = null

ViewUri = 'atom://ChameleonLoginOSC'

createView = (state) ->
  ChameleonLoginOSCView ?= require './login-osc-view'
  new ChameleonLoginOSCView(state)

deserializer =
  name: 'ChameleonLoginOSCView'
  deserialize: (state) ->
    createView(state)

atom.deserializers.add(deserializer)

module.exports =
  activate: ->
    atom.workspace.addOpener (filePath) ->
      createView(uri: ViewUri) if filePath is ViewUri

    atom.workspace.open(ViewUri)

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()