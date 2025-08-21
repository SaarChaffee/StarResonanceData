local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_furniture_subView = class("Home_editor_furniture_subView", super)
local furnitureItem = require("ui.component.home.home_furniture_loop_item")
local loopScrollRect = require("ui/component/loopscrollrect")

function Home_editor_furniture_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "home_editor_furniture_sub", "home_editor/home_editor_furniture_sub", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("home_editor")
  self.data_ = Z.DataMgr.Get("home_editor_data")
end

function Home_editor_furniture_subView:initBinders()
  self.delBtn_ = self.uiBinder.btn_delete
  self.searchInput_ = self.uiBinder.input_search
  self.furnitureItemLoop_ = self.uiBinder.loopscroll_item
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.loopScrollRect_ = loopScrollRect.new(self.furnitureItemLoop_, self, furnitureItem)
end

function Home_editor_furniture_subView:OnActive()
  self:initBinders()
  self:bindEvents()
  self:AddClick(self.delBtn_, function()
    self.searchInput_.text = ""
  end)
  local data = self.vm_:GetHomelandDatas()
  self.homeLangdData_ = self.vm_.HomeDatasStrMatched(self.searchInput_.text, data)
  self:AddClick(self.searchInput_, function(str)
    self.homeLangdData_ = self.vm_.HomeDatasStrMatched(self.searchInput_.text, data)
    self:setData()
  end)
  self:setData()
end

function Home_editor_furniture_subView:setData()
  self.loopScrollRect_:SetData(self.homeLangdData_)
end

function Home_editor_furniture_subView:OnDeActive()
  self.loopScrollRect_:ClearCells()
end

function Home_editor_furniture_subView:OnRefresh()
end

function Home_editor_furniture_subView:refreshHome()
  local data = self.vm_:GetHomelandDatas()
  self.homeLangdData_ = self.vm_.HomeDatasStrMatched(self.searchInput_.text, data)
  self.loopScrollRect_:SetData(self.homeLangdData_)
end

function Home_editor_furniture_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshHome, self.refreshHome, self)
end

return Home_editor_furniture_subView
