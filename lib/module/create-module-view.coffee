desc = require '../utils/text-description'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class CreateModuleView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 '请填写要创建的模块信息:'
      @div class: 'form-horizontal', =>
        @div class: 'form-group', =>
          @label '模块标识', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'moduleId', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '模块名称', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'moduleName', new TextEditorView(mini: true)
        @div class: 'form-group', =>
          @label '模块入口', class: 'col-sm-3 control-label'
          @div class: 'col-sm-9', =>
            @subview 'mainEntry', new TextEditorView(mini: true)

  initialize: ->
    @moduleId.getModel().onDidChange => @checkInput()
    @moduleName.getModel().onDidChange => @checkInput()
    @mainEntry.getModel().onDidChange => @checkInput()

  attached: ->
    @mainEntry.setText(desc.mainEntry)

    @parentView.setNextBtn('finish')
    @parentView.disableNext()
    @parentView.hidePrevBtn()
    # console.log @

  # destroy: ->
  #   @element.remove()

  getElement: ->
    @element

  serialize: ->

  getModuleInfo: ->
    info =
      mainEntry: @mainEntry.getText()
      moduleId: @moduleId.getText()
      moduleName: @moduleName.getText()
      version: "0.0.0"
      releaseNote: ''
    info

  onTypeItemClick: (e) ->
    el = e.currentTarget
    $('.item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    @parentView.enableNext()

  checkInput: ->
    flag1 = @moduleId.getText().trim() isnt ""
    flag2 = @moduleName.getText().trim() isnt ""
    flag3 = @mainEntry.getText().trim() isnt ""

    if flag1 and flag2 and flag3
      @parentView.enableNext()
    else
      @parentView.disableNext()

  nextStep: (box)->
    box.setPrevStep @
    box.mergeOptions {moduleInfo:@getModuleInfo()}
    box.nextStep()
