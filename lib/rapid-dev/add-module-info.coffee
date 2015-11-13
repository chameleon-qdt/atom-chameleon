AddModuleInfoView = require './add-module-info-view'
Builder = require '../QDT-Builder/builder'


module.exports = AddModuleInfo =

  activate: (path) ->
    @chameleonBox = new AddModuleInfoView(path)
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()
    @chameleonBox.onFinish (options) => @openBuilder(options)

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    @chameleonBox.openView()

  openBuilder: (options) ->
    Builder.activate(options.moduleInfo)
    @chameleonBox.closeView()
