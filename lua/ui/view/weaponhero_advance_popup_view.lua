local UI = Z.UI
local super = require("ui.ui_view_base")
local Weaponhero_advance_popupView = class("Weaponhero_advance_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local weaponResonanceAdvanceLoopItem = require("ui.component.weapon.weapon_resonance_advance_loop_item")
local CENTER_COUNT = 3

function Weaponhero_advance_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weaponhero_advance_popup")
  self.weaponVM_ = Z.VMMgr.GetVM("weapon")
  self.weaponSkillVM_ = Z.VMMgr.GetVM("weapon_skill")
  self.skillVM_ = Z.VMMgr.GetVM("skill")
end

function Weaponhero_advance_popupView:OnActive()
  self:initComponent()
  self:onStartAnimShow()
  self:initLoopListView()
  self:refreshAdvanceInfo()
end

function Weaponhero_advance_popupView:OnDeActive()
  self.uiBinder.point_check.ContainGoEvent:RemoveAllListeners()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.point_check:StopCheck()
  self:unInitLoopListView()
end

function Weaponhero_advance_popupView:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.anim:PlayOnce("anim_weaponhero_advance_popup_an")
  self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Weaponhero_advance_popupView:OnRefresh()
end

function Weaponhero_advance_popupView:initComponent()
  self:EventAddAsyncListener(self.uiBinder.point_check.ContainGoEvent, function(isContain)
    if not isContain then
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.point_check:StartCheck()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.node_audio:PlayByTrigger(Panda.ZUi.UIAudioTrigger.commonAudio_1)
end

function Weaponhero_advance_popupView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_advance, weaponResonanceAdvanceLoopItem, "weaponhero_advance_item_tpl")
  local dataList = {}
  self.loopListView_:Init(dataList)
end

function Weaponhero_advance_popupView:refreshLoopListView(dataList)
  self.loopListView_:RefreshListView(dataList)
  if #dataList >= CENTER_COUNT then
    self.uiBinder.trans_advance_content:SetPivot(0, 1)
  else
    self.uiBinder.trans_advance_content:SetPivot(0, 0.5)
  end
end

function Weaponhero_advance_popupView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Weaponhero_advance_popupView:refreshAdvanceInfo()
  local skillId = self.viewData.skillId
  local advanceLv = self.viewData.advanceLv
  local skillAoyiTableRow = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
  if skillAoyiTableRow == nil then
    return
  end
  local skillTableRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  if skillTableRow == nil then
    return
  end
  self.uiBinder.lab_title_grade_former.text = Lang("AdvanceLevel2") .. advanceLv - 1
  self.uiBinder.lab_title_grade_after.text = Lang("AdvanceLevel2") .. advanceLv
  self.uiBinder.lab_title.text = Lang(advanceLv == 0 and "ActiveSuccess" or "AdvanceSuccess")
  self.uiBinder.lab_name.text = skillTableRow.Name
  self.uiBinder.rimg_monster:SetImage(skillAoyiTableRow.ArtPreview)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_name, advanceLv == 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_num, 0 < advanceLv)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_loop_active, advanceLv == 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_loop_advance, 0 < advanceLv)
  if 0 < advanceLv then
    local resultList = {}
    self:GetSkillData(skillId, advanceLv, resultList)
    self:GetAdvanceData(skillId, advanceLv, resultList)
    self:refreshLoopListView(resultList)
  else
    local content = self.weaponSkillVM_:ParseResonanceSkillBaseDesc(skillId)
    content = string.zconcat(Lang("ActiveEffectColor"), "\n", content)
    local attrDescList, buffDescList = self.weaponSkillVM_:ParseResonanceSkillDesc(skillId, advanceLv, true)
    local resultDescList = {}
    for i, info in ipairs(attrDescList) do
      table.insert(resultDescList, info.desc)
      table.insert(resultDescList, "\n")
    end
    for i, info in ipairs(buffDescList) do
      table.insert(resultDescList, info.desc)
      table.insert(resultDescList, "\n")
    end
    if 0 < #resultDescList then
      local passiveContent = table.concat(resultDescList)
      content = string.zconcat(content, [[


]], Lang("PassiveEffectColor"), "\n", passiveContent)
    end
    self.uiBinder.lab_skill_desc.text = content
    self.uiBinder.scroll_active.verticalNormalizedPosition = 1
  end
end

function Weaponhero_advance_popupView:GetSkillData(skillId, advanceLv, resultList)
  local skillFightConfigList = self.weaponSkillVM_:GetSkillFightDataById(skillId)
  local curSkillFightConfig = skillFightConfigList[1]
  if curSkillFightConfig == nil then
    return
  end
  local curSkillDecsList = self.skillVM_.GetSkillDecs(curSkillFightConfig.Id, advanceLv, true)
  if curSkillDecsList == nil then
    return
  end
  local lastSkillDecsList = self.skillVM_.GetSkillDecs(curSkillFightConfig.Id, advanceLv - 1, true)
  lastSkillDecsList = self.skillVM_.GetSkillDecsWithColor(lastSkillDecsList)
  curSkillDecsList = self.skillVM_.ContrastSkillDecs(lastSkillDecsList, curSkillDecsList)
  local lastAttrData = {}
  for _, value in ipairs(lastSkillDecsList) do
    lastAttrData[value.Dec] = {
      desc = value.Dec,
      value = value.Num
    }
  end
  for _, value in ipairs(curSkillDecsList) do
    if lastAttrData[value.Dec] == nil or lastAttrData[value.Dec].value ~= value.Num then
      local data = {
        type = 1,
        lastValue = lastAttrData[value.Dec] and lastAttrData[value.Dec].value or 0,
        curValue = value.Num,
        desc = value.Dec
      }
      table.insert(resultList, data)
    end
  end
end

function Weaponhero_advance_popupView:GetAdvanceData(skillId, advanceLv, resultList)
  local curAttrDescList, curBuffDescList = self.weaponSkillVM_:ParseResonanceSkillDesc(skillId, advanceLv)
  local lastAttrDescList, lastBuffDescList = self.weaponSkillVM_:ParseResonanceSkillDesc(skillId, advanceLv - 1)
  local lastDescDict = {}
  for _, value in ipairs(lastAttrDescList) do
    lastDescDict[value.desc] = true
  end
  for _, value in ipairs(lastBuffDescList) do
    lastDescDict[value.desc] = true
  end
  for _, value in ipairs(curAttrDescList) do
    if not lastDescDict[value.desc] then
      local data = {
        type = 2,
        desc = value.desc
      }
      table.insert(resultList, data)
    end
  end
  for _, value in ipairs(curBuffDescList) do
    if not lastDescDict[value.desc] then
      local data = {
        type = 3,
        desc = value.desc
      }
      table.insert(resultList, data)
    end
  end
end

return Weaponhero_advance_popupView
