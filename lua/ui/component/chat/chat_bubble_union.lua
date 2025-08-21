local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleUnion = class("ChatBubbleUnion", super)

function ChatBubbleUnion:OnInit()
  super.OnInit(self)
  self.uiBinder.btn_union:AddListener(function()
    if not self.data_ then
      return
    end
    if self.chatHyperLink_.Type == E.ChatHyperLinkShowType.NpcHeadTips then
      if self.chatHyperLink_.FuncType == E.ClientPlaceHolderType.UnionAlbum then
        self:openAlbumMain()
      elseif self.chatHyperLink_.FuncType == E.ClientPlaceHolderType.UnionLock then
        self:openUnionPreview()
      elseif self.chatHyperLink_.FuncType == E.ClientPlaceHolderType.UnionUnlock then
        self:openUnionHelp()
      end
    elseif self.chatHyperLink_.Type == E.ChatHyperLinkShowType.PictureBtnTips then
      self:unionQuickJump()
    elseif self.chatHyperLink_.Type == E.ChatHyperLinkShowType.PictureBtnTipsNew then
      self:openUnionUnlockScene()
    end
  end)
end

function ChatBubbleUnion:OnRefresh(data)
  super.OnRefresh(self, data)
  self.data_ = data
  local noticeConfigId = Z.ChatMsgHelper.GetNoticeConfigId(self.data_)
  if not noticeConfigId or noticeConfigId == 0 then
    return
  end
  self.chatHyperLink_ = Z.TableMgr.GetTable("ChatHyperlinkMgr").GetRow(noticeConfigId)
  if not self.chatHyperLink_ then
    return
  end
  if self.chatHyperLink_.Type == E.ChatHyperLinkShowType.NpcHeadTips then
    if self.chatHyperLink_.FuncType == 0 then
      self:refreshOnlyShowTips()
    elseif self.chatHyperLink_.FuncType == E.ClientPlaceHolderType.UnionAlbum then
      self:refreshOnlyShowBtn(Lang("UnionAlbum"))
    elseif self.chatHyperLink_.FuncType == E.ClientPlaceHolderType.UnionLock then
      self:refreshOnlyShowBtn(Lang("FunctionOpenTips"))
    elseif self.chatHyperLink_.FuncType == E.ClientPlaceHolderType.UnionUnlock then
      self:refreshOnlyShowBtn(Lang("UnionAskTips"))
    end
  elseif self.chatHyperLink_.Type == E.ChatHyperLinkShowType.PictureBtnTips then
    self:refreshUnionInfo()
  elseif self.chatHyperLink_.Type == E.ChatHyperLinkShowType.PictureBtnTipsNew then
    self:refreshUnionCrowd()
  end
  if self.chatHyperLink_.NpcHeadEscape ~= "" then
    self.uiBinder.lab_name.text = self.chatHyperLink_.NpcHeadEscape
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

function ChatBubbleUnion:refreshBubbleSize(isShowIcon, isShowBtn, content)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, isShowIcon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, isShowBtn)
  self:refreshChannelOffest()
  local channelOffest = (Z.IsPCUI or self.isShowChannelOrName_) and 30 or 0
  local contentHeight = self:getContentHeight(content)
  if isShowBtn then
    local contentOffest = Z.IsPCUI and 39 or 78
    self.uiBinder.lab_content_ref:SetAnchorPosition(0, contentOffest)
  else
    self.uiBinder.lab_content_ref:SetAnchorPosition(0, 5)
  end
  self.uiBinder.lab_content_ref:SetHeight(contentHeight)
  local iconHight = self:getIconHeight(isShowIcon)
  self.uiBinder.img_bg_ref:SetHeight(iconHight)
  local btnHeight = self:getBtnHeight(isShowBtn)
  local height = contentHeight + iconHight + btnHeight + 15
  self.uiBinder.img_bg_ref:SetHeight(height)
  if self.uiBinder.bg_fitter then
    self.uiBinder.bg_fitter:RefreshRectSize()
  end
  local heightOffest = 22
  self.uiBinder.Trans:SetHeight(height + heightOffest + channelOffest)
end

function ChatBubbleUnion:refreshChannelOffest()
  if Z.IsPCUI then
    return
  end
  local offestX = Z.ChatMsgHelper.GetIsSelfMessage(self.data_) and -143 or 143
  if self.isShowChannelOrName_ then
    self.uiBinder.img_bg_ref:SetAnchorPosition(offestX, -45)
  else
    self.uiBinder.img_bg_ref:SetAnchorPosition(offestX, -15)
  end
