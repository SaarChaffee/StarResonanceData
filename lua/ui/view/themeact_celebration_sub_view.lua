local UI = Z.UI
local super = require("ui.ui_subview_base")
local Themeact_celebration_subView = class("Themeact_celebration_subView", super)
local loopListView = require("ui.component.loop_list_view")
local common_reward_loop_list_item_2 = require("ui.component.common_reward_loop_list_item_2")

function Themeact_celebration_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "themeact_celebration_sub", "themeact/themeact_celebration_sub", UI.ECacheLv.None)
end

function Themeact_celebration_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initData()
  self:initComponent()
  self:initLoopListView()
  self:initChildActivity()
  self:refreshActivityInfo()
end

function Themeact_celebration_subView:OnDeActive()
  self:unInitLoopListView()
end

function Themeact_celebration_subView:OnRefresh()
end

function Themeact_celebration_subView:initData()
  self.config_ = self.viewData.config
  self.childIdList_ = self.viewData.childIdList
  table.sort(self.childIdList_, function(a, b)
    return a < b
  end)
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
  self.themePlayVM_ = Z.VMMgr.GetVM("theme_play")
  self.curTimeStage_ = self.themePlayVM_:GetActivityTimeStage(self.config_.Id)
end

function Themeact_celebration_subView:initComponent()
  self:AddClick(self.uiBinder.btn_switch, function()
    local quickJumpVM = Z.VMMgr.GetVM("quick_jump")
    quickJumpVM.DoJumpByConfigParam(self.config_.QuickJumpType, self.config_.QuickJumpParam, {
      DynamicFlagName = self.config_.Name
    })
  end)
  self:SetUIVisible(self.uiBinder.btn_switch, self.curTimeStage_ ~= E.SeasonActivityTimeStage.NotOpen)
end

function Themeact_celebration_subView:initChildActivity()
  self:SetUIVisible(self.uiBinder.binder_shop.Ref, false)
  if self.curTimeStage_ ~= E.SeasonActivityTimeStage.NotOpen then
    local specialBtnCount = 0
    for i, childId in ipairs(self.childIdList_) do
      local childConfig = Z.TableMgr.GetRow("SeasonActTableMgr", childId)
      if childConfig ~= nil then
        do
          local childRedDotId = childConfig.ShowNewRed
          local resultRedDotId = self.config_.Id .. "_" .. childRedDotId
          if childConfig.ThemeType == E.ThemeActivityFuncType.Shop then
            self:SetUIVisible(self.uiBinder.binder_shop.Ref, true)
            self.uiBinder.binder_shop.lab_name.text = childConfig.Name
            self:AddClick(self.uiBinder.binder_shop.btn_item, function()
              local shopVM = Z.VMMgr.GetVM("shop")
              shopVM.OpenActivityShopView()
              if childRedDotId ~= 0 then
                Z.RedPointMgr.ResetAllChildNodeCount(childRedDotId, 0)
                Z.RedPointMgr.OnClickRedDot(childRedDotId)
                self.themePlayVM_:SetNewDirty(childConfig)
              end
            end)
            if childRedDotId ~= 0 then
              Z.RedPointMgr.LoadRedDotItem(resultRedDotId, self, self.uiBinder.binder_shop.Trans)
            end
          else
            specialBtnCount = specialBtnCount + 1
            do
              local btnComp = self.uiBinder["btn_special_" .. specialBtnCount]
              if btnComp ~= nil then
                local config = Z.TableMgr.GetRow("SeasonActTableMgr", childId)
                if config ~= nil then
                  self:AddClick(btnComp, function()
                    local quickJumpVM = Z.VMMgr.GetVM("quick_jump")
                    quickJumpVM.DoJumpByConfigParam(config.QuickJumpType, config.QuickJumpParam, {
                      DynamicFlagName = childConfig.Name
                    })
                    if childRedDotId ~= 0 then
                      Z.RedPointMgr.ResetAllChildNodeCount(childRedDotId, 0)
                      Z.RedPointMgr.OnClickRedDot(childRedDotId)
                      self.themePlayVM_:SetNewDirty(childConfig)
                    end
                  end)
                end
                if childRedDotId ~= 0 then
                  Z.RedPointMgr.LoadRedDotItem(resultRedDotId, self, btnComp.Trans)
                end
              end
            end
          end
        end
      end
    end
  end
end

function Themeact_celebration_subView:refreshActivityInfo()
  self.uiBinder.rimg_title:SetImage(self.config_.ActName)
  self:SetUIVisible(self.uiBinder.img_icon, false)
  if self.curTimeStage_ == E.SeasonActivityTimeStage.NotOpen then
    local currentTime = Z.TimeTools.Now() / 1000
    local startTime, endTime = self.themePlayVM_:GetActivityTimeStamp(self.config_.Id)
    local leftTimeDesc = Z.TimeFormatTools.FormatToDHMS(math.floor(startTime - currentTime))
    local timeDesc = Lang("WillOpenDesc", {time = leftTimeDesc})
    self.uiBinder.lab_time.text = timeDesc
    self:SetUIVisible(self.uiBinder.img_icon, true)
  elseif self.curTimeStage_ == E.SeasonActivityTimeStage.Over then
    self.uiBinder.lab_time.text = Lang("HadOver")
  elseif self.curTimeStage_ == E.SeasonActivityTimeStage.Open then
    local currentTime = Z.TimeTools.Now() / 1000
    local startTime, endTime = self.themePlayVM_:GetActivityTimeStamp(self.config_.Id)
    local leftTimeDesc = Z.TimeFormatTools.FormatToDHMS(math.floor(endTime - currentTime))
    local timeDesc = Lang("MonthlyRemainingTime", {time = leftTimeDesc})
    self.uiBinder.lab_time.text = timeDesc
    self:SetUIVisible(self.uiBinder.img_icon, true)
  end
  if self.curTimeStage_ == E.SeasonActivityTimeStage.NotOpen then
    self.uiBinder.lab_content.text = self.config_.PreDec
  else
    self.uiBinder.lab_content.text = self.config_.ActDes
  end
  self:refreshLoopListView(self.config_.PreviewAward)
end

function Themeact_celebration_subView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, common_reward_loop_list_item_2, "com_item_square_1_8")
  local dataList = {}
  self.loopListView_:Init(dataList)
end

function Themeact_celebration_subView:refreshLoopListView(awardId)
  local dataList = {}
  if awardId and awardId ~= 0 then
    dataList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardId)
  end
  self.loopListView_:RefreshListView(dataList)
  self:SetUIVisible(self.uiBinder.node_reward, 0 < #dataList)
end

function Themeact_celebration_subView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

return Themeact_celebration_subView
