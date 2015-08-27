{$,Emitter} = require 'atom-space-pen-views'
ModuleView = require './module-view'
ChameleonBox = require '../../utils/chameleon-box-view'

module.exports = ConfigureModule =
  chameleonBox: null
  modalPanel: null

  activate:(state) ->
    @chameleonBox = new ModuleView()
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()
    @chameleonBox.prevBtn.addClass('hide')
    # @chameleonBox.onCancelClick = => @clearOrCloseView()
    # @chameleonBox.onCloseClick = => @closeView()
    @chameleonBox.onNextClick = => @chameleonBox.contentView.nextStep()
    @chameleonBox.onPrevClick = => @chameleonBox.contentView.prevStep()


  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()

  clearOrCloseView: ->
    # console.log @chameleonBox.contentView.second
    if @chameleonBox.contentView.second.hasClass('hide')
      if @modalPanel.isVisible()
        @modalPanel.hide()
        # body...
    else
      @chameleonBox.contentView.moduleName.setText("")
      @chameleonBox.contentView.moduleVersion.setText("")
      @chameleonBox.contentView.moduleDescription.setText("")
      @chameleonBox.contentView.moduleInput.setText("")

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    @chameleonBox.openView()
