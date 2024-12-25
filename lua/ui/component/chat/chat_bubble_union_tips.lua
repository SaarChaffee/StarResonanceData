local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleUnionTips = class("ChatBubbleUnionTips", super)

function ChatBubbleUnionTips:OnInit()
  super.OnInit(self)
  self.uiBinder.btn_go:AddListener(function()
    if self.data_ then
      local noticeConfigId = Z.ChatMsgHelper.GetNoticeConfigId(self.data_)
      if not noticeConfigId or noticeConfigId == 0 then
        return
      end
      local chatHyperLink = Z.TableMgr.GetTable("ChatHyperlinkMgr").GetRow(noticeConfigId)
      if not chatHyperLink then
        return
      end
      if chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionAlbum then
        local albumMainData = Z.DataMgr.Get("album_main_data")
        albumMainData:SetAlbumDefaultTab(E.AlbumTabType.EAlbumUnionTemporary)
        Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.Album)
      elseif chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionLock then
        local funcPreviewVM = Z.VMMgr.GetVM("function_preview")
        funcPreviewVM.OpenFuncPreviewWindow(E.UnionFuncId.Union)
      elseif chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionUnlock then
        local helpsSysVm = Z.VMMgr.GetVM("helpsys")
        helpsSysVm.OpenMulHelpSysView(7000)
      end
    end
  end)
end

function ChatBubbleUnionTips:OnRefresh(data)
  super.OnRefresh(self, data)
  local noticeConfigId = Z.ChatMsgHelper.GetNoticeConfigId(self.data_)
  if not noticeConfigId or noticeConfigId == 0 then
    return
  end
  local btnContent = ""
  local chatHyperLink = Z.TableMgr.GetTable("ChatHyperlinkMgr").GetRow(noticeConfigId)
  if not chatHyperLink then
    return
  end
  if chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionAlbum then
    btnContent = Lang("UnionAlbum")
  elseif chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionLock then
    btnContent = Lang("FunctionOpenTips")
  elseif chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionUnlock then
    btnContent = Lang("UnionAskTips")
  end
  local contentWidth = 0
  if btnContent == "" then
    contentWidth = 490
  else
    contentWidth = 250
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_go, btnContent ~= "")
  self.uiBinder.lab_go.text = btnContent
  self.uiBinder.lab_content_ref:SetWidth(contentWidth)
  local showContent = self.chatMainVm_.GetShowMsg(data, self.uiBinder.lab_content, self.uiBinder.Trans)
  self.uiBinder.lab_content.text = showContent
  local maxHeight = 31
  if btnContent ~= "" then
    maxHeight = 58
  end
  local size = self.uiBinder.lab_content:GetPreferredValues(showContent, contentWidth, maxHeight)
  local height = math.max(size.y, maxHeight)
  self.uiBinder.lab_content_ref:SetHeight(height)
  self.uiBinder.img_bg_ref:SetHeight(height + 52)
  if self.isShowChannelOrName_ then
    self.uiBinder.Trans:SetHeight(height + 122)
    self.uiBinder.img_bg_ref:SetAnchorPosition(143, -65)
  else
    self.uiBinder.Trans:SetHeight(height + 90)
    self.uiBinder.img_bg_ref:SetAnchorPosition(143, -31.7)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

return ChatBubbleUnionTips
