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
  Discard = 24,
  EquipEnchant = 25,
  GotoEnchant = 26,
  TraceMaterial = 27,
  Make = 28,
  EquipTrace = 29,
  ModTrace = 30,
  ResonanceSwitch = 31,
  HomePreview = 32,
  FuncSwitch = 33
}
E.BtnViewType = {
  Bag = {
    [E.BackPackItemPackageType.Item] = {
      [eBtnType.ItemUseBtn] = 1,
      [eBtnType.ItemUseBatchBtn] = 2,
      [eBtnType.KeyRecast] = 3,
      [eBtnType.ItemDetailBtn] = 4,
      [eBtnType.ItemSell] = 5,
      [eBtnType.FuncSwitch] = 6
    },
    [E.BackPackItemPackageType.Equip] = {
      [eBtnType.GotoEquipView] = 1,
      [eBtnType.ItemSell] = 2,
      [eBtnType.EquipTrace] = 3
    },
    [E.BackPackItemPackageType.Mod] = {
      [eBtnType.GotoModEquip] = 1,
      [eBtnType.ItemSell] = 2,
      [eBtnType.ModTrace] = 3
    },
    [E.BackPackItemPackageType.ResonanceSkill] = {
      [eBtnType.ResonanceSkillMake] = 1,
      [eBtnType.ItemSell] = 2,
      [eBtnType.Recycle] = 3,
      [eBtnType.ResonanceSwitch] = 4
    }
  },
  Equip = {
    [eBtnType.EquipPutOnBtn] = 1,
    [eBtnType.ItemDecomposeBtn] = 2,
    [eBtnType.EquipReplaceBtn] = 3,
    [eBtnType.EquipTakeOff] = 4,
    [eBtnType.EquipRecast] = 5,
    [eBtnType.EquipRefine] = 6,
    [eBtnType.EquipEnchant] = 7,
    [eBtnType.EquipTrace] = 8
  },
  Mod = {
    [eBtnType.ModIntensify] = 1,
    [eBtnType.ModDecompose] = 2,
    [eBtnType.ModInstall] = 3,
    [eBtnType.ModUninstall] = 4,
    [eBtnType.ModReplace] = 5,
    [eBtnType.ModTrace] = 6
  },
  Resonance = {
    [eBtnType.ResonanceSkillMake] = 1,
    [eBtnType.ResonanceSkillDecompose] = 2,
    [eBtnType.ResonanceSwitch] = 3
  }
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
  [eBtnType.Discard] = require("ui.item_btns.discard_item_btn"),
  [eBtnType.EquipEnchant] = require("ui.item_btns.enchant_equip_btn"),
  [eBtnType.GotoEnchant] = require("ui.item_btns.enchant_goto_btn"),
  [eBtnType.TraceMaterial] = require("ui.item_btns.item_trace_material_btn"),
  [eBtnType.Make] = require("ui.item_btns.item_make_btn"),
  [eBtnType.EquipTrace] = require("ui.item_btns.item_equip_trace_btn"),
  [eBtnType.ModTrace] = require("ui.item_btns.item_mod_trace_btn"),
  [eBtnType.ResonanceSwitch] = require("ui.item_btns.resonance_switch_btn"),
  [eBtnType.HomePreview] = require("ui.item_btns.item_home_preview_btn"),
  [eBtnType.FuncSwitch] = require("ui.item_btns.item_func_switch_btn")
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
  [eBtnType.Discard] = E.FunctionID.None,
  [eBtnType.EquipEnchant] = E.FunctionID.None,
  [eBtnType.GotoEnchant] = E.FunctionID.None,
  [eBtnType.TraceMaterial] = E.FunctionID.None,
  [eBtnType.Make] = E.FunctionID.None,
  [eBtnType.EquipTrace] = E.EquipFuncId.EquipTrace,
  [eBtnType.ModTrace] = E.FunctionID.ModTrace,
  [eBtnType.ResonanceSwitch] = E.FunctionID.WeaponAoyiSkill,
  [eBtnType.HomePreview] = E.FunctionID.None,
  [eBtnType.FuncSwitch] = E.FunctionID.None
}
local sortBtn = function(left, right, data)
  return btns_[left.key].Priority(data) - btns_[right.key].Priority(data) < 0
end
local getBtnInfos = function(btns, itemUuid, configId, data)
  local btnInfos = {}
  for k, value in pairs(btns) do
    local btn = btns_[k]
    if btn then
      local state = btn.CheckValid(itemUuid, configId, data)
      if state == E.ItemBtnState.Active or state == E.ItemBtnState.IsDisabled then
        local funState = btnFun_[k] == 0 and true or switchVm_.CheckFuncSwitch(btnFun_[k])
        if funState ~= false then
          table.insert(btnInfos, {key = k, state = state})
        end
      end
    end
  end
  table.sort(btnInfos, function(a, b)
    return sortBtn(a, b, data)
  end)
  return btnInfos
end
local getItemBtns = function(itemUuid, configId, data)
  return getBtnInfos(btns_, itemUuid, configId, data)
end
local getBtnStateByKey = function(key, itemUuid, configId, data)
  local btn = btns_[key]
  if btn then
    local state = btn.CheckValid(itemUuid, configId, data)
  else
    logError("itemBtnsMgr: getBtnStateByKey no find key, kye = {0}", key)
  end
end
local getItemBtnInfosByType = function(viewBtns, itemUuid, configId, data)
  return getBtnInfos(viewBtns, itemUuid, configId, data)
end
local getFilterEquipBtns = function(btns)
  local lefBtns = {}
  local rightBtns = {}
  for k, btn in ipairs(btns) do
    if btn.key == eBtnType.EquipPutOnBtn or btn.key == eBtnType.EquipTakeOff or btn.key == eBtnType.EquipReplaceBtn or btn.key == eBtnType.GotoEquipView then
      rightBtns[#rightBtns + 1] = btn
    else
      lefBtns[#lefBtns + 1] = btn
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
local onClick = function(key, itemUuid, configId, data, token)
  local btn = btns_[key]
  if btn then
    return btn.OnClick(itemUuid, configId, data, token)
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
  LoadRedNode = loadRedNode,
  GetItemBtnInfosByType = getItemBtnInfosByType
}
return ret
