local UI = Z.UI
local super = require("ui.ui_view_base")
local Personalzone_edit_windowView = class("Personalzone_edit_windowView", super)
local PersonalZoneDefine = require("ui.model.personalzone_define")
local TogConfig = {
  [PersonalZoneDefine.IdCardEditorType.Set] = {
    LeftSub = "ui/view/personalzone_edit_setting_sub_view"
  },
  [PersonalZoneDefine.IdCardEditorType.Frame] = {
    LeftSub = "ui/view/personalzone_edit_bg_sub_view",
    RedDot = E.RedType.PersonalzoneBg,
    FuncId = E.FunctionID.PersonalzoneBg
  },
  [PersonalZoneDefine.IdCardEditorType.Badge] = {
    LeftSub = "ui/view/personalzone_edit_badge_sub_view",
    FuncId = E.FunctionID.PersonalzoneMedal,
    Tips = "PersonalzoneMedalSetTIps",
    RedDot = E.RedType.PersonalzoneMedal
  },
  [PersonalZoneDefine.IdCardEditorType.Album] = {
    LeftSub = "ui/view/personalzone_edit_album_sub_view",
    FuncId = E.FunctionID.PersonalzonePhoto,
    Tips = "PersonalzonePhotoSetTIps"
  }
}

function Personalzone_edit_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "personalzone_edit_window")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.gotofuncVm_ = Z.VMMgr.GetVM("gotofunc")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.rightGroupSubView_ = require("ui/view/personalzone_idcard_sub_view").new(self)
end

