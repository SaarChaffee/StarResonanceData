local UI = Z.UI
local super = require("ui.ui_view_base")
local House_application_list_popupView = class("House_application_list_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local applyLoopItem = require("ui.component.house.house_apply_loop_item")

function House_application_list_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_application_list_popup")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.socialData_ = Z.DataMgr.Get("social_data")
end

function House_application_list_popupView:initBinders()
  self.closeBtn_ = self.uiBinder.btn
  self.applyLoopList_ = self.uiBinder.scrollview_item
  self.sceneMask_ = self.uiBinder.scenemask
  self.emptyNode_ = self.uiBinder.com_empty_new
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function House_application_list_popupView:initData()
end

function House_application_list_popupView:initUI()
  self.applyListView_ = loopListView.new(self, self.applyLoopList_, applyLoopItem, "house_application_list_item_tpl")
  self.applyListView_:Init({})
  self.emptyNode_.Ref.UIComp:SetVisible(false)
end

function House_application_list_popupView:initBtns()
  self:AddClick(self.closeBtn_, function()
    self.houseVm_.CloseHouseApplyView()
  end)
end

function House_application_list_popupView:OnActive()
  self:initBinders()
  self:initData()
  self:initBtns()
  self:initUI()
  self:refreshList()
  Z.EventMgr:Add(Z.ConstValue.House.RefreshApplyList, self.refreshList, self)
end

function House_application_list_popupView:refreshList()
  Z.CoroUtil.create_coro_xpcall(function()
    self.personData_ = self.houseVm_.AsyncGetPersonData(self.cancelSource:CreateToken())
    if self.personData_ then
      local itemCount = #self.personData_.items
      if 0 < itemCount then
        table.sort(self.personData_.items, function(left, right)
          return left.time > right.time
        end)
      end
      self.applyListView_:RefreshListView(self.personData_.items)
      self.emptyNode_.Ref.UIComp:SetVisible(0 < itemCount)
      self.emptyNode_.Ref.UIComp:SetVisible(itemCount == 0)
    else
      self.emptyNode_.Ref.UIComp:SetVisible(true)
    end
  end)()
end

function House_application_list_popupView:OnDeActive()
  if self.applyListView_ then
    self.applyListView_:UnInit()
    self.applyListView_ = nil
  end
end

function House_application_list_popupView:OnRefresh()
end

return House_application_list_popupView
