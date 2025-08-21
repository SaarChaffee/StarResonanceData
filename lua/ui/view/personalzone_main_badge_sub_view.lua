local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_main_badge_subView = class("Personalzone_main_badge_subView", super)
local PersonalZoneDefine = require("ui.model.personalzone_define")
local MedalCell = {x = 142, y = 142}
local MedalPaddingLeft = 6
local MedalPaddingTop = 10
local MedalSpacing = {x = 12, y = 12}

function Personalzone_main_badge_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_main_badge_sub", "personalzone/personalzone_main_badge_sub", UI.ECacheLv.None)
  self.parentView_ = parent
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.viewData = nil
end

function Personalzone_main_badge_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_setting, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isPersonalzoneMedal = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Personalzone)
    if not isPersonalzoneMedal then
      return
    end
    self.personalzoneVm_.OpenPersonalZoneEditor(PersonalZoneDefine.IdCardEditorType.Badge)
  end)
  self:AddAsyncClick(self.uiBinder.node_change_over.btn_left, function()
    if not self.isInitMedalCell_ then
      return
    end
    self.curPage_ = self.curPage_ - 1
    self.curPage_ = math.max(1, self.curPage_)
    self:refreshPageIndex()
    self:refreshPageMedal(true)
  end)
  self:AddAsyncClick(self.uiBinder.node_change_over.btn_right, function()
    if not self.isInitMedalCell_ then
      return
    end
    self.curPage_ = self.curPage_ + 1
    self.curPage_ = math.min(Z.Global.PersonalMedalLimit, self.curPage_)
    self:refreshPageIndex()
    self:refreshPageMedal(true)
  end)
  self.curPage_ = 1
  self.isInitMedalCell_ = false
  self.medals_ = self.viewData.medals
  self.editorType_ = self.viewData.editorType
  self.medalUnits_ = {}
  self.selectMedalIndex_ = nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, false)
  local isShowEmpty = self.editorType_ == PersonalZoneDefine.IdCardEditorType.None and next(self.medals_) == nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_items, not isShowEmpty)
  self.uiBinder.node_change_over.Ref.UIComp:SetVisible(not isShowEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, isShowEmpty)
  self:refreshPageIndex()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_setting, self.editorType_ == PersonalZoneDefine.IdCardEditorType.None and self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId)
  Z.CoroUtil.create_coro_xpcall(function()
    self:initMedalCell()
    self:refreshPageMedal(false)
  end)()
end

function Personalzone_main_badge_subView:OnDeActive()
  for _, v in pairs(self.medalUnits_) do
    self:RemoveUiUnit(v.name)
  end
end

function Personalzone_main_badge_subView:OnRefresh()
end

function Personalzone_main_badge_subView:ChangeMedals(medals)
  self.medals_ = medals
  if not self.isInitMedalCell_ then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshPageMedal(true)
  end)()
end

function Personalzone_main_badge_subView:refreshPageIndex()
  for i = 1, 5 do
    local img = self.uiBinder.node_change_over.node_dot["img_dot_" .. i]
    if i <= Z.Global.PersonalMedalLimit then
      self.uiBinder.node_change_over.node_dot.Ref:SetVisible(img, true)
      img:SetColor(i == self.curPage_ and PersonalZoneDefine.PageIndexColor.Select or PersonalZoneDefine.PageIndexColor.UnSelect)
    else
      self.uiBinder.node_change_over.node_dot.Ref:SetVisible(img, false)
    end
  end
  if self.curPage_ == 1 then
    self.uiBinder.node_change_over.img_left:SetColor(PersonalZoneDefine.PageBtnColor.CannotTouch)
  else
    self.uiBinder.node_change_over.img_left:SetColor(PersonalZoneDefine.PageBtnColor.CanTouch)
  end
  if self.curPage_ == Z.Global.PersonalMedalLimit then
    self.uiBinder.node_change_over.img_right:SetColor(PersonalZoneDefine.PageBtnColor.CannotTouch)
  else
    self.uiBinder.node_change_over.img_right:SetColor(PersonalZoneDefine.PageBtnColor.CanTouch)
  end
end

