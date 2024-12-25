local UI = Z.UI
local super = require("ui.ui_subview_base")
local Mail_windowView = class("Mail_windowView", super)
local MailQuantityMax = Z.Global.MailQuantityMax
local WorldProxy = require("zproxy.world_proxy")
local loopScrollRect = require("ui/component/loopscrollrect")
local mailItemLoop = require("ui.component.mail.mail_loop_item")
local loopListView = require("ui.component.loop_list_view")
local mailRewardItemLoop = require("ui.component.mail.mail_reaward_loop_item")
local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")

function Mail_windowView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "mail_window_view", "mail/mail_window", UI.ECacheLv.None)
  self.mailData_ = Z.DataMgr.Get("mail_data")
  self.MailVm_ = Z.VMMgr.GetVM("mail")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
end

function Mail_windowView:OnActive()
  self:initFunc()
  self:initMailData()
  self:onInitRed()
  self:BindLuaAttrWatchers()
  self:startAnimatedShow()
  self.mailData_:SortAllMailData()
  self:refreshMailLoopData()
end

function Mail_windowView:OnDeActive()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_normal, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_content, false)
  self.mailScrollRect_:ClearCells()
  self:clearRed()
  self.mailRewardList_:UnInit()
end

function Mail_windowView:OnRefresh()
end

function Mail_windowView:initMailData()
  self.uiBinder.Trans:SetOffsetMin(-92, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.NowSelectMailItemData = nil
  self.selectItemIndex_ = 0
  self.uiBinder.lab_max.text = "/" .. MailQuantityMax
  self.mailScrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_mail, self, mailItemLoop)
  self.mailRewardList_ = loopListView.new(self, self.uiBinder.node_reward_list, mailRewardItemLoop, "com_item_square_8")
  self.mailRewardList_:Init({})
  self.uiBinder.tog_important.group = self.uiBinder.group_top
  self.uiBinder.tog_normal.group = self.uiBinder.group_top
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
  local importantUnReadList = self.mailData_:GetImportantUnReadList()
  local normalUnReadList = self.mailData_:GetNormalUnReadList()
  if 0 < table.zcount(importantUnReadList) or table.zcount(normalUnReadList) == 0 then
    self.uiBinder.tog_important.isOn = true
    self.mailData_:SetIsImportant(true)
    self:clickImportantAnimatedShow()
    self:onClickImportRed()
  else
    self.uiBinder.tog_normal.isOn = true
    self.mailData_:SetIsImportant(false)
    self.MailVm_.ClearMailRed(false)
    self:onClickNormalRed()
  end
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.mailData_:GetIsInit() then
      self.MailVm_.AsyncGetMailList(self.cancelSource)
    end
    local newMailList = self.mailData_:GetNewMailList()
    if 0 < #newMailList then
      self.MailVm_.AsyncCheckNewMailList(self.cancelSource)
    end
  end)()
  Z.RichTextHelper.ClickLink(self.uiBinder.lab_txt_mail_content, function(linkType, linkContent, text)
    if linkType == E.ELinkType.Recordclick then
      local str = string.zconcat(self.NowSelectMailItemData.mailUuid, "|", self.NowSelectMailItemData.mailConfigId, "|", self.NowSelectMailItemData.mailTitle, "|", text, "|", linkContent)
      WorldProxy.UploadTLogBody("MailClickUrlFlow", str)
    end
  end)
end

