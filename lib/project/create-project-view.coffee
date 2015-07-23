# CmdView = require '../utils/cmd-view'
desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
syncProjectView = require './sync-project'
newProjectView = require './new-project'
ChameleonBox = require '../utils/chameleon-box-view'

# module.exports =
class CreateOrSynchronize extends View

  v:
    syncProject:syncProjectView
    newProject:newProjectView

  @content: ->
    @div class: 'create-project container', =>
      @div class: 'row',outlet: 'main', =>
        @div class: 'col-xs-6', =>
          @div class: 'item new-project text-center', 'data-type':'newProject', =>
            @img class: 'pic', src: desc.iconPath
            @h3 desc.newProject, class: 'title'
            @div class: 'desc', '创建一个本地应用'
        @div class: 'col-xs-6', =>
          @div class: 'item sync-project text-center', 'data-type':'syncProject', =>
            @img class: 'pic', src: desc.iconPath
            @h3 desc.syncProject, class: 'title'
            @div class: 'desc', '同步已登录账户中的项目到本地，未登录的用户请登录'

  attached: ->
    console.log 'c'
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
    nextStepView = new @v[@createType]()
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView}
    box.nextStep()

module.exports =
class CreateProjectView extends ChameleonBox

  options :
    title : desc.createProject
    subview : new CreateOrSynchronize()
