desc = require '../utils/text-description'
pathM = require 'path'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class CreateModuleInfoView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 desc.CreateModuleTitle
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '模块所在项目', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @select class: 'form-control', outlet: 'selectProject'
        @div class: 'form-group', =>
          @label desc.modulePath, class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'modulePath', new TextEditorView(mini: true)
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
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
        @div class: 'col-sm-9 col-sm-offset-3', =>
          @div desc.createModuleErrorMsg, class: 'text-warning hide', outlet: 'errorMsg'

  initialize: ->
    @modulePath.getModel().onDidChange => @checkInput()
    @moduleId.getModel().onDidChange => @checkMoudleID()
    @moduleName.getModel().onDidChange => @checkInput()
    @mainEntry.getModel().onDidChange => @checkInput()
    @selectProject.on 'change',(e) => @onSelectChange(e)

  attached: ->
    @mainEntry.setText desc.mainEntryFileName
    @modulePath.setText desc.newProjectDefaultPath

    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @parentView.hidePrevBtn()

    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    if projectNum isnt 0
      @selectProject.empty()
      @setSelectItem path for path in projectPaths
      @modulePath.parents('.form-group').addClass 'hide'
      @selectProject.parents('.form-group').removeClass 'hide'
      @modulePath.setText pathM.join @selectProject.val(),'modules'
    else
      @selectProject.parents('.form-group').addClass 'hide'
      @modulePath.parents('.form-group').removeClass 'hide'
    # console.log @

  # destroy: ->
  #   @element.remove()
  setSelectItem:(path) ->
    projectName = pathM.basename path
    optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
    @selectProject.append optionStr

  getElement: ->
    @element

  serialize: ->

  getModuleInfo: ->
    info =
      mainEntry: @mainEntry.getText()
      moduleId: @moduleId.getText()
      moduleName: @moduleName.getText()
      modulePath: @modulePath.getText()
    info

  openFolder: (e) ->
    console.log 'openFolder'
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        @modulePath.setText paths[0]

  onSelectChange: (e) ->
    el = e.currentTarget
    # console.log el.value
    @modulePath.setText pathM.join el.value,'modules'

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