function Mail_windowView:initFunc()
  self.uiBinder.tog_important:AddListener(function(isOn)
    if self.mailData_:GetIsImportant() == isOn then
      return
    end
    self.mailData_:SetIsImportant(isOn)
    self.selectItemIndex_ = 0
    if isOn then
      self:clickImportantAnimatedShow()
      self:onClickImportRed()
      self.mailData_:SortMailData(false)
    else
      self.MailVm_.ClearMailRed(false)
      self:onClickNormalRed()
      self:clickNormalAnimatedShow()
      self.mailData_:SortMailData(true)
    end
    self:refreshMailLoopData()
  end)
  self:AddAsyncClick(self.uiBinder.btn_quick_pick, function()
    self.MailVm_.GetAllMailAppendix(self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_delete_left, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DeleAllEmail"), function()
      self.MailVm_.DeleteAllReadMail(self.cancelSource:CreateToken())
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  end)
  self:AddClick(self.uiBinder.btn_recept, function()
    local mailTab = {}
    mailTab[1] = self.NowSelectMailItemData.mailUuid
    self.MailVm_.GetMailAppendix(mailTab)
  end)
  self:AddClick(self.uiBinder.btn_com_check, function()
    local awardList_ = self.NowSelectMailItemData.awardIds
    if table.zcount(awardList_) > 0 then
      local definitelyList = self.awardPreviewVM_.GetAllAwardPreListByIds(awardList_)
      self.awardPreviewVM_.OpenRewardDetailViewByListData(definitelyList)
    else
      self.awardPreviewVM_.OpenRewardDetailViewByItemList(self.NowSelectMailItemData.appendix)
    end
  end)
  self:AddClick(self.uiBinder.btn_tips, function()
    self.helpsysVM_.OpenFullScreenTipsView(30002)
  end)
  self:AddAsyncClick(self.uiBinder.btn_delete, function()
    local mailTab = {}
    table.insert(mailTab, self.NowSelectMailItemData.mailUuid)
    local ret = self.MailVm_.DeleteMail(mailTab, self.cancelSource:CreateToken())
    if ret.errCode == 0 then
      self.NowSelectMailItemData = nil
      self.selectItemIndex_ = 0
      self:refreshMailLoopData()
    end
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    Z.VMMgr.GetVM("socialcontact_main").CloseSocialContactView()
  end)
end

function Mail_windowView:onInitRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.MailImport, self, self.uiBinder.node_red_import)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.MailNormal, self, self.uiBinder.node_red_normal)
end

function Mail_windowView:onClickImportRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.MailImport)
end

function Mail_windowView:onClickNormalRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.MailNormal)
end

function Mail_windowView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.MailImport)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.MailNormal)
end

function Mail_windowView:mailType()
  if not self.mailData_:GetIsImportant() then
    self:refreshBtn()
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete_left, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_quick_pick, false)
  end
end

function Mail_windowView:SelectMailItem(itemIndex, mailData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_normal, mailData == nil and true or false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_content, mailData ~= nil and true or false)
  if mailData == nil then
    return
  end
  self.selectItemIndex_ = itemIndex
  local mailTab
  if mailData.mailConfigId then
    mailTab = Z.TableMgr.GetTable("MailTableMgr").GetRow(mailData.mailConfigId, true)
  end
  local title = self.MailVm_.GetMailShowContext(mailData.mailTitle, mailData.titlePrams)
  local mailBody = self.MailVm_.GetMailShowContext(mailData.mailBody, mailData.bodyPrams)
  if mailTab and mailTab.MailType > 0 then
    title = self.MailVm_.GetMailShowContext(mailTab.Title, mailData.titlePrams)
    mailBody = self.MailVm_.GetMailShowContext(mailTab.Content, mailData.bodyPrams)
  end
  self.uiBinder.lab_mail_title.text = title
  self.uiBinder.lab_txt_mail_content.text = mailBody
  local timeStrYMD = Z.TimeTools.FormatTimeToYMD(mailData.createTime)
  local timeStrHMS = Z.TimeTools.FormatTimeToHMS(mailData.createTime)
  self.uiBinder.lab_time.text = string.format("%s %s", timeStrYMD, timeStrHMS)
  if mailData.sendName == "" then
    if mailTab then
      self.uiBinder.lab_send.text = mailTab.NpcName
    else
      self.uiBinder.lab_send.text = ""
    end
  else
    self.uiBinder.lab_send.text = mailData.sendName
  end
  self.NowSelectMailItemData = mailData
  local hasAward = 0 < table.zcount(mailData.awardIds)
  local hasItem = 0 < table.zcount(mailData.appendix)
  self:isRewardMail(hasAward or hasItem)
end

