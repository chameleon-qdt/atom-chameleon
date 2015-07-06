
{$,TextEditorView,View} = require 'atom-space-pen-views'
desc = require './../utils/text-description'
module.exports =
	class SelectTemplate extends View
		@content: ->
			@div class: 'new-project', =>
				@h2 '创建业务模板:'
				@div class: 'col-sm-12 col-md-12', outlet:'template', =>
					@div class: 'new-template text-center', 'data-type': 'empty',  =>
						@img class: 'pic', src:'atom://chameleon-qdt-atom/images/1.jpeg'
						@h3 '电商',class: 'project-name'
					@div class: 'new-template text-center', 'data-type': 'empty',  =>
						@img class: 'pic', src:'atom://chameleon-qdt-atom/images/2.jpg'
						@h3 '新闻',class: 'project-name'
				@div class: 'col-sm-12 col-md-12', outlet:'show-template', =>
					@div class : 'template-item text-center', 'data-type' : 'empty', =>
						@img class: 'pic', src:'atom://chameleon-qdt-atom/images/3.jpeg'
					@div class : 'template-item text-center', 'data-type' : 'empty', =>
						@img class: 'pic', src:'atom://chameleon-qdt-atom/images/8.jpeg'
					@div class : 'template-item text-center', 'data-type' : 'empty', =>
						@img class: 'pic', src:'atom://chameleon-qdt-atom/images/5.jpg'

    initialize: ->
			# 调获取样板的接口  获取 样板列表
			temp =
				count : 2
				
			console.log temp
