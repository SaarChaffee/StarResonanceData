local ModCardAllTplItem = {}
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")
local ModFabtassyDotTplItem = require("ui.component.mod.mod_fabtassy_dot_tpl_item")
local itemClass = require("common.item_binder")
local MOD_DEFINE = require("ui.model.mod_define")
local MAXTOGSTARCOUNT = 10

function ModCardAllTplItem.RefreshTpl(uibinder, effectId, logs, uuid, view, isEmpty)
  if isEmpty then
    uibinder.Ref:SetVisible(uibinder.node_info, false)
    uibinder.Ref:SetVisible(uibinder.img_empty, true)
    return nil, false
  else
    uibinder.Ref:SetVisible(uibinder.node_info, true)
    uibinder.Ref:SetVisible(uibinder.img_empty, false)
    local res
    local itemsVM = Z.VMMgr.GetVM("items")
    local modVM = Z.VMMgr.GetVM("mod")
    local modData = Z.DataMgr.Get("mod_data")
    local itemInfo = itemsVM.GetItemInfo(uuid, E.BackPackItemPackageType.Mod)
    local logsCount = 0
    local enhancementHoleNum = 0
    local successCount = 0
    if itemInfo then
      local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemInfo.configId)
      local qualityConfig = modData:GetQualityConfig(itemConfig.Quality)
      local modConfig = Z.TableMgr.GetTable("ModTableMgr").GetRow(itemInfo.configId)
      if qualityConfig then
        enhancementHoleNum = qualityConfig.enhancementHoleNum
        logsCount = #logs
        for i = 1, MAXTOGSTARCOUNT do
          local starUIBinder = uibinder["tog_star_level_" .. i]
          if i <= enhancementHoleNum then
            starUIBinder.Ref.UIComp:SetVisible(true)
            if i <= logsCount then
              if logs[i] then
                ModFabtassyDotTplItem.RefreshTpl(starUIBinder, false, true, nil)
                successCount = successCount + 1
              else
                ModFabtassyDotTplItem.RefreshTpl(starUIBinder, false, false, nil)
              end
            elseif modConfig and modConfig.IsCanLink then
              ModFabtassyDotTplItem.RefreshTpl(starUIBinder, true, false, nil)
            else
              ModFabtassyDotTplItem.RefreshTpl(starUIBinder, false, false, nil)
            end
          else
            starUIBinder.Ref.UIComp:SetVisible(false)
          end
          if view.IntensifyEffectId and effectId == view.IntensifyEffectId and i == logsCount then
            if logs[logsCount] then
              uibinder.node_effect:CreatEFFGO(MOD_DEFINE.ModIntensifyEffect[2][1], Vector3.zero)
              uibinder.node_effect:SetEffectGoVisible(true)
              view.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(uibinder.node_effect)
              starUIBinder.node_effect:CreatEFFGO(MOD_DEFINE.ModIntensifyEffect[2][2], Vector3.zero)
              view.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(starUIBinder.node_effect)
              starUIBinder.node_effect:SetEffectGoVisible(true)
            else
              uibinder.node_effect:CreatEFFGO(MOD_DEFINE.ModIntensifyEffect[1][1], Vector3.zero)
              uibinder.node_effect:SetEffectGoVisible(true)
              view.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(uibinder.node_effect)
              starUIBinder.node_effect:CreatEFFGO(MOD_DEFINE.ModIntensifyEffect[1][2], Vector3.zero)
              view.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(starUIBinder.node_effect)
              starUIBinder.node_effect:SetEffectGoVisible(true)
            end
            table.insert(view.IntensifyEffects, uibinder.node_effect)
            table.insert(view.IntensifyEffects, starUIBinder.node_effect)
          end
        end
        do
          local isEquip = modVM.IsModEquip(uuid)
          local successTimes, level, nextSuccessTimes = modVM.GetEquipEffectSuccessTimesAndLevelAndNextLevelSuccessTimes(effectId)
          if isEquip then
            local successTimesText = successTimes
            if nextSuccessTimes < successTimes then
              successTimesText = Z.RichTextHelper.ApplyStyleTag(successTimesText, E.TextStyleTag.TipsRed)
            end
            uibinder.lab_lv.text = string.format("<u><link>%s: +%s / +%s</link></u>", Lang("NextLevel"), successTimesText, nextSuccessTimes)
          else
            uibinder.lab_lv.text = Lang("NotEquipped")
          end
          uibinder.lab_lv:AddListener(function()
            if isEquip then
              local text = ""
              if successTimes > MOD_DEFINE.MaxEffectIntensifyCount then
                text = Lang("ModMaximumOpenLevelTips")
              elseif successTimes > nextSuccessTimes then
                local tempConfig = modData:GetEffectTableConfig(effectId, level)
                if tempConfig then
                  text = Lang("ModCurrentOpenLevelTips", {
                    val1 = tempConfig.Level,
                    val2 = tempConfig.EnhancementNum
                  })
                end
              else
                text = Lang("ModLinkSuccessRateMiniTips", {
                  val1 = level + 1,
                  val2 = nextSuccessTimes - successTimes
                })
              end
              Z.CommonTipsVM.ShowTipsContent(uibinder.rect_lv, text)
            end
          end)
          res = itemClass.new(view)
          res:Init({
            uiBinder = uibinder.node_item,
            configId = qualityConfig.enhancedConsumption.itemId,
            labType = E.ItemLabType.Expend,
            lab = itemsVM.GetItemTotalCount(qualityConfig.enhancedConsumption.itemId),
            expendCount = qualityConfig.enhancedConsumption.count
          })
          uibinder.btn_intensify:AddListener(function()
            if view.isInIntensify_ then
              return
            end
            local totalCount = itemsVM.GetItemTotalCount(qualityConfig.enhancedConsumption.itemId)
            if totalCount < qualityConfig.enhancedConsumption.count then
              local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(qualityConfig.enhancedConsumption.itemId)
              if itemConfig then
                Z.TipsVM.ShowTipsLang(1042113, {
                  val = itemConfig.Name
                })
                view:openNotEnoughItemTips(qualityConfig.enhancedConsumption.itemId, uibinder.node_item.Trans)
                return
              end
            end
            if logsCount >= enhancementHoleNum then
              Z.TipsVM.ShowTipsLang(1042108)
              return
            end
            Z.CoroUtil.create_coro_xpcall(function()
              local confirmFunc = function()
                local intensifyFunc = function()
                  view.isInIntensify_ = true
                  modVM.AsyncIntensify(uuid, effectId, view.cancelSource:CreateToken())
                  view.isInIntensify_ = false
                end
                if itemInfo.bindFlag == 1 then
                  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ModStrengthenBindingTips"), intensifyFunc, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.ModIntensifyBindFlag)
                  return
                else
                  intensifyFunc()
                end
              end
              if not modVM.IsModEquip(uuid) then
                Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ModStrengthenUnassembledTips"), confirmFunc, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.ModIntensifyNotEquip)
                return
              else
                local successTimes, level, nextSuccessTimes = modVM.GetEquipEffectSuccessTimesAndLevelAndNextLevelSuccessTimes(effectId)
                if nextSuccessTimes <= successTimes then
                  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ModStrengthenHighestTips"), confirmFunc, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.ModIntensifyMaxSuccessTimes)
                  return
                else
                  confirmFunc()
                  return
                end
              end
            end)()
          end)
          if enhancementHoleNum <= logsCount then
            uibinder.Ref:SetVisible(uibinder.lab_allintensify, true)
            uibinder.Ref:SetVisible(uibinder.btn_intensify, false)
            uibinder.Ref:SetVisible(uibinder.lab_successful, false)
            uibinder.node_item.Ref.UIComp:SetVisible(false)
          else
            uibinder.Ref:SetVisible(uibinder.lab_allintensify, false)
            uibinder.Ref:SetVisible(uibinder.btn_intensify, true)
            uibinder.Ref:SetVisible(uibinder.lab_successful, true)
            uibinder.node_item.Ref.UIComp:SetVisible(true)
            uibinder.lab_successful.text = Lang("UpgradeRate", {
              val = modVM.CalculateCurModSuccessRate(uuid)
            })
          end
          local effectConfig = modData:GetEffectTableConfig(effectId, level)
          if effectConfig then
            uibinder.lab_effect_name.text = effectConfig.EffectName .. " " .. Lang("Grade", {val = level})
            ModGlossaryItemTplItem.RefreshTpl(uibinder.node_glossary_item_tpl, effectId)
            view:AddAsyncClick(uibinder.btn_tips, function()
              local viewData = {
                parent = uibinder.node_glossary_item_tpl.Trans,
                effectId = effectId,
                config = effectConfig
              }
              Z.UIMgr:OpenView("mod_item_popup", viewData)
            end)
            if effectConfig.IsNegative then
              uibinder.img_base:SetImage(MOD_DEFINE.ModEffectIsNegative[2])
            else
              uibinder.img_base:SetImage(MOD_DEFINE.ModEffectIsNegative[1])
            end
          end
        end
      end
    end
    return res, enhancementHoleNum <= logsCount
  end
end

return ModCardAllTplItem