function Mail_windowView:isRewardMail(flag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_title, flag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_com_check, flag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reward_list, flag)
  if flag then
    local bGetReward = self.NowSelectMailItemData.mailState == Z.PbEnum("MailState", "MailStateGet")
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_recept, not bGetReward)
    local awardIds = self.NowSelectMailItemData.awardIds
    self.itemList_ = {}
    if table.zcount(awardIds) > 0 then
      local awardList = self.awardPreviewVM_.GetAllAwardPreListByIds(awardIds)
      for _, v in pairs(awardList) do
        local awardData_ = v
        local labType, lab = self.awardPreviewVM_.GetPreviewShowNum(awardData_)
        local itemData = {
          configId = awardData_.awardId,
          labType = labType,
          lab = lab,
          isShowZero = false,
          isShowOne = true,
          isShowReceive = awardData_.beGet ~= nil and awardData_.beGet,
          isSquareItem = true,
          PrevDropType = awardData_.PrevDropType
        }
        table.insert(self.itemList_, itemData)
      end
    else
      itemSortFactoryVm.DefaultSendAwardSortByConfigId(self.NowSelectMailItemData.appendix)
      local reward = self.NowSelectMailItemData.appendix
      for i = 1, #reward do
        local itemData = {
          configId = reward[i].configId,
          labType = E.ItemLabType.Num,
          lab = reward[i].count,
          itemInfo = reward[i],
          isShowReceive = self.NowSelectMailItemData.mailState == Z.PbEnum("MailState", "MailStateGet"),
          isSquareItem = true
        }
        table.insert(self.itemList_, itemData)
      end
    end
    self.mailRewardList_:RefreshListView(self.itemList_, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete, bGetReward)
    self.uiBinder.tog_img_icon.isOn = bGetReward
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_recept, flag)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete, not flag)
  end
end

function Mail_windowView:loadingMailData()
  local data = self.mailData_:GetIsImportant() and self.mailData_:GetImportantMailList() or self.mailData_:GetNormalMailList()
  if table.zcount(data) > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_login, true)
  end
end

function Mail_windowView:refreshMailLoopData()
  local data = self.mailData_:GetIsImportant() and self.mailData_:GetImportantMailList() or self.mailData_:GetNormalMailList()
  local isEmpty = table.zcount(data) == 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, isEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_normal, isEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_content, not isEmpty)
  self:refreshBtn()
  if isEmpty then
    self.uiBinder.loopscroll_mail_ref:SetOffsetMin(0, 86)
  else
    self.uiBinder.loopscroll_mail_ref:SetOffsetMin(0, 168)
  end
  self.mailScrollRect_:SetSelected(self.selectItemIndex_)
  if 0 < self.selectItemIndex_ then
    self.mailScrollRect_:RefreshData(data)
  else
    self.mailScrollRect_:SetData(data)
  end
  self:mailType()
  self:setMailnum()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_login, false)
end

function Mail_windowView:refreshBtn()
  local data = self.mailData_:GetIsImportant() and self.mailData_:GetImportantMailList() or self.mailData_:GetNormalMailList()
  local isEmpty = table.zcount(data) == 0
  local isShowBtn = not isEmpty and not self.mailData_:GetIsImportant()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete_left, not isEmpty and not self.mailData_:GetIsImportant())
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_quick_pick, not isEmpty and not self.mailData_:GetIsImportant())
  self.uiBinder.node_bottom:SetHeight(isShowBtn and 158 or 100)
end

function Mail_windowView:setMailnum()
  self.uiBinder.lab_current.text = self.mailData_:GetImportantMailNum() + self.mailData_:GetNormalMailNum()
end

function Mail_windowView:BindLuaAttrWatchers()
  Z.EventMgr:Add(Z.ConstValue.Mail.RefreshMailBtn, self.refreshBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Mail.RefreshMailLoopData, self.refreshMailLoopData, self)
  Z.EventMgr:Add(Z.ConstValue.Mail.LoadingMail, self.loadingMailData, self)
  Z.EventMgr:Add(Z.ConstValue.Mail.ReceiveNewMal, self.ReceiveNewMal, self)
end

function Mail_windowView:ReceiveNewMal(mailUuid)
  Z.CoroUtil.create_coro_xpcall(function()
    self.MailVm_.AsyncGetNewMailByUuid(mailUuid, self.cancelSource:CreateToken())
  end)()
end

function Mail_windowView:clickImportantAnimatedShow()
  self.uiBinder.anim_mail:Restart(Z.DOTweenAnimType.Tween_1)
end

function Mail_windowView:clickNormalAnimatedShow()
  self.uiBinder.anim_mail:Restart(Z.DOTweenAnimType.Tween_2)
end

function Mail_windowView:startAnimatedShow()
  if self.viewData.isFirstOpen then
    self.uiBinder.anim_mail:Restart(Z.DOTweenAnimType.Open)
  end
end

return Mail_windowView
