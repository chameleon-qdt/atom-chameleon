Path = require 'path'
desc = require '../utils/text-description'
Util = require '../utils/util'
infoView = require './new-project-info'
SelectTemplate = require './select-template-view'
{$, TextEditorView, View} = require 'atom-space-pen-views'


module.exports =
class NewProjectView extends View

  frameworks: []

  @content: (params) ->
    @div class: 'new-project', =>
        @h2 '请选择要创建的应用类型:'
        @div class: 'flex-container', =>
          @button class:'btn btn-lg btn-action', outlet: 'prevPage',click: 'onPrevPageClick', =>
            @img src: desc.getImgPath 'arrow_left.png'
          @div class: 'frameList', outlet:'frameList', =>
            @div class: 'new-item text-center', 'data-type': 'empty',  =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_empty.png'
              @h3 '空白应用',class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'frame', =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_frame.png'
              @h3 '自带框架应用',class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'template',  =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_template.png'
              @h3 '业务模板',class: 'project-name'
            @div outlet:'divider'
          @button class:'btn btn-lg btn-action',outlet: 'nextPage',click: 'onNextPageClick', =>
            @img src: desc.getImgPath 'arrow_right.png'

  attached: ->
    @disableNextPage()
    @disablePrevPage()
    @pageIndex = 0;
    @pageSize = 1;
    @frameworks =
      [
        {
          icon: desc.getImgPath 'icon_empty.png'
          dataName:''
          displayName: '空白应用'
          type: 'empty'
        },
        {
          icon: desc.getImgPath 'icon_frame.png'
          dataName:''
          displayName: '自带框架应用'
          type: 'frame'
        },
        {
          icon: desc.getImgPath 'icon_template.png'
          dataName: ''
          displayName: '业务模板'
          type: 'template'
        }
      ]
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
    @name = el.dataset.name
    @parentView.enableNext()

  onPrevPageClick: (e) ->
    @frameList.empty()
    @pageIndex--
    @disablePrevPage() if @pageIndex is 0
    @enableNextPage() if @nextPage.prop('disabled') is yes
    # console.log @pageIndex*3,@pageIndex,@pageSize,@frameworks,@frameworks[3]
    @addFrameworkItems()

  onNextPageClick: (e) ->
    @frameList.empty()
    @pageIndex++
    @disableNextPage() if @pageIndex is @pageSize-1
    @enablePrevPage() if @prevPage.prop('disabled') is yes
    # console.log @pageIndex*3,@pageIndex,@pageSize,@frameworks,@frameworks[3]
    @addFrameworkItems()

  nextStep:(box) ->
    if @newType is 'template'
      nextStepView = new SelectTemplate()
    else
      nextStepView = new infoView()
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView,newType:@newType,name:@name}
    box.nextStep()

  findFrameworks: ->
    # fp = Path.join desc.chameleonHome,'empty'
    fp = desc.getFrameworkPath()
    Util.readDir fp, (err,files) =>
      return console.error err if err
      files.forEach (file,i) =>
        unless file is '.githolder' or file is 'butterfly-tiny' or file is '.gitkeep'
          configPath = Path.join fp,file,desc.moduleConfigFileName
          Util.readJson configPath, (err,json) =>
            # return console.error err if err
            unless err
              obj =
                dataName: json.name
                displayName:json.name
                type: 'frame'
              @frameworks.push(obj)
              @enableNextPage() if @nextPage.prop('disabled') is yes
              @pageSize = Math.ceil(@frameworks.length/3)

  addFrameworkItems: ->
    item1 = @frameworks[@pageIndex*3+0]
    item2 = @frameworks[@pageIndex*3+1]
    item3 = @frameworks[@pageIndex*3+2]
    @renderListItem item1 if item1?
    @renderListItem item2 if item2?
    @renderListItem item3 if item3?
    $('.new-item').on 'click',(e) => @onItemClick(e)


  renderListItem: (data) ->
    data.icon?=desc.getImgPath 'icon_template.png'
    html = """
    <div class="new-item text-center" data-type="#{data.type}" data-name="#{data.dataName}">
      <div class="itemIcon">
        <img src="#{data.icon}">
      </div>
      <h3 class="project-name">#{data.displayName}</h3>
    </div>
    """
    @frameList.append html


  enableNextPage: ->
    @nextPage.prop 'disabled',false

  disableNextPage: ->
    @nextPage.prop 'disabled',true

  enablePrevPage: ->
    @prevPage.prop 'disabled',false

  disablePrevPage: ->
    @prevPage.prop 'disabled',true
