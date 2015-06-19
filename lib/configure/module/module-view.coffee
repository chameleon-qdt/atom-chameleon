{$,View} = require 'atom-space-pen-views'

module.exports =
	class ModuleView extends View
		@content: ->
			@div class: 'container', =>
				@label '选择要配置的模块'
				@div class: 'col-md-12', =>
			  	@div class: 'col-md-3', =>
				 		@input type:'checkbox'
				 		@label  "模块A" ,style:'font-size:12px;padding-bottom:2px'
			  	@div class:'col-md-3', =>
						@input type:'checkbox'
						@label  "模块A" ,style:'font-size:12px;padding-bottom:2px'
					@div class:'col-md-3', =>
						@input type:'checkbox'
						@label  "模块A" ,style:'font-size:12px;padding-bottom:2px'

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
		destroy: ->

		onCloseClick: ->

		onCancelClick: ->
		  console.log 'onCancelClick'
