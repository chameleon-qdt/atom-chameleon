desc = require '../utils/text-description'
ModuleInfoView = require './create-module-info-view'
ChameleonBox = require '../utils/chameleon-box-view'

module.exports =
class CreateModuleView extends ChameleonBox

  options :
    title : desc.createModule
    begining: ModuleInfoView
    subview : new ModuleInfoView()
