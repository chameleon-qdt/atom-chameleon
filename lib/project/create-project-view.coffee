# CmdView = require '../utils/cmd-view'
desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
syncProjectView = require './sync-project'
NewProjectType = require './new-project-type'
ChameleonBox = require '../utils/chameleon-box-view'
Util = require '../utils/util'

# module.exports =
class CreateOrSynchronize extends View

  v:
    syncProject:syncProjectView
    newProject:NewProjectType

  @content: ->
    @div class: 'create-project container', =>
      @h2 "#{desc.createAppType}:"
      @div class: 'row',outlet: 'main', =>
        @div class: 'col-xs-6', =>
          @div class: 'item new-project text-center', 'data-type':'newProject', =>
            @div class: 'itemIcon', =>
              @img src: desc.getImgPath 'icon_new.png'
            @h3 desc.newProject, class: 'title'
            @div class: 'desc', desc.createLocalAppDesc
        @div class: 'col-xs-6', =>
          @div class: 'item sync-project text-center', 'data-type':'syncProject', =>
            @div class: 'itemIcon', =>
              @img src: desc.getImgPath 'icon_sync.png'
            @h3 desc.syncProject, class: 'title'
            @div class: 'desc', desc.syncAccountAppDesc

  attached: ->
    @parentView.disableNext()
    @parentView.hidePrevBtn()
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
    if @createType is 'syncProject'
      if Util.isLogin()
        nextStepView = @v[@createType]
        box.setPrevStep @
        box.mergeOptions {subview: nextStepView}
        box.nextStep()
    else
      nextStepView = @v[@createType]
      box.setPrevStep @
      box.mergeOptions {subview: nextStepView}
      box.nextStep()

module.exports =
class CreateProjectView extends ChameleonBox

  options :
    title : desc.createProject
    begining : CreateOrSynchronize
    subview : new CreateOrSynchronize()
