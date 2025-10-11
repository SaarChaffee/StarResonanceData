local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_idcard_subView = class("Personalzone_idcard_subView", super)
local ReportDefine = require("ui.model.report_define")
local PersonalZoneDefine = require("ui.model.personalzone_define")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local LanguagePrompt = {
  [PersonalZoneDefine.IdCardEditorType.Badge] = "LongPressDragAdjustBadgeLocation",
  [PersonalZoneDefine.IdCardEditorType.Album] = "LongPressDragAdjustAlbumLocation"
}
local TogFunction = {
  [E.FunctionID.PersonalzoneMedal] = {
    subView = "ui/view/personalzone_main_badge_sub_view",
    redDot = E.RedType.PersonalzoneMedal,
    editorType = PersonalZoneDefine.IdCardEditorType.Badge
  },
  [E.FunctionID.PersonalzonePhoto] = {
    subView = "ui/view/personalzone_main_photo_sub_view",
    editorType = PersonalZoneDefine.IdCardEditorType.Album
  }
}

function Personalzone_idcard_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_idcard_sub", "personalzone/personalzone_idcard_sub", UI.ECacheLv.None)
  self.parentView_ = parent
  self.viewData = nil
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.gotofuncVm_ = Z.VMMgr.GetVM("gotofunc")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.reportVM_ = Z.VMMgr.GetVM("report")
  self.heroDungeionMainVm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.editorType_ = PersonalZoneDefine.IdCardEditorType.None
  self.togs_ = {}
  self.subView_ = {}
end

function Personalzone_idcard_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.togs_ = {}
  self.subView_ = {}
  self.curSubView_ = nil
  self.editorType_ = self.viewData.editorType
  self:initBtns()
  self:refreshPlayerInfo()
  self:refreshBtns()
  if self.viewData.editorType == PersonalZoneDefine.IdCardEditorType.None then
    self:refreshTimeTags()
    self:refreshSubTogs()
  else
    self:RefreshTimeTags(self.viewData.onlinePeriods, self.viewData.tags)
    self:ChangeSubTogs(self.viewData.subFuncs, self.viewData.selectFuncId, self.viewData.editorType)
  end
  self:binderEvents()
  self:binderRedDot()
end

function Personalzone_idcard_subView:OnDeActive()
  self:clearTogs()
  self:clearSubView()
  PlayerPortraitHgr.ClearActiveItem(self.playerHead_)
  if self.viewData.editorType == PersonalZoneDefine.IdCardEditorType.None then
    self:unbinderEvents()
    self:unbinderRedDot()
  end
end

function Personalzone_idcard_subView:OnRefresh()
end

function Personalzone_idcard_subView:clearTogs()
  for _, v in ipairs(self.togs_) do
    self:RemoveUiUnit(v.name)
  end
  self.togs_ = {}
end

function Personalzone_idcard_subView:clearSubView()
  for _, v in pairs(self.subView_) do
    v:DeActive()
  end
  self.subView_ = {}
  self.curSubView_ = nil
end

