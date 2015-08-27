ChameleonSettingsView = null

ViewUri = 'atom://ChameleonSettings'

createView = (state) ->
  ChameleonSettingsView ?= require './settings-view'
  new ChameleonSettingsView(state)

deserializer =
  name: 'ChameleonSettingsView'
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