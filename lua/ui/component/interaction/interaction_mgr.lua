local InteractionBtn = require("ui.component.interaction.interaction_btn_base")
local interactionData = Z.DataMgr.Get("interaction_data")
local InteractionBtnDic = {
  [Z.EInteractionBtnType.EBase] = InteractionBtn,
  [Z.EInteractionBtnType.EDungeon] = InteractionBtn,
  [Z.EInteractionBtnType.EHeroNormalDungeon] = InteractionBtn,
  [Z.EInteractionBtnType.EHeroChallengeDungeon] = InteractionBtn,
  [Z.EInteractionBtnType.EOptionSelect] = require("ui.component.interaction.interaction_btn_option_select"),
  [Z.EInteractionBtnType.EStaticObj] = require("ui.component.interaction.interaction_btn_static_obj")
}
local asyncInitInteraction = function(uiData)
  local btnType = uiData.btnType
  local handleData = InteractionBtnDic[btnType].new()
  interactionData:AddData(handleData)
  handleData:AsyncInit(uiData, btnType)
  interactionData:SortData()
  Z.EventMgr:Dispatch(Z.ConstValue.RefreshOption)
end
local ret = {AsyncInitInteraction = asyncInitInteraction}
return ret