function Personalzone_idcard_subView:refreshPlayerInfo()
  local viewData = {
    id = self.viewData.avatarId,
    headFrameId = self.viewData.avatarFrameId,
    modelId = self.viewData.modelId,
    charId = self.viewData.charId,
    token = self.cancelSource:CreateToken(),
    func = function()
      if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
        return
      end
      self.personalzoneVm_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
    end
  }
  self.playerHead_ = PlayerPortraitHgr.InsertNewPortrait(self.uiBinder.binder_head, viewData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_newbie, self.viewData.isNewbie)
  self.uiBinder.lab_name.text = self.viewData.name
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_armband, false)
  local isOn = self.gotofuncVm_.CheckFuncCanUse(E.FunctionID.SeasonTitle, true)
  if isOn and self.viewData.seasonTitleId ~= nil then
    local seasonTitleId = self.viewData.seasonTitleId
    if seasonTitleId and seasonTitleId ~= 0 then
      local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonTitleId)
      if seasonRankConfig then
        self.uiBinder.rimg_armband_icon:SetImage(seasonRankConfig.IconBig)
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_armband, true)
      end
    else
      local seasonData = Z.DataMgr.Get("season_title_data")
      local allRankConfigList = seasonData:GetAllRankConfigList()
      if allRankConfigList and allRankConfigList[1] ~= nil then
        self.uiBinder.rimg_armband_icon:SetImage(allRankConfigList[1].IconBig)
        self.uiBinder.Ref:SetVisible(self.uiBinder.btn_armband, true)
      end
    end
  end
  isOn = self.gotofuncVm_.CheckFuncCanUse(E.FunctionID.PersonalzoneTitle, true)
  if isOn then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_title, true)
    if self.viewData.titleId ~= 0 then
      local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.viewData.titleId)
      if profileImageConfig and profileImageConfig.Unlock ~= PersonalZoneDefine.ProfileImageUnlockType.DefaultUnlock then
        self.uiBinder.lab_title.text = profileImageConfig.Name
      else
        self.uiBinder.lab_title.text = Lang("NoneTitle")
      end
    else
      self.uiBinder.lab_title.text = Lang("NoneTitle")
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_title, false)
  end
  self.uiBinder.lab_collection_degree.text = self.viewData.fashionCollectPoint
  if self.viewData.masterModeDungeonData ~= nil and self.heroDungeionMainVm_.CheckAnyMasterDungeonOpen() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_master_integral, true)
    if not self.viewData.masterModeDungeonData.isShow then
      self.uiBinder.lab_master_integral.text = self.heroDungeionMainVm_.GetPlayerSeasonMasterDungeonTotalScoreWithColor(self.viewData.masterModeDungeonData.score)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_integral, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_info, false)
    else
      self.uiBinder.lab_master_info.text = Lang("Hidden")
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_integral, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_info, true)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_master_integral, false)
  end
  self.uiBinder.lab_id.text = Lang("UID") .. self.viewData.charId
end

function Personalzone_idcard_subView:refreshTimeTags()
  self:refreshOnlineTime(self.viewData.onlinePeriods)
  self:refreshTags(self.viewData.tags)
end

function Personalzone_idcard_subView:refreshSubTogs()
  local togsPath = self.uiBinder.uiprefab_cache:GetString("tog")
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearTogs()
    for _, v in ipairs(self.viewData.subFuncs) do
      local subConfig = TogFunction[v]
      local name = "tog_" .. v
      if self.gotofuncVm_.CheckFuncCanUse(v, true) then
        do
          local unit = self:AsyncLoadUiUnit(togsPath, name, self.uiBinder.node_tog)
          if unit then
            unit.tog_tab:AddListener(function(isOn)
              if isOn then
                if self.curSubView_ then
                  self.curSubView_:DeActive()
                end
                self.curSubView_ = nil
                if self.subView_[v] == nil then
                  self.subView_[v] = require(subConfig.subView).new(self)
                end
                self.curSubView_ = self.subView_[v]
                local viewData
                if v == E.FunctionID.PersonalzonePhoto then
                  viewData = {
                    charId = self.viewData.charId,
                    photos = self.viewData.photos,
                    editorType = self.viewData.editorType,
                    name = self.viewData.name
                  }
                elseif v == E.FunctionID.PersonalzoneMedal then
                  viewData = {
                    charId = self.viewData.charId,
                    medals = self.viewData.medals,
                    editorType = self.viewData.editorType
                  }
                end
                self.subView_[v]:Active(viewData, self.uiBinder.node_sub)
              end
            end)
            unit.tog_tab.group = self.uiBinder.toggroup_sub
            local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(v)
            if functionConfig then
              unit.lab_off.text = functionConfig.Name
              unit.lab_on.text = functionConfig.Name
            end
            if subConfig.redDot and self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId then
              Z.RedPointMgr.LoadRedDotItem(subConfig.redDot, self, unit.Trans)
            end
            table.insert(self.togs_, {
              unit = unit,
              name = name,
              funcId = v
            })
          end
        end
      end
    end
    self.uiBinder.toggroup_sub:SetAllTogglesOff()
    if self.togs_[1] then
      self.togs_[1].unit.tog_tab.isOn = true
    end
  end)()
