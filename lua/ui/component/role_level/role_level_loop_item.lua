local super = require("ui.component.loop_list_view_item")
local RoleLevelItem = class("RoleLevelItem", super)
local loopListView = require("ui.component.loop_list_view")
local levelAwardLoopItem = require("ui.component.role_level.role_level_reward_loop_item")
local completeColor = Color.New(0.8549019607843137, 0.8549019607843137, 0.8549019607843137, 1.0)
local unCompleteColor = Color.New(0.8549019607843137, 0.8549019607843137, 0.8549019607843137, 0.25098039215686274)

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
  cont_energy_.Ref:SetVisible(cont_energy_.img_complete, false)
  cont_energy_.Ref:SetVisible(cont_energy_.lab_name, false)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  cont_energy_.lab_energy_num.text = self.awardData.Level
  if self.level < self.awardData.Level then
    cont_energy_.img_slider.fillAmount = 0
    cont_energy_.Ref:SetVisible(cont_energy_.img_complete, false)
    cont_energy_.Ref:SetVisible(cont_energy_.lab_name, true)
    cont_energy_.img_bg:SetColor(unCompleteColor)
    cont_energy_.img_slider_bg.alpha = 0.5
    cont_energy_.img_frame_bg.alpha = 0.5
  else
    self.itemClassData_.isShowReceive = true
    self.isGetAward_ = true
    cont_energy_.Ref:SetVisible(cont_energy_.img_complete, true)
    cont_energy_.Ref:SetVisible(cont_energy_.lab_name, false)
    cont_energy_.img_slider.fillAmount = 1
    cont_energy_.img_bg:SetColor(completeColor)
    cont_energy_.img_slider_bg.alpha = 1
    cont_energy_.img_frame_bg.alpha = 1
    local curAwardData = self:GetCurData()
    if curAwardData and self.level == self.awardData.Level then
      local levelExp = curAwardData.Exp
      local curExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp or 0
      local ratio = 0
      if levelExp ~= 0 then
        ratio = curExp / levelExp
      end
      cont_energy_.img_slider.fillAmount = math.min(ratio, 1)
    end
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
