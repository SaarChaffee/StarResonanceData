local UI = Z.UI
local super = require("ui.ui_view_base")
local Lifework_settle_windowView = class("Lifework_settle_windowView", super)
local lifeWorkAwardLoopItem = require("ui.component.life_work.life_work_settlement_reward_item")
local loopListView = require("ui.component.loop_list_view")

function Lifework_settle_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "lifework_settle_window")
  self.lifeWorkVM = Z.VMMgr.GetVM("life_work")
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function Lifework_settle_windowView:OnActive()
  self:initBtnClick()
  self:initLoopList()
  self.curWorkingProID = self.lifeWorkVM.GetCurWorkingPro()
  if self.curWorkingProID == 0 then
    return
  end
  self.lifeProfessionWorkInfo = Z.ContainerMgr.CharSerialize.lifeProfessionWork.lifeProfessionWorkInfo
  if self.lifeProfessionWorkInfo == nil then
    return
  end
  local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curWorkingProID)
  if lifeWorkTableRow == nil then
    return
  end
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(self.curWorkingProID)
  if lifeProfessionTableRow == nil then
    return
  end
  self.uiBinder.lab_title_name.text = lifeWorkTableRow.Title
  self.uiBinder.lab_content.text = lifeWorkTableRow.Desc
  self.uiBinder.img_icon:SetImage(lifeProfessionTableRow.Icon)
  self:refreshCost()
end

function Lifework_settle_windowView:initLoopList()
  local data = {}
  self.rewardLoopListView_ = loopListView.new(self, self.uiBinder.loop_item, lifeWorkAwardLoopItem, "com_item_square_1_8")
  self.rewardLoopListView_:Init(data)
end

function Lifework_settle_windowView:refreshCost()
  local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(self.curWorkingProID)
  if lifeWorkTableRow == nil then
    return
  end
  self.uiBinder.rimg_icon:SetImage(self.itemVm_.GetItemIcon(Z.SystemItem.VigourItemId))
  self.uiBinder.lab_num.text = math.ceil(self.lifeProfessionWorkInfo.cost)
  self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(math.ceil(self.lifeProfessionWorkInfo.count * lifeWorkTableRow.Time), true)
  self.rewardLoopListView_:RefreshListView(self.lifeProfessionWorkInfo.reward)
  local lifeProfessionTableRow = Z.TableMgr.GetRow("LifeProfessionTableMgr", self.curWorkingProID)
  if lifeProfessionTableRow == nil then
    return
  end
  self.uiBinder.img_icon:SetImage(lifeProfessionTableRow.Icon)
end

function Lifework_settle_windowView:initBtnClick()
  self:AddAsyncClick(self.uiBinder.btn_reward, function()
    self.lifeWorkVM.AsyncRequsetGetReward()
    self.lifeWorkVM.CloseWorkRewardView()
  end)
end

function Lifework_settle_windowView:OnDeActive()
  self.rewardLoopListView_:UnInit()
  self.rewardLoopListView_ = nil
end

function Lifework_settle_windowView:OnRefresh()
end

return Lifework_settle_windowView