end

function Personalzone_idcard_subView:RefreshTimeTags(onlinePeriods, tags)
  self:refreshOnlineTime(onlinePeriods)
  self:refreshTags(tags)
end

function Personalzone_idcard_subView:ChangeSubTogs(subTogs, selectFunc, editorType)
  self.editorType_ = editorType
  local togsPath = self.uiBinder.uiprefab_cache:GetString("tog")
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearTogs()
    for _, v in ipairs(subTogs) do
      local subConfig = TogFunction[v]
      local name = "tog_" .. v
      if self.gotofuncVm_.CheckFuncCanUse(v, true) then
        do
          local unit = self:AsyncLoadUiUnit(togsPath, name, self.uiBinder.node_tog)
          if unit then
            unit.tog_tab:AddListener(function(isOn)
              if isOn then
                self.parentView_:ChangeTog(subConfig.editorType)
              end
            end)
            unit.tog_tab.group = self.uiBinder.toggroup_sub
            local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(v)
            if functionConfig then
              unit.lab_off.text = functionConfig.Name
              unit.lab_on.text = functionConfig.Name
            end
            if subConfig.redDot and self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId then
              Z.RedPointMgr.LoadRedDotItem(subConfig.redDot, self, unit.Trans)
            end
            table.insert(self.togs_, {
              unit = unit,
              name = name,
              funcId = v
            })
          end
        end
      end
    end
    self.uiBinder.toggroup_sub:SetAllTogglesOff()
    local showSubViewFunc
    if selectFunc then
      local key
      for k, v in ipairs(self.togs_) do
        if v.funcId == selectFunc then
          key = k
          break
        end
      end
      if key then
        self.togs_[key].unit.tog_tab:SetIsOnWithoutCallBack(true)
        showSubViewFunc = self.togs_[key].funcId
      elseif self.togs_[1] then
        self.togs_[1].unit.tog_tab:SetIsOnWithoutCallBack(true)
        showSubViewFunc = self.togs_[1].funcId
      end
    end
    if showSubViewFunc then
      if self.subView_[showSubViewFunc] == nil then
        self.subView_[showSubViewFunc] = require(TogFunction[showSubViewFunc].subView).new(self)
      end
      if self.subView_[showSubViewFunc].IsActive then
        self.curSubView_:ChangeEditorType(editorType)
      else
        if self.curSubView_ then
          self.curSubView_:DeActive()
        end
        local viewData
        if showSubViewFunc == E.FunctionID.PersonalzonePhoto then
          viewData = {
            charId = self.viewData.charId,
            photos = self.parentView_:GetPhotos(),
            editorType = editorType
          }
        elseif showSubViewFunc == E.FunctionID.PersonalzoneMedal then
          viewData = {
            charId = self.viewData.charId,
            medals = self.parentView_:GetMedals(),
            editorType = editorType
          }
        end
        self.subView_[showSubViewFunc]:Active(viewData, self.uiBinder.node_sub)
        self.curSubView_ = self.subView_[showSubViewFunc]
      end
    elseif #subTogs == 0 then
      self:clearSubView()
    elseif self.curSubView_ ~= nil then
      local curSubCanShow = false
      for _, tog in ipairs(self.togs_) do
        if self.subView_[tog.funcId] == self.curSubView_ then
          tog.unit.tog_tab:SetIsOnWithoutCallBack(true)
          curSubCanShow = true
          break
        end
      end
      if curSubCanShow then
        self.curSubView_:ChangeEditorType(editorType)
      else
        self.curSubView_:DeActive()
        self.curSubView_ = nil
        if self.togs_[1] then
          self.togs_[1].unit.tog_tab:SetIsOnWithoutCallBack(true)
          local funcId = self.togs_[1].funcId
          if self.subView_[funcId] == nil then
            self.subView_[funcId] = require(TogFunction[funcId].subView).new(self)
          end
          local viewData
          if funcId == E.FunctionID.PersonalzonePhoto then
            viewData = {
              charId = self.viewData.charId,
              photos = self.parentView_:GetPhotos(),
              editorType = editorType
            }
          elseif funcId == E.FunctionID.PersonalzoneMedal then
            viewData = {
              charId = self.viewData.charId,
              medals = self.parentView_:GetMedals(),
              editorType = editorType
            }
          end
          self.subView_[funcId]:Active(viewData, self.uiBinder.node_sub)
          self.curSubView_ = self.subView_[funcId]
        end
      end
    elseif self.togs_[1] then
      self.togs_[1].unit.tog_tab:SetIsOnWithoutCallBack(true)
      local funcId = self.togs_[1].funcId
      if self.subView_[funcId] == nil then
        self.subView_[funcId] = require(TogFunction[funcId].subView).new(self)
      end
      local viewData
      if funcId == E.FunctionID.PersonalzonePhoto then
        viewData = {
          charId = self.viewData.charId,
          photos = self.parentView_:GetPhotos(),
          editorType = editorType
        }
      elseif funcId == E.FunctionID.PersonalzoneMedal then
        viewData = {
          charId = self.viewData.charId,
          medals = self.parentView_:GetMedals(),
          editorType = editorType
        }
      end
      self.subView_[funcId]:Active(viewData, self.uiBinder.node_sub)
      self.curSubView_ = self.subView_[funcId]
    end
    self:refreshBtns()
  end)()
