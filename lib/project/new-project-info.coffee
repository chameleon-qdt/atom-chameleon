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
      @h2 '请填写要创建的应用信息:', class: 'box-subtitle'
      @div class: 'box-form', =>
        @div class: 'form-row clearfix', =>
          @label '请输入应用标识', class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'appId', new TextEditorView(mini: true, placeholderText: '例如: com.foreveross.myapp')
        @div class: 'form-row msg clearfix in-row', =>
          @div '只能输入文字和点，且至少三级目录，例如: com.foreveross.myapp', class: 'text-warning hide errorMsg', outlet: 'errorMsg2'
        @div class: 'form-row clearfix', =>
          @label '请输入应用名称', class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'appName', new TextEditorView(mini: true, placeholderText: '应用显示的名称')
        @div class: 'form-row clearfix', =>
          @label '应用创建位置', class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            # @subview 'appPath', new TextEditorView(mini: true)
            @div class: 'textEditStyle',outlet: 'appPath'
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder'
        @div class: 'form-row msg clearfix', =>
          @div '该应用目录已存在', class: 'text-warning hide errorMsg', outlet: 'errorMsg'

  initialize: ->
    @appId.getModel().onDidChange => @checkProjectName()
    @appName.getModel().onDidChange => @checkInput()
    # @appPath.getModel().onDidChange => @checkPath()

  attached: ->
    console.log @parentView.options
    @type = @parentView.options.newType
    # if @type isnt 'template'
    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @appPath.html desc.newProjectDefaultPath

  openFolder: ->
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        # path = pathM.join paths[0],@appId.getText()
        # console.log  path
        @appPath.html paths[0]

  getElement: ->
    @element

  getProjectInfo: ->
    appId = @appId.getText().trim()
    appPath = @appPath.html().trim()
    path = pathM.join appPath,appId
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
    @checkPath()
    # @checkInput()

  checkPath: ->
    appId = @appId.getText().trim()
    appPath = @appPath.html().trim()
    path = pathM.join appPath,appId
    if path isnt ""
      dir = new Directory(path);
      dir.exists()
        .then (isExists) =>
          console.log isExists,dir.getRealPathSync()
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