function Personalzone_edit_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self:initUI()
  local charSerialize = Z.ContainerMgr.CharSerialize
  local seasonData = Z.DataMgr.Get("season_title_data")
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local selectFuncId
  if self.viewData ~= nil and TogConfig[self.viewData] and TogConfig[self.viewData].FuncId then
    selectFuncId = TogConfig[self.viewData].FuncId
  end
  local collectionVM = Z.VMMgr.GetVM("collection")
  local viewData = {
    editorType = self.viewData == nil and PersonalZoneDefine.IdCardEditorType.Set or self.viewData,
    charId = charSerialize.charBase.charId,
    onlinePeriods = charSerialize.personalZone ~= nil and charSerialize.personalZone.onlinePeriods or {},
    tags = charSerialize.personalZone ~= nil and charSerialize.personalZone.tags or {},
    name = charSerialize.charBase.name,
    avatarId = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.Head),
    avatarFrameId = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.HeadFrame),
    modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
    seasonTitleId = seasonData:GetCurRankInfo().curRanKStar,
    titleId = charSerialize.personalZone ~= nil and charSerialize.personalZone.titleId or 0,
    fashionCollectPoint = collectionVM.GetFashionCollectionPoints(),
    photos = charSerialize.personalZone ~= nil and charSerialize.personalZone.photosWall or {},
    medals = charSerialize.personalZone ~= nil and charSerialize.personalZone.medals or {},
    subFuncs = {
      [1] = E.FunctionID.PersonalzoneMedal,
      [2] = E.FunctionID.PersonalzonePhoto
    },
    bg = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.PersonalzoneBg),
    isNewbie = Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value),
    masterModeDungeonData = {
      isShow = charSerialize.masterModeDungeonInfo.isShow,
      score = Z.VMMgr.GetVM("hero_dungeon_main").GetPlayerSeasonMasterDungeonScore(seasonId)
    },
    selectFuncId = selectFuncId
  }
  self.onlinePeriods_ = table.zclone(viewData.onlinePeriods)
  self.tags_ = table.zclone(viewData.tags)
  self.photos_ = table.zclone(viewData.photos)
  self.medals_ = table.zclone(viewData.medals)
  self.subFuncs_ = table.zclone(viewData.subFuncs)
  self.selectbgId_ = viewData.bg
  self.selectTogKey_ = nil
  self.leftSubViews_ = {}
  self.curLeftSubView_ = nil
  self.isPlayOpenAnim_ = false
  for key, tog in pairs(self.togs_) do
    if TogConfig[key].FuncId then
      self.uiBinder.Ref:SetVisible(tog, self.gotofuncVm_.CheckFuncCanUse(TogConfig[key].FuncId, true))
    else
      self.uiBinder.Ref:SetVisible(tog, true)
    end
    tog:AddListener(function(isOn)
      if isOn then
        if self:checkTogCanChange(key) then
          self.selectTogKey_ = key
          if self.curLeftSubView_ then
            self.curLeftSubView_:DeActive()
          end
          if self.leftSubViews_[key] == nil then
            self.leftSubViews_[key] = require(TogConfig[key].LeftSub).new(self)
          end
          self.curLeftSubView_ = self.leftSubViews_[key]
          self.curLeftSubView_:Active(nil, self.uiBinder.node_left_sub)
          if self.rightGroupSubView_.IsActive and self.rightGroupSubView_.IsLoaded then
            self:ChangeShowSubFunc(nil, false, TogConfig[key].FuncId, key)
          else
            self.rightGroupSubView_:Active(viewData, self.uiBinder.node_right)
          end
          if not self.isPlayOpenAnim_ then
            self.isPlayOpenAnim_ = true
          else
            self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
          end
        else
          Z.DialogViewDataMgr:OpenNormalDialog(Lang(TogConfig[key].Tips), function()
            self.selectTogKey_ = key
            if self.curLeftSubView_ then
              self.curLeftSubView_:DeActive()
            end
            if self.leftSubViews_[key] == nil then
              self.leftSubViews_[key] = require(TogConfig[key].LeftSub).new(self)
            end
            self.curLeftSubView_ = self.leftSubViews_[key]
            self.curLeftSubView_:Active(nil, self.uiBinder.node_left_sub)
            if self.rightGroupSubView_.IsActive and self.rightGroupSubView_.IsLoaded then
              self:ChangeShowSubFunc(TogConfig[key].FuncId, true, TogConfig[key].FuncId, key)
            else
              self.rightGroupSubView_:Active(viewData, self.uiBinder.node_right)
            end
            if not self.isPlayOpenAnim_ then
              self.isPlayOpenAnim_ = true
            else
              self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
            end
          end, function()
            self.togs_[self.selectTogKey_].isOn = true
          end)
        end
      end
    end)
    if TogConfig[key] and TogConfig[key].RedDot then
      Z.RedPointMgr.LoadRedDotItem(TogConfig[key].RedDot, self, tog.transform)
    end
  end
  self.uiBinder.layout_tab:SetAllTogglesOff()
  if self.viewData then
    if self.togs_[self.viewData] then
      self.togs_[self.viewData].isOn = true
    end
  else
    self.togs_[PersonalZoneDefine.IdCardEditorType.Set].isOn = true
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.selectbgId_)
    if config then
      Z.UnrealSceneMgr:ChangeBinderGOTexture("sky", 0, "_MainTex", config.Image2, self.cancelSource:CreateToken())
    end
  end)()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Personalzone_edit_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.leftSubViews_ then
    for _, v in pairs(self.leftSubViews_) do
      v:DeActive()
    end
  end
  self.rightGroupSubView_:DeActive()
  for key, _ in pairs(self.togs_) do
    if TogConfig[key] and TogConfig[key].RedDot then
      Z.RedPointMgr.RemoveNodeItem(TogConfig[key].RedDot)
    end
  end
  self.selectTogKey_ = nil
end

function Personalzone_edit_windowView:OnRefresh()
end

function Personalzone_edit_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.viewConfigKey)
end

function Personalzone_edit_windowView:initUI()
  self:AddClick(self.uiBinder.btn_close, function()
    if self:CheckEditorNeedSave() then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("SecondCheck"), function()
        Z.UIMgr:CloseView(self.ViewConfigKey)
      end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.PersonalzoneSecondCheck)
    else
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end)
  self.togs_ = {
    [PersonalZoneDefine.IdCardEditorType.Set] = self.uiBinder.toggle_set,
    [PersonalZoneDefine.IdCardEditorType.Frame] = self.uiBinder.toggle_frame,
    [PersonalZoneDefine.IdCardEditorType.Badge] = self.uiBinder.toggle_badge,
    [PersonalZoneDefine.IdCardEditorType.Album] = self.uiBinder.toggle_album
  }
