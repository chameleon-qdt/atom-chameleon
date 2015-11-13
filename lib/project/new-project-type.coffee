# CmdView = require '../utils/cmd-view'
desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
syncProjectView = require './sync-project'
newProjectView = require './new-project'
ChameleonBox = require '../utils/chameleon-box-view'
SelectTemplate = require './select-template-view'
newProjectView = require './new-project'
Util = require '../utils/util'

module.exports =
class NewProjectType extends View

  v:
    newFramework:newProjectView
    newTemplate:SelectTemplate

  @content: ->
    @div class: 'create-project container', =>
      @h2 "#{desc.createAppType}:"
      @div class: 'row',outlet: 'main', =>
        @div class: 'col-xs-6', =>
          @div class: 'item new-project text-center', 'data-type':'newFramework', =>
            @div class: 'itemIcon', =>
              @img src: desc.getImgPath 'icon_frame.png'
            @h3 desc.appFrameworks, class: 'title'
            # @div class: 'desc', desc.createLocalAppDesc
        @div class: 'col-xs-6', =>
          @div class: 'item sync-project text-center', 'data-type':'newTemplate', =>
            @div class: 'itemIcon', =>
              @img src: desc.getImgPath 'icon_template.png'
            @h3 desc.appTemplate, class: 'title'
            # @div class: 'desc', desc.syncAccountAppDesc

  attached: ->
    @parentView.disableNext()
    # @parentView.hidePrevBtn()
    $('.item.select').removeClass 'select'
    $('.item').on 'click', (e) => @onTypeItemClick(e)

  destroy: ->
    @element.remove()

  getElement: ->
    @element

  onTypeItemClick: (e) ->
    el = e.currentTarget
    $('.item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    @parentView.enableNext()

  nextStep: (box)->
    nextStepView = @v[@createType]
    box.setPrevStep @
    box.mergeOptions {subview: nextStepView}
    box.nextStep()
