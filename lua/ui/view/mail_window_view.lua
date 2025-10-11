local UI = Z.UI
local super = require("ui.ui_subview_base")
local Mail_windowView = class("Mail_windowView", super)
local MailQuantityMax = Z.Global.MailQuantityMax
local WorldProxy = require("zproxy.world_proxy")
local mailItemLoop = require("ui.component.mail.mail_loop_item")
local loopListView = require("ui.component.loop_list_view")
local mailRewardItemLoop = require("ui.component.mail.mail_reaward_loop_item")
local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")

function Mail_windowView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "mail_window_view", "mail/mail_window", UI.ECacheLv.None, true)
end

function Mail_windowView:OnActive()
  self:initVMData()
  self:initFunc()
  self:onInitRed()
  self:initMailData()
  self:BindLuaAttrWatchers()
  self:startAnimatedShow()
end

function Mail_windowView:OnDeActive()
  self.mailLoopList_:UnInit()
  self.mailRewardList_:UnInit()
  self:clearRed()
  self:clearTogFunc()
end

function Mail_windowView:initMailData()
  self.uiBinder.tog_system:SetIsOnWithoutCallBack(true)
  self.uiBinder.tog_collect:SetIsOnWithoutCallBack(false)
  self:refreshLeftView(true)
  self:showMailEmptyState()
  self:asyncInitMailData()
end

function Mail_windowView:initVMData()
  self.mailData_ = Z.DataMgr.Get("mail_data")
  self.MailVm_ = Z.VMMgr.GetVM("mail")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.NowSelectMailItemData = nil
  self.selectItemIndex_ = 1
  self.isSystem_ = true
  self.mainUIData_.MainUIPCShowMail = false
  if not Z.IsPCUI then
    self.uiBinder.Trans:SetOffsetMin(-92, 0)
    self.uiBinder.Trans:SetOffsetMax(0, 0)
  end
end

function Mail_windowView:initFunc()
  self.uiBinder.tog_system.group = self.uiBinder.group_top
  self.uiBinder.tog_collect.group = self.uiBinder.group_top
  self.uiBinder.tog_system:AddListener(function(isOn)
    self.isSystem_ = isOn
    self:refreshLeftView(isOn)
    self:refreshMailLoopData()
  end)
  self:AddAsyncClick(self.uiBinder.btn_quick_pick, function()
    self.MailVm_.GetAllMailAppendix(self.cancelSource)
  end)
  self:AddClick(self.uiBinder.btn_delete_left, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DeleAllEmail"), function()
      self.MailVm_.DeleteAllReadMail(self.cancelSource:CreateToken())
    end)
  end)
  self:AddAsyncClick(self.uiBinder.btn_recept, function()
    local mailTab = {}
    mailTab[1] = self.NowSelectMailItemData.mailUuid
    self.MailVm_.GetMailAppendix(mailTab, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_com_check, function()
    if self.NowSelectMailItemData.isHaveAward then
      local definitelyList = self.awardPreviewVM_.GetAllAwardPreListByIds(self.NowSelectMailItemData.awardIds)
      self.awardPreviewVM_.OpenRewardDetailViewByListData(definitelyList)
    else
      self.awardPreviewVM_.OpenRewardDetailViewByItemList(self.NowSelectMailItemData.appendix)
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_delete, function()
    if not self.NowSelectMailItemData then
      return
    end
    if self.NowSelectMailItemData.isCollect then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("MailDeleteConfirmTips"), function()
        self:asyncDeleteCurMail()
      end, nil, E.DlgPreferencesType.Day, E.DlgPreferencesKeyType.MailDeleteConfirmTips)
    else
      self:asyncDeleteCurMail()
    end
  end)
  if not Z.IsPCUI then
    self:AddClick(self.uiBinder.btn_return, function()
      Z.VMMgr.GetVM("socialcontact_main").CloseSocialContactView()
    end)
    self:AddClick(self.uiBinder.btn_tips, function()
      self.helpsysVM_.OpenFullScreenTipsView(30002)
    end)
  end
  self:AddAsyncClick(self.uiBinder.btn_collect, function()
    if not self.NowSelectMailItemData or self.NowSelectMailItemData.isCollect then
      return
    end
    local ret = self.MailVm_.AsyncAddMailCollect(self.NowSelectMailItemData.mailUuid, self.cancelSource:CreateToken())
    if ret == 0 then
      self.NowSelectMailItemData.isCollect = true
      self.mailLoopList_:UpDateByIndex(self.selectItemIndex_, self.NowSelectMailItemData)
      self:refreshRightView()
    else
      Z.TipsVM.ShowTips(ret.errCode)
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_collect_cancel, function()
    if not self.NowSelectMailItemData or not self.NowSelectMailItemData.isCollect then
      return
    end
    local ret = self.MailVm_.AsyncCancelMailCollect(self.NowSelectMailItemData.mailUuid, self.cancelSource:CreateToken())
    if ret == 0 then
      self.NowSelectMailItemData.isCollect = false
      self.mailLoopList_:UpDateByIndex(self.selectItemIndex_, self.NowSelectMailItemData)
      self:refreshRightView()
    else
      Z.TipsVM.ShowTips(ret.errCode)
    end
  end)
  Z.RichTextHelper.ClickLink(self.uiBinder.lab_txt_mail_content, function(linkType, linkContent, text)
    if linkType == E.ELinkType.Recordclick then
      local str = string.zconcat(self.NowSelectMailItemData.mailUuid, "|", self.NowSelectMailItemData.mailConfigId, "|", self.NowSelectMailItemData.mailTitle, "|", text, "|", linkContent)
      WorldProxy.UploadTLogBody("MailClickUrlFlow", str)
    end
  end)
  self.mailLoopList_ = loopListView.new(self, self.uiBinder.loop_mail, mailItemLoop, "mail_tpl", true)
  self.mailLoopList_:Init({})
  self.mailRewardList_ = loopListView.new(self, self.uiBinder.node_reward_list, mailRewardItemLoop, "com_item_square_8", true)
  self.mailRewardList_:Init({})
  local width = Z.IsPCUI and 176 or 372
  local height = Z.IsPCUI and 40 or 64
  local offest = Z.IsPCUI and 30 or 42
  local size = self.uiBinder.lab_exceed:GetPreferredValues(Lang("MailShowTips"), width, height)
  self.imgBgHeight_ = size.y + offest
  self.uiBinder.img_lab_bg:SetHeight(self.imgBgHeight_)
  self.uiBinder.lab_max.text = "/" .. MailQuantityMax
