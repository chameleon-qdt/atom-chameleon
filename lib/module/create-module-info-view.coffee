desc = require '../utils/text-description'
Util = require '../utils/util'
pathM = require 'path'
{Directory} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'
disabled = 'disabled'

module.exports =
class CreateModuleInfoView extends View

  @content: ->
    @div class: 'create-module', =>
      @h2 desc.createModuleTitle, class: 'box-subtitle'
      @div class: 'box-form', =>
        @div class: 'form-row clearfix', =>
          @div class: 'row-title pull-left selectPath', =>
            @input type: 'radio', name: 'modulePaths', outlet: 'selectAppPath', id: 'selectAppPath'
            @label desc.moduleInApp, for: 'selectAppPath'
          @div class: 'row-content pull-left', =>
            @select class: 'form-control', outlet: 'selectProject'
        @div class: 'form-row clearfix', =>
          @div class: 'row-title pull-left selectPath', =>
            @input type: 'radio', name: 'modulePaths', outlet: 'selectModulePath', id: 'selectModulePath'
            @label desc.modulePath,for: 'selectModulePath'
          @div class: 'row-content pull-left', =>
            @div class: 'textEditStyle', outlet: 'modulePath'
            @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openFolder', outlet:'openBtn'
        @div class: 'form-row clearfix', =>
          @label desc.moduleId, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleId', new TextEditorView(mini: true)
        @div class: 'form-row msg clearfix in-row', =>
          @div desc.moduleIdErrorMsg, class: 'text-warning hide errorMsg', outlet: 'errorMsg2'
        @div class: 'form-row clearfix', =>
          @label desc.moduleName, class: 'row-title pull-left'
          @div class: 'row-content pull-left', =>
            @subview 'moduleName', new TextEditorView(mini: true)
        @div class: 'form-row msg clearfix', =>
          @div desc.createModuleErrorMsg, class: 'text-warning hide errorMsg', outlet: 'errorMsg'

  initialize: ->

  attached: ->
    # @modulePath.getModel().onDidChange => @checkPath()
    @moduleId.getModel().onDidChange => @checkPath()
    @moduleName.getModel().onDidChange => @checkInput()
    # @mainEntry.getModel().onDidChange => @checkInput()
    @selectProject.on 'change',(e) => @onSelectChange(e)
    @selectAppPath.on 'change',(e) => @toggleRow(e)
    @selectModulePath.on 'change',(e) => @toggleRow(e)
    @moduleName.setText ''
    @moduleId.setText ''
    # @mainEntry.setText desc.mainEntryFileName
    @modulePath.html desc.newProjectDefaultPath
    btnText = if @parentView.options.createType is 'simple' then desc.next else desc.finish
    @parentView.setNextBtn('finish',btnText)
    @parentView.disableNext()

    @projects = @findProject()
    projectNum = @projects.length

    if projectNum isnt 0
      @selectProject.find('.sopt').remove()
      @setSelectItem path for path in @projects
      @selectAppPath[0].checked = true
    else
      @setSelectItem '','sopt'
      @selectModulePath[0].checked = true
    @toggleRow()
    @setSelectItem 'other','other',"#{desc.other}--#{desc.openFromFolder}"
    @checkPath()

  # destroy: ->
  #   @element.remove()

  toggleRow: ->
    console.log 'toggleRow'
    selectRow = @selectProject.parents('.form-row')
    inputRow = @modulePath.parents('.form-row')
    if @selectModulePath[0].checked
      selectRow.addClass disabled
      inputRow.removeClass disabled
      @openBtn.removeClass disabled
      @selectProject.attr(disabled,disabled)
    else
      inputRow.addClass disabled
      @openBtn.addClass disabled
      selectRow.removeClass disabled
      @selectProject.removeAttr(disabled)
    @checkPath()

  setSelectItem:(path,className,text,insertBefore,isSelected) ->
    if className?
      text?=""
      optionStr = "<option value='#{path}' class='#{className}'>#{text}</option>"
    else
      filePath = pathM.join path,desc.projectConfigFileName
      obj = Util.readJsonSync filePath
      projectName = if obj? then obj.name else pathM.basename path
      if isSelected? and isSelected is true
        isSelected = ' selected'
      else
        isSelected = ''
      optionStr = "<option value='#{path}' class='sopt'#{isSelected}>#{projectName}  -  #{path}</option>"
    if insertBefore is true
      @selectProject.find('.other').before optionStr
    else
      @selectProject.append optionStr

  getElement: ->
    @element

  getPath: ->
    if @selectAppPath[0].checked
      @isChameleonProject = true
      pathM.join @selectProject.val().trim(),'modules'
    else
      @isChameleonProject = false
      @modulePath.html().trim()

  serialize: ->

  findProject: ->
    projects = []
    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    if projectNum isnt 0
      projectPaths.forEach (path,i) ->
        configPath = pathM.join path,desc.projectConfigFileName
        projects.push path if yes is Util.isFileExist configPath,'sync'
    return projects

  getModuleInfo: ->
    modulePath = @getPath()
    info =
      mainEntry: desc.mainEntryFileName
      moduleId: @moduleId.getText()
      moduleName: @moduleName.getText()
      modulePath: modulePath
      isChameleonProject:@isChameleonProject

  openFolder: (e) ->
    console.log 'openFolder'
    el = e.currentTarget
    if el.classList.contains(disabled) is true
      return
    atom.pickFolder (paths) =>
      if paths?
        path = paths[0]
        selectEl = @selectProject[0]
        console.log "select path:#{path}"
        if el is selectEl
          if @checkProjectPath(path)
            for opt in selectEl.options
              console.log opt,opt.value,path,opt.value is path
              if opt.value is path
                opt.selected = true
                return
            @selectProject.find('option[value=""]').remove()
            @setSelectItem path,null,null,true,true
          else
            alert desc.selectProjectPath
            @selectProject[0].selectedIndex = 0
        else
          @modulePath.html path
          @checkPath()
      else
        @selectProject[0].selectedIndex = 0


  onSelectChange: (e) ->
    el = e.currentTarget
    console.log el.value
    if el.value is 'other'
      @openFolder(e)
    @checkPath()

  checkProjectPath: (path) ->
    result = null
    configPath = pathM.join path,desc.projectConfigFileName
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
      isProject = @modulePath.isProject = @checkProjectPath projectPath
      projectPath = pathM.join projectPath,'modules' if isProject


      path = pathM.join projectPath,path
      console.log path
      dir = new Directory(path);
      dir.exists()
        .then (isExists) =>
          console.log isExists,@errorMsg
          unless isExists
            @errorMsg.addClass('hide')
          else
            @errorMsg.removeClass('hide')
          @checkInput()


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
