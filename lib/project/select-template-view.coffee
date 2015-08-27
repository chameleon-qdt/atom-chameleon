{$,View} = require 'atom-space-pen-views'
desc = require './../utils/text-description'
infoView = require './new-project-info'
_ = require 'underscore-plus'
config = require '../../config/config'
module.exports =
class SelectTemplate extends View
  @content: ->
    @div class: 'new-project template', =>
      @h2 '请选择业务模板:'
      @div class: 'flex-container ', =>
        @div class: 'frameList', outlet:'projectList', =>
          @div class: 'new-item text-center', projectId: 'data.identifier', click: 'onItemClick', =>
            @div class: 'itemIcon', =>
              @img src: desc.getImgPath 'icon.png'
            @h3 config.tempList[0].name, class: 'project-name'
      @div class: 'flex-container', =>
        @button class:'btn btn-lg btn-action', outlet: 'prevPage', click: 'onPrevPageClick', disabled: true, =>
          @img src: desc.getImgPath 'arrow_left.png'
        @div class: 'frameList', outlet:'thumbList'
        @button class:'btn btn-lg btn-action',outlet: 'nextPage', click: 'onNextPageClick', disabled: true, =>
          @img src: desc.getImgPath 'arrow_right.png'

  pageSize: 4
  currentIndex: 1
  thumbsList: config.tempList[0].thumbnail

  attached: ->
    # console.log @
    @parentView.disableNext()
    @renderThumbList()

  getElement: ->
    @element

  nextStep:(box) ->
    nextStepView = new infoView()
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView, tmpType: @createType}
    box.nextStep()

  renderThumbList: () ->
    thumbs = @thumbsList.slice( @currentIndex * @pageSize - @pageSize, @currentIndex * @pageSize)
    @thumbList.html('')
    thumbs.forEach (url)=>
      thumbItem = new thumbnail(url)
      @thumbList.append(thumbItem)
    @canClick()

  canClick: () ->
    pageNum = Math.ceil(@thumbsList.length/@pageSize)
    if @currentIndex < pageNum
      @enableClick('nextPage')
    else
      @disabledClick('nextPage')

    if @currentIndex > 1
      @enableClick('prevPage')
    else
      @disabledClick('prevPage')

  enableClick: (direction) ->
    dom = if direction is 'prevPage' then @prevPage else @nextPage
    dom.removeAttr('disabled')

  disabledClick: (direction) ->
    dom = if direction is 'prevPage' then @prevPage else @nextPage
    dom.attr('disabled', true)

  onNextPageClick: () ->
    @currentIndex++
    @renderThumbList()
    
  onPrevPageClick: () ->
    @currentIndex--
    @renderThumbList()

  onItemClick: (e, el) ->
    $('.new-item.select').removeClass 'select'
    el.addClass 'select'
    @createType = el.data('type')
    @parentView.enableNext()

class thumbnail extends View
  @content: (url) ->
    @div class: 'temp-pic', =>
      @img src: url