end

function Personalzone_edit_windowView:checkTogCanChange(id)
  if TogConfig[id] == nil then
    return true
  end
  if TogConfig[id].FuncId == nil or TogConfig[id].FuncId == E.FunctionID.PersonalzoneBg then
    return true
  end
  local funcId = TogConfig[id].FuncId
  for _, v in pairs(self.subFuncs_) do
    if funcId == v then
      return true
    end
  end
  return false
end

function Personalzone_edit_windowView:ChangeTog(editorType)
  if self.togs_[editorType] then
    self.togs_[editorType].isOn = true
  end
end

function Personalzone_edit_windowView:CheckEditorNeedSave()
  return self:CheckSetting() or self:CheckFrame() or self:CheckMedal() or self:CheckPhoto()
end

function Personalzone_edit_windowView:SaveEditorData()
  if self:CheckEditorNeedSave() then
    Z.CoroUtil.create_coro_xpcall(function()
      local reply1 = self:SaveSetting()
      local reply2 = self:SaveFrame()
      local reply3 = self:SaveMedal()
      local reply4 = self:SavePhoto()
      if reply1 and reply2 and reply3 and reply4 then
        Z.TipsVM.ShowTipsLang(1002103)
      end
    end)()
  else
    Z.TipsVM.ShowTipsLang(1002105)
  end
end

local subViewSort = {
  [E.FunctionID.PersonalzoneMedal] = 1,
  [E.FunctionID.PersonalzonePhoto] = 2
}

function Personalzone_edit_windowView:IsSubViewOn(func)
  for k, v in ipairs(self.subFuncs_) do
    if v == func then
      return true, k
    end
  end
  return false, -1
end

function Personalzone_edit_windowView:ChangeShowSubFunc(func, isOn, selectFunc, editorType)
  if func ~= nil then
    local isExist, index = self:IsSubViewOn(func)
    if isExist and not isOn then
      table.remove(self.subFuncs_, index)
    elseif not isExist and isOn then
      table.insert(self.subFuncs_, func)
      table.sort(self.subFuncs_, function(a, b)
        return subViewSort[a] < subViewSort[b]
      end)
    end
  end
  self.rightGroupSubView_:ChangeSubTogs(self.subFuncs_, selectFunc, editorType)
end

function Personalzone_edit_windowView:IsOnlinePeriodsOn(id)
  for k, v in ipairs(self.onlinePeriods_) do
    if v == id then
      return true, k
    end
  end
  return false, -1
end

function Personalzone_edit_windowView:ChangeOnlinePeriods(id, isOn)
  local isExist, index = self:IsOnlinePeriodsOn(id)
  if isOn and not isExist then
    if #self.onlinePeriods_ == Z.Global.PersonalOnlinePeriodLimit then
      Z.TipsVM.ShowTipsLang(1002106)
      return false
    else
      table.insert(self.onlinePeriods_, id)
    end
  elseif not isOn and isExist then
    table.remove(self.onlinePeriods_, index)
  end
  self.rightGroupSubView_:RefreshTimeTags(self.onlinePeriods_, self.tags_)
  return true
end

function Personalzone_edit_windowView:IsTagsOn(id)
  for k, v in ipairs(self.tags_) do
    if v == id then
      return true, k
    end
  end
  return false, -1
end

function Personalzone_edit_windowView:ChangeTags(id, isOn)
  local isExist, index = self:IsTagsOn(id)
  if isOn and not isExist then
    if #self.tags_ == Z.Global.PersonalTagLimit then
      Z.TipsVM.ShowTipsLang(1002106)
      return false
    else
      table.insert(self.tags_, id)
    end
  elseif not isOn and isExist then
    table.remove(self.tags_, index)
  end
  self.rightGroupSubView_:RefreshTimeTags(self.onlinePeriods_, self.tags_)
  return true
end

