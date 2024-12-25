local ChatHyperLinkBase = class("ChatHyperLinkBase")

function ChatHyperLinkBase:ctor(type)
  self.shareDataProto_ = nil
  self.shareData_ = {}
  local chatHyperLinkRow = Z.TableMgr.GetTable("ChatHyperlinkMgr").GetRow(type)
  local shareContent = ""
  if chatHyperLinkRow then
    shareContent = chatHyperLinkRow.Content
  else
    logError("ChatHyperlinkMgr\230\156\170\230\137\190\229\136\176\233\133\141\231\189\174\228\191\161\230\129\175, id: " .. type)
  end
  self.shareContent_ = shareContent
  self.shareShowContent_ = ""
  self.Type = type
  self.shareBeforeTag_ = "[ <u>"
  self.shareAfterTag_ = "</u> ]"
end

function ChatHyperLinkBase:RefreshShareData(text1, data, text2, playerName, charId)
end

function ChatHyperLinkBase:CheckShareData(text)
  return false
end

function ChatHyperLinkBase:ClearShareData()
  self.shareDataProto_ = nil
  self.shareData_ = {}
  self.shareShowContent_ = ""
end

function ChatHyperLinkBase:GetShareContent()
  return self.shareShowContent_
end

function ChatHyperLinkBase:GetShareProtoData()
  return self.shareDataProto_
end

function ChatHyperLinkBase:GetShareData()
  return self.shareData_
end

return ChatHyperLinkBase
