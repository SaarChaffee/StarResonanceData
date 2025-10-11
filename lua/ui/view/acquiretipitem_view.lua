local Id = 1
local AcquiretipItemView = class("AcquiretipItemView")

function AcquiretipItemView:ctor()
  self.uiBinder = nil
  self.IsActive = false
  self.targetHeight_ = 0
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function AcquiretipItemView:Active(acquiretipView, itemData, targetHeight, itemParent)
  self.IsActive = true
  self.itemData_ = itemData
  self.targetHeight_ = targetHeight
  self.Height = -30
  self.view_ = acquiretipView
  self.itemParent_ = itemParent
  self:refresh()
  self:playAnim()
  if self.uiBinder == nil then
    self:load()
  else
    self:onloadCompleted()
  end
end

function AcquiretipItemView:UnInit()
  if self.uiBinder ~= nil then
    self.uiBinder.Ref.UIComp:SetVisible(false)
    self.uiBinder.Trans:SetAnchorPosition(0, self.Height)
    self.uiBinder = nil
  end
  self.view_ = nil
  self.itemParent_ = nil
  self.unitName = nil
  self.IsActive = false
end

function AcquiretipItemView:Update(deltaTime, addHeightNum)
  self.targetHeight_ = self.targetHeight_ + addHeightNum
  if self.uiBinder ~= nil and self.Height ~= self.targetHeight_ then
    self.Height = self.Height + deltaTime * 200
    if self.Height > self.targetHeight_ then
      self.Height = self.targetHeight_
    end
    local x, y = self.uiBinder.Trans:GetAnchorPosition(nil, nil)
    self.uiBinder.Trans:SetAnchorPosition(x, self.Height)
  end
end

function AcquiretipItemView:load()
  self.unitName = "item" .. Id
  Id = Id + 1
  local prefabPath = Z.IsPCUI and "ui/prefabs/tips/tips_acquire_tpl_pc" or "ui/prefabs/tips/tips_acquire_tpl"
  Z.CoroUtil.create_coro_xpcall(function()
    self.uiBinder = self.view_:AsyncLoadUiUnit(prefabPath, self.unitName, self.itemParent_, self.view_.cancelSource:CreateToken())
    self:onloadCompleted()
  end)()
end

function AcquiretipItemView:onloadCompleted()
  if self.uiBinder == nil then
    return
  end
  self.uiBinder.Trans:SetAnchorPosition(0, self.Height)
  self:refresh()
  self:playAnim()
end

function AcquiretipItemView:refresh()
  if self.uiBinder == nil then
    return
  end
  if self.itemData_ == nil then
    return
  end
  local itemTableData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.itemData_.ItemConfigId)
  if itemTableData == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_done, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_special, false)
  local isSpecial = false
  local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", self.itemData_.ItemConfigId, true)
  if itemConfig then
    local typeConfig = Z.TableMgr.GetRow("ItemTypeTableMgr", itemConfig.Type, true)
    if typeConfig and table.zcontains(typeConfig.SpecialHint, itemConfig.Quality) then
      isSpecial = true
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_done, not isSpecial)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_special, isSpecial)
  if itemConfig.Quality >= 4 then
    Z.AudioMgr:Play("UI_Event_GetTip_Golden")
  else
    Z.AudioMgr:Play("UI_Event_GetTip_Normal")
  end
  self.uiBinder.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(self.itemData_.ItemConfigId))
  local text = self.itemsVM_.ApplyItemNameWithQualityTag(self.itemData_.ItemConfigId)
  self.uiBinder.lab_name.text = Lang("TvAcquireItemNameWithCount", {
    name = text,
    count = self.itemData_.ChangeCount
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_time_limit, itemTableData.TimeType ~= 0)
  self.uiBinder.comp_rebuilder:ForceRebuildLayoutImmediate()
end

function AcquiretipItemView:playAnim()
  if self.uiBinder == nil then
    return
  end
  self.uiBinder.Ref.UIComp:SetVisible(true)
  local anim = self.uiBinder.anim_main
  anim:ResetAniState("acquiretip_item", 0)
  local token = self.view_.cancelSource:CreateToken()
  self.commonVM_.CommonPlayAnim(anim, "acquiretip_item", token, function()
    self.IsActive = false
    if self.uiBinder ~= nil then
      self.uiBinder.Ref.UIComp:SetVisible(false)
      self.uiBinder.Trans:SetAnchorPosition(0, self.Height)
    end
  end)
end

return AcquiretipItemView
