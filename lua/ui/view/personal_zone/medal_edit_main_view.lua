local super = require("ui.ui_view_base")
local PersonalZoneMedalEditMain = class("PersonalZoneMedalEditMain", super)
local loopGridView = require("ui.component.loop_grid_view")
local MedalLoopItem = require("ui.view.personal_zone.medal_edit_main_view.medal_edit_loopitem")
local DEFINE = require("ui.model.personalzone_define")
local CELL_SIZE = 188
local MEDAL_SIZE = {
  [1] = {x = 188, y = 188},
  [2] = {x = 260, y = 520},
  [3] = {x = 376, y = 376}
}
local MEDAL_PATH = {
  [1] = GetLoadAssetPath("PersonalZoneMedalDiy01"),
  [2] = GetLoadAssetPath("PersonalZoneMedalDiy02"),
  [3] = GetLoadAssetPath("PersonalZoneMedalDiy03")
}

function PersonalZoneMedalEditMain:ctor()
  self.panel = nil
  super.ctor(self, "personal_zone_medal_edit_main")
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.socialVM_ = Z.VMMgr.GetVM("social")
end

function PersonalZoneMedalEditMain:OnActive()
  self.uiBinder.scenemask_bg:SetSceneMaskByKey(self.SceneMaskKey)
  self.toggles_ = {
    [DEFINE.PersonalzoneMedalType.Season] = self.uiBinder.binder_one_lattice.tog_function,
    [DEFINE.PersonalzoneMedalType.Leisure] = self.uiBinder.binder_four_lattice.tog_function
  }
  self.isAdding_ = false
  self.selectMedalClassify_ = 0
  self.selectMedalId_ = -1
  self.medalInfos_ = {}
  self.count_ = 0
  self.cellPosition_ = {}
  self.heightCellCount_ = 0
  self.widthCellCount_ = 0
  self:prepareCellPosition()
  self.oneLatticelooprect_ = loopGridView.new(self, self.uiBinder.loop_one_lattice, MedalLoopItem, "personalzone_medal_edit_01_tpl")
  self.fourLatticelooprect_ = loopGridView.new(self, self.uiBinder.loop_four_lattice, MedalLoopItem, "personalzone_medal_edit_03_tpl")
  local data = {}
  self.oneLatticelooprect_:Init(data)
  self.fourLatticelooprect_:Init(data)
  for i, toggle in pairs(self.toggles_) do
    local index = i
    toggle:AddListener(function(isOn)
      if isOn and self.selectMedalClassify_ ~= index then
        self.selectMedalClassify_ = index
        self:onToggleChange()
      end
    end)
  end
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_save, function()
    local save = {}
    for i, medal in pairs(self.medalInfos_) do
      save[medal.posIndex] = medal.id
    end
    local flag = self.personalZoneVM_.AsyncSetPersonalZoneMedal(save, self.cancelSource:CreateToken())
    if flag then
      local current = self.medalInfos_[self.selectMedalId_]
      if current then
        current.unit.Ref:SetVisible(current.unit.btn_close, false)
        current.unit.Ref:SetVisible(current.unit.img_on, false)
      end
      self.selectMedalId_ = -1
      Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnSaveMedalEdit)
      Z.TipsVM.ShowTipsLang(1002103)
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_obtain, function()
    self.personalZoneVM_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneMedal)
  end)
  self:AddAsyncClick(self.uiBinder.btn_prompt, function()
    self.personalZoneVM_.OpenPersonalZoneMain()
  end)
  self:refreshSecondReddot()
end

function PersonalZoneMedalEditMain:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self:createCurrentMedal()
    if self.toggles_[DEFINE.PersonalzoneMedalType.Season].isOn then
      self.selectMedalClassify_ = 1
      self:onToggleChange()
    else
      self.toggles_[DEFINE.PersonalzoneMedalType.Season].isOn = true
    end
    self.count_ = 0
    for _, v in pairs(self.medalInfos_) do
      if v ~= 0 then
        self.count_ = self.count_ + 1
      end
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_left, self.count_ == 0)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_line_frame, self.count_ ~= 0)
  end)()