end

function Mail_windowView:clearTogFunc()
  self.uiBinder.tog_collect.group = nil
  self.uiBinder.tog_system.group = nil
  self.uiBinder.tog_collect:RemoveAllListeners()
  self.uiBinder.tog_system:RemoveAllListeners()
  self.uiBinder.tog_collect.isOn = false
  self.uiBinder.tog_system.isOn = false
end

function Mail_windowView:refreshLeftView(isSystemMail)
  self.selectItemIndex_ = 1
  self.mailData_:SortMailData()
  if isSystemMail then
    self:clickNormalAnimatedShow()
    self.MailVm_.ClearMailRed()
    self:onClickNormalRed()
  else
    self:clickImportantAnimatedShow()
  end
end

function Mail_windowView:showMailEmptyState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_login, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_normal, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_content, false)
end

function Mail_windowView:asyncInitMailData()
  if self.mailData_:GetIsInit() or self.mailData_:GetServerMailNum() == 0 then
    self.mailData_:SetIsInit()
    self:onInitMailList()
  else
    self.MailVm_.AsyncInitMailList(self.cancelSource)
  end
end

function Mail_windowView:onInitMailList()
  Z.CoroUtil.create_coro_xpcall(function()
    local curServerTime = Z.ServerTime:GetServerTime() / 1000
    if self.mailData_:GetMailNum() == 0 and curServerTime - self.mailData_.LastGetMailListTime > 5 then
      self.MailVm_.AsyncCheckMailList()
      self.mailData_.LastGetMailListTime = Z.ServerTime:GetServerTime() / 1000
    end
    local newMailList = self.mailData_:GetNewMailList()
    if 0 < #newMailList then
      self.MailVm_.AsyncCheckNewMailList(self.cancelSource)
    end
    self.MailVm_.CheckMailTimeOut()
    self:refreshMailLoopData()
    self:checkMailTips()
  end)()
end

function Mail_windowView:checkMailTips()
  if self.mailData_:GetIsShowMailRemindClaimTips() then
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("MailGetTips"), function()
      Z.CoroUtil.create_coro_xpcall(function()
        self.MailVm_.GetAllMailAppendix(self.cancelSource)
      end)()
    end, nil, E.DlgPreferencesType.Day, E.DlgPreferencesKeyType.MailGetTips, nil, true)
  end
  if self.mailData_:GetIsShowMailRemindDeleteTips() then
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("MailDeleteTips"), function()
      Z.CoroUtil.create_coro_xpcall(function()
        self.MailVm_.DeleteAllReadMail(self.cancelSource:CreateToken())
      end)()
    end, nil, E.DlgPreferencesType.Day, E.DlgPreferencesKeyType.MailDeleteTips, nil, true)
  end
end

function Mail_windowView:onInitRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.MailNormal, self, self.uiBinder.node_red_system)
end

function Mail_windowView:onClickNormalRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.MailNormal)
end

function Mail_windowView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.MailNormal)
end

function Mail_windowView:SelectMailItem(itemIndex, mailData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_normal, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_mail_content, true)
  self.selectItemIndex_ = itemIndex
  self.NowSelectMailItemData = mailData
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
  local timeStrYMDHMS = Z.TimeFormatTools.TicksFormatTime(mailData.createTime, E.TimeFormatType.YMDHMS)
  self.uiBinder.lab_time.text = timeStrYMDHMS
  if mailData.sendName == "" then
    if mailTab then
      self.uiBinder.lab_send.text = mailTab.NpcName
    else
      self.uiBinder.lab_send.text = ""
    end
  else
    self.uiBinder.lab_send.text = mailData.sendName
  end
  self:isRewardMail(mailData.isHaveAward or mailData.isHaveAppendix)
  self:refreshRightView()
