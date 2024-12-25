local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_reward_popupView = class("Fishing_reward_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local fishing_reward_loop_item = require("ui.component.fishing.fishing_reward_loop_item")

function Fishing_reward_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_reward_popup")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
end

function Fishing_reward_popupView:OnActive()
  self.gradeListView_ = loopListView.new(self, self.uiBinder.loop_list_fish, fishing_reward_loop_item, "fishing_reward_list_item_tpl")
  self.gradeListView_:Init({})
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    self.fishingVM_.CloseFishingLevelPopup()
  end)
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingDataChange, self.refreshUI, self)
end

function Fishing_reward_popupView:OnDeActive()
  self.gradeListView_:UnInit()
  self.gradeListView_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Fishing.FishingDataChange, self.refreshUI, self)
end

function Fishing_reward_popupView:OnRefresh()
  self:refreshUI()
end

function Fishing_reward_popupView:refreshUI()
  local dataList = {}
  local keys = {}
  local levelCfgs = Z.TableMgr.GetTable("FishingLevelTableMgr").GetDatas()
  for k, _ in pairs(levelCfgs) do
    table.insert(keys, k)
  end
  table.sort(keys)
  for _, v in ipairs(keys) do
    if levelCfgs[v].ItemAward > 0 then
      table.insert(dataList, levelCfgs[v])
    end
  end
  self.gradeListView_:RefreshListView(dataList)
  self.uiBinder.lab_lv.text = Lang("LvFormatSymbol", {
    val = self.fishingData_.FishingLevel
  })
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FishingLevelAwardAllBtn, self, self.uiBinder.btn_receive_trans)
  local canReceive = false
  for k, v in ipairs(dataList) do
    local isGet = Z.ContainerMgr.CharSerialize.fishSetting.levelReward[v.FishingLevel]
    local canGet = self.fishingData_.FishingLevel >= v.FishingLevel
    if canGet and not isGet then
      canReceive = true
      break
    end
  end
  self.uiBinder.btn_receive:RemoveAllListeners()
  self.uiBinder.btn_receive.IsDisabled = not canReceive
  if canReceive then
    self:AddAsyncClick(self.uiBinder.btn_receive, function()
      self.fishingVM_.GetLevelReward(nil, self.cancelSource:CreateToken())
    end)
  end
end

return Fishing_reward_popupView
