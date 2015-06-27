desc = require '../utils/text-description'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class CreateModuleView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 desc.CreateModuleTitle
      @div class: 'form-horizontal', =>
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
    @moduleId.getModel().onDidChange => @checkMoudleID()
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
    info

  onTypeItemClick: (e) ->
    el = e.currentTarget
    $('.item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    @parentView.enableNext()

  checkMoudleID: ->
    path = @moduleId.getText().trim()
    if path isnt ""
      projectPath = atom.project.getPaths()[0]
      path = "#{projectPath}/#{path}"
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

    if flag1 and flag2 and flag3
      @parentView.enableNext()
    else
      @parentView.disableNext()

  nextStep: (box)->
    box.setPrevStep @
    box.mergeOptions {moduleInfo:@getModuleInfo()}
    box.nextStep()
