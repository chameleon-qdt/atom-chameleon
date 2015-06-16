CmdView = require '../utils/cmd-view'
{$, View} = require 'atom-space-pen-views'

module.exports =
class CreateProjectView extends View

  @content: ->
    @div 'subView', class: 'subView', =>

  serialize: ->

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