function Personalzone_main_badge_subView:initMedalCell()
  local medalItemPath = self.uiBinder.uiprefab_cache:GetString("item")
  self.medalUnits_ = {}
  for y = 1, Z.Global.PersonalzoneMedalRow[2] do
    for x = 1, Z.Global.PersonalzoneMedalRow[1] do
      local name = string.format("medal_%s_%s", x, y)
      local medalUnit = self:AsyncLoadUiUnit(medalItemPath, name, self.uiBinder.node_items)
      if medalUnit then
        medalUnit.Trans:SetAnchorPosition(MedalPaddingLeft + (x - 1) * (MedalCell.x + MedalSpacing.x), -MedalPaddingTop - (y - 1) * (MedalCell.y + MedalSpacing.y))
        medalUnit.eventtrigger.onBeginDrag:RemoveAllListeners()
        medalUnit.eventtrigger.onDrag:RemoveAllListeners()
        medalUnit.eventtrigger.onEndDrag:RemoveAllListeners()
        local key = x + (y - 1) * Z.Global.PersonalzoneMedalRow[1]
        if self.editorType_ == PersonalZoneDefine.IdCardEditorType.Badge then
          medalUnit.btn_close:AddListener(function()
            local index = (self.curPage_ - 1) * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] + key
            self.parentView_:DeleteMedal(index)
          end)
          medalUnit.eventtrigger.onBeginDrag:AddListener(function(go, eventData)
            local index = (self.curPage_ - 1) * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] + key
            if self.medals_[index] == nil then
              return
            end
            self.selectMedalIndex_ = index
            local config = Z.TableMgr.GetTable("MedalTableMgr").GetRow(self.medals_[index])
            if config then
              self.uiBinder.rimg_icon:SetImage(config.Image)
              self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, true)
            end
          end)
          medalUnit.eventtrigger.onDrag:AddListener(function(go, eventData)
            local index = (self.curPage_ - 1) * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] + key
            if self.medals_[index] == nil then
              return
            end
            local _, toPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.node_items, eventData.position, nil)
            local width, height = self.uiBinder.node_items:GetSizeDelta(nil, nil)
            toPos.x = toPos.x + width / 2 - MedalCell.x / 2
            toPos.y = toPos.y - height / 2 + MedalCell.y / 2
            self.uiBinder.rect_icon:SetAnchorPosition(toPos.x, toPos.y)
          end)
          medalUnit.eventtrigger.onEndDrag:AddListener(function(go, eventData)
            self.selectMedalIndex_ = nil
            self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, false)
            local index = (self.curPage_ - 1) * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] + key
            if self.medals_[index] == nil then
              return
            end
            local rectPosX, rectPosY = self.uiBinder.rect_icon:GetAnchorPosition(nil, nil)
            local xRow = math.ceil((rectPosX + MedalCell.x / 2 - MedalPaddingLeft) / (MedalCell.x + MedalSpacing.x))
            local yRow = math.ceil((-rectPosY + MedalCell.y / 2 - MedalPaddingTop) / (MedalCell.y + MedalSpacing.y))
            if xRow < 1 or xRow > Z.Global.PersonalzoneMedalRow[1] or yRow < 1 or yRow > Z.Global.PersonalzoneMedalRow[2] then
              return
            end
            local exchangeKey = (self.curPage_ - 1) * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] + xRow + (yRow - 1) * Z.Global.PersonalzoneMedalRow[1]
            local curKey = key + (self.curPage_ - 1) * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2]
            self:exchangeMedal(curKey, exchangeKey)
          end)
        else
          medalUnit.Ref:SetVisible(medalUnit.btn_close, false)
        end
        self.medalUnits_[x + (y - 1) * Z.Global.PersonalzoneMedalRow[1]] = {name = name, unit = medalUnit}
      end
    end
  end
  self.isInitMedalCell_ = true
end

function Personalzone_main_badge_subView:refreshPageMedal(isResetPosition)
  if self.medals_ then
    for k, v in pairs(self.medalUnits_) do
      v.unit.Ref:SetVisible(v.unit.btn_close, false)
      if isResetPosition then
        local x = k % Z.Global.PersonalzoneMedalRow[1] == 0 and Z.Global.PersonalzoneMedalRow[1] or k % Z.Global.PersonalzoneMedalRow[1]
        local y = math.ceil(k / Z.Global.PersonalzoneMedalRow[1])
        v.unit.Trans:SetAnchorPosition(MedalPaddingLeft + (x - 1) * (MedalCell.x + MedalSpacing.x), -MedalPaddingTop - (y - 1) * (MedalCell.y + MedalSpacing.y))
      end
      local medalId = self.medals_[(self.curPage_ - 1) * Z.Global.PersonalzoneMedalRow[1] * Z.Global.PersonalzoneMedalRow[2] + k]
      v.unit.img_icon.enabled = false
      if medalId and medalId ~= 0 then
        local medalconfig = Z.TableMgr.GetTable("MedalTableMgr").GetRow(medalId)
        if medalconfig then
          v.unit.Ref:SetVisible(v.unit.btn_close, self.editorType_ == PersonalZoneDefine.IdCardEditorType.Badge and self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId)
          v.unit.img_icon:SetImage(medalconfig.Image)
        end
      end
    end
  end
end

function Personalzone_main_badge_subView:exchangeMedal(curKey, exchangeKey)
  self.parentView_:ExchangeMedal(curKey, exchangeKey)
end

function Personalzone_main_badge_subView:GetCurPage()
  return self.curPage_
end

function Personalzone_main_badge_subView:ChangeEditorType(editorType)
  self.editorType_ = editorType
  Z.CoroUtil.create_coro_xpcall(function()
    self:initMedalCell()
    self:refreshPageMedal(false)
  end)()
end

return Personalzone_main_badge_subView
