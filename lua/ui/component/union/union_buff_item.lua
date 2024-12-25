local UnionBuffItem = class("UnionBuffItem")
local STATE_ENUM = {
  BuffLock = 1,
  SlotLock = 2,
  Empty = 3,
  Normal = 4,
  Preview = 5
}
local COLOR_NORMAL = Color.New(1, 1, 1, 1)
local COLOR_LOCK = Color.New(1, 1, 1, 0.2)

function UnionBuffItem:Init(uiBinder, data)
  self.uiBinder = uiBinder
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.uiBinder.btn_item:AddListener(function()
    self:onItemClick()
  end)
  self:Refresh(data)
end

function UnionBuffItem:setData(data)
  self.curData = data
  self.curBuffId = data.BuffId
  local unlockSlotNum = self.unionVM_:GetUnlockBuffSlotNum()
  if self.curData.SlotIndex and unlockSlotNum < self.curData.SlotIndex then
    self.curState = STATE_ENUM.SlotLock
  elseif self.curBuffId == nil then
    self.curState = STATE_ENUM.Empty
  elseif self.curData.IsPreview then
    self.curState = STATE_ENUM.Preview
  else
    local isBuffUnlock = self.unionVM_:CheckUnionBuffUnlock(self.curBuffId)
    if isBuffUnlock then
      self.curState = STATE_ENUM.Normal
    else
      self.curState = STATE_ENUM.BuffLock
    end
  end
end

function UnionBuffItem:Refresh(data)
  self:setData(data)
  if self.curState == STATE_ENUM.Normal then
    local config = Z.TableMgr.GetTable("UnionTimelinessBuffTableMgr").GetRow(self.curBuffId)
    self.uiBinder.img_icon:SetImage(config.Icon)
  end
  local isLock = self.curState == STATE_ENUM.BuffLock or self.curState == STATE_ENUM.SlotLock
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, isLock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_add, self.curState == STATE_ENUM.Empty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, self.curState == STATE_ENUM.Normal or self.curState == STATE_ENUM.Preview)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.curData.IsSelect)
  self.uiBinder.img_bg.color = isLock and COLOR_LOCK or COLOR_NORMAL
end

function UnionBuffItem:UnInit()
  self.uiBinder = nil
  Z.UIMgr:CloseView("union_buff_tips")
end

function UnionBuffItem:onItemClick()
  if self.curData == nil or self.curData.IgnoreClick then
    return
  end
  if (self.curState == STATE_ENUM.Normal or self.curState == STATE_ENUM.Empty) and self.curData.ClickFunc then
    self.curData.ClickFunc()
    return
  end
  if self.curState == STATE_ENUM.SlotLock then
    Z.UIMgr:OpenView("union_buff_tips", {
      ParentTrans = self.uiBinder.btn_item.transform,
      BuffSlotIndex = self.curData.SlotIndex
    })
  elseif self.curState == STATE_ENUM.Empty then
    local buildConfig = self.unionVM_:GetUnionBuildConfig(E.UnionBuildId.Buff)
    local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
    quickJumpVm.DoJumpByConfigParam(buildConfig.QuickJumpType, buildConfig.QuickJumpParam)
  else
    Z.UIMgr:OpenView("union_buff_tips", {
      ParentTrans = self.uiBinder.btn_item.transform,
      BuffId = self.curBuffId,
      IsPreview = self.curData.IsPreview
    })
  end
end

return UnionBuffItem
