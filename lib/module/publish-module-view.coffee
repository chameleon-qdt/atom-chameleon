desc = require '../utils/text-description'
{$,TextEditorView,View} = require 'atom-space-pen-views'

module.exports =
	class PublishModuleView extends View
		@content: ->
			@div class : 'publishModule', =>
				@div outlet : 'first' , =>
					@h2 desc.publishModulePageOneTitle
					@div class : 'col-md-12', =>
						@div class : 'col-md-2', =>
						@div class : 'col-md-3',=>
							@input type : 'checkbox', name : ''
							@label '列表'
						@div class : 'col-md-3', =>
							@input type : 'checkbox', name : ''
							@label '二维码'
						@div class : 'col-md-3', =>
							@input type : 'checkbox', name : ''
							@label '投票'
				@div outlet : 'second',class : 'hide', =>
					@h2 desc.publishModulePageTwoTitle
					@div class: 'col-md-12', =>
						@label '模块名称 : '
						@label '二维码'
					@div class : 'col-md-12', =>
						@div class : 'col-md-6', =>
							@label '上传版本 : '
							@label '0.0.1'
						@div class : 'col-md-6', =>
							@label '服务器版本 : '
							@label '0.0.0'
					@div class : 'col-md-12', =>
						@label '更新日志 : '
						@div class : 'col-md-4', =>
							@subview 'uploadFile', new TextEditorView(mini: true,placeholderText: 'password...')
						@button '上传'
						@button '上传并应用'
						@br
					@div class : 'col-md-12', =>
						@label '模块列表 : '
						@label '列表'
					@div class : 'col-md-12', =>
						@div class : 'col-md-6', =>
							@label '上传版本 : '
							@label '0.0.1'
						@div class : 'col-md-6', =>
							@label '服务器版本 : '
							@label '0.0.0'
					@div class : 'col-md-12', =>
						@label '更新日志 : '
						@div class : 'col-md-4', =>
							@subview 'uploadFile', new TextEditorView(mini: true,placeholderText: 'password...')
						@button '上传'
						@button '上传并应用'

		prevStep: ->
			console.log 'click prev button'
			@first.removeClass('hide')
			@second.addClass('hide')
			@parentView.prevBtn.addClass('hide')
			@parentView.nextBtn.text('下一步')


		nextStep: ->
			console.log 'click next button'
			if @parentView.prevBtn.hasClass('hide')
				@second.removeClass('hide')
				@first.addClass('hide')
				@parentView.prevBtn.removeClass('hide')
				@parentView.nextBtn.text('取消')
