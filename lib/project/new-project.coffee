Path = require 'path'
desc = require '../utils/text-description'
Util = require '../utils/util'
infoView = require './new-project-info'
SelectTemplate = require './select-template-view'
{$, TextEditorView, View} = require 'atom-space-pen-views'


module.exports =
class NewProjectView extends View

  @content: (params) ->
    @div class: 'new-project', =>
        @h2 '请选择要创建的项目类型:'
        @div class: 'flex-container', =>
          @button class:'btn btn-lg btn-action', outlet: 'prevPage', =>
            @span class: 'icon icon-chevron-left'
          @div class: 'frameList', outlet:'frameList', =>
            @div class: 'new-item text-center', 'data-type': 'empty',  =>
              @img class: 'pic', src:desc.iconPath
              @h3 '空白项目',class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'frame', =>
              @img class: 'pic', src: desc.iconPath
              @h3 '自带框架项目',class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'template',  =>
              @img class: 'pic', src: desc.iconPath
              @h3 '业务模板',class: 'project-name'
            @div outlet:'divider'
          @button class:'btn btn-lg btn-action',outlet: 'nextPage', =>
            @span class: 'icon icon-chevron-right'

  attached: ->
    @findFrameworks()
    @parentView.setPrevBtn('back')
    @parentView.disableNext()

    $('.new-item').on 'click',(e) => @onItemClick(e)

  getElement: ->
    @element

  onItemClick: (e) ->
    el = e.currentTarget
    $('.new-item.select').removeClass 'select'
    el.classList.add 'select'
    @newType = el.dataset.type
    @parentView.enableNext()

  nextStep:(box) ->
    if @newType is 'template'
      nextStepView = new SelectTemplate()
    else
      nextStepView = new infoView()
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView,newType:@newType}
    box.nextStep()

  findFrameworks: ->
    # fp = Path.join desc.chameleonHome,'empty'
    fp = desc.getFrameworkPath()
    Util.readDir fp, (err,files) =>
      return console.error err if err
      files.forEach (file) =>
        unless file is '.githolder'
          configPath = Path.join fp,file,desc.moduleConfigFileName
          Util.readJson configPath, (err,json) =>
            # return console.error err if err
            unless err
              @addFrameworkItem(json)

  addFrameworkItem:(json) ->
    html = @renderListItem 'frame',json.name,json.name
    @frameList.append html

  renderListItem: (type,dataName,displayName,icon) ->
    icon?=desc.iconPath
    """
    <div class="new-item text-center" data-type="#{type}" data-name="#{dataName}">
      <img class="pic" src="#{icon}">
      <h3 class="project-name">#{displayName}</h3>
    </div>
    """
