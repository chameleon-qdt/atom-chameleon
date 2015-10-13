Path = require 'path'
desc = require '../utils/text-description'
Util = require '../utils/util'
{$, TextEditorView, View} = require 'atom-space-pen-views'


module.exports =
class CreateModuleTypeView extends View

  @content: (params) ->
    @div class: 'create-module-type', =>
        @h2 '请选择要创建的模块类型:'
        @div class: 'flex-container', =>
          @div class: 'frameList', outlet:'frameList', =>
            @div class: 'new-item text-center', 'data-type': 'empty',  =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_empty.png'
              @h3 '空白模块',class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'simple', =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_frame.png'
              @h3 '快速开发模板',class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'template',  =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_template.png'
              @h3 '已有模块模版',class: 'project-name'

  attached: ->
    @frameworks = [];
    @findFrameworks()
    @parentView.disableNext()
    $('.new-item').on 'click',(e) => @onItemClick(e)



  getElement: ->
    @element

  onItemClick: (e) ->
    el = e.currentTarget
    $('.new-item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    if @createType is 'empty'
      @parentView.setNextBtn('finish')
    else
      @parentView.setNextBtn()

    switch @createType
      when 'empty' then @parentView.setNextBtn 'finish'
      when 'simple'
        @parentView.setNextBtn()
      when 'template'
        console.log @frameworks
        if @frameworks.length > 1
          @parentView.setNextBtn()
        else
          if @frameworks.length is 0
            el.dataset.src = desc.defaultModule
          else
            el.dataset.src = @frameworks[0].folderName
          @parentView.setNextBtn 'finish'
    @parentView.enableNext()

  nextStep:(box) ->
    box.setPrevStep @
    source = $('.select[data-type=template]').attr('data-src')
    params =
      createType:@createType
    params.source = source if source?
    if params.createType is 'simple'
      params.subview = null
    else if params.createType is 'template' and params.source? is no
      params.frameworks = @frameworks
      params.subview = require './select-module-template-view'
    box.mergeOptions params
    box.nextStep()

  findFrameworks: ->
    # fp = Path.join desc.chameleonHome,'empty'
    fp = desc.getFrameworkPath()
    Util.readDir fp, (err,files) =>
      return console.error err if err
      files.forEach (file,i) =>
        configPath = Path.join fp,file,desc.moduleConfigFileName
        Util.readJson configPath, (err,json) =>
          # return console.error err if err
          unless err
            obj =
              dataName:json.name
              folderName: file
            @frameworks.push(obj)
            # @pageSize = Math.ceil(@frameworks.length/3)
