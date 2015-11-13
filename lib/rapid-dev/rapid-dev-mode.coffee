RapidDevModeView = null
rapidDevModeView = null

ViewUri = "atom://rapid-dev-mode"

createRapidDevModeView = (state) ->
  RapidDevModeView ?= require './rapid-dev-mode-view'
  rapidDevModeView = new RapidDevModeView(state)

deserializer =
  name: 'RapidDevModeView'
  deserialize: (state) ->
    createRapidDevModeView(state) if state.constructor is Object

atom.deserializers.add(deserializer)

module.exports =
  activate: (state) ->
    atom.workspace.addOpener (uri) ->
      # console.log uri
      rapidDevModeView ?= createRapidDevModeView({uri}) if uri is ViewUri

    atom.workspace.open(ViewUri)


  deactivate: ->
    rapidDevModeView?.dispose()
    rapidDevModeView?.remove()
    rapidDevModeView = null
