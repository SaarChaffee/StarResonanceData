local UI = Z.UI
local super = require("ui.ui_view_base")
local Helpsys_windowView = class("Helpsys_windowView", super)
local toggleGroup_ = require("ui/component/togglegroup")
local helpsys_firstclass_item_ = require("ui.component.helpsys.helpsys_firstclass_loop_item")
local loopListView_ = require("ui/component/loop_list_view")
local helpSysSecondTab = require("ui/component/helpsys/helpsys_second_loop_item")
local helpSysFindItem = require("ui/component/helpsys/helpsys_find_loop_item")

function Helpsys_windowView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.helpsys_window.PrefabPath = "helpsys/helpsys_main_pc"
  else
    Z.UIConfig.helpsys_window.PrefabPath = "helpsys/helpsys_main"
  end
  super.ctor(self, "helpsys_window")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.helpsysData_ = Z.DataMgr.Get("helpsys_data")
  self.rightView_ = require("ui/view/helpsys_window_right_tpl_view").new(self)
  self.selectBottomIndex_ = 1
  self.maxBottomIndex_ = 1
end

function Helpsys_windowView:initUiBinders()
  self.listLoopView_ = self.uiBinder.scrollview_content
  self.findNode_ = self.uiBinder.img_find_bg
  self.scrollview_find = self.uiBinder.scrollview_find
  self.dotNode_ = self.uiBinder.layout_dot
  self.subNode_ = self.uiBinder.node_sub
end

function Helpsys_windowView:OnActive()
  self:initUiBinders()
  self:startAnimatedShow()
  self.dotUnits_ = {}
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.functionName_ = ""
  local funcRow = Z.TableMgr.GetRow("FunctionTableMgr", E.FunctionID.Guide)
  if funcRow then
    self.functionName_ = funcRow.Name
  end
  local itemName = Z.IsPCUI and "helpsys_btn_list_sub_tpl_pc" or "helpsys_btn_list_sub_tpl"
  self.secondClassListView_ = loopListView_.new(self, self.listLoopView_, helpSysSecondTab, itemName)
  self.secondClassListView_:Init({})
  self:addHelpsysClick()
  self.datas_ = self.helpsysData_:GetEnableMulData(true)
  self.firstClassToggleGroup_ = toggleGroup_.new(self.uiBinder.node_tab, helpsys_firstclass_item_, self.datas_, self, Z.IsPCUI and Z.ConstValue.LoopItembindName.back_toggle_item_pc or Z.ConstValue.LoopItembindName.back_toggle_item)
  local index = 1
  if self.viewData and self.viewData.selectId then
    for k, datas in ipairs(self.datas_) do
      for i, data in ipairs(datas.DataList) do
        if data.Id == self.viewData.selectId then
          index = k
          break
        end
      end
    end
  end
  self.firstClassToggleGroup_:Init(index, function(index)
    self:OnFirstClassSelected(index)
  end)
  local itemName = Z.IsPCUI and "helpsys_ring_find_item_tpl_pc" or "helpsys_ring_find_item_tpl"
  self.findItemListView_ = loopListView_.new(self, self.scrollview_find, helpSysFindItem, itemName)
  self.findItemListView_:Init({})
end

function Helpsys_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.helpsysVM_.CheckTipsView(false, true)
  if self.secondClassListView_ then
    self.secondClassListView_:UnInit()
    self.secondClassListView_ = nil
  end
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  if self.findItemListView_ then
    self.findItemListView_:UnInit()
    self.findItemListView_ = nil
  end
  self.rightView_:DeActive()
  self.firstClassToggleGroup_:UnInit()
  self.uiBinder.input_search:SetTextWithoutNotify("")
end

function Helpsys_windowView:OnRefresh()
end

function Helpsys_windowView:addHelpsysClick()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, false)
  self.uiBinder.Ref:SetVisible(self.findNode_, false)
  self:AddClick(self.uiBinder.btn_return, function()
    self.helpsysVM_.CloseMulHelpSysView()
  end)
  self:AddClick(self.uiBinder.input_search, function(str)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, true)
    local isEmpty = string.zisEmpty(str)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, not isEmpty)
    self.uiBinder.Ref:SetVisible(self.findNode_, not isEmpty)
    local showData = {}
    if not isEmpty then
      for k, data in ipairs(self.datas_) do
        for k, dt in ipairs(data.DataList) do
          local helpLibraryTableRow = Z.TableMgr.GetTable("HelpLibraryTableMgr").GetRow(dt.Id)
          if helpLibraryTableRow and string.find(helpLibraryTableRow.Title, str) then
            showData[#showData + 1] = {data = dt, index = k}
          end
        end
      end
    end
    self.findItemListView_:RefreshListView(showData)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_empty, #showData == 0)
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.uiBinder.input_search.text = ""
  end)
  self:initBottomClick()
