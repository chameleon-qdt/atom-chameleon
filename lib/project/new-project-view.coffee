_ = require 'underscore-plus'
desc = require '../utils/text-description'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class NewProjectView extends View

  @content: (params) ->
    @div class: 'new-project hide', =>
      @div class: 'step active', 'data-step': '1', =>
        @h2 '请选择要创建的项目类型:'
        @div class: 'new-item text-center',  =>
          @img class: 'pic', src:'atom://chameleon/images/icon.png'
          @h3 '空白项目',class: 'project-name'
        @div class: 'new-item text-center',  =>
          @img class: 'pic', src: 'atom://chameleon/images/icon.png'
          @h3 '自带框架项目',class: 'project-name'
        @div class: 'new-item text-center',  =>
          @img class: 'pic', src: 'atom://chameleon/images/icon.png'
          @h3 '业务模板',class: 'project-name'
        # @div '描述', class: 'desc'
      @div class: 'step', 'data-step': '2', =>
        @h2 '请选择要创建的项目类型:'
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

  # initialize: (params) ->
    # params = _.extend defaultOpt,params
    # console.log params

  attached: ->
    $('.new-item').on 'click',(e) => @onItemClick(e)
    @prevBtn?= @parentView.prevBtn
    @nextBtn?= @parentView.nextBtn

    @appId.setText 'newPackage'
    @appName.setText '新项目'
    @appPath.setText 'D:/_Study/atom/package/newPackage'

  getElement: ->
    @element

  onItemClick: (e) ->
    # console.log e,@
    $('.step').toggleClass('active')

    @prevBtn.text(desc.prev).removeClass('hide back');
    @nextBtn.text(desc.finish).addClass('finish').removeClass('hide');

  getProjectInfo: ->
    console.log @appId
    projectInfo =
      appId : @appId.getText();
      appName : @appName.getText();
      appPath : @appPath.getText();

    console.log projectInfo
    projectInfo
