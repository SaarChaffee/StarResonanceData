local Id = 1
local AcquiretipItemView = class("AcquiretipItemView")

function AcquiretipItemView:ctor()
  self.unit_ = nil
  self.IsActive = false
  self.targetHeight_ = 0
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function AcquiretipItemView:Active(acquiretipView, itemData, targetHeight)
  self.IsActive = true
  self.itemData_ = itemData
  self.targetHeight_ = targetHeight
  self.Height = -65
  self.view_ = acquiretipView
  self:refresh()
  self:playAnim()
  if self.unit_ == nil then
    self:load()
  else
    self:onloadCompleted()
  end
end

function AcquiretipItemView:UnInit()
  if self.unit_ then
    self.unit_:SetVisible(false)
    self.unit_.Ref:SetPosition(0, self.Height)
  end
  self.unit_ = nil
  self.view_ = nil
  self.unitName = nil
  self.IsActive = false
end

function AcquiretipItemView:Update(deltaTime, addHeightNum)
  self.targetHeight_ = self.targetHeight_ + addHeightNum
  if self.unit_ and self.Height ~= self.targetHeight_ then
    self.Height = self.Height + deltaTime * 200
    if self.Height > self.targetHeight_ then
      self.Height = self.targetHeight_
    end
    local pos = self.unit_.Ref.RectTransform.anchoredPosition
    self.unit_.Ref:SetPosition(pos.x, self.Height)
  end
end

function AcquiretipItemView:load()
  self.unitName = "item" .. Id
  Id = Id + 1
  local parent = self.view_.panel.rect.Trans
  local prefabPath = Z.IsPCUI and "ui/prefabs/tips/tips_acquire_tpl_pc" or "ui/prefabs/tips/tips_acquire_tpl"
  Z.CoroUtil.create_coro_xpcall(function()
    self.unit_ = self.view_:AsyncLoadUiUnit(prefabPath, self.unitName, parent, self.view_.cancelSource:CreateToken())
    self:onloadCompleted()
  end)()
end

function AcquiretipItemView:onloadCompleted()
  if self.unit_ == nil then
    return
  end
  self.unit_.Ref:SetPosition(0, self.Height)
  self:refresh()
  self:playAnim()
end

function AcquiretipItemView:refresh()
  if self.unit_ == nil then
    return
  end
  if self.itemData_ == nil then
    return
  end
  local itemTableData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemData_.ItemConfigId)
  if itemTableData == nil then
    return
  end
  self.unit_.rimg_icon:SetVisible(true)
  self.unit_.img_tv_acquire_done.Go:SetActive(false)
  self.unit_.node_tv_acquire_special.Go:SetActive(false)
  local isSpecial = false
  local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", self.itemData_.ItemConfigId, true)
  if itemConfig then
    local typeConfig = Z.TableMgr.GetRow("ItemTypeTableMgr", itemConfig.Type, true)
    if typeConfig and table.zcontains(typeConfig.SpecialHint, itemConfig.Quality) then
      isSpecial = true
    end
  end
  self.unit_.img_tv_acquire_done.Go:SetActive(not isSpecial)
  self.unit_.node_tv_acquire_special.Go:SetActive(isSpecial)
  if isSpecial then
    Z.AudioMgr:Play("sfx_treasure_gorgeous")
  end
  self.unit_.rimg_icon.RImg:SetImage(self.itemsVm_.GetItemIcon(self.itemData_.ItemConfigId))
  local text = self.itemsVm_.ApplyItemNameWithQualityTag(self.itemData_.ItemConfigId)
  self.unit_.lab_name.TMPLab.text = text
  self.unit_.lab_count.TMPLab.text = self.itemData_.ChangeCount
  self.unit_.content.ZLayout:ForceRebuildLayoutImmediate()
  self.unit_.img_icon_timelimit:SetVisible(itemTableData.TimeType ~= 0)
end

function AcquiretipItemView:playAnim()
  if self.unit_ == nil then
    return
  end
  self.unit_:SetVisible(true)
  local anim = self.unit_.anim.anim
  anim:ResetAniState("acquiretip_item", 0)
  local token = self.view_.cancelSource:CreateToken()
  anim:CoroPlayOnce("acquiretip_item", token, function()
    self.IsActive = false
    if self.unit_ then
      self.unit_:SetVisible(false)
      self.unit_.Ref:SetPosition(0, self.Height)
    end
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

return AcquiretipItemView
