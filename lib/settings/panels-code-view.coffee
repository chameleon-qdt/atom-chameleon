{$, View} = require 'atom-space-pen-views'

module.exports =
class CodePanel extends View
  @content: ->
    @div class: 'code-view', =>
      @div class: 'frameworkList', =>
        @header class: 'code-panel-header', =>
          @h2 '框架', =>
            @span class: 'icon icon-repo'
          @button class: 'btn icon icon-plus addNewCode', '添加'
        @div class: 'codePack-card', =>
          @h2 'butterflyjs'
          @p 'version: 1.0.0'
          @p 'butterfly.js grunt product'
          @div class: 'btn-group', =>
            @button class: 'btn icon icon-cloud-download inline-block', '更新'
            @button class: 'btn icon icon-trashcan inline-block', '删除'
      @div class: 'tempList', =>
        @header class: 'code-panel-header', =>
          @h2 '模板', =>
            @span class: 'icon icon-file-code'
          @button class: 'btn icon icon-plus addNewCode', '添加'
        @ul =>
          @li class: 'codePack-card', =>
            @h2 =>
              @a '新闻模板', href: 'http://www.baidu.com'
            @p 'version: 1.0.0'
            @p 'butterfly.js grunt product'
            @div class: 'btn-group', =>
              @button class: 'btn icon icon-cloud-download inline-block', '更新'
              @button class: 'btn icon icon-trashcan inline-block', '删除'
          @li class: 'codePack-card', =>
            @h2 =>
              @a '新闻模板', href: 'http://www.baidu.com'
            @p 'version: 1.0.0'
            @p 'butterfly.js grunt product'
            @div class: 'btn-group', =>
              @button class: 'btn icon icon-cloud-download inline-block', '更新'
              @button class: 'btn icon icon-trashcan inline-block', '删除'
          @li class: 'codePack-card', =>
            @h2 =>
              @a '新闻模板', href: 'http://www.baidu.com'
            @p 'version: 1.0.0'
            @p 'butterfly.js grunt product'
            @div class: 'btn-group', =>
              @button class: 'btn icon icon-cloud-download inline-block', '更新'
              @button class: 'btn icon icon-trashcan inline-block', '删除'