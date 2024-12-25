local eBtnType = {
  ItemUseBtn = 1,
  ItemUseBatchBtn = 2,
  ItemComposeBtn = 3,
  EquipPutOnBtn = 4,
  EquipReplaceBtn = 5,
  ItemDecomposeBtn = 6,
  ModUninstall = 7,
  EquipRecast = 8,
  GotoModEquip = 9,
  GotoEquipView = 10,
  ExpressionItemUseBtn = 11,
  ModIntensify = 12,
  ModDecompose = 13,
  ModInstall = 14,
  ModReplace = 15,
  KeyRecast = 16,
  ItemDetailBtn = 17,
  EquipTakeOff = 18,
  ResonanceSkillMake = 19,
  ResonanceSkillDecompose = 20,
  ItemSell = 21,
  EquipRefine = 22,
  Recycle = 23,
  Discard = 24
}
local btns_ = {
  [eBtnType.ItemUseBtn] = require("ui.item_btns.item_use_btn"),
  [eBtnType.ItemUseBatchBtn] = require("ui.item_btns.item_batch_use_btn"),
  [eBtnType.ItemComposeBtn] = require("ui.item_btns.item_compose_btn"),
  [eBtnType.EquipPutOnBtn] = require("ui.item_btns.puton_equip_btn"),
  [eBtnType.ItemDecomposeBtn] = require("ui.item_btns.decompose_item_btn"),
  [eBtnType.EquipReplaceBtn] = require("ui.item_btns.replace_equip_btn"),
  [eBtnType.ItemDetailBtn] = require("ui.item_btns.item_detail_btn"),
  [eBtnType.GotoModEquip] = require("ui.item_btns.mod_assemble_btn"),
  [eBtnType.GotoEquipView] = require("ui.item_btns.item_gotoequip_btn"),
  [eBtnType.ExpressionItemUseBtn] = require("ui.item_btns.expression_item_use_btn"),
  [eBtnType.ModIntensify] = require("ui.item_btns.mod_intensify_btn"),
  [eBtnType.ModDecompose] = require("ui.item_btns.mod_decompose_btn"),
  [eBtnType.ModInstall] = require("ui.item_btns.mod_install_btn"),
  [eBtnType.ModUninstall] = require("ui.item_btns.mod_uninstall_btn"),
  [eBtnType.ModReplace] = require("ui.item_btns.mod_replace_btn"),
  [eBtnType.KeyRecast] = require("ui.item_btns.key_recast_btn"),
  [eBtnType.EquipRecast] = require("ui.item_btns.recast_equip_btn"),
  [eBtnType.EquipTakeOff] = require("ui.item_btns.take_equip_btn"),
  [eBtnType.ResonanceSkillMake] = require("ui.item_btns.resonance_skill_make"),
  [eBtnType.ResonanceSkillDecompose] = require("ui.item_btns.resonance_skill_decompose"),
  [eBtnType.ItemSell] = require("ui.item_btns.item_sell_btn"),
  [eBtnType.EquipRefine] = require("ui.item_btns.refine_equip_btn"),
  [eBtnType.Recycle] = require("ui.item_btns.recycle_item_btn"),
  [eBtnType.Discard] = require("ui.item_btns.discard_item_btn")
}
local switchVm_ = Z.VMMgr.GetVM("switch")
local btnFun_ = {
  [eBtnType.ItemUseBtn] = E.FunctionID.None,
  [eBtnType.ItemUseBatchBtn] = E.FunctionID.None,
  [eBtnType.ItemComposeBtn] = E.FunctionID.None,
  [eBtnType.EquipPutOnBtn] = E.EquipFuncId.Equip,
  [eBtnType.EquipReplaceBtn] = E.FunctionID.None,
  [eBtnType.ItemDecomposeBtn] = E.EquipFuncId.EquipDecompose,
  [eBtnType.ItemDetailBtn] = E.FunctionID.None,
  [eBtnType.GotoModEquip] = E.FunctionID.Mod,
  [eBtnType.GotoEquipView] = E.EquipFuncId.Equip,
  [eBtnType.ExpressionItemUseBtn] = E.EquipFuncId.Equip,
  [eBtnType.ModIntensify] = E.FunctionID.Mod,
  [eBtnType.ModDecompose] = E.FunctionID.Mod,
  [eBtnType.ModInstall] = E.FunctionID.Mod,
  [eBtnType.ModUninstall] = E.FunctionID.Mod,
  [eBtnType.ModReplace] = E.FunctionID.Mod,
  [eBtnType.KeyRecast] = E.FunctionID.None,
  [eBtnType.EquipRecast] = E.FunctionID.None,
  [eBtnType.EquipTakeOff] = E.FunctionID.None,
  [eBtnType.ResonanceSkillMake] = E.ResonanceFuncId.Create,
  [eBtnType.ResonanceSkillDecompose] = E.ResonanceFuncId.Decompose,
  [eBtnType.ItemSell] = E.FunctionID.Trade,
  [eBtnType.EquipRefine] = E.FunctionID.None,
  [eBtnType.Recycle] = E.FunctionID.Recycle,
  [eBtnType.Discard] = E.FunctionID.None
}
local sortBtn = function(left, right, data)
  return btns_[left.key].Priority(data) - btns_[right.key].Priority(data) < 0
end
local getItemBtns = function(itemUuid, configId, data)
  local btns = {}
  for k, btn in ipairs(btns_) do
    local state = btn.CheckValid(itemUuid, configId, data)
    if state ~= E.ItemBtnState.UnActive then
      local funState = btnFun_[k] == 0 and true or switchVm_.CheckFuncSwitch(btnFun_[k])
      if funState ~= false then
        table.insert(btns, {key = k, state = state})
      end
    end
  end
  table.sort(btns, function(a, b)
    return sortBtn(a, b, data)
  end)
  return btns
end
local getFilterEquipBtns = function(btns)
  local lefBtns = {}
  local rightBtns = {}
  for k, btn in ipairs(btns) do
    if btn.state == E.ItemBtnState.Active then
      if btn.key == eBtnType.EquipPutOnBtn or btn.key == eBtnType.EquipTakeOff or btn.key == eBtnType.EquipReplaceBtn or btn.key == eBtnType.GotoEquipView then
        rightBtns[#rightBtns + 1] = btn
      else
        lefBtns[#lefBtns + 1] = btn
      end
    end
  end
  return lefBtns, rightBtns
end
local getBtnName = function(key, itemUuid, configId, data)
  local btn = btns_[key]
  if btn then
    return btn.GetBtnName(itemUuid, configId, data)
  end
end
local onClick = function(key, itemUuid, configId, data)
  local btn = btns_[key]
  if btn then
    return btn.OnClick(itemUuid, configId, data)
  end
end
local loadRedNode = function(key, itemUuid, configId)
  local btn = btns_[key]
  if btn and btn.LoadRedNode then
    return btn.LoadRedNode(itemUuid, configId)
  end
end
local ret = {
  EBtnType = eBtnType,
  GetItemBtns = getItemBtns,
  GetBtnName = getBtnName,
  GetFilterEquipBtns = getFilterEquipBtns,
  OnClick = onClick,
  LoadRedNode = loadRedNode
}
return ret