end

function Personalzone_idcard_subView:GetSubViewPage()
  if self.curSubView_ then
    return self.curSubView_:GetCurPage()
  end
  return 1
end

function Personalzone_idcard_subView:ChangeMedals(medals)
  if self.curSubView_ then
    return self.curSubView_:ChangeMedals(medals)
  end
end

function Personalzone_idcard_subView:ExchangeMedal(curKey, exchangeKey)
  self.parentView_:ExchangeMedal(curKey, exchangeKey)
end

function Personalzone_idcard_subView:DeleteMedal(index)
  self.parentView_:DeleteMedal(index)
end

function Personalzone_idcard_subView:ChangePhotos(photos)
  if self.curSubView_ then
    return self.curSubView_:ChangePhotos(photos)
  end
end

function Personalzone_idcard_subView:ExchangePhoto(curKey, exchangeKey)
  self.parentView_:ExchangePhoto(curKey, exchangeKey)
end

function Personalzone_idcard_subView:DeletePhoto(index)
  self.parentView_:DeletePhoto(index)
end

function Personalzone_idcard_subView:initBtns()
  self:AddClick(self.uiBinder.btn_armband, function()
    if self.viewData.seasonTitleId == nil or self.viewData.seasonTitleId == 0 then
      local seasonData = Z.DataMgr.Get("season_title_data")
      local allRankConfigList = seasonData:GetAllRankConfigList()
      if allRankConfigList and allRankConfigList[1] ~= nil then
        Z.TipsVM.ShowTips(1002107, {
          val = allRankConfigList[1].Name
        })
      end
      return
    end
    local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(self.viewData.seasonTitleId)
    if seasonRankConfig == nil then
      return
    end
    Z.TipsVM.ShowTips(1002107, {
      val = seasonRankConfig.Name
    })
  end)
  self:AddClick(self.uiBinder.btn_title, function()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
      return
    end
    self.personalzoneVm_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneTitle)
  end)
  self:AddClick(self.uiBinder.btn_master_integral, function()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
      if not self.viewData.masterModeDungeonData.isShow then
        Z.TipsVM.ShowTips(1002109, {
          val = self.viewData.masterModeDungeonData.score
        })
      else
        Z.TipsVM.ShowTips(1002110)
      end
    else
      self.heroDungeionMainVm_.OpenMaseterScoreView(true)
    end
  end)
  self:AddClick(self.uiBinder.btn_collection_degree, function()
    Z.TipsVM.ShowTips(1002108, {
      val = self.viewData.fashionCollectPoint
    })
  end)
  self:AddClick(self.uiBinder.btn_member, function()
  end)
  self:AddClick(self.uiBinder.node_online_time.btn_online, function()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
      local unionTagTableMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
      local onlineDay = self.viewData.onlinePeriods
      local tags = self.viewData.tags
      local temp = {}
      local tempindex = 0
      for _, v in ipairs(onlineDay) do
        tempindex = tempindex + 1
        temp[tempindex] = unionTagTableMgr.GetRow(v)
      end
      for _, v in ipairs(tags) do
        tempindex = tempindex + 1
        temp[tempindex] = unionTagTableMgr.GetRow(v)
      end
      if 0 < tempindex then
        local viewData = {
          tagList = temp,
          trans = self.uiBinder.rect_editor_tag,
          type = 2
        }
        Z.VMMgr.GetVM("union"):OpenLabelTipsView(viewData)
      end
    else
      if self.editorType_ ~= PersonalZoneDefine.IdCardEditorType.None then
        return
      end
      self.personalzoneVm_.OpenPersonalZoneEditor()
    end
  end)
  self:AddClick(self.uiBinder.node_personality_labels.btn_active, function()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
      local unionTagTableMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
      local onlineDay = self.viewData.onlinePeriods
      local tags = self.viewData.tags
      local temp = {}
      local tempindex = 0
      for _, v in ipairs(onlineDay) do
        tempindex = tempindex + 1
        temp[tempindex] = unionTagTableMgr.GetRow(v)
      end
      for _, v in ipairs(tags) do
        tempindex = tempindex + 1
        temp[tempindex] = unionTagTableMgr.GetRow(v)
      end
      if 0 < tempindex then
        local viewData = {
          tagList = temp,
          trans = self.uiBinder.rect_editor_tag,
          type = 2
        }
        Z.VMMgr.GetVM("union"):OpenLabelTipsView(viewData)
      end
    else
      if self.editorType_ ~= PersonalZoneDefine.IdCardEditorType.None then
        return
      end
      self.personalzoneVm_.OpenPersonalZoneEditor()
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_chat, function()
    if not self.socialVm_.CheckCanSwitch(E.IdCardFuncId.SendMsg, false) then
      return
    end
    local charId = self.viewData.charId
    self.friendsMainVm_.OpenPrivateChat(charId)
    if Z.IsPCUI then
      Z.UIMgr:CloseView("personalzone_main")
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_add_friend, function()
    if not self.socialVm_.CheckCanSwitch(E.IdCardFuncId.AddFriend, false) then
      return
    end
    self.friendsMainVm_.AsyncSendAddFriend(self.viewData.charId, E.FriendAddSource.EPersonalzone, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_enter_edit, function()
    self.personalzoneVm_.OpenPersonalZoneEditor()
  end)
  self:AddAsyncClick(self.uiBinder.btn_save, function()
    self.parentView_:SaveEditorData()
  end)
  self:AddClick(self.uiBinder.btn_quit_edit, function()
    if self.parentView_:CheckEditorNeedSave() then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("SecondCheck"), function()
        Z.UIMgr:CloseView("personalzone_edit_window")
      end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.PersonalzoneSecondCheck)
    else
      Z.UIMgr:CloseView("personalzone_edit_window")
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_share, function()
    local isOn = self.gotofuncVm_.CheckFuncCanUse(E.FunctionID.ShareToChat)
    if not isOn then
      return
    end
    local chatData_ = Z.DataMgr.Get("chat_main_data")
    chatData_:RefreshShareData("", nil, E.ChatHyperLinkType.PersonalZone)
    local draftData = {}
    draftData.msg = chatData_:GetHyperLinkShareContent()
    chatData_:SetChatDraft(draftData, E.ChatChannelType.EChannelWorld, E.ChatWindow.Main)
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.MainChat)
  end)
  self:AddClick(self.uiBinder.btn_report, function()
    self.reportVM_.OpenReportPop(ReportDefine.ReportScene.PersonalInfo, self.viewData.name, self.viewData.charId)
  end)
