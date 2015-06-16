# CmdView = require '../utils/cmd-view'
desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'

module.exports =
class CreateProjectView extends View

  @content: ->
    @div class: 'create-project container', =>
      @div class: 'frist-step row',outlet: 'fristStep', dataStep: '1', =>
        @div class: 'col-sm-6 col-md-6', =>
          @div class: 'item new-project text-center', =>
            @img class: 'pic', src: 'atom://chameleon/images/icon.png'
            @h3 desc.newProject, class: 'title'
            @div class: 'desc', '创建一个本地应用'
        @div class: 'item col-sm-6 col-md-6', =>
          @div class: 'sync-project text-center', =>
            @img class: 'pic', src: 'atom://chameleon/images/icon.png'
            @h3 desc.syncProject, class: 'title'
            @div class: 'desc', '同步已登录账户中的项目到本地，未登录的用户请登录'

  serialize: ->

  initialize: ->

  # Tear down any state and detach
  # destroy: ->
  #   if @modalPanel?
  #     @modalPanel.destroy()
  #   @element.remove()
  #
  getElement: ->
    @element

  move: ->
    @element.parentElement.classList.add('down')
