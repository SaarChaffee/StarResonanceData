local super = require("ui.component.loop_list_view_item")
local ChatBubbleChannelNotice = class("ChatBubbleChannelNotice", super)

function ChatBubbleChannelNotice:OnInit()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function ChatBubbleChannelNotice:OnRefresh(data)
  if data == nil then
    return
  end
  self.data_ = data
  local leftOffest = Z.IsPCUI and 25 or 32
  local channelWidth = self:refreshChannelName()
  leftOffest = leftOffest + channelWidth + 15
  leftOffest = self:refreshItemSource(leftOffest)
  self:refreshContent(leftOffest)
end

function ChatBubbleChannelNotice:refreshChannelName()
  local config = self.chatMainData_:GetConfigData(Z.ChatMsgHelper.GetChannelId(self.data_))
  local channelContent = ""
  if config then
    channelContent = config.ChannelName
    self.uiBinder.lab_sys.text = config.ChannelName
    self.uiBinder.img_notice_bg:SetColorByHex(config.NoticeStyle)
  else
    channelContent = Lang("chat_system")
  end
  self.uiBinder.lab_sys.text = channelContent
  local labChannelSize = self.uiBinder.lab_sys:GetPreferredValues(channelContent)
  self.uiBinder.img_notice_ref:SetWidth(labChannelSize.x + 10)
  return labChannelSize.x
end

function ChatBubbleChannelNotice:refreshItemSource(leftOffest)
  local type, id, headStr = Z.ChatMsgHelper.GetSystemType(self.data_)
  if type == E.ESystemTipInfoType.ItemInfo then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_source, false)
    self.uiBinder.lab_source.text = headStr
    local sourceLabSize = self.uiBinder.lab_source:GetPreferredValues(headStr)
    self.uiBinder.lab_source_ref:SetWidth(sourceLabSize.x)
    self.uiBinder.lab_source_ref.localPosition = Vector3.New(leftOffest, -5, 0)
    leftOffest = leftOffest + sourceLabSize.x + 5
    if id and 0 < id then
      local config = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
      if config then
        self.uiBinder.rimg_source:SetImage(self.itemVm_.GetItemIcon(id))
        self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_source, true)
        local rimgSourceHeight = Z.IsPCUI and -2 or 0
        self.uiBinder.rimg_source_ref.localPosition = Vector3.New(leftOffest, rimgSourceHeight, 0)
        local rimgsourceOffest = Z.IsPCUI and 28 or 40
        leftOffest = leftOffest + rimgsourceOffest + 5
      end
    end
  else
    self.uiBinder.lab_source.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_source, false)
  end
  return leftOffest
end

function ChatBubbleChannelNotice:refreshContent(leftOffest)
  local content = self.chatMainVm_.GetShowMsg(self.data_, self.uiBinder.lab_content, self.uiBinder.lab_content_ref)
  self.uiBinder.lab_content.text = content
  self.uiBinder.lab_content_ref:SetOffsetMin(leftOffest, 0)
  self.uiBinder.lab_content_ref:SetOffsetMax(-10, 0)
  self.uiBinder.lab_content_ref.localPosition = Vector3.New(leftOffest, -5, 0)
  local height = Z.IsPCUI and 20 or 30
  local contentSize = self.uiBinder.lab_content:GetPreferredValues(content, self.uiBinder.lab_content_ref.rect.width, height)
  self.uiBinder.lab_content_ref:SetHeight(height)
  local labHeight = math.max(height + 10, contentSize.y)
  self.uiBinder.Trans:SetHeight(labHeight + 10)
end

return ChatBubbleChannelNotice
