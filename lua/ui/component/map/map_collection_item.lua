local super = require("ui.component.loop_list_view_item")
local MapCollectionItem = class("MapCollectionItem", super)
local NAME_LOCK_NORMAL_COLOR = Color.New(1.0, 1.0, 1.0, 0.5)
local NAME_LOCK_SELECT_COLOR = Color.New(0.2, 0.2, 0.2, 1)
local NAME_UNLOCK_NORMAL_COLOR = Color.New(1.0, 1.0, 1.0, 1)
local NAME_UNLOCK_SELECT_COLOR = Color.New(0.2, 0.2, 0.2, 1)

function MapCollectionItem:OnInit()
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function MapCollectionItem:OnRefresh(data)
  self.uiBinder.lab_name_on.text = data.Name
  self.uiBinder.lab_name_off.text = data.Name
  self.uiBinder.img_icon:SetImage(data.Icon)
  self.uiBinder.img_quality_bg:SetImage(Z.ConstValue.Item.SquareItemQualityPath .. data.Quality)
  self:RefreshCollectionSelectState(data)
end

function MapCollectionItem:OnUnInit()
end

function MapCollectionItem:OnSelected(isSelected, isClick)
  local data = self:GetCurData()
  if data == nil then
    return
  end
  self:RefreshCollectionSelectState(data)
end

function MapCollectionItem:RefreshCollectionSelectState(config)
  local isUnlock = Z.ConditionHelper.CheckCondition(config.UnlockCondition, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_unlock, not isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
  if isUnlock then
    self.uiBinder.lab_name_on.color = self.IsSelected and NAME_UNLOCK_SELECT_COLOR or NAME_UNLOCK_NORMAL_COLOR
    self.uiBinder.lab_name_off.color = self.IsSelected and NAME_UNLOCK_SELECT_COLOR or NAME_UNLOCK_NORMAL_COLOR
  else
    self.uiBinder.lab_name_on.color = self.IsSelected and NAME_LOCK_SELECT_COLOR or NAME_LOCK_NORMAL_COLOR
    self.uiBinder.lab_name_off.color = self.IsSelected and NAME_LOCK_SELECT_COLOR or NAME_LOCK_NORMAL_COLOR
  end
end

function MapCollectionItem:OnPointerClick()
  local data = self:GetCurData()
  if data == nil then
    return
  end
  Z.ConditionHelper.CheckCondition(data.UnlockCondition, true)
  self.parent.UIView:OnCollectionItemClick(data.Id)
end

return MapCollectionItem
