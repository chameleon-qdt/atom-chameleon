desc = require '../utils/text-description'
pathM = require 'path'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class CreateModuleView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 desc.CreateModuleTitle
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label desc.modulePath, class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'modulePath', new TextEditorView(mini: true)
            @span class: 'inline-block status-added icon icon-file-directory openFolder', outlet: 'folderIcon'
        @div class: 'form-group', =>
          @label desc.moduleId, class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'moduleId', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label desc.moduleName, class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'moduleName', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label desc.mainEntry, class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'mainEntry', new TextEditorView(mini: true)
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'col-sm-9 col-sm-offset-3', =>
          @button 'asdsd', click: 'openFolder'
          @div desc.createModuleErrorMsg, class: 'text-warning hide', outlet: 'errorMsg'

  initialize: ->
    @modulePath.getModel().onDidChange => @checkInput()
    @moduleId.getModel().onDidChange => @checkMoudleID()
    @moduleName.getModel().onDidChange => @checkInput()
    @mainEntry.getModel().onDidChange => @checkInput()

    console.log  @folderIcon.on 'click',@openFolder

  attached: ->
    @mainEntry.setText desc.mainEntryFileName
    @modulePath.setText desc.newProjectDefaultPath

    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @parentView.hidePrevBtn()

    # console.log @

  # destroy: ->
  #   @element.remove()

  openFolder: ->
    atom.pickFolder (paths) =>
      if paths?
        console.log paths

  getElement: ->
    @element

  serialize: ->

  getModuleInfo: ->
    info =
      mainEntry: @mainEntry.getText()
      moduleId: @moduleId.getText()
      moduleName: @moduleName.getText()
    info

  openFolder: () ->
    console.log 'openFolder'
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        @modulePath.setText paths[0]

  checkMoudleID: ->
    path = @moduleId.getText().trim()
    if path isnt ""
      # projectPath = atom.project.getPaths()[0]
      projectPath = @modulePath.getText().trim()
      # console.log pathM.join atom.project.getPaths()[0],path
      path = pathM.join projectPath,path
      console.log path
      dir = new Directory(path);
      dir.exists()
        .then (isExists) =>
          console.log isExists,@,dir.getRealPathSync()
          unless isExists
            @checkInput()
            @errorMsg.addClass('hide')
          else
            @errorMsg.removeClass('hide')


  checkInput: ->
    flag1 = @moduleId.getText().trim() isnt ""
    flag2 = @moduleName.getText().trim() isnt ""
    flag3 = @mainEntry.getText().trim() isnt ""
    flag4 = @modulePath.getText().trim() isnt ""

    if flag1 and flag2 and flag3
      @parentView.enableNext()
    else
      @parentView.disableNext()

  nextStep: (box)->
    box.setPrevStep @
    box.mergeOptions {moduleInfo:@getModuleInfo()}
    box.nextStep()
