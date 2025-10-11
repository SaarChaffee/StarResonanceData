local UI = Z.UI
local super = require("ui.ui_subview_base")
local Personalzone_main_photo_subView = class("Personalzone_main_photo_subView", super)
local PersonalZoneDefine = require("ui.model.personalzone_define")
local PersonalzonePhotoItem = require("ui.component.personalzone.personalzone_photo_item")
local PhotoCell = {x = 238, y = 126}
local PhotoPaddingLeft = 18
local PhotoPaddingTop = 14
local PhotoSpacing = {x = 30, y = 20}

function Personalzone_main_photo_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "personalzone_main_photo_sub", "personalzone/personalzone_main_photo_sub", UI.ECacheLv.None)
  self.viewData = nil
  self.parentView_ = parent
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
end

function Personalzone_main_photo_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_setting, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isPersonalzoneOpen = gotoFuncVM.CheckFuncCanUse(E.FunctionID.Personalzone)
    local isPersonalzonephoto = gotoFuncVM.CheckFuncCanUse(E.AlbumFuncId.Album)
    if not isPersonalzoneOpen or not isPersonalzonephoto then
      return
    end
    self.personalzoneVm_.OpenPersonalZoneEditor(PersonalZoneDefine.IdCardEditorType.Album)
  end)
  self:AddAsyncClick(self.uiBinder.node_change_over.btn_left, function()
    if not self.isInitPhotoCell_ then
      return
    end
    self.curPage_ = self.curPage_ - 1
    self.curPage_ = math.max(1, self.curPage_)
    self:refreshPageIndex()
    self:refreshPagePhoto(true)
  end)
  self:AddAsyncClick(self.uiBinder.node_change_over.btn_right, function()
    if not self.isInitPhotoCell_ then
      return
    end
    self.curPage_ = self.curPage_ + 1
    self.curPage_ = math.min(Z.Global.PersonalPhotoLimit, self.curPage_)
    self:refreshPageIndex()
    self:refreshPagePhoto(true)
  end)
  self.curPage_ = 1
  self.isInitPhotoCell_ = false
  self.photos_ = self.viewData.photos
  self.photoUnits_ = {}
  self.editorType_ = self.viewData.editorType
  self.selectPhotoIndex_ = nil
  local isShowEmpty = self.editorType_ == PersonalZoneDefine.IdCardEditorType.None and next(self.photos_) == nil
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_items, not isShowEmpty)
  self.uiBinder.node_change_over.Ref.UIComp:SetVisible(not isShowEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, isShowEmpty)
  self.uiBinder.dragitem.Ref.UIComp:SetVisible(false)
  self.dragItem_ = PersonalzonePhotoItem.new(self)
  self.dragItem_:Init(self.uiBinder.dragitem)
  self:refreshPageIndex()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_setting, self.editorType_ == PersonalZoneDefine.IdCardEditorType.None and self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId)
  Z.CoroUtil.create_coro_xpcall(function()
    self:initPhotoCell()
    self:refreshPagePhoto(false)
  end)()
end

function Personalzone_main_photo_subView:OnDeActive()
  for _, v in pairs(self.photoUnits_) do
    v.item:UnInit()
    self:RemoveUiUnit(v.name)
  end
end

function Personalzone_main_photo_subView:OnRefresh()
end

function Personalzone_main_photo_subView:ChangePhotos(photos)
  self.photos_ = photos
  if not self.isInitPhotoCell_ then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshPagePhoto(true)
  end)()
end

function Personalzone_main_photo_subView:refreshPageIndex()
  for i = 1, 5 do
    local img = self.uiBinder.node_change_over.node_dot["img_dot_" .. i]
    if i <= Z.Global.PersonalPhotoLimit then
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
  if self.curPage_ == Z.Global.PersonalPhotoLimit then
    self.uiBinder.node_change_over.img_right:SetColor(PersonalZoneDefine.PageBtnColor.CannotTouch)
  else
    self.uiBinder.node_change_over.img_right:SetColor(PersonalZoneDefine.PageBtnColor.CanTouch)
  end
end

