local super = require("ui.component.loop_list_view_item")
local RoleLevelItem = class("RoleLevelItem", super)
local loopListView = require("ui.component.loop_list_view")
local levelAwardLoopItem = require("ui.component.role_level.role_level_reward_loop_item")

function RoleLevelItem:ctor()
  self.roleLevelVm_ = Z.VMMgr.GetVM("rolelevel_main")
end

function RoleLevelItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClassData_ = {}
  self.level = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.curLevelExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp
  self.awardScrollRect_ = loopListView.new(self.parentUIView, self.uiBinder.cont_energy.loop_item, levelAwardLoopItem, "com_item_square_8")
  self.awardScrollRect_:Init({})
end

function RoleLevelItem:OnRefresh(data)
  self.isGetAward_ = false
  self:initUI()
  self:initItem()
  self:initAward()
end

function RoleLevelItem:initItem()
  local cont_energy_ = self.uiBinder.cont_energy
  local isLevelComplete = self.level >= self.awardData.Level
  local dataList_ = self.parent:GetData()
  local setVisibility = function()
    cont_energy_.Ref:SetVisible(cont_energy_.img_complete, isLevelComplete)
    cont_energy_.Ref:SetVisible(cont_energy_.img_dot_off, not isLevelComplete)
    cont_energy_.Ref:SetVisible(cont_energy_.img_dot_on, isLevelComplete)
    cont_energy_.Ref:SetVisible(cont_energy_.lab_name, not isLevelComplete)
    cont_energy_.Ref:SetVisible(cont_energy_.lab_energy_num_on, isLevelComplete)
    cont_energy_.Ref:SetVisible(cont_energy_.lab_energy_num_off, not isLevelComplete)
    cont_energy_.Ref:SetVisible(cont_energy_.img_up, self.Index == 1)
    cont_energy_.Ref:SetVisible(cont_energy_.img_down, self.Index == #dataList_ - 1)
  end
  setVisibility()
  cont_energy_.lab_energy_num_on.text = self.awardData.Level
  cont_energy_.lab_energy_num_off.text = self.awardData.Level
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  if isLevelComplete then
    self.itemClassData_.isShowReceive = true
    self.isGetAward_ = true
    cont_energy_.img_slider.fillAmount = 1
    cont_energy_.img_frame_bg.alpha = 1
    local curAwardData = self:GetCurData()
    if curAwardData and self.level == self.awardData.Level then
      local levelExp = curAwardData.Exp
      local curExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp or 0
      local ratio = levelExp ~= 0 and curExp / levelExp or 0
      cont_energy_.img_slider.fillAmount = math.min(ratio, 1)
    end
  else
    cont_energy_.img_slider.fillAmount = 0
    cont_energy_.img_frame_bg.alpha = 0.65
  end
end

function RoleLevelItem:initAward()
  local awardDataList = {}
  if self.awardData.LevelAwardID ~= 0 then
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(self.awardData.LevelAwardID)
    if awardList then
      for _, data in ipairs(awardList) do
        table.insert(awardDataList, {
          type = 1,
          data = data,
          isGetAward = self.isGetAward_
        })
      end
    end
  end
  if 0 < self.awardData.TalentPoint then
    local talentSkillData = Z.DataMgr.Get("talent_skill_data")
    local awardData = {
      awardId = talentSkillData:GetTalentPointConfigId(),
      awardNum = self.awardData.TalentPoint,
      awardNumExtend = self.awardData.TalentPoint,
      PrevDropType = 0
    }
    table.insert(awardDataList, {
      type = 1,
      data = awardData,
      isGetAward = self.isGetAward_
    })
  end
  if 0 < #self.awardData.LevelUpAttr then
    table.insert(awardDataList, 1, {
      type = 2,
      attr = self.awardData.LevelUpAttr,
      level = self.awardData.Level,
      isGetAward = self.isGetAward_
    })
  end
  if self.awardData.ExplainText ~= "" then
    table.insert(awardDataList, 1, {
      type = 3,
      explainText = self.awardData.ExplainText,
      isGetAward = self.isGetAward_
    })
  end
  self.awardScrollRect_:RefreshListView(awardDataList)
end

function RoleLevelItem:initUI()
  local dataList_ = self.parent:GetData()
  self.awardData = self:GetCurData()
  local flg = self.Index == #dataList_
  self.uiBinder.cont_energy.Ref:SetVisible(self.uiBinder.cont_energy.img_slider_bg, not flg)
end

function RoleLevelItem:OnBeforePlayAnim()
end

function RoleLevelItem:Selected(isSelected)
  if isSelected then
  end
  self:SelectState()
end

function RoleLevelItem:SelectState()
end

function RoleLevelItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function RoleLevelItem:OnPointerClick(go, eventData)
end

function RoleLevelItem:OnUnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  self.tipsId_ = nil
  self:unInitLoopListView()
end

function RoleLevelItem:unInitLoopListView()
  self.awardScrollRect_:UnInit()
  self.awardScrollRect_ = nil
end

return RoleLevelItem
