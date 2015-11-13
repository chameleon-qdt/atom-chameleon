desc = require '../utils/text-description'
Util = require '../utils/util'
pathM = require 'path'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
# SelectTemplate = require './select-template-view'

module.exports =
class NewProjectView extends View

  @content: (params) ->
    @div class: 'new-project', =>
      @h2 "#{desc.createAppInfo}:", class: 'box-subtitle'
      @div class: 'box-form', =>
        @div class: 'form-row clearfix', =>
          @label desc.inputAppID, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'appId', new TextEditorView(mini: true, placeholderText: desc.appIDPlaceholder)
        @div class: 'form-row msg clearfix in-row', =>
          @div desc.appIDError, class: 'text-warning hide errorMsg', outlet: 'errorMsg2'
        @div class: 'form-row clearfix', =>
          @label desc.inputAppName, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'appName', new TextEditorView(mini: true, placeholderText: desc.appNamePlaceholder)
        @div class: 'form-row clearfix', =>
          @label desc.inputAppPath, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @div class: 'textEditStyle',outlet: 'appPath'
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'form-row msg clearfix', =>
          @div desc.appPathExist, class: 'text-warning hide errorMsg', outlet: 'errorMsg'

  initialize: ->
    @appId.getModel().onDidChange => @checkProjectName()
    @appName.getModel().onDidChange => @checkInput()
    # @appPath.getModel().onDidChange => @checkPath()

  attached: ->
    console.log @parentView.options
    @type = @parentView.options.newType
    # if @type isnt 'template'
    btnText = if @parentView.options.newType is 'quick' then desc.next else desc.finish
    @parentView.setNextBtn('finish',btnText)
    @parentView.disableNext()
    @appPath.html desc.newProjectDefaultPath

  openFolder: ->
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        @appPath.html paths[0]
        @checkPath()

  getElement: ->
    @element

  getProjectInfo: ->
    appId = @appId.getText().trim()
    appPath = @appPath.html().trim()
    projectInfo =
      appId : @appId.getText()
      appName : @appName.getText()
      appPath : appPath

    projectInfo

  checkInput: ->
    flag1 = @appId.getText().trim() isnt ""
    flag2 = @appName.getText().trim() isnt ""
    flag3 = @appPath.html().trim() isnt ""
    flag4 = @errorMsg.hasClass('hide')
    flag5 = @errorMsg2.hasClass('hide')

    if flag1 and flag2 and flag3 and flag4 and flag5
      @parentView.enableNext()
    else
      @parentView.disableNext()

  checkProjectName: ->
    # currPath = @appPath.basePath
    str = @appId.getText().trim()
    console.log str,Util.checkProjectName str
    if str is "" or Util.checkProjectName str
      @errorMsg2.addClass('hide')
    else
      @errorMsg2.removeClass('hide')
    # @appPath.setText pathM.join currPath,str if currPath isnt ""
    # @checkPath()
    @checkInput()

  checkPath: ->
    appId = @appId.getText().trim()
    appPath = @appPath.html().trim()
    # path = pathM.join appPath,appId
    if appPath isnt ''
      appConfigPath = pathM.join appPath,desc.projectConfigFileName
      isExists = Util.isFileExist(appConfigPath)
      unless isExists
        @errorMsg.addClass('hide')
      else
        @errorMsg.removeClass('hide') if appId isnt ""
      @checkInput()
    else
      console.log 'empty'

  nextStep:(box) ->
    # console.log box
    info = @getProjectInfo()
    box.setPrevStep @
    box.mergeOptions {projectInfo:info}
    box.nextStep()
