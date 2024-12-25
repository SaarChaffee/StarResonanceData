local super = require("ui.component.loop_list_view_item")
local ChatBubbleChannelNotice = class("ChatBubbleChannelNotice", super)

function ChatBubbleChannelNotice:OnRefresh(data)
  if data == nil then
    return
  end
  local sourceImgWidth = 0
  local type, id, headStr = Z.ChatMsgHelper.GetSystemType(data)
  if type == E.ESystemTipInfoType.ItemInfo then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_source, false)
    self.uiBinder.lab_source.text = headStr
    if id and 0 < id then
      local config = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
      if config then
        local itemVm = Z.VMMgr.GetVM("items")
        self.uiBinder.rimg_source:SetImage(itemVm.GetItemIcon(id))
        self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_source, true)
        sourceImgWidth = 40
      end
    end
  else
    self.uiBinder.lab_source.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_source, false)
  end
  local chatMainData = Z.DataMgr.Get("chat_main_data")
  local config = chatMainData:GetConfigData(Z.ChatMsgHelper.GetChannelId(data))
  if config then
    self.uiBinder.lab_sys.text = config.ChannelName
    self.uiBinder.img_notice_bg:SetColorByHex(config.NoticeStyle)
  end
  local chatMainVm = Z.VMMgr.GetVM("chat_main")
  self.uiBinder.lab_content.text = chatMainVm.GetShowMsg(data, self.uiBinder.lab_content, self.uiBinder.lab_content_ref)
  local sourceLabSize = self.uiBinder.lab_source:GetPreferredValues()
  self.uiBinder.lab_content_ref:SetOffsetMin(sourceLabSize.x + sourceImgWidth + 98, 0)
  local contentLabHeight = self.uiBinder.lab_content:GetPreferredValues().y
  local labHeight = math.max(sourceLabSize.y, contentLabHeight)
  self.uiBinder.Trans:SetHeight(labHeight + 15)
end

return ChatBubbleChannelNotice
