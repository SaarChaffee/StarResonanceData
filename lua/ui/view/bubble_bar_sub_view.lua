local UI = Z.UI
local super = require("ui.ui_subview_base")
local Bubble_bar_subView = class("Bubble_bar_subView", super)

function Bubble_bar_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "bubble_bar_sub", "main/track/bubble_bar_sub", UI.ECacheLv.None, true)
  self.itemTable_ = {}
  self.bubbleData_ = Z.DataMgr.Get("bubble_data")
  self.bubbleVM_ = Z.VMMgr.GetVM("bubble")
end

function Bubble_bar_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:bindWatcher()
end

function Bubble_bar_subView:OnDeActive()
  self:unBindWatcher()
  self:removeBubbleItem()
end

function Bubble_bar_subView:OnRefresh()
  self:setViewInfo()
end

function Bubble_bar_subView:bindWatcher()
  function self.bubbleActDataChanged_(contin, dirtys)
    if dirtys and dirtys.bubbleInfo then
      self:setViewInfo()
    end
  end
  
  Z.ContainerMgr.CharSerialize.bubbleActData.Watcher:RegWatcher(self.bubbleActDataChanged_)
end

function Bubble_bar_subView:unBindWatcher()
  Z.ContainerMgr.CharSerialize.bubbleActData.Watcher:UnregWatcher(self.bubbleActDataChanged_)
  self.bubbleActDataChanged_ = nil
end

function Bubble_bar_subView:setViewInfo()
  self.bubbleInfo_ = self.bubbleVM_:GetCurrentBubbleInfo()
  self.uiBinder.lab_title.text = self.bubbleInfo_.tableData.Name
  self.uiBinder.lab_get_num.text = Lang("HasGetAward", {
    val = self.bubbleInfo_.servicesData.bubbleAwardCount
  })
  self.uiBinder.lab_mark_num.text = Lang("BubbleScore", {
    val1 = self.bubbleInfo_.servicesData.bubbleScore,
    val2 = self.bubbleInfo_.tableData.TargetScore
  })
  self.uiBinder.img_bar.fillAmount = self.bubbleInfo_.servicesData.bubbleScore / self.bubbleInfo_.tableData.TargetScore
  self:asyncLoadItem()
end

function Bubble_bar_subView:asyncLoadItem()
  Z.CoroUtil.create_coro_xpcall(function()
    local dataArr = self.bubbleInfo_.tableData.AdditionalTargetName
    local prefabPath = Z.IsPCUI and "bubble_item_tpl_pc" or "bubble_item_tpl"
    local itemPath = self.uiBinder.prefab_cache:GetString(prefabPath)
    local name
    local currentY = 0
    self:removeBubbleItem()
    for k, v in pairs(dataArr) do
      name = string.format("bubble_item_%d", k)
      local item = self:AsyncLoadUiUnit(itemPath, name, self.uiBinder.node_bubble_quest, self.cancelSource:CreateToken())
      self.itemTable_[k] = name
      item.lab_quest_name.text = v
      item.Ref:SetVisible(item.lab_progress_num, false)
      local preferredHeight = item.lab_quest_name.preferredHeight
      item.Trans:SetHeight(preferredHeight)
      item.Trans.anchoredPosition = Vector2.New(0, -currentY)
      currentY = currentY + item.Trans.rect.height
    end
    self:adjustRectHeight(currentY)
  end)()
end

function Bubble_bar_subView:adjustRectHeight(posY)
  local posX = self.uiBinder.node_bubble_quest.sizeDelta.x
  self.uiBinder.node_bubble_quest:SetSizeDelta(posX, posY)
  local bottomY = self.uiBinder.node_bubble_quest.anchoredPosition.y - self.uiBinder.node_bubble_quest.rect.height
  self.uiBinder.node_get_num.anchoredPosition = Vector2.New(self.uiBinder.node_get_num.anchoredPosition.x, bottomY)
  self.uiBinder.node_content:SetHeight(self.uiBinder.node_top.rect.height + self.uiBinder.node_bubble_quest.rect.height + self.uiBinder.node_get_num.rect.height)
end

function Bubble_bar_subView:removeBubbleItem()
  if not self.itemTable_ or next(self.itemTable_) == nil then
    return
  end
  for k, v in pairs(self.itemTable_) do
    self:RemoveUiUnit(v)
  end
  self.itemTable_ = {}
end

return Bubble_bar_subView
