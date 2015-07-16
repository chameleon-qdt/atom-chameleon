{Emitter} = require 'atom'
_ = require 'underscore-plus'
desc = require './text-description'
{$, View} = require 'atom-space-pen-views'

module.exports = ChameleonBox =
class ChameleonBoxView extends View

  modalPanel : null
  enable : true

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
    # console.log options,@options
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
    if @prevBtn.hasClass('other')
      @contentView.prevStep(@);
    else
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


  setNextBtn: (type = 'normal',text) ->
    if type is 'finish'
      text?=desc.finish
      @nextBtn.text(text).addClass('finish')
    else
      text?=desc.next
      @nextBtn.text(text).removeClass('finish')
    @showNextBtn()

  setPrevBtn: (type = 'normal',text) ->
    if type is 'back'
      text?=desc.back
      @prevBtn.text(text).addClass('back')
    else
      text?=desc.prev
      @prevBtn.text(text).removeClass('back')
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

    # console.log @modalPanel,atom.workspace.getModalPanels(),@,atom.workspace.getModalPanels()[0].item is @
    # console.dir @element.parentElement
    @findModalPanel()
    # console.log @modalPanel,@modalPanel?.isVisible()
    if @modalPanel?.isVisible()
      @modalPanel.hide()
    else unless @modalPanel?
      @hide()

  openView: ->
    if @enable isnt yes
      return
    @findModalPanel()
    if @modalPanel?.isVisible() is no
      @modalPanel.show()
      return @modalPanel.isVisible()
    else
      return false

  findModalPanel: ->
    @modalPanel?= _.find atom.workspace.getModalPanels(), (modalPanel) =>
      # console.log modalPanel.item,@,modalPanel.item is @
      return modalPanel.item is @



module.exports.$ = $
