{$, View} = require 'atom-space-pen-views'

module.exports =
class LoadingMask extends View

	@content: ->
    @div class: 'loading-mask', =>
    	@span class: 'loading loading-spinner-large inline-block'

	destroy: ->
    @element.remove()
