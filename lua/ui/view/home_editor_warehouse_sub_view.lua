local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_warehouse_subView = class("Home_editor_warehouse_subView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local wareHouseTabItem = require("ui.component.home.home_warehouse_tab_loop_item")
local wareHouseItem = require("ui.component.home.home_warehouse_loop_item")

function Home_editor_warehouse_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "home_editor_warehouse_sub", "home_editor/home_editor_warehouse_sub", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("home")
  self.data_ = Z.DataMgr.Get("home_data")
end

function Home_editor_warehouse_subView:initBinders()
  self.searchInput_ = self.uiBinder.input_search
  self.delBtn_ = self.uiBinder.btn_delete
  self.togItemLoop_ = self.uiBinder.loopscroll_tog
  self.wareHouseItemLoop_ = self.uiBinder.loopscroll_item
  self.viewRect_ = self.uiBinder.view_rect
  self.viewRect_:SetSizeDelta(0, 0)
  self.wareHouseItemLoop_ = loopScrollRect.new(self.wearhouseItemLoop_, self, wareHouseItem)
  self.wareHouseTabItemLoop_ = loopScrollRect.new(self.togItemLoop_, self, wareHouseTabItem)
end

function Home_editor_warehouse_subView:OnActive()
  self:initBinders()
  self:AddClick(self.delBtn_, function()
    self.searchInput_.text = ""
  end)
  self:AddClick(self.searchInput_, function(str)
    self.showData_ = self.vm_.ItemsNameMatched(self.searchInput_.text, self.weraHouseData_)
    self:setData()
  end)
  self.wareHouseTabItemLoop_:SetData(self.data_:GetHomeCfgDatas())
  self.wareHouseTabItemLoop_:SetSelected(0)
end

function Home_editor_warehouse_subView:OnDeActive()
  self.wareHouseItemLoop_:ClearCells()
  self.wareHouseTabItemLoop_:ClearCells()
  self.wareHouseItemLoop_ = nil
  self.wareHouseTabItemLoop_ = nil
end

function Home_editor_warehouse_subView:SetWareHouseData(typeId)
  self.weraHouseData_ = self.vm_.GetWareHouseDataByTypeId(typeId)
  self.showData_ = self.vm_.ItemsNameMatched(self.searchInput_.text, self.weraHouseData_)
  self:setData()
end

function Home_editor_warehouse_subView:setData()
  if self.wareHouseItemLoop_ then
    self.wareHouseItemLoop_:SetData(self.showData_)
  end
end

function Home_editor_warehouse_subView:OnRefresh()
end

return Home_editor_warehouse_subView
