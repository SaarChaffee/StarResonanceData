local super = require("ui.component.loop_grid_view_item")
local ExpressionEmojiItem = class("ExpressionEmojiItem", super)

function ExpressionEmojiItem:OnInit()
  self.wheelData_ = Z.DataMgr.Get("wheel_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function ExpressionEmojiItem:OnRefresh(data)
  self.data_ = data
  if data.type == E.ExpressionSettingType.QuickMessage then
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      self.uiBinder.lab_content.text = slotData.Text
    end
  elseif data.type == E.ExpressionSettingType.Emoji then
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_emoji, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_emoji, false)
    self.uiBinder.rimg_emoji:SetImageWithCallback(string.zconcat(Z.ConstValue.Emoji.EmojiPath, slotData.Res), function()
      if not self.uiBinder then
        return
      end
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_emoji, true)
    end)
  elseif data.type == E.ExpressionSettingType.UseItem then
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      self.uiBinder.img_item_quality:SetImage(Z.ConstValue.Item.SquareItemQualityPath .. slotData.Quality)
      self.uiBinder.rimg_item_icon:SetImage(self.itemsVm_.GetItemIcon(data.id))
      local curHave = self.itemsVm_.GetItemTotalCount(data.id)
      self.uiBinder.lab_item_count.text = curHave
    end
  elseif data.type == E.ExpressionSettingType.Transporter then
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      self.uiBinder.lab_info.text = slotData.Name
      local sceneTagTableRow = Z.TableMgr.GetRow("SceneTagTableMgr", slotData.SceneTag)
      if sceneTagTableRow then
        self.uiBinder.img_transproter:SetImage(sceneTagTableRow.Icon1)
      end
    end
  else
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    self.uiBinder.img_emoji:SetImage(slotData.tableData.Icon)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_emoji, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_emoji, true)
  end
end

function ExpressionEmojiItem:OnPointerClick(go, eventData)
  self.parent.UIView:AddEmoji(self.data_)
end

return ExpressionEmojiItem
