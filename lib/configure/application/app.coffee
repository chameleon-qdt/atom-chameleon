{$} = require 'atom-space-pen-views'
AppConfigView = require './app-view'

module.exports = ConfigureApp =
  modalPanel: null

  activate:(state) ->

    @chameleonBox = new AppConfigView()
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()
    @chameleonBox.onFinish (options) => @saveConfig(options)

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    @chameleonBox.openView()
    # unless @chameleonBox.openView()
    #   unless @modalPanel.isVisible()
    #     @modalPanel.show()

  saveConfig: (options) ->
    @chameleonBox.contentView.saveInput()
    # @closeView()
