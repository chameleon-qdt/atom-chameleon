{Emitter} = require 'atom'
_ = require 'underscore-plus'
desc = require './text-description'
{$, View} = require 'atom-space-pen-views'

module.exports =
class ChameleonBoxView extends View

  modalPanel : null

  @content : (options) ->
    @div class: 'chameleon', =>
      @h1 (options.title if options?), class: 'box-title', outlet: 'title'
      @span class: 'icon icon-remove-close close-view', outlet: 'closeBtn', click: 'onCloseClick'
      @div class: 'box', outlet: 'contentBox', =>
        if options?
          @subview  'contentView', options.subview
      @div class: 'clearfix', =>
        @button desc.cancel, class: 'btn cancel pull-left', outlet: 'cancelBtn', click: 'onCancelClick'
        @button desc.next, class: 'btn next pull-right', outlet: 'nextBtn', click: 'onNextClick'
        @button desc.prev, class: 'btn prev pull-right', outlet: 'prevBtn', click: 'onPrevClick'


  initialize: (options) ->
    console.log options,@options
    @order = 0
    @options ?= {}
    @prevStep = []
    @emitter = new Emitter
    @options = options = _.extend @options,options

  attached: ->
    @_refresh()
    @

  destroy: ->
    @emitter.dispose()
    @remove()

  _refresh: ->
    console.log 'refresh...'
    @_destroyCurrentStep()
    # @options.subviews[@order]
    @setPrevBtn()
    @setNextBtn()
    @title.text @options.title
    @contentView =  @options.subview
    @contentView.parentView = @
    @contentBox.append(@contentView)

  getElement: ->
    @element

  _destroyCurrentStep: ->
    @contentView.destroy?() or @contentView.remove?() if @contentView

  move: ->
    @element.parentElement.classList.add('down')

  mergeOptions: (options) ->
    _.extend @options, options

  setPrevStep:(prevStep) ->
    @prevStep.unshift prevStep
    @prevStep

  getPrevStep: ->
    @prevStep.shift()

  onCloseClick: ->
    @closeView()

  onCancelClick: ->
    @closeView()

  onNextClick: ->
    @contentView.nextStep(@);

  onPrevClick: ->
    @order--
    console.log @options,@prevStep
    @mergeOptions {subview:prevView} if prevView = @getPrevStep()
    @_refresh()

  onFinish: (callback) ->
    @emitter.on 'finish', callback

  nextStep: ->
    if @nextBtn.hasClass 'finish'
      @emitter.emit 'finish', @options
    else
      @order++
      @_refresh(@options)


  setNextBtn: (type = 'normal') ->
    if type is 'finish'
      @nextBtn.text(desc.finish).addClass('finish')
    else
      @nextBtn.text(desc.next).removeClass('finish')
    @showNextBtn()

  setPrevBtn: (type = 'normal') ->
    if type is 'back'
      @prevBtn.text(desc.back).addClass('back')
    else
      @prevBtn.text(desc.prev).removeClass('back')
    @showPrevBtn()

  enableNext: ->
    @nextBtn.prop 'disabled', false

  disableNext: ->
    @nextBtn.prop 'disabled', true

  showNextBtn: ->
    @nextBtn.removeClass 'hide'

  hideNextBtn: ->
    @nextBtn.addClass 'hide'

  showPrevBtn: ->
    @prevBtn.removeClass 'hide'

  hidePrevBtn: ->
    @prevBtn.addClass 'hide'

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @hide()