end

function PersonalZoneMedalEditMain:OnDeActive()
  for _, toggle in pairs(self.toggles_) do
    toggle:RemoveAllListeners()
  end
  self.isAdding_ = nil
  self.toggles_ = nil
  self.selectMedalClassify_ = nil
  self.cellPosition_ = nil
  self.heightCellCount_ = nil
  self.widthCellCount_ = nil
  self.oneLatticelooprect_:UnInit()
  self.oneLatticelooprect_ = nil
  self.fourLatticelooprect_:UnInit()
  self.fourLatticelooprect_ = nil
  self.selectMedalId_ = nil
  self.medalInfos_ = nil
  self.personalzoneData_:ClearMedalAddReddot()
  self.personalZoneVM_.CheckRed()
end

function PersonalZoneMedalEditMain:AddNewMedal(id)
  if self.isAdding_ then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.isAdding_ = true
    if self.medalInfos_[id] then
      return
    end
    local config = Z.TableMgr.GetTable("MedalTableMgr").GetRow(id)
    if config then
      local tempMedalInfo = {id = id, config = config}
      local cells = self:findAllCellCanAttach(tempMedalInfo)
      if cells then
        self:createMedal(cells[1], id, true)
      end
    end
    self.isAdding_ = false
    self.personalzoneData_:RemovePersonalzoneItem(config.Id)
    self.personalZoneVM_.CheckRed()
    self:refreshSecondReddot()
    if self.selectMedalClassify_ == 1 then
      self.oneLatticelooprect_:RefreshAllShownItem()
    elseif self.selectMedalClassify_ == 3 then
      self.fourLatticelooprect_:RefreshAllShownItem()
    end
    self.count_ = self.count_ + 1
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_left, self.count_ == 0)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_line_frame, self.count_ ~= 0)
  end)()
end

function PersonalZoneMedalEditMain:RemoveMedal(id)
  if not self.medalInfos_[id] then
    return
  end
  self:RemoveUiUnit(tostring(id))
  self.medalInfos_[id] = nil
  if self.selectMedalId_ == id then
    self.selectMedalId_ = -1
  end
  if self.selectMedalClassify_ == DEFINE.PersonalzoneMedalType.Season then
    self.oneLatticelooprect_:RefreshAllShownItem()
  elseif self.selectMedalClassify_ == DEFINE.PersonalzoneMedalType.Leisure then
    self.fourLatticelooprect_:RefreshAllShownItem()
  end
  self.count_ = self.count_ - 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_left, self.count_ == 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_line_frame, self.count_ ~= 0)
end

function PersonalZoneMedalEditMain:prepareCellPosition()
  local w = self.uiBinder.trans_panel.rect.width
  local h = self.uiBinder.trans_panel.rect.height
  self.cellPosition_ = self.personalZoneVM_.PrepareCellPos(w, h, CELL_SIZE)
  local widthCount = Mathf.Floor(w / CELL_SIZE)
  local heightCount = Mathf.Floor(h / CELL_SIZE)
  self.heightCellCount_ = heightCount
  self.widthCellCount_ = widthCount
end

function PersonalZoneMedalEditMain:createCurrentMedal()
  self:ClearAllUnits()
  local socialData = self.socialVM_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.EntId, self.cancelSource:CreateToken())
  local medals
  if socialData.personalZone then
    medals = socialData.personalZone.medals
  end
  if not medals or not next(medals) then
    return
  end
  for pos, id in pairs(medals) do
    self:createMedal(pos, id, false)
  end
end

