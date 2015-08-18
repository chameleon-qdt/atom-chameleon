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
      @h2 '请填写要创建的项目信息:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '请输入应用标识', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appId', new TextEditorView(mini: true, placeholderText: '应用标识需以字母开头,且不能有中文')
        @div class: 'col-sm-9 col-sm-offset-3', =>
          @div '应用标识非法，应用标识不能以数字开头,且不能有中文', class: 'text-warning hide errorMsg', outlet: 'errorMsg2'
        @div class: 'form-group', =>
          @label '请输入应用名称', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appName', new TextEditorView(mini: true, placeholderText: '应用显示的名称')
        @div class: 'form-group', =>
          @label '应用创建位置', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'appPath', new TextEditorView(mini: true)
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'col-sm-9 col-sm-offset-3', =>
          @div '该目录已存在', class: 'text-warning hide errorMsg', outlet: 'errorMsg'

  initialize: ->
    @appId.getModel().onDidChange => @setPath()
    @appName.getModel().onDidChange => @checkInput()
    @appPath.getModel().onDidChange => @checkPath()

  attached: ->
    console.log @parentView.options
    @type = @parentView.options.newType
    # if @type isnt 'template'
    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @appPath.basePath = desc.newProjectDefaultPath
    @appPath.setText @appPath.basePath

  openFolder: ->
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        path = pathM.join paths[0],@appId.getText()
        console.log  path
        @appPath.basePath = path
        @appPath.setText @appPath.basePath

  getElement: ->
    @element

  getProjectInfo: ->
    path = @appPath.getText().trim()
    dir = new Directory(path)
    path = pathM.join desc.newProjectDefaultPath,dir.getBaseName() if dir.getParent().isRoot() is yes
    projectInfo =
      appId : @appId.getText()
      appName : @appName.getText()
      appPath : path

    console.log projectInfo
    projectInfo

  checkInput: ->
    flag1 = @appId.getText().trim() isnt ""
    flag2 = @appName.getText().trim() isnt ""
    flag3 = @appPath.getText().trim() isnt ""
    flag4 = @errorMsg.hasClass('hide')
    flag5 = @errorMsg2.hasClass('hide')

    if flag1 and flag2 and flag3 and flag4 and flag5
      @parentView.enableNext()
    else
      @parentView.disableNext()

  setPath: ->
    currPath = @appPath.basePath
    str = @appId.getText().trim()
    console.log Util.checkProjectName str
    if Util.checkProjectName str
      @errorMsg2.addClass('hide')
    else
      @errorMsg2.removeClass('hide')
    @appPath.setText pathM.join currPath,str if currPath isnt ""
    @checkInput()

  checkPath: ->
    path = @appPath.getText().trim()
    @appPath.basePath = path if @appPath.hasFocus()
    if path isnt ""
      dir = new Directory(path);
      dir.exists()
        .then (isExists) =>
          console.log isExists,dir.getRealPathSync()
          unless isExists
            @errorMsg.addClass('hide')

          else
            @errorMsg.removeClass('hide')
          @checkInput()
    else
      console.log 'empty'

  nextStep:(box) ->
    # console.log box
    info = @getProjectInfo()
    box.setPrevStep @
    box.mergeOptions {projectInfo:info}
    box.nextStep()
