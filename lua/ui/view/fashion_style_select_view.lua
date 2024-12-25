local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_style_selectView = class("Fashion_style_selectView", super)
local loopGridView = require("ui.component.loop_grid_view")
local style_icon_item = require("ui.component.fashion.style_icon_loop_item")
local fashionTbl = Z.TableMgr.GetTable("FashionTableMgr")
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")

function Fashion_style_selectView:ctor(parent)
  self.uiBinder = nil
  local assetPath
  if Z.IsPCUI then
    assetPath = "fashion/fashion_style_select_sub_pc"
  else
    assetPath = "fashion/fashion_style_select_sub"
  end
  super.ctor(self, "fashion_style_select_sub", assetPath)
  self.parentView_ = parent
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
end

function Fashion_style_selectView:SelectStyle(styleData)
  self.style_ = styleData.fashionId
  self.fashionVM_.SetFashionWear(self.region_, styleData)
  self:refreshFashionDetail()
end

function Fashion_style_selectView:UnSelectStyle()
  self.style_ = 0
  self:refreshFashionDetail()
  self.fashionVM_.RevertFashionWearByRegion(self.region_)
end

function Fashion_style_selectView:GetCurRegion()
  return self.region_
end

function Fashion_style_selectView:OnActive()
  self.parentView_:SetScrollContent(self.uiBinder.Trans)
  self.styleScrollRect_ = loopGridView.new(self, self.uiBinder.loop_item, style_icon_item, "fashion_item_square_3_8")
  self.region_ = self.viewData.region
  self.dataList_ = self.fashionVM_.GetStyleDataListByRegion(self.region_)
  self.styleScrollRect_:Init(self.dataList_)
  if not Z.StageMgr.GetIsInLogin() then
    function self.onFashionChangeFunc_(container, dirty)
      self.styleScrollRect_:RefreshAllShownItem()
      
      self:refreshCurWearFashion()
    end
    
    Z.ContainerMgr.CharSerialize.fashion.Watcher:RegWatcher(self.onFashionChangeFunc_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.switch_setting, true)
    self.uiBinder.switch_setting:AddListener(function(isOn)
      local settingVM = Z.VMMgr.GetVM("fashion_setting")
      settingVM.SetSingleFashionRegionIsHide(self.region_, not isOn)
    end)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.switch_setting, false)
  end
  self:AddClick(self.uiBinder.btn_go_dyeing1, function()
    self:goFashionSource(self.sourceData_)
  end)
  self:AddClick(self.uiBinder.btn_go_dyeing2, function()
    self.parentView_:OpenDyeingView(self.style_)
  end)
  self:BindEvents()
end

function Fashion_style_selectView:OnRefresh()
  self.region_ = self.viewData.region
  self.styleScrollRect_:ClearAllSelect()
  self.dataList_ = self.fashionVM_.GetStyleDataListByRegion(self.region_)
  self.styleScrollRect_:RefreshListView(self.dataList_, false)
  local regionName = self.fashionVM_.GetRegionName(self.region_)
  self.uiBinder.lab_title.text = regionName
  self:refreshCurWearFashion()
  self:refreshSettingUI()
end

function Fashion_style_selectView:OnDeActive()
  self.region_ = nil
  self.dataList_ = nil
  self.style_ = nil
  self.styleScrollRect_:UnInit()
  self.styleScrollRect_ = nil
  if self.cameraTimer_ then
    self.timerMgr:StopTimer(self.cameraTimer_)
    self.cameraTimer_ = nil
  end
  if not Z.StageMgr.GetIsInLogin() then
    Z.ContainerMgr.CharSerialize.fashion.Watcher:UnregWatcher(self.onFashionChangeFunc_)
    self.onFashionChangeFunc_ = nil
  end
end

function Fashion_style_selectView:refreshCurWearFashion()
  local tryonStyleData = self.fashionData_:GetWear(self.region_)
  self.style_ = tryonStyleData and tryonStyleData.fashionId or 0
  self.styleScrollRect_:ClearAllSelect()
  local selectIndex = 0
  if tryonStyleData then
    for i, data in ipairs(self.dataList_) do
      if data.fashionId == tryonStyleData.fashionId then
        selectIndex = i - 1
        self:SelectStyle(data)
        break
      end
    end
  end
  self.styleScrollRect_:MovePanelToItemIndex(selectIndex)
  self.styleScrollRect_:SelectIndex(selectIndex)
  self:refreshFashionDetail()
end

function Fashion_style_selectView:refreshFashionDetail()
  if self.style_ > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_detail, true)
    local styleData = itemTbl.GetRow(self.style_)
    if styleData then
      self.uiBinder.lab_name1.text = styleData.Name
      local sourceData = self.itemSourceVm_.GetItemSource(self.style_)
      if Z.StageMgr.GetIsInGameScene() and sourceData and 0 < #sourceData then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquire_entry, true)
        self.sourceData_ = sourceData[1]
        self.uiBinder.lab_name2.text = string.format(Lang("FashionSource"), self.sourceData_.name)
        self.uiBinder.img_icon:SetImage(self.sourceData_.icon)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquire_entry, false)
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_detail, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_dyeing_entry, self:isAllowDyeing(self.style_))
end

function Fashion_style_selectView:isAllowDyeing(fashionId)
  if fashionId <= 0 then
    return false
  end
  local fashionRow = fashionTbl.GetRow(fashionId)
  if not fashionRow then
    return false
  end
  if #fashionRow.ColorPart == 0 then
    return false
  end
  return true
end

function Fashion_style_selectView:refreshSettingUI()
  if Z.StageMgr.GetIsInLogin() then
    return
  end
  local settingVM = Z.VMMgr.GetVM("fashion_setting")
  local isHide = settingVM.GetFashionRegionIsHide(self.region_)
  self.uiBinder.switch_setting:SetIsOnWithoutNotify(not isHide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, isHide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, not isHide)
end

function Fashion_style_selectView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionWearRevert, self.refreshCurWearFashion, self)
  Z.EventMgr:Add(Z.ConstValue.FashionSettingChange, self.onFashionSettingChange, self)
end

function Fashion_style_selectView:onFashionSettingChange(regionDict)
  if Z.StageMgr.GetIsInLogin() then
    return
  end
  local isHide = regionDict[self.region_] == 2
  self.uiBinder.switch_setting:SetIsOnWithoutNotify(not isHide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, isHide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, not isHide)
end

function Fashion_style_selectView:goFashionSource(sourceData)
  if not sourceData then
    return
  end
  local tipsId = self.viewData.tipsId
  local jumpType = self.itemSourceVm_.JumpToSource(sourceData)
  if jumpType ~= E.QuickJumpType.Message and tipsId ~= nil then
    Z.TipsVM.CloseItemTipsView(tipsId)
  end
end

return Fashion_style_selectView