function Personalzone_edit_windowView:CheckSetting()
  local charSerialize = Z.ContainerMgr.CharSerialize
  local onlinePeriods = charSerialize.personalZone ~= nil and charSerialize.personalZone.onlinePeriods or {}
  local tags = charSerialize.personalZone ~= nil and charSerialize.personalZone.tags or {}
  if #onlinePeriods ~= #self.onlinePeriods_ or #tags ~= #self.tags_ then
    return true
  end
  local dicOnline = {}
  for _, v in ipairs(onlinePeriods) do
    dicOnline[v] = v
  end
  for _, v in ipairs(self.onlinePeriods_) do
    if dicOnline[v] == nil then
      return true
    end
  end
  local dicTag = {}
  for _, v in ipairs(tags) do
    dicTag[v] = v
  end
  for _, v in ipairs(self.tags_) do
    if dicTag[v] == nil then
      return true
    end
  end
  return false
end

function Personalzone_edit_windowView:SaveSetting()
  return self.personalzoneVm_.AsyncSavePersonalTags(0, self.onlinePeriods_, self.tags_, self.cancelSource:CreateToken())
end

function Personalzone_edit_windowView:GetCurBgId()
  return self.selectbgId_
end

function Personalzone_edit_windowView:ChangeBg(id)
  self.selectbgId_ = id
  Z.CoroUtil.create_coro_xpcall(function()
    local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.selectbgId_)
    if config then
      Z.UnrealSceneMgr:ChangeBinderGOTexture("sky", 0, "_MainTex", config.Image2, self.cancelSource:CreateToken())
    end
  end)()
end

function Personalzone_edit_windowView:CheckFrame()
  local frameId = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.PersonalzoneBg)
  local defaultId = self.personalZoneData_:GetDefaultProfileImageConfigByType(PersonalZoneDefine.ProfileImageType.PersonalzoneBg)
  local isUnlock = self.itemsVm_.GetItemTotalCount(self.selectbgId_) > 0 or defaultId == self.selectbgId_
  return isUnlock and frameId ~= self.selectbgId_
end

function Personalzone_edit_windowView:SaveFrame()
  if not self.gotofuncVm_.CheckFuncCanUse(E.FunctionID.PersonalzoneBg, true) then
    return true
  end
  local defaultId = self.personalZoneData_:GetDefaultProfileImageConfigByType(PersonalZoneDefine.ProfileImageType.PersonalzoneBg)
  if self.selectbgId_ == defaultId or self.itemsVm_.GetItemTotalCount(self.selectbgId_) > 0 then
    return self.personalzoneVm_.AsyncSaveTheme(self.selectbgId_, self.cancelSource:CreateToken())
  end
  return true
end

function Personalzone_edit_windowView:GetMedals()
  return self.medals_
end

function Personalzone_edit_windowView:IsMedalUse(id)
  for _, v in pairs(self.medals_) do
    if v == id then
      return true
    end
  end
  return false
end

function Personalzone_edit_windowView:SelectMedal(id)
  local isExist = false
  local index = -1
  for k, v in pairs(self.medals_) do
    if v == id then
      isExist = true
      index = k
      break
    end
  end
  if isExist then
    self.medals_[index] = nil
    self.curLeftSubView_:RefreshAllShownItem()
    self.rightGroupSubView_:ChangeMedals(self.medals_)
  elseif not isExist then
    local canInsert = false
    local curPage = self.rightGroupSubView_:GetSubViewPage()
    local count = Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2]
    for i = (curPage - 1) * count + 1, curPage * count do
      if self.medals_[i] == nil then
        self.medals_[i] = id
        canInsert = true
        break
      end
    end
    if canInsert then
      self.curLeftSubView_:RefreshAllShownItem()
      self.rightGroupSubView_:ChangeMedals(self.medals_)
      return
    end
    for i = 1, Z.Global.PersonalMedalLimit * count do
      if self.medals_[i] == nil then
        self.medals_[i] = id
        canInsert = true
        break
      end
    end
    if canInsert then
      self.curLeftSubView_:RefreshAllShownItem()
      self.rightGroupSubView_:ChangeMedals(self.medals_)
      return
    else
      Z.TipsVM.ShowTips(1002106)
      return
    end
  end
end