end

function Personalzone_idcard_subView:refreshOnlineTime(onlinePeriods)
  if onlinePeriods == nil then
    onlinePeriods = {}
  end
  local personalTagMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  table.sort(onlinePeriods, function(a, b)
    local aConfig = personalTagMgr.GetRow(a)
    local bConfig = personalTagMgr.GetRow(b)
    if aConfig.ShowSort == bConfig.ShowSort then
      return aConfig.Id < bConfig.Id
    else
      return aConfig.ShowSort < bConfig.ShowSort
    end
  end)
  for i = 1, 3 do
    self.uiBinder.node_online_time.Ref:SetVisible(self.uiBinder.node_online_time["img_timer_" .. i], false)
  end
  if 0 < #onlinePeriods then
    for i = 1, 3 do
      local img = self.uiBinder.node_online_time["img_timer_" .. i]
      if i <= #onlinePeriods then
        local config = personalTagMgr.GetRow(onlinePeriods[i])
        if config then
          self.uiBinder.node_online_time.Ref:SetVisible(img, true)
          img:SetImage(config.ShowTagRoute)
          img:SetColor(PersonalZoneDefine.OnlineTagColor[2])
        end
      end
    end
  elseif self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId then
    self.uiBinder.node_online_time.Ref:SetVisible(self.uiBinder.node_online_time.img_timer_1, true)
    self.uiBinder.node_online_time.img_timer_1:SetImage(PersonalZoneDefine.UNSHOWTAGICON)
    self.uiBinder.node_online_time.img_timer_1:SetColor(PersonalZoneDefine.OnlineTagColor[1])
  end
