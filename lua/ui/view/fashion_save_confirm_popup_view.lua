local super = require("ui.ui_view_base")
local Fashion_save_confirm_popupView = class("Fashion_save_confirm_popupView", super)
local itemPath = "ui/prefabs/fashion/fashion_save_list_tpl"

function Fashion_save_confirm_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fashion_save_confirm_popup")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.saveVM_ = Z.VMMgr.GetVM("fashion_save_tips")
end

function Fashion_save_confirm_popupView:OnActive()
  self.tipsId_ = nil
  self.uiBinder.scene_mask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self:AddClick(self.uiBinder.btn_close, function()
    self.saveVM_.CloseSaveTipsView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_ignore, function()
    self:onClickIgnore()
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    self:createItem()
  end)()
end

function Fashion_save_confirm_popupView:OnDeActive()
end

function Fashion_save_confirm_popupView:createItem()
  local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
  self.dataList_ = self.saveVM_.GetFashionConfirmDataList()
  for _, confirmData in ipairs(self.dataList_) do
    local fashionId = confirmData.FashionId
    local region = self.fashionVM_.GetFashionRegion(fashionId)
    local unit = self:AsyncLoadUiUnit(itemPath, region, self.uiBinder.node_content)
    if unit then
      do
        local itemRow = itemTbl.GetRow(fashionId)
        if itemRow then
          unit.lab_name.text = itemRow.Name
          local itemsVM = Z.VMMgr.GetVM("items")
          unit.rimg_icon:SetImage(itemsVM.GetItemIcon(fashionId))
          unit.img_quality:SetImage(string.zconcat(Z.ConstValue.Item.SquareItemQualityPath, itemRow.Quality))
          unit.lab_region.text = self.fashionVM_.GetRegionName(region)
          unit.lab_reason.text = self:getReasonDesc(confirmData)
          self:AddClick(unit.btn_bg, function()
            Z.EventMgr:Dispatch(Z.ConstValue.FashionSaveConfirmItemClick, confirmData)
            self.saveVM_.CloseSaveTipsView()
          end)
          self:AddClick(unit.btn_rimg_icon, function()
            if self.tipsId_ then
              Z.TipsVM.CloseItemTipsView(self.tipsId_)
            end
            Z.TipsVM.OpenSourceTips(fashionId, unit.Trans)
          end)
        end
      end
    end
  end
end

function Fashion_save_confirm_popupView:getReasonDesc(confirmData)
  local reason = confirmData.Reason
  if reason == E.FashionTipsReason.UnlockedWear then
    return Lang("FashionUnlockedWear")
  elseif reason == E.FashionTipsReason.UnlockedColor then
    local areaStr = self.saveVM_.GetFashionColorAreaStr(confirmData.FashionId, confirmData.AreaList)
    return Lang("FashionUnlockedColor", {str = areaStr})
  end
  return ""
end

function Fashion_save_confirm_popupView:onClickIgnore()
  for _, confirmData in ipairs(self.dataList_) do
    local fashionId = confirmData.FashionId
    local reason = confirmData.Reason
    if reason == E.FashionTipsReason.UnlockedWear then
      local region = self.fashionVM_.GetFashionRegion(fashionId)
      self.fashionVM_.RevertFashionWearByRegion(region)
    elseif reason == E.FashionTipsReason.UnlockedColor then
      for _, area in ipairs(confirmData.AreaList) do
        self.fashionVM_.RevertFashionColorByFashionIdAndArea(fashionId, area)
      end
    end
  end
  self.fashionVM_.AsyncSaveAllFashion(self.cancelSource)
  Z.EventMgr:Dispatch(Z.ConstValue.FashionWearRevert)
  self.saveVM_.CloseSaveTipsView()
end

return Fashion_save_confirm_popupView
