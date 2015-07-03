{$, View} = require 'atom-space-pen-views'

module.exports =
class CodePanel extends View
  @content: ->
    @div =>
    	@h2 '已下载框架', =>
    		@span class: 'icon icon-repo'
    	@div class: 'codePack-card', =>
    		@h3 'butterfly-slim'