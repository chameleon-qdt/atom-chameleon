{ScrollView} = require 'atom-space-pen-views'

module.exports =
class ChameleonSettingsView extends ScrollView
  @content: ->
    @div class: 'chameleonsettingsview pane-item native-key-bindings', tabindex: -1, =>
      @p 'chameleonsettings'

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  getURI: -> @uri

  getTitle: -> 'chameleonsettings'

  initialize: ({@uri}) ->
    console.log @uri