desc = require '../utils/text-description'
{Directory} = require 'atom'
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
        @div class: 'col-sm-9 col-sm-offset-3', =>
          @div '该目录已存在', class: 'text-warning hide', outlet: 'errorMsg'

  initialize: ->
    @appId.getModel().onDidChange => @setPath()
    @appName.getModel().onDidChange => @checkInput()
    @appPath.getModel().onDidChange => @checkPath()

  attached: ->
    @type = @parentView.options.newType
    if @type isnt 'template'
      @parentView.setNextBtn('finish')
    @parentView.disableNext()
    # @appId.setText 'newPackage'
    # @appName.setText '新项目'
    @appPath.setText desc.newProjectDefaultPath

  openFolder: ->
    atom.pickFolder (paths) =>
      if paths[0]?
        console.log paths[0]
        path = "#{paths[0]}/#{@appId.getText()}".replace(/\\/g,'/')
        console.log  path
        @appPath.setText path

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

  checkInput: ->
    flag1 = @appId.getText().trim() isnt ""
    flag2 = @appName.getText().trim() isnt ""
    flag3 = @appPath.getText().trim() isnt ""

    if flag1 and flag2 and flag3
      @parentView.enableNext()
    else
      @parentView.disableNext()

  setPath: ->
    currPath = @appPath.getText().trim()
    currPath = currPath.substr(0,currPath.lastIndexOf('/')+1)
    console.log currPath
    @appPath.setText currPath+@appId.getText().trim() if currPath isnt ""
    @checkInput()

  checkPath: ->
    path = @appPath.getText().trim()
    if path isnt ""
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

  nextStep:(box) ->
    # console.log box
    info = @getProjectInfo()
    box.setPrevStep @
    if @type isnt 'template'
      box.mergeOptions {projectInfo:info}
    else
      # box.mergeOptions {subview:'',projectInfo:info}
    box.nextStep()
