desc = require '../utils/text-description'
pathM = require 'path'
Util = require '../utils/util'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
client = require '../utils/client'

syncInfoView = require './sync-project-info'

module.exports =
class SyncProjectView extends View

  projectDetail: {}

  @content: (params) ->
    @div class: 'new-project', =>
      @h2 '请选择平台:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group iOS-item', =>
          @label 'iOS', class: 'col-sm-3 control-label', for: 'platform'
          @input type: 'radio', name: 'platform', value: 'IOS', class: 'radio-input'
        @div class: 'form-group android-item', =>
          @label 'android', class: 'col-sm-3 control-label', for: 'platform'
          @input type: 'radio', name: 'platform', value: 'ANDROID', class: 'radio-input'
            

  initialize: ->
    # @appId.getModel().onDidChange => @checkProjectName()
    # @appName.getModel().onDidChange => @checkInput()
    # @appPath.getModel().onDidChange => @checkPath()

  attached: ->
    @type = @parentView.options.newType
    # @appPath.html desc.newProjectDefaultPath
    @getProjectDetail(@parentView.options.projectId, @parentView.options.account_id)
    @parentView.setNextBtn()
    # @parentView.disableNext()
    

  getProjectDetail: (projectId, accountId) ->
    params =
      sendCookie: true
      qs:
        account: accountId
        identifier: projectId
      success: (data) =>
        @projectDetail = data
        if !!@projectDetail.platformMap.ANDROID
          $('.android-item').show()
          $('input:radio[value="ANDROID"]').val('ANDROID/' + @projectDetail.platformMap.ANDROID[0])
        if !!@projectDetail.platformMap.IOS
          $('.iOS-item').show()
          $('input:radio[value="IOS"]').val('IOS/' + @projectDetail.platformMap.IOS[0])
      error: (err) ->
        console.log err
    client.getProjectDetail params

  getElement: ->
    @element

  getProjectInfo: ->
    platform = $('input:radio[name="platform"]:checked').val();
    console.log platform
    if !platform
      alert '请选择平台'
      return false
    else
      @platform = platform
    # appId = @appId.getText().trim()
    # appId = @appId.html()
    # appPath = @appPath.html().trim()
    # path = pathM.join appPath,appId
    # dir = new Directory(path)
    # path = pathM.join desc.newProjectDefaultPath,dir.getBaseName() if dir.getParent().isRoot() is yes
    # projectInfo =
    #   appId : @appId.html()
    #   appName : @appName.getText()
    #   appPath : path

    # console.log projectInfo
    # projectInfo

  checkInput: ->
    flag2 = @appName.getText().trim() isnt ""
    flag4 = @errorMsg.hasClass('hide')

    if flag2 and flag4
      @parentView.enableNext()
    else
      @parentView.disableNext()

  nextStep:(box) ->
    box.setPrevStep @
    box.mergeOptions {subview: syncInfoView, projectInfo: @getProjectInfo(), projectDetail: @projectDetail, platform: @platform, newType: 'syncProject'}
    box.nextStep()
