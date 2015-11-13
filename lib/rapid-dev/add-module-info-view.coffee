Util = require '../utils/util'
Desc = require '../utils/text-description'
PathM = require 'path'
{$, View, TextEditorView} = require 'atom-space-pen-views'
ChameleonBox = require '../utils/chameleon-box-view'

class ModuleInfoView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 Desc.createModuleTitle, class: 'box-subtitle'
      @div class: 'box-form', =>
        @div class: 'form-row clearfix', =>
          @label Desc.moduleInApp, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @div class: 'textEditStyle', outlet: 'modulePath'
        @div class: 'form-row clearfix', =>
          @label Desc.moduleId, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleId', new TextEditorView(mini: true)
        @div class: 'form-row msg clearfix in-row', =>
          @div Desc.moduleIdErrorMsg, class: 'text-warning hide errorMsg', outlet: 'errorMsg2'
        @div class: 'form-row clearfix', =>
          @label Desc.moduleName, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleName', new TextEditorView(mini: true)
        @div class: 'form-row msg clearfix', =>
          @div Desc.createModuleErrorMsg, class: 'text-warning hide errorMsg', outlet: 'errorMsg'

  attached: ->
    activeItem = document.querySelector('.settingsItem.active')
    currentProject = activeItem.dataset.projectpath
    @moduleId.getModel().onDidChange => @checkPath()
    @moduleName.getModel().onDidChange => @checkInput()

    @moduleName.setText ''
    @moduleId.setText ''
    @modulePath.html currentProject

    @parentView.setNextBtn('finish',Desc.next)
    @parentView.disableNext()

  # destroy: ->
  #   @element.remove()

  getElement: ->
    @element

  getPath: ->
    PathM.join @modulePath.html().trim(),Desc.moduleLocatFileName

  serialize: ->

  getModuleInfo: ->
    modulePath = @getPath()
    info =
      mainEntry: Desc.mainEntryFileName
      moduleId: @moduleId.getText()
      moduleName: @moduleName.getText()
      modulePath: modulePath
      isChameleonProject:@isChameleonProject

    moduleConfig = Util.formatModuleConfigToObj info
    params =
      projectInfo: null
      builderConfig: [
        {
          name: "index.html",
          components: []
        }
      ]
      moduleConfig: moduleConfig
      moduleInfo:
        identifier: info.moduleId
        moduleName: info.moduleName
        modulePath: info.modulePath

  checkProjectPath: (path) ->
    result = null
    configPath = PathM.join path,Desc.projectConfigFileName
    return Util.isFileExist configPath,'sync'

  checkPath: ->
    path = @moduleId.getText().trim()
    if path isnt ""
      regEx = /^[a-zA-z]\w{5,31}$/
      if regEx.test path
        @errorMsg2.addClass('hide')
      else
        @errorMsg2.removeClass('hide')
      projectPath = @getPath().trim()

      path = PathM.join projectPath,path
      console.log path
      isExists = Util.isFileExist path
      if isExists
        @errorMsg.removeClass('hide')
        @checkInput()
      else
        @errorMsg.addClass('hide')


  checkInput: ->
    flag1 = @moduleId.getText().trim() isnt ""
    flag2 = @moduleName.getText().trim() isnt ""
    # flag3 = @mainEntry.getText().trim() isnt ""
    flag4 = @getPath().trim() isnt ""
    flag5 = @errorMsg.hasClass 'hide'
    flag6 = @errorMsg2.hasClass 'hide'

    if flag1 and flag2 and flag4 and flag5 and flag6
      @parentView.enableNext()
    else
      @parentView.disableNext()

  nextStep: (box)->
    box.setPrevStep @
    box.mergeOptions {moduleInfo:@getModuleInfo()}
    box.nextStep()


module.exports =
class AddModuleInfoView extends ChameleonBox

  options :
    title : Desc.createModule
    begining: ModuleInfoView
    subview : new ModuleInfoView()
