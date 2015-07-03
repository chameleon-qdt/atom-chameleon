{$, View} = require 'atom-space-pen-views'

module.exports =
class CodePanel extends View
  @content: ->
    @div =>
    	@div class: 'codePack-card', style: 'max-width: 60em'