pathM = require 'path'
Util = require '../utils/util'
desc = require '../utils/text-description'
AddNewFrameworkView = require './addNewFramework-view'
config = require '../../config/config'

module.exports =
  chameleonBox: null
  modalPanel: null
  addNewFrameworkView: null

  activate: ->
    @addNewFrameworkView = new AddNewFrameworkView()
    @addNewFrameworkView.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @addNewFrameworkView, visible: false)
    @addNewFrameworkView.move()
    @addNewFrameworkView.onCancelClick = => @closeView()
    @addNewFrameworkView.rerenderList = => @rerenderList()

  deactivate: ->
    @modalPanel.destroy()
    @addNewFrameworkView.destroy()

  openView: ->
    unless @modalPanel.isVisible()
      @modalPanel.show()
      @addNewFrameworkView.show()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
      @addNewFrameworkView.hide()
      @addNewFrameworkView = null

  rerenderList: ->

