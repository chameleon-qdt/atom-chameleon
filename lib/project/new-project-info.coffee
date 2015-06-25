_ = require 'underscore-plus'
desc = require '../utils/text-description'
{openDirectory} = require '../utils/dialog'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class NewProjectView extends View

  @content: (params) ->
    @div class: 'new-project', =>
      @h2 '请填写要创建的项目信息:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '请输入应用标识', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appId', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '请输入应用名称', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appName', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '应用创建位置', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appPath', new TextEditorView(mini: true)
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'

  attached: ->
    console.log
    @type = @parentView.options.newType
    if @type isnt 'template'
      @parentView.setNextBtn('finish')
      # @parentView.disableNext()
    @appId.setText 'newPackage'
    @appName.setText '新项目'
    @appPath.setText desc.newProjectDefaultPath

  openFolder: ->
    openDirectory(title: 'Select Path')
    .then (destPath) =>
      appId = @appId.getText()
      sPath = destPath[0]
      rPath = sPath + '\\' + appId
      console.log rPath
      @appPath.setText rPath

  getElement: ->
    @element

  getProjectInfo: ->
    console.log @appId
    projectInfo =
      appId : @appId.getText();
      appName : @appName.getText();
      appPath : @appPath.getText();

    console.log projectInfo
    projectInfo

  nextStep:(box) ->
    # console.log box
    info = @getProjectInfo()
    box.setPrevStep @
    if @type isnt 'template'
      box.mergeOptions {projectInfo:info}
    else
      # box.mergeOptions {subview:'',projectInfo:info}
    box.nextStep()
