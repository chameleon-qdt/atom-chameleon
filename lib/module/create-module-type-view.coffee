Path = require 'path'
desc = require '../utils/text-description'
Util = require '../utils/util'
ModuleInfoView = require './create-module-info-view'
{$, TextEditorView, View} = require 'atom-space-pen-views'


module.exports =
class CreateModuleTypeView extends View

  @content: (params) ->
    @div class: 'create-module-type', =>
        @h2 "#{desc.createModuleType}:"
        @div class: 'flex-container', =>
          @div class: 'frameList', outlet:'frameList', =>
            @div class: 'new-item text-center', 'data-type': 'empty',  =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_empty.png'
              @h3 desc.emptyModule,class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'simple', =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_quick.png'
              @h3 desc.simpleMoudle,class: 'project-name'
            @div class: 'new-item text-center', 'data-type': 'template',  =>
              @div class: 'itemIcon', =>
                @img src: desc.getImgPath 'icon_template.png'
              @h3 desc.defaultTemplateModule,class: 'project-name'

  attached: ->
    @frameworks = [];
    @findFrameworks()
    @parentView.disableNext()
    @on 'click', '.new-item',(e) => @onItemClick(e)



  getElement: ->
    @element

  onItemClick: (e) ->
    el = e.currentTarget
    $('.new-item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    # if @createType is 'template'
    #   if @frameworks.length is 0
    #     el.dataset.src = desc.defaultModuleName
    #   if @frameworks.length is 1
    #     el.dataset.src = @frameworks[0].folderName
    @parentView.enableNext()
    @parentView.disableNext() if @createType is 'simple'

  nextStep:(box) ->
    box.setPrevStep @
    source = $('.select[data-type=template]').attr('data-src')
    params =
      createType:@createType
      subview:ModuleInfoView
    # params.source = source if source?
    # if params.createType is 'template' and params.source? is no

    if params.createType is 'template'
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