end

function Mail_windowView:isRewardMail(flag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_title, flag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_com_check, flag)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reward_list, flag)
  if flag then
    local bGetReward = self.NowSelectMailItemData.mailState == Z.PbEnum("MailState", "MailStateGet")
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_recept, not bGetReward)
    self.itemList_ = {}
    if self.NowSelectMailItemData.isHaveAward then
      local awardList = self.awardPreviewVM_.GetAllAwardPreListByIds(self.NowSelectMailItemData.awardIds)
      for _, v in pairs(awardList) do
        local awardData_ = v
        local labType, lab = self.awardPreviewVM_.GetPreviewShowNum(awardData_)
        local itemData = {
          configId = awardData_.awardId,
          labType = labType,
          lab = lab,
          isShowZero = false,
          isShowOne = true,
          isShowReceive = bGetReward,
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
          isShowReceive = bGetReward,
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

function Mail_windowView:asyncDeleteCurMail()
  local ret = self.MailVm_.DeleteMail({
    self.NowSelectMailItemData.mailUuid
  }, self.cancelSource:CreateToken())
  if ret.errCode == 0 then
    self.NowSelectMailItemData = nil
    self.selectItemIndex_ = 1
    self:refreshMailLoopData()
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function Mail_windowView:refreshMailLoopData()
  self.mailData_:CheckMailVaild()
  local data = self.mailData_:GetMailList()
  self.curList_ = {}
  if self.isSystem_ then
    self.curList_ = data
  else
    for i = 1, #data do
      if data[i].isCollect then
        self.curList_[#self.curList_ + 1] = data[i]
      end
    end
  end
  local isShowMail = self:refreshBtnState()
  local bottomOffest = Z.IsPCUI and 0 or 41
  self.uiBinder.loop_mail_ref:SetOffsetMin(0, self.bottomHeight_ + bottomOffest)
  if isShowMail then
    self.mailLoopList_:RefreshListView(self.curList_, false)
    self.mailLoopList_:ClearAllSelect()
    if self.selectItemIndex_ > #self.curList_ then
      self:showMailEmptyState()
    else
      self.mailLoopList_:SetSelected(self.selectItemIndex_)
    end
  else
    self.mailLoopList_:RefreshListView({}, false)
    self:showMailEmptyState()
  end
  self.uiBinder.lab_current.text = self.mailData_:GetMailNum()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_login, false)
end

function Mail_windowView:refreshBtnState()
  local isShowMail = #self.curList_ > 0
  local isShowBtn = isShowMail and self.isSystem_
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete_left, isShowBtn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_quick_pick, isShowBtn)
  local bottomOffest = isShowBtn and (Z.IsPCUI and 70 or 80) or Z.IsPCUI and 10 or 0
  self.bottomHeight_ = self.imgBgHeight_ + bottomOffest
  self.uiBinder.node_bottom:SetHeight(self.bottomHeight_)
  return isShowMail
end

function Mail_windowView:refreshRightView()
  if not self.NowSelectMailItemData then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_collect, not self.NowSelectMailItemData.isCollect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_collect_cancel, self.NowSelectMailItemData.isCollect)
end

function Mail_windowView:BindLuaAttrWatchers()
  Z.EventMgr:Add(Z.ConstValue.Mail.RefreshMailBtn, self.refreshBtnState, self)
  Z.EventMgr:Add(Z.ConstValue.Mail.RefreshMailLoopData, self.refreshMailLoopData, self)
  Z.EventMgr:Add(Z.ConstValue.Mail.ReceiveNewMal, self.ReceiveNewMal, self)
  Z.EventMgr:Add(Z.ConstValue.Mail.InitMailList, self.onInitMailList, self)
end

function Mail_windowView:ReceiveNewMal(mailUuid)
  Z.CoroUtil.create_coro_xpcall(function()
    self.MailVm_.AsyncGetNewMailByUuid(mailUuid, self.cancelSource:CreateToken())
    self.mainUIData_.MainUIPCShowMail = false
  end)()
end

function Mail_windowView:clickImportantAnimatedShow()
  if Z.IsPCUI then
  else
    self.uiBinder.anim_mail:Restart(Z.DOTweenAnimType.Tween_1)
  end
end

function Mail_windowView:clickNormalAnimatedShow()
  if Z.IsPCUI then
  else
    self.uiBinder.anim_mail:Restart(Z.DOTweenAnimType.Tween_2)
  end
end

function Mail_windowView:startAnimatedShow()
  if Z.IsPCUI then
  elseif self.viewData.isFirstOpen then
    self.uiBinder.anim_mail:Restart(Z.DOTweenAnimType.Open)
  end
end

return Mail_windowView
