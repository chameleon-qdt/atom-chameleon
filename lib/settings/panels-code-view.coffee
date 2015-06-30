{$, View} = require 'atom-space-pen-views'

module.exports =
class CodePanel extends View
  @content: ->
    @p 'code'