function Personalzone_edit_windowView:ExchangeMedal(curKey, exchangeKey)
  local exchangeMedal = self.medals_[exchangeKey]
  self.medals_[exchangeKey] = self.medals_[curKey]
  self.medals_[curKey] = exchangeMedal
  self.rightGroupSubView_:ChangeMedals(self.medals_)
end

function Personalzone_edit_windowView:DeleteMedal(index)
  if self.medals_[index] ~= nil then
    self.medals_[index] = nil
    self.rightGroupSubView_:ChangeMedals(self.medals_)
    self.curLeftSubView_:RefreshAllShownItem()
  end
end

function Personalzone_edit_windowView:CheckMedal()
  local medals = Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.medals or {}
  if medals == nil then
    medals = {}
  end
  for i = 1, Z.Global.PersonalMedalLimit * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] do
    if self.medals_[i] ~= medals[i] then
      return true
    end
  end
  return false
end

function Personalzone_edit_windowView:SaveMedal()
  if not self.gotofuncVm_.CheckFuncCanUse(E.FunctionID.PersonalzoneMedal, true) then
    return true
  end
  return self.personalzoneVm_.AsyncSetPersonalZoneMedal(self.medals_, self.cancelSource:CreateToken())
end

function Personalzone_edit_windowView:GetPhotos()
  return self.photos_
end

function Personalzone_edit_windowView:IsPhotoUse(id)
  for _, v in pairs(self.photos_) do
    if v == id then
      return true
    end
  end
  return false
end

function Personalzone_edit_windowView:SelectPhoto(id)
  if not self.ListSelectEvent then
    return
  end
  local isExist = false
  local index = -1
  for k, v in pairs(self.photos_) do
    if v == id then
      isExist = true
      index = k
      break
    end
  end
  if isExist then
    self.photos_[index] = nil
    self.curLeftSubView_:RefreshAllShownItem()
    self.rightGroupSubView_:ChangePhotos(self.photos_)
  elseif not isExist then
    local canInsert = false
    local curPage = self.rightGroupSubView_:GetSubViewPage()
    local count = Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2]
    for i = (curPage - 1) * count + 1, curPage * count do
      if self.photos_[i] == nil then
        self.photos_[i] = id
        canInsert = true
        break
      end
    end
    if canInsert then
      self.curLeftSubView_:RefreshAllShownItem()
      self.rightGroupSubView_:ChangePhotos(self.photos_)
      return
    end
    for i = 1, Z.Global.PersonalPhotoLimit * count do
      if self.photos_[i] == nil then
        self.photos_[i] = id
        canInsert = true
        break
      end
    end
    if canInsert then
      self.curLeftSubView_:RefreshAllShownItem()
      self.rightGroupSubView_:ChangePhotos(self.photos_)
      return
    else
      Z.TipsVM.ShowTips(1002106)
      return
    end
  end
end

function Personalzone_edit_windowView:DeletePhoto(index)
  if self.photos_[index] ~= nil then
    self.photos_[index] = nil
    self.curLeftSubView_:RefreshAllShownItem()
    self.rightGroupSubView_:ChangePhotos(self.photos_)
  end
end

function Personalzone_edit_windowView:ExchangePhoto(curKey, exchangeKey)
  local exchangePhoto = self.photos_[exchangeKey]
  self.photos_[exchangeKey] = self.photos_[curKey]
  self.photos_[curKey] = exchangePhoto
  self.rightGroupSubView_:ChangePhotos(self.photos_)
end

function Personalzone_edit_windowView:CheckPhoto()
  local photos = Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.photosWall or {}
  if photos == nil then
    photos = {}
  end
  for i = 1, Z.Global.PersonalPhotoLimit * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] do
    if self.photos_[i] ~= photos[i] then
      return true
    end
  end
  return false
end

function Personalzone_edit_windowView:SavePhoto()
  if not self.gotofuncVm_.CheckFuncCanUse(E.FunctionID.PersonalzonePhoto, true) then
    return true
  end
  return self.personalzoneVm_.AsyncSavePhoto(self.photos_, self.cancelSource:CreateToken())
end

return Personalzone_edit_windowView