function Personalzone_main_photo_subView:initPhotoCell()
  local photoItemPath = self.uiBinder.uiprefab_cache:GetString("item")
  self.photoUnits_ = {}
  for y = 1, Z.Global.PersonalzonePhotoRow[2] do
    for x = 1, Z.Global.PersonalzonePhotoRow[1] do
      local name = string.format("photo_%s_%s", x, y)
      local photoUnit = self:AsyncLoadUiUnit(photoItemPath, name, self.uiBinder.node_items)
      if photoUnit then
        photoUnit.Trans:SetAnchorPosition(PhotoPaddingLeft + (x - 1) * (PhotoCell.x + PhotoSpacing.x), -PhotoPaddingTop - (y - 1) * (PhotoCell.y + PhotoSpacing.y))
        photoUnit.eventtrigger.onBeginDrag:RemoveAllListeners()
        photoUnit.eventtrigger.onDrag:RemoveAllListeners()
        photoUnit.eventtrigger.onEndDrag:RemoveAllListeners()
        local key = x + (y - 1) * Z.Global.PersonalzonePhotoRow[1]
        if self.editorType_ == PersonalZoneDefine.IdCardEditorType.None then
          photoUnit.btn_bg:AddListener(function()
            local index = (self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] + key
            if self.photos_[index] and self.photos_[index] ~= 0 then
              Z.UIMgr:OpenView("personalzone_photo_show_window", {
                charId = self.viewData.charId,
                photoId = self.photos_[index],
                name = self.viewData.name
              })
            end
          end)
        end
        if self.editorType_ == PersonalZoneDefine.IdCardEditorType.Album then
          photoUnit.btn_close:AddListener(function()
            local index = (self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] + key
            self.parentView_:DeletePhoto(index)
          end)
          photoUnit.eventtrigger.onBeginDrag:AddListener(function(go, eventData)
            local index = (self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] + key
            if self.photos_[index] == nil then
              return
            end
            self.selectPhotoIndex_ = index
            self.uiBinder.dragitem.Ref.UIComp:SetVisible(true)
            Z.CoroUtil.create_coro_xpcall(function()
              self.dragItem_:AsyncRefreshPhotoId(self.viewData.charId, self.photos_[index])
            end)()
          end)
          photoUnit.eventtrigger.onDrag:AddListener(function(go, eventData)
            local index = (self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] + key
            if self.photos_[index] == nil then
              return
            end
            local _, toPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.node_items, eventData.position, nil)
            local width, height = self.uiBinder.node_items:GetSizeDelta(nil, nil)
            toPos.x = toPos.x + width / 2 - PhotoCell.x / 2
            toPos.y = toPos.y - height / 2 + PhotoCell.y / 2
            self.uiBinder.dragitem.Trans:SetAnchorPosition(toPos.x, toPos.y)
          end)
          photoUnit.eventtrigger.onEndDrag:AddListener(function(go, eventData)
            self.selectPhotoIndex_ = nil
            self.uiBinder.dragitem.Ref.UIComp:SetVisible(false)
            local index = (self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] + key
            if self.photos_[index] == nil then
              return
            end
            local rectPosX, rectPosY = self.uiBinder.dragitem.Trans:GetAnchorPosition(nil, nil)
            local xRow = math.ceil((rectPosX + PhotoCell.x / 2 - PhotoPaddingLeft) / (PhotoCell.x + PhotoSpacing.x))
            local yRow = math.ceil((-rectPosY + PhotoCell.x / 2 - PhotoPaddingTop) / (PhotoCell.y + PhotoSpacing.y))
            if xRow < 1 or xRow > Z.Global.PersonalzonePhotoRow[1] or yRow < 1 or yRow > Z.Global.PersonalzonePhotoRow[2] then
              return
            end
            local exchangeKey = (self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] + xRow + (yRow - 1) * Z.Global.PersonalzonePhotoRow[1]
            local curKey = x + (y - 1) * Z.Global.PersonalzonePhotoRow[1] + (self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2]
            self:exchangePhoto(curKey, exchangeKey)
          end)
        end
        local photoItem = PersonalzonePhotoItem.new(self)
        photoItem:Init(photoUnit)
        self.photoUnits_[x + (y - 1) * Z.Global.PersonalzonePhotoRow[1]] = {
          name = name,
          unit = photoUnit,
          item = photoItem
        }
      end
    end
  end
  self.isInitPhotoCell_ = true
end

function Personalzone_main_photo_subView:refreshPagePhoto(isResetPosition)
  if self.photos_ then
    for k, v in pairs(self.photoUnits_) do
      if isResetPosition then
        local x = k % Z.Global.PersonalzonePhotoRow[1] == 0 and Z.Global.PersonalzonePhotoRow[1] or k % Z.Global.PersonalzonePhotoRow[1]
        local y = math.ceil(k / Z.Global.PersonalzonePhotoRow[1])
        v.unit.Trans:SetAnchorPosition(PhotoPaddingLeft + (x - 1) * (PhotoCell.x + PhotoSpacing.x), -PhotoPaddingTop - (y - 1) * (PhotoCell.y + PhotoSpacing.y))
      end
      local photoId = self.photos_[(self.curPage_ - 1) * Z.Global.PersonalzonePhotoRow[1] * Z.Global.PersonalzonePhotoRow[2] + k]
      v.item:AsyncRefreshPhotoId(self.viewData.charId, photoId)
      v.unit.Ref:SetVisible(v.unit.btn_close, photoId and photoId ~= 0 and self.editorType_ == PersonalZoneDefine.IdCardEditorType.Album and self.viewData.charId == Z.EntityMgr.PlayerEnt.CharId)
    end
  end
end

function Personalzone_main_photo_subView:exchangePhoto(curKey, exchangeKey)
  self.parentView_:ExchangePhoto(curKey, exchangeKey)
end

function Personalzone_main_photo_subView:GetCurPage()
  return self.curPage_
end

function Personalzone_main_photo_subView:ChangeEditorType(editorType)
  self.editorType_ = editorType
  Z.CoroUtil.create_coro_xpcall(function()
    self:initPhotoCell()
    self:refreshPagePhoto(false)
  end)()
end

return Personalzone_main_photo_subView
