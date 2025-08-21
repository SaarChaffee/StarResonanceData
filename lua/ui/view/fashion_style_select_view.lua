local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_style_selectView = class("Fashion_style_selectView", super)
local loopGridView = require("ui.component.loop_grid_view")
local style_icon_item = require("ui.component.fashion.style_icon_loop_item")
local fashionTbl = Z.TableMgr.GetTable("FashionTableMgr")
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
local FashionAdvancedTableMap = require("table.FashionAdvancedTableMap")

function Fashion_style_selectView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fashion_style_select_sub", "fashion/fashion_style_select_sub", nil, true)
  self.parentView_ = parent
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.settingVM_ = Z.VMMgr.GetVM("fashion_setting")
end

function Fashion_style_selectView:SelectStyle(styleData, isClick)
  self.fashionId_ = styleData.fashionId
  self.wearFashionId_ = styleData.wearFashionId
  self.fashionVM_.SetFashionWear(self.region_, styleData, not isClick)
  self:refreshCustomCollectionState()
  self:refreshFashionDetail()
  self:refreshStyleRed()
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionWearChange)
end

function Fashion_style_selectView:UnSelectStyle()
  self.fashionId_ = 0
  self:refreshFashionDetail()
  self.fashionVM_.RevertFashionWearByRegion(self.region_)
end

function Fashion_style_selectView:GetCurRegion()
  return self.region_
end

function Fashion_style_selectView:OnActive()
  self.parentView_:SetScrollContent(self.uiBinder.Trans)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetWidth(Z.IsPCUI and 316 or 424)
  self.styleScrollRect_ = loopGridView.new(self, self.uiBinder.loop_item, style_icon_item, "fashion_item_square_3_8", true)
  self.region_ = self.viewData.region
  self.dataList_ = self.fashionVM_.GetStyleDataListByRegion(self.region_)
  self.styleScrollRect_:Init(self.dataList_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_icon, true)
  self.uiBinder.lab_tips.text = ""
  if not Z.StageMgr.GetIsInLogin() then
    function self.onFashionChangeFunc_(container, dirty)
      self.styleScrollRect_:RefreshAllShownItem()
      
      self:refreshCurWearFashion()
    end
    
    Z.ContainerMgr.CharSerialize.fashion.Watcher:RegWatcher(self.onFashionChangeFunc_)
  end
  self:AddClick(self.uiBinder.btn_go_source, function()
    self:goFashionSource(self.sourceData_)
  end)
  self:AddClick(self.uiBinder.btn_go_dyeing, function()
    if not self.wearFashionId_ then
      self.parentView_:OpenDyeingView(self.fashionId_)
      return
    end
    local row = self.fashionVM_.GetFashionAdvanced(self.wearFashionId_)
    if not row then
      self.parentView_:OpenDyeingView(self.fashionId_)
      return
    end
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("FashionAdvancedColorTips"), function()
      local styleData = {
        fashionId = self.fashionId_,
        wearFashionId = self.fashionId_,
        isUnlock = self.fashionVM_.GetFashionIsUnlock(self.fashionId_)
      }
      self.fashionVM_.SetFashionWear(self.region_, styleData)
      self.parentView_:OpenDyeingView(row.FashionId)
    end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.FashionAdvancedColorTips)
  end)
  self:AddClick(self.uiBinder.btn_customized, function()
    Z.RedPointMgr.OnClickRedDot(self.regionRed_)
    self.parentView_:OpenCustomizedView(self.fashionId_)
  end)
  self:AddClick(self.uiBinder.btn_collection, function()
    self.parentView_:OpenCustomizedView(self.fashionId_)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_customized, not self.viewData.isPreview)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_collection, false)
  self:BindEvents()
  if not self.viewData.isPreview then
    self.parentView_:ShowSaveBtn()
  end
end

function Fashion_style_selectView:OnRefresh()
  self.region_ = self.viewData.region
  self:refreshStyleData()
end

function Fashion_style_selectView:refreshStyleData()
  self.styleScrollRect_:ClearAllSelect()
  self.dataList_ = self.fashionVM_.GetStyleDataListByRegion(self.region_)
  self.styleScrollRect_:RefreshListView(self.dataList_, false)
  self:refreshCurWearFashion()
end

function Fashion_style_selectView:OnDeActive()
  self.region_ = nil
  self.dataList_ = nil
  self.fashionId_ = nil
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
  if self.regionRed_ then
    Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
  end
end

function Fashion_style_selectView:refreshStyleRed()
  if self.regionRed_ then
    Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
  end
  if not self.fashionId_ then
    return
  end
  self.regionRed_ = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomRed, self.fashionId_)
  Z.RedPointMgr.LoadRedDotItem(self.regionRed_, self, self.uiBinder.customized_ref)
end

function Fashion_style_selectView:refreshCustomCollectionState()
  if self.viewData.isPreview then
    return
  end
  if FashionAdvancedTableMap.FashionAdvanced[self.fashionId_] then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_customized, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_customized, false)
  end
end

function Fashion_style_selectView:refreshCurWearFashion()
  local tryonStyleData = self.fashionData_:GetWear(self.region_)
  self.fashionId_ = tryonStyleData and tryonStyleData.fashionId or 0
  self.styleScrollRect_:ClearAllSelect()
  local selectIndex = 0
  if tryonStyleData then
    for i, data in ipairs(self.dataList_) do
      if data.fashionId == self.fashionVM_.GetOriginalFashionId(tryonStyleData.fashionId) then
        selectIndex = i - 1
        self:SelectStyle(data, false)
        break
      end
    end
  end
  self.styleScrollRect_:MovePanelToItemIndex(selectIndex)
  self.styleScrollRect_:SelectIndex(selectIndex)
  self:refreshFashionDetail()
end

function Fashion_style_selectView:refreshFashionDetail()
  if self.fashionId_ > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_detail, true)
    local styleData = itemTbl.GetRow(self.fashionId_)
    if styleData then
      self.uiBinder.lab_name.text = styleData.Name
      local fashionTableRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
      if fashionTableRow and 0 < fashionTableRow.Score and Z.StageMgr.GetIsInGameScene() then
        self.uiBinder.lab_score.text = fashionTableRow.Score
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_score, true)
      else
        self.uiBinder.lab_score.text = ""
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_score, false)
      end
      local sourceData = self.itemSourceVm_.GetItemSource(self.fashionId_)
      if Z.StageMgr.GetIsInGameScene() and sourceData and 0 < table.zcount(sourceData) then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquire_entry, true)
        self.sourceData_ = sourceData[1]
        self.uiBinder.lab_source.text = string.format(Lang("FashionSource"), self.sourceData_.name)
        self.uiBinder.img_icon:SetImage(self.sourceData_.icon)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_acquire_entry, false)
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_detail, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_go_dyeing, self:isAllowDyeing(self.fashionId_))
end

function Fashion_style_selectView:isAllowDyeing(fashionId)
  local isDyeingUnlock = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.FashionDyeing, true)
  if not isDyeingUnlock then
    return false
  end
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

function Fashion_style_selectView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionWearRevert, self.refreshCurWearFashion, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionViewRefresh, self.refreshCurWearFashion, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionShowState, self.refreshStyleData, self)
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
