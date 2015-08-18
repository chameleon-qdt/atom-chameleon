{$,View} = require 'atom-space-pen-views'
desc = require './../utils/text-description'
infoView = require './new-project-info'
_ = require 'underscore-plus'
config = require '../../config/config'
module.exports =
  class SelectTemplate extends View
    @content: ->
      @div class: 'new-project', =>
        @h2 '请选择业务模板:'
        @div class: 'col-sm-12 col-md-12', outlet:'template', =>
          @div class: 'new-template text-center', 'data-type': desc.newsTemplate.type, click: 'onItemClick',  =>
            @img class: 'pic', src: desc.newsTemplate.pic
            @h3 desc.newsTemplate.name, class: 'project-name'
        @div class: 'col-sm-12 col-md-12', outlet:'show-template', =>
          @div class : 'template-item text-center', =>
            @img class: 'pic', src: desc.getImgPath '3.jpeg'
          @div class : 'template-item text-center', =>
            @img class: 'pic', src: desc.getImgPath '8.jpeg'
          @div class : 'template-item text-center', =>
            @img class: 'pic', src: desc.getImgPath '5.jpg'

    attached: ->
      # console.log @
      @parentView.disableNext()

    getElement: ->
      @element

    nextStep:(box) ->
      nextStepView = new infoView()
      box.setPrevStep @
      box.mergeOptions {subview:nextStepView, tmpType: @createType}
      box.nextStep()

    onItemClick: (e, el) ->
      $('.new-template.select').removeClass 'select'
      el.addClass 'select'
      @createType = el.data('type')
      @parentView.enableNext()
