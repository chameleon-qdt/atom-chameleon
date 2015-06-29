{$, View} = require 'atom-space-pen-views'

module.exports =
class ProgressBarView extends View

	@content: ->
    @div class: 'block', =>
    	@progress class: 'inline-block', =>
		  	@span 'Indeterminate', class: 'inline-block'