function PersonalZoneMedalEditMain:createMedal(pos, id, select)
  if id == 0 then
    return
  end
  local config = Z.TableMgr.GetTable("MedalTableMgr").GetRow(id)
  if config then
    local path = MEDAL_PATH[config.Type]
    local unit = self:AsyncLoadUiUnit(path, tostring(id), self.uiBinder.trans_panel.transform, self.cancelSource:CreateToken())
    if unit then
      self.medalInfos_[id] = {
        posIndex = pos,
        id = id,
        unit = unit,
        config = config
      }
      unit.img_medal_02:SetImage(config.Image)
      do
        local cellOffset = self.cellPosition_[pos]
        unit.rect_unit:SetAnchorPosition(cellOffset.x, cellOffset.y)
        unit.Ref:SetVisible(unit.img_not, false)
        unit.Ref:SetVisible(unit.btn_close, select)
        unit.Ref:SetVisible(unit.img_on, select)
        unit.event_medal_02.onClick:RemoveAllListeners()
        unit.event_medal_02.onClick:AddListener(function(go, eventData)
          local current = self.medalInfos_[self.selectMedalId_]
          if current then
            current.unit.Ref:SetVisible(current.unit.btn_close, false)
            current.unit.Ref:SetVisible(current.unit.img_on, false)
          end
          unit.Ref:SetVisible(unit.btn_close, true)
          unit.Ref:SetVisible(unit.img_on, true)
          self.selectMedalId_ = id
        end)
        unit.event_medal_02.onBeginDrag:RemoveAllListeners()
        unit.event_medal_02.onBeginDrag:AddListener(function(go, eventData)
          local current = self.medalInfos_[self.selectMedalId_]
          if current then
            current.unit.Ref:SetVisible(current.unit.btn_close, false)
            current.unit.Ref:SetVisible(current.unit.img_on, false)
          end
          unit.Ref:SetVisible(unit.btn_close, true)
          unit.Ref:SetVisible(unit.img_on, true)
          self.selectMedalId_ = id
        end)
        unit.event_medal_02.onDrag:RemoveAllListeners()
        unit.event_medal_02.onDrag:AddListener(function(go, eventData)
          local _, toPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.trans_panel, eventData.position, nil)
          local width = self.uiBinder.trans_panel.rect.width
          local height = self.uiBinder.trans_panel.rect.height
          local size = MEDAL_SIZE[config.Type]
          toPos.x = toPos.x + width / 2 - size.x / 2
          toPos.y = toPos.y - height / 2 + size.y / 2
          unit.rect_unit:SetAnchorPosition(toPos.x, toPos.y)
        end)
        unit.event_medal_02.onEndDrag:RemoveAllListeners()
        unit.event_medal_02.onEndDrag:AddListener(function(go, eventData)
          self:adsorbCell(self.medalInfos_[id])
        end)
        unit.btn_close:AddListener(function()
          self:RemoveMedal(id)
        end, true)
        if select then
          local current = self.medalInfos_[self.selectMedalId_]
          if current then
            current.unit.Ref:SetVisible(current.unit.btn_close, false)
            current.unit.Ref:SetVisible(current.unit.img_on, false)
          end
          self.selectMedalId_ = id
        end
      end
    end
  end
end

function PersonalZoneMedalEditMain:adsorbCell(medalInfo)
  if not medalInfo then
    return
  end
  local cells = self:findAllCellCanAttach(medalInfo)
  if cells then
    table.sort(cells, function(a, b)
      local posA = self.cellPosition_[a]
      local posB = self.cellPosition_[b]
      local endPos = medalInfo.unit.rect_unit.anchoredPosition
      local lenA = (posA.x - endPos.x) * (posA.x - endPos.x) + (posA.y - endPos.y) * (posA.y - endPos.y)
      local lenB = (posB.x - endPos.x) * (posB.x - endPos.x) + (posB.y - endPos.y) * (posB.y - endPos.y)
      return lenA < lenB
    end)
    medalInfo.posIndex = cells[1]
  end
  local position = self.cellPosition_[medalInfo.posIndex]
  medalInfo.unit.rect_unit:SetAnchorPosition(position.x, position.y)