end

function Personalzone_idcard_subView:refreshTags(tags)
  if tags == nil then
    tags = {}
  end
  local personalTagMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  table.sort(tags, function(a, b)
    local aConfig = personalTagMgr.GetRow(a)
    local bConfig = personalTagMgr.GetRow(b)
    if aConfig.ShowSort == bConfig.ShowSort then
      return aConfig.Id < bConfig.Id
    else
      return aConfig.ShowSort < bConfig.ShowSort
    end
  end)
  for i = 1, 4 do
    self.uiBinder.node_personality_labels.Ref:SetVisible(self.uiBinder.node_personality_labels["img_personality_labels_" .. i], false)
  end
  if 0 < #tags then
    for i = 1, 4 do
      if i <= #tags then
        local img = self.uiBinder.node_personality_labels["img_personality_labels_" .. i]
        local config = personalTagMgr.GetRow(tags[i])
        if config then
          self.uiBinder.node_personality_labels.Ref:SetVisible(img, true)
          img:SetImage(config.ShowTagRoute)
          img:SetColor(PersonalZoneDefine.OnlineTagColor[2])
        end
      end
    end
  elseif self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId then
    self.uiBinder.node_personality_labels.Ref:SetVisible(self.uiBinder.node_personality_labels.img_personality_labels_1, true)
    self.uiBinder.node_personality_labels.img_personality_labels_1:SetImage(PersonalZoneDefine.UNSHOWTAGICON)
    self.uiBinder.node_personality_labels.img_personality_labels_1:SetColor(PersonalZoneDefine.OnlineTagColor[1])
  end
end