end

function ChatBubbleUnion:getContentHeight(content)
  local width = Z.IsPCUI and 234 or 450
  local height = Z.IsPCUI and 42 or 70
  local size = self.uiBinder.lab_content:GetPreferredValues(content, width, height)
  return math.max(size.y, height)
end

function ChatBubbleUnion:getIconHeight(isShowIcon)
  if not isShowIcon then
    return 0
  end
  return Z.IsPCUI and 78 or 154
end

function ChatBubbleUnion:getBtnHeight(isShowBtn)
  if not isShowBtn then
    return 0
  end
  return Z.IsPCUI and 30 or 60
end

function ChatBubbleUnion:openAlbumMain()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData:SetAlbumDefaultTab(E.AlbumTabType.EAlbumUnionTemporary)
  Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.Album)
end

function ChatBubbleUnion:openUnionPreview()
  local funcPreviewVM = Z.VMMgr.GetVM("function_preview")
  funcPreviewVM.OpenFuncPreviewWindow(E.UnionFuncId.Union)
end

function ChatBubbleUnion:openUnionHelp()
  local helpsSysVm = Z.VMMgr.GetVM("helpsys")
  helpsSysVm.OpenMulHelpSysView(7000)
end

function ChatBubbleUnion:unionQuickJump()
  local unionBuild = Z.ChatMsgHelper.GetUnionBuild(self.data_)
  if unionBuild then
    local quickjumpVm_ = Z.VMMgr.GetVM("quick_jump")
    quickjumpVm_.DoJumpByConfigParam(unionBuild.QuickJumpType, unionBuild.QuickJumpParam)
  end
end

function ChatBubbleUnion:openUnionUnlockScene()
  Z.UIMgr:OpenView("union_unlockscene_main")
end

function ChatBubbleUnion:refreshOnlyShowTips()
  local content = self.chatMainVm_.GetShowMsg(self.data_, self.uiBinder.lab_content, self.uiBinder.Trans)
  self.uiBinder.lab_content.text = content
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, false)
  self.uiBinder.node_crowd.Ref.UIComp:SetVisible(false)
  self:refreshBubbleSize(false, false, content)
end

function ChatBubbleUnion:refreshOnlyShowBtn(btnContent)
  local content = self.chatMainVm_.GetShowMsg(self.data_, self.uiBinder.lab_content, self.uiBinder.Trans)
  self.uiBinder.lab_content.text = content
  self.uiBinder.lab_btn.text = btnContent
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, true)
  self.uiBinder.node_crowd.Ref.UIComp:SetVisible(false)
  self:refreshBubbleSize(false, true, content)
end

function ChatBubbleUnion:refreshUnionInfo()
  local content = self.chatMainVm_.GetShowMsg(self.data_, self.uiBinder.lab_content, self.uiBinder.Trans)
  self.uiBinder.lab_content.text = content
  local unionBuild = Z.ChatMsgHelper.GetUnionBuild(self.data_)
  if unionBuild then
    self.uiBinder.rimg_icon:SetImage(unionBuild.SmallPicture)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, true)
  self.uiBinder.node_crowd.Ref.UIComp:SetVisible(false)
  self.uiBinder.lab_btn.text = Lang("UnionAskTips")
  self:refreshBubbleSize(true, true, content)
end

function ChatBubbleUnion:refreshUnionCrowd()
  local content, param = self.chatMainVm_.GetShowMsg(self.data_, self.uiBinder.lab_content, self.uiBinder.Trans)
  self.uiBinder.lab_content.text = content
  if param then
    local val1 = 0
    local val2 = 1
    if param.arrVal then
      val1 = param.arrVal[1] or 0
      val2 = param.arrVal[2] or 1
    end
    self.uiBinder.lab_num.text = string.format("%s/%s", val1, val2)
    if val1 < val2 then
      self.uiBinder.lab_btn.text = Lang("Participatecrowdfunding")
    else
      self.uiBinder.lab_btn.text = Lang("Participatecrowdjioning")
    end
    self.uiBinder.node_crowd.Ref.UIComp:SetVisible(true)
  else
    self.uiBinder.node_crowd.Ref.UIComp:SetVisible(false)
  end
  self.uiBinder.rimg_icon:SetImage(Z.ConstValue.Chat.ChatUnionBubbleCrwodPicture)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, true)
  self:refreshBubbleSize(true, true, content)
end

return ChatBubbleUnion