end

function Helpsys_windowView:tabViewCallback(data)
  self:initBottomView(data)
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.HelpsysItemRed .. data.Id, 0)
end

function Helpsys_windowView:initBottomClick()
  self:AddClick(self.uiBinder.btn_next_left, function()
    self.selectBottomIndex_ = math.max(self.selectBottomIndex_ - 1, 1)
    self:refreshBottomView(true)
  end)
  self:AddClick(self.uiBinder.btn_next_right, function()
    self.selectBottomIndex_ = math.min(self.selectBottomIndex_ + 1, self.maxBottomIndex_)
    self:refreshBottomView(true)
  end)
end

function Helpsys_windowView:initBottomView(data)
  Z.CoroUtil.create_coro_xpcall(function()
    self.rightView_:Active(data, self.subNode_.transform)
    self.selectBottomIndex_ = 1
    self.maxBottomIndex_ = #data.Content
    self.uiBinder.Ref:SetVisible(self.dotNode_, #data.Content > 0)
    for index, unit in pairs(self.dotUnits_) do
      unit.Ref.UIComp:SetVisible(false)
    end
    for i = 1, #data.Content do
      local unit = self:AsyncLoadUiUnit("ui/prefabs/helpsys/helpsys_main_dot_tpl", "dot" .. i, self.dotNode_.transform)
      if unit then
        unit.Ref.UIComp:SetVisible(true)
        self.dotUnits_[i] = unit
        unit.Ref:SetVisible(unit.img_on, false)
      end
    end
    self:refreshBottomView(false)
  end)()
end

function Helpsys_windowView:refreshBottomView(isUpdate)
  self:refreshBottomBtnView()
  self:refreshBottomDotView()
  if isUpdate and self.rightView_ ~= nil then
    self.rightView_:SelectShow(self.selectBottomIndex_)
  end
end

function Helpsys_windowView:refreshBottomDotView()
  local lastUnit = self.dotUnits_[self.lastIndex_]
  if lastUnit ~= nil then
    lastUnit.Ref:SetVisible(lastUnit.img_on, false)
  end
  local unit = self.dotUnits_[self.selectBottomIndex_]
  if unit then
    self.lastIndex_ = self.selectBottomIndex_
    unit.Ref:SetVisible(unit.img_on, true)
  end
end

function Helpsys_windowView:refreshBottomBtnView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_next_left, self.selectBottomIndex_ ~= 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_next_right, self.selectBottomIndex_ ~= self.maxBottomIndex_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_bottom, 1 < self.maxBottomIndex_)
end

function Helpsys_windowView:GetGroupData(index)
  return self.datas_[index]
end

function Helpsys_windowView:OnFirstClassSelected(index)
  if self.selectedIndex_ == index or self.datas_[index] == nil then
    return
  end
  self.uiBinder.lab_title.text = self.functionName_ .. "/" .. self.datas_[index].GroupName
  self.selectedIndex_ = index
  self.showSecondData_ = self.datas_[index].DataList
  local index = 1
  if self.viewData and self.viewData.selectId then
    for k, data in ipairs(self.showSecondData_) do
      if data.Id == self.viewData.selectId then
        index = k
        break
      end
    end
    self.viewData.selectId = nil
  end
  self.secondClassListView_:ClearAllSelect()
  self.secondClassListView_:RefreshListView(self.showSecondData_, false)
  self.secondClassListView_:MovePanelToItemIndex(index)
  self.secondClassListView_:SetSelected(index)
end

function Helpsys_windowView:OnSelectedFindItem(data)
  self.firstClassToggleGroup_:SelectedByIndex(data.data.HelpGroup)
  self.secondClassListView_:ClearAllSelect()
  self.secondClassListView_:MovePanelToItemIndex(data.index)
  self.secondClassListView_:SetSelected(data.index)
  self.uiBinder.input_search.text = ""
end

function Helpsys_windowView:startAnimatedShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Helpsys_windowView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Z.DOTweenAnimType.Close)
end

return Helpsys_windowView
