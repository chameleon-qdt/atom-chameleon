{$} = require 'atom-space-pen-views'
UploadProjectView = require './upload-project-view'
ChameleonBox = require './../utils/chameleon-box-view'
desc = require './../utils/text-description'

module.exports = UploadProject =
  chameleonBox: null
  modalPanel: null

  activate: (state) ->
    console.log "build project activate"
    @chameleonBox = new UploadProjectView()
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()
    @chameleonBox.cancelBtn.hide()
    @chameleonBox.prevBtn.hide()
    @chameleonBox.nextBtn.text("确认上传")
    @chameleonBox.onNextClick = => @chameleonBox.contentView.nextBtnClick()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!',@
      @modalPanel.show()

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
