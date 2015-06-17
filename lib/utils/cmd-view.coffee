_ = require 'underscore-plus'
childProcess = require 'child_process'
{Emitter,BufferedNodeProcess} = require 'atom'
desc = require '../utils/text-description'
{$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class CmdView extends View

  modalPanel : null

  @content : (params) ->
    @div class: 'chameleon-cmd', =>
      @subview 'cmd', new TextEditorView(mini: true)


  initialize: (params) ->
    atom.commands.add @element,
      'core:confirm': => @confirm()
      'core:cancel': => @close()

  getElement: ->
    @element

  close: ->
    @modalPanel?.hide()

  setText: (text) ->
    @cmd.setText text

  getText: ->
    @cmd.getText()

  confirm: ->
    console.log @getText()
    @executeCommand() if @getText() isnt ""

  hasFocus: ->
    @cmd.hasFocus()

  executeCommand: (command) ->
    command = @getText() if not command?
    childProcess.exec command, (err, stdout, stderr) ->
      throw err if err
      console.log stdout
