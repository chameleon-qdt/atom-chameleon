{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'

module.exports = Module =
  createModuleView: null
  modalPanel: null

  activate: (state) ->
    @createModuleView = new CreateModuleView(state.moduleViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @CreateModuleView.getElement(), visible: false)


  deactivate: ->
    @modalPanel.destroy()
    @moduleView.destroy()

  serialize: ->
    createModuleViewState: @createModuleView.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateModuleView was opened!',@
      @modalPanel.show()
