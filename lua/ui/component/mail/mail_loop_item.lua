local super = require("ui.component.loopscrollrectitem")
local MailItem = class("MailItem", super)
local mailReadState = Z.PbEnum("MailState", "MailStateRead")
local mailGetState = Z.PbEnum("MailState", "MailStateGet")
local mailDelState = Z.PbEnum("MailState", "MailStateDelete")
local mailSendState = Z.PbEnum("MailState", "MailStateSend")
local mailVm = Z.VMMgr.GetVM("mail")

function MailItem:ctor()
end

function MailItem:OnInit()
  self.isInit_ = false
end

function MailItem:InitUi()
  self:SetVisible(self.uiBinder.group_already_get, false)
  self.uiBinder.c_com_player_portrait_item.Ref:SetVisible(self.uiBinder.c_com_player_portrait_item.img_mask, false)
  self:SetVisible(self.uiBinder.group_get, true)
  self:SetVisible(self.uiBinder.group_status_selected, false)
  self:SetVisible(self.uiBinder.group_status_normal, true)
end

function MailItem:Refresh()
  if not self.isInit_ then
    self.isInit_ = true
    self.uiBinder.anim_mail_tpl:Restart(Z.DOTweenAnimType.Open)
  end
  self.uiBinder.Ref.UIComp:SetVisible(true)
  local index = self.component.Index + 1
  self.mailData = self.parent:GetDataByIndex(index)
  self:InitUi()
  local title = mailVm.GetMailShowContext(self.mailData.mailTitle, self.mailData.titlePrams)
  local mailTab
  if self.mailData.mailConfigId then
    mailTab = Z.TableMgr.GetTable("MailTableMgr").GetRow(self.mailData.mailConfigId, true)
  end
  if mailTab and mailTab.MailType > 0 then
    title = mailVm.GetMailShowContext(mailTab.Title, self.mailData.titlePrams)
  end
  self.uiBinder.lab_mail_item_title_grey.text = title
  self.uiBinder.lab_mail_item_title.text = title
  if not self.mailData.timeoutMs or 0 >= self.mailData.timeoutMs then
    self.uiBinder.lab_mail_item_time.text = Lang("MailPermanent")
    self.uiBinder.lab_mail_item_time_grey.text = Lang("MailPermanent")
  else
    local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    local endTime = math.floor(tonumber(self.mailData.timeoutMs) / 1000)
    local text = mailVm.GetDateNum(nowTime, endTime)
    self.uiBinder.lab_mail_item_time.text = text
    self.uiBinder.lab_mail_item_time_grey.text = text
  end
  self:mailState()
  self:SetVisible(self.uiBinder.img_redpoint, false)
  local npcTab = Z.TableMgr.GetTable("NpcTableMgr").GetRow(self.mailData.sendId)
  if npcTab == nil then
    return
  end
  local imageName = npcTab.NpcIcon
  local path = "ui/atlas/avatar/" .. imageName
  self.uiBinder.c_com_player_portrait_item.img_portrait:SetImage(path)
  self.uiBinder.c_com_player_portrait_item.Ref:SetVisible(self.uiBinder.c_com_player_portrait_item.img_portrait, true)
  self.uiBinder.c_com_player_portrait_item.Ref:SetVisible(self.uiBinder.c_com_player_portrait_item.rimg_portrait, false)
end

function MailItem:mailState()
  if table.zcount(self.mailData.appendix) > 0 then
    self:SetVisible(self.uiBinder.group_icon_receive, true)
    self:SetVisible(self.uiBinder.group_icon_received, false)
  else
    self:SetVisible(self.uiBinder.group_icon_receive, false)
    self:SetVisible(self.uiBinder.group_icon_received, false)
  end
  if mailReadState == self.mailData.mailState then
    if table.zcount(self.mailData.appendix) == 0 then
      self:isShowUi(true)
    end
  elseif mailGetState == self.mailData.mailState then
    if table.zcount(self.mailData.appendix) > 0 then
      self:SetVisible(self.uiBinder.group_icon_receive, false)
      self:SetVisible(self.uiBinder.group_icon_received, true)
    end
    self:isShowUi(true)
  elseif mailDelState == self.mailData.mailState then
  elseif mailSendState == self.mailData.mailState then
    self:isShowUi(false)
  end
end

function MailItem:isShowUi(flag)
  self:SetVisible(self.uiBinder.group_already_get, flag)
  self.uiBinder.group_already_get.alpha = flag and 0.5 or 0
  self:SetVisible(self.uiBinder.group_get, not flag)
  self.uiBinder.c_com_player_portrait_item.Ref:SetVisible(self.uiBinder.c_com_player_portrait_item.img_mask, flag)
end

function MailItem:Selected(selected)
  self:SetVisible(self.uiBinder.group_status_selected, selected)
  if selected then
    if mailReadState ~= self.mailData.mailState and mailGetState ~= self.mailData.mailState then
      Z.CoroUtil.create_coro_xpcall(function()
        mailVm.AsyncReadMail(self.mailData.mailUuid, self.parent.uiView.cancelSource:CreateToken())
      end)()
    end
    self.parent.uiView:SelectMailItem(self.component.Index, self.mailData)
  end
end

function MailItem:SetVisible(comp, visible)
  self.uiBinder.Ref:SetVisible(comp, visible)
end

function MailItem:OnUnInit()
  self.isInit_ = false
end

return MailItem