end

function PersonalZoneMedalEditMain:findAllCellCanAttach(medalInfo)
  local size = MEDAL_SIZE[medalInfo.config.Type]
  local cellCountX = size.x / CELL_SIZE
  local cellCountY = size.y / CELL_SIZE
  local validCell = {}
  for i = 1, self.heightCellCount_ - cellCountY + 1 do
    for j = 1, self.widthCellCount_ - cellCountX + 1 do
      local index = (i - 1) * self.widthCellCount_ + j
      if not self:checkOverlap(index, medalInfo) then
        validCell[#validCell + 1] = index
      end
    end
  end
  if 0 < #validCell then
    return validCell
  end
  return nil
end

function PersonalZoneMedalEditMain:checkOverlap(index, medalInfo)
  local otherRect = {}
  for id, v in pairs(self.medalInfos_) do
    if id ~= medalInfo.id then
      local pos = self.cellPosition_[v.posIndex]
      otherRect[#otherRect + 1] = {
        x1 = pos.x,
        y1 = pos.y,
        x2 = pos.x + MEDAL_SIZE[v.config.Type].x,
        y2 = pos.y - MEDAL_SIZE[v.config.Type].y
      }
    end
  end
  local selfPos = self.cellPosition_[index]
  local rect2 = {
    x1 = selfPos.x,
    y1 = selfPos.y,
    x2 = selfPos.x + MEDAL_SIZE[medalInfo.config.Type].x,
    y2 = selfPos.y - MEDAL_SIZE[medalInfo.config.Type].y
  }
  for _, rect1 in pairs(otherRect) do
    local x1 = rect1.x1
    local y1 = rect1.y1
    local x2 = rect1.x2
    local y2 = rect1.y2
    local x3 = rect2.x1
    local y3 = rect2.y1
    local x4 = rect2.x2
    local y4 = rect2.y2
    if not (x1 >= x4) and not (x2 <= x3) and not (y1 <= y4) and not (y2 >= y3) then
      return true
    end
  end
  return false
end

function PersonalZoneMedalEditMain:onToggleChange()
  self:SetUIVisible(self.uiBinder.loop_one_lattice, self.selectMedalClassify_ == DEFINE.PersonalzoneMedalType.Season)
  self:SetUIVisible(self.uiBinder.loop_four_lattice, self.selectMedalClassify_ == DEFINE.PersonalzoneMedalType.Leisure)
  local configs = self.personalZoneVM_.GetMedalConfig(self.selectMedalClassify_)
  if configs then
    local haveMedel = 0 < #configs
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_right, not haveMedel)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_obtain, not haveMedel)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, haveMedel)
    if self.selectMedalClassify_ == DEFINE.PersonalzoneMedalType.Season then
      self.oneLatticelooprect_:RefreshListView(configs)
    elseif self.selectMedalClassify_ == DEFINE.PersonalzoneMedalType.Leisure then
      self.fourLatticelooprect_:RefreshListView(configs)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_right, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_obtain, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_save, false)
  end
end

function PersonalZoneMedalEditMain:refreshSecondReddot()
  local reds = {
    [DEFINE.PersonalzoneMedalType.Season] = false,
    [DEFINE.PersonalzoneMedalType.Leisure] = false
  }
  for type, _ in pairs(reds) do
    local configs = self.personalZoneVM_.GetMedalConfig(type)
    if configs then
      for _, config in ipairs(configs) do
        if self.personalZoneVM_.CheckSingleRedDot(config.Id) then
          reds[type] = true
          break
        end
      end
    end
  end
  for type, red in pairs(reds) do
    self.uiBinder.Ref:SetVisible(self.uiBinder["node_reddot_" .. type], red)
  end
end

return PersonalZoneMedalEditMain
