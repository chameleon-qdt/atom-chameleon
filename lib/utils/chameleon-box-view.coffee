_ = require 'underscore-plus'
desc = require './text-description'
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChameleonBoxView extends View

  modalPanel : null

  @content : (params) ->
    @div class: 'chameleon', =>
      @h1 desc.headtitle, class: 'box-title', outlet: 'title'
      @span class: 'icon icon-remove-close close-view', outlet: 'closeBtn', click: 'onCloseClick'
      @div class: 'box', outlet: 'content-box', =>
        if params.subview?
          @subview 'contentView', params.subview
      @div class: 'clearfix', =>
        @button desc.cancel, class: 'btn cancel pull-left', outlet: 'cancelBtn', click: 'onCancelClick'
        @button desc.next, class: 'btn next pull-right', outlet: 'nextBtn', click: 'onNextClick'
        @button desc.prev, class: 'btn prev pull-right', outlet: 'prevBtn', click: 'onPrevClick'


  initialize: (params) ->
    defaultOpt =
      title: desc.headtitle

    params = _.extend defaultOpt,params
    console.log params
    @title.text params.title

  setTitle: (title)->
    @title.text title

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  getElement: ->
    @element

  attached: ->

  move: ->
    @element.parentElement.classList.add('down')

  onCloseClick: ->

  onCancelClick: ->
    console.log 'onCancelClick'

  onNextClick: ->

  onPrevClick: ->
