{$} = require 'atom-space-pen-views'
BuildProjectView = require './build-project-view'
ChameleonBox = require './../utils/chameleon-box-view'
desc = require './../utils/text-description'

module.exports = BuildProject =
  chameleonBox: null
  modalPanel: null

  activate: (state) ->
    console.log "build project activate"
    @chameleonBox = new BuildProjectView()
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()
    @chameleonBox.cancelBtn.hide()
    @chameleonBox.prevBtn.hide()
    @chameleonBox.onNextClick = => @chameleonBox.contentView.nextBtnClick()
    @chameleonBox.onPrevClick = => @chameleonBox.contentView.prevBtnClick()

  openView: ->
    @chameleonBox.openView()

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