function Personalzone_idcard_subView:refreshBtns()
  local isSelf = self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  local chatMainData = Z.DataMgr.Get("chat_main_data")
  local isInBlackList = chatMainData:IsInBlack(self.viewData.charId) or isSelf
  local isFriend = friendMainData:IsFriendByCharId(self.viewData.charId) or isSelf
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add_friend, not isFriend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_chat, not isInBlackList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_enter_edit, isSelf and self.editorType_ == PersonalZoneDefine.IdCardEditorType.None)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, isSelf and self.editorType_ ~= PersonalZoneDefine.IdCardEditorType.None)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_quit_edit, isSelf and self.editorType_ ~= PersonalZoneDefine.IdCardEditorType.None)
  if self.editorType_ == PersonalZoneDefine.IdCardEditorType.Badge or self.editorType_ == PersonalZoneDefine.IdCardEditorType.Album then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_prompt, isSelf)
    self.uiBinder.lab_prompt.text = Lang(LanguagePrompt[self.editorType_])
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_prompt, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, isSelf and self.editorType_ == PersonalZoneDefine.IdCardEditorType.None)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_report, not isSelf)
end

function Personalzone_idcard_subView:binderEvents()
  if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
    return
  end
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnTagsRefresh, self.onChangeOnlinePeriodsAndTags, self)
  Z.EventMgr:Add(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Add(Z.ConstValue.MasterScoreShowRefresh, self.onMasterScoreShowChange, self)
end

function Personalzone_idcard_subView:unbinderEvents()
  if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
    return
  end
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnTagsRefresh, self.onChangeOnlinePeriodsAndTags, self)
  Z.EventMgr:Remove(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Remove(Z.ConstValue.MasterScoreShowRefresh, self.onMasterScoreShowChange, self)
end

function Personalzone_idcard_subView:binderRedDot()
  if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
    return
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHead, self, self.uiBinder.binder_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHeadFrame, self, self.uiBinder.binder_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneTitle, self, self.uiBinder.node_title)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneBg, self, self.uiBinder.btn_enter_edit.transform)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneMedal, self, self.uiBinder.btn_enter_edit.transform)
end

function Personalzone_idcard_subView:unbinderRedDot()
  if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
    return
  end
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHead)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHeadFrame)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneTitle)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneBg)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneMedal)
end

function Personalzone_idcard_subView:onChangeNameResultNtf(errCode)
  if errCode == 0 and self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId then
    self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  end
end

function Personalzone_idcard_subView:onChangePortrait(avatarId, frameId)
  local viewData = {
    id = avatarId,
    headFrameId = frameId,
    modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
    charId = Z.EntityMgr.PlayerEnt.CharId,
    token = self.cancelSource:CreateToken(),
    func = function()
      if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
        return
      end
      self.personalzoneVm_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
    end
  }
  PlayerPortraitHgr.RefreshNewProtrait(self.uiBinder.binder_head, viewData, self.playerHead_)
end

function Personalzone_idcard_subView:onChangeOnlinePeriodsAndTags(onlinePeriods, tags)
  self:refreshOnlineTime(onlinePeriods)
  self:refreshTags(tags)
end

function Personalzone_idcard_subView:onChangeTitle()
  local titleId = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.Title)
  if titleId and titleId ~= 0 then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
    if profileImageConfig and profileImageConfig.Unlock ~= PersonalZoneDefine.ProfileImageUnlockType.DefaultUnlock then
      self.uiBinder.lab_title.text = profileImageConfig.Name
    else
      self.uiBinder.lab_title.text = Lang("NoneTitle")
    end
  else
    self.uiBinder.lab_title.text = Lang("NoneTitle")
  end
end

function Personalzone_idcard_subView:onMasterScoreShowChange(isShow)
  if self.heroDungeionMainVm_.CheckAnyMasterDungeonOpen() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_master_integral, true)
    if not isShow then
      local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
      local score = Z.VMMgr.GetVM("hero_dungeon_main").GetPlayerSeasonMasterDungeonScore(seasonId)
      self.uiBinder.lab_master_integral.text = self.heroDungeionMainVm_.GetPlayerSeasonMasterDungeonTotalScoreWithColor(score)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_integral, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_info, false)
    else
      self.uiBinder.lab_master_info.text = Lang("Hidden")
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_integral, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_master_info, true)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_master_integral, false)
  end
end

return Personalzone_idcard_subView
