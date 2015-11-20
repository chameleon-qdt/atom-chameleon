desc = require '../utils/text-description'
pathM = require 'path'
Util = require '../utils/util'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
client = require '../utils/client'

module.exports =
class SyncProjectView extends View

  projectDetail: {}

  @content: (params) ->
    @div class: 'sync-project', =>
      @h2 '请填写要创建的应用信息:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '请输入应用标识', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @div class:'textEditStyle', outlet: 'appId'
        @div class: 'form-group', =>
          @label '请输入应用名称', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appName', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '应用创建位置', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @div class:'textEditStyle', outlet: 'appPath'
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'col-sm-9 col-sm-offset-3', =>
          @div '该目录已存在', class: 'text-warning hide', outlet: 'errorMsg'

  initialize: ->
    # @appId.getModel().onDidChange => @checkProjectName()
    @appName.getModel().onDidChange => @checkInput()
    # @appPath.getModel().onDidChange => @checkPath()

  attached: ->
    @type = @parentView.options.newType
    @platform = if @parentView.options.platform then @parentView.options.platform.split('/') else ''
    @appPath.html desc.newProjectDefaultPath
    @getProjectDetail(@parentView.options.projectId, @parentView.options.account_id, platform: @platform[0], version: @platform[1])
    @parentView.setNextBtn('finish')
    @parentView.disableNext()


  getProjectDetail: (projectId, accountId, platform) ->
    params =
      sendCookie: true
      qs:
        identifier: projectId
        platform: platform.platform
        version: platform.version
      success: (data) =>
        console.log data
        @projectDetail = data
        @appId.html @projectDetail.identifier
        @appName.setText @projectDetail.name
        @checkPath()
      error: (err) ->
        console.log err
    client.getProjectPlatformDetail params

  openFolder: ->
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        @appPath.html paths[0]
        @checkPath()

  getElement: ->
    @element

  getProjectInfo: ->
    # appId = @appId.getText().trim()
    appId = @appId.html()
    appPath = @appPath.html().trim()
    path = pathM.join appPath,appId
    dir = new Directory(path)
    path = pathM.join desc.newProjectDefaultPath,dir.getBaseName() if dir.getParent().isRoot() is yes
    projectInfo =
      appId : @appId.html()
      appName : @appName.getText()
      appPath : path

    console.log projectInfo
    projectInfo

  checkInput: ->
    flag2 = @appName.getText().trim() isnt ""
    flag4 = @errorMsg.hasClass('hide')

    if flag2 and flag4
      @parentView.enableNext()
    else
      @parentView.disableNext()


  checkProjectName: ->
    str = @appId.getText().trim()
    console.log Util.checkProjectName str
    if Util.checkProjectName str
      @errorMsg.addClass('hide')
    else
      @errorMsg.removeClass('hide')
    @checkPath()

  checkPath: ->
    # appId = @appId.getText().trim()
    appId = @appId.html().trim()
    appPath = @appPath.html().trim()
    path = pathM.join appPath,appId
    if path isnt ''
      appConfigPath = pathM.join path,desc.projectConfigFileName
      isExists = Util.isFileExist(appConfigPath)
      unless isExists
        @errorMsg.addClass('hide')
      else
        @errorMsg.removeClass('hide') if appId isnt ""
      @checkInput()

  nextStep:(box) ->
    box.setPrevStep @
    box.mergeOptions {projectInfo: @getProjectInfo(), projectDetail: @projectDetail, newType: 'syncProject'}
    box.nextStep()
