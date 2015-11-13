desc = require '../utils/text-description'
# ModuleInfoView = require './create-module-info-view'
ModuleTypeView = require './create-module-type-view'
ChameleonBox = require '../utils/chameleon-box-view'

module.exports =
class CreateModuleView extends ChameleonBox

  options :
    title : desc.createModule
    begining: ModuleTypeView
    subview : new ModuleTypeView()
