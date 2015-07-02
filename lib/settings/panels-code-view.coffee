{$, View} = require 'atom-space-pen-views'

module.exports =
class CodePanel extends View
  @content: ->
    @div class: 'container', =>
    	@div 'hi'