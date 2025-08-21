local super = require("ui.ui_view_base")
local Photo_editingView = class("Photo_editingView", super)
local TextSub = require("ui/view/photo_editor_container_text_sub_view")
local MovieScreenSub = require("ui/view/photo_editor_container_moviescreen_sub_view")
local THUMB_WIDTH = 256
local THUMB_HEIGHT = 144

function Photo_editingView:ctor()
  self.uiBinder = nil
  super.ctor(self, "photo_editing")
  self.decorate_subView = require("ui/view/decorate_sub_view").new(self)
  self.photoeditor_right_subView = require("ui/view/photo_editor_right_sub_view").new(self)
  self.viewData = nil
  self.photoEditorData_ = Z.DataMgr.Get("photo_editing_data")
  self.rightSubViewData = {
    togDatas = {
      [1] = {
        functionId = E.CamerasysFuncType.Frame,
        operate = function(frameType, res)
          local tempFrameType, tempRes = self.photoEditorData_:GetOriginalFrameTable()
          if tempFrameType == nil and frameType == E.CameraFrameType.None then
            return true
          elseif tempFrameType == frameType and (tempFrameType == E.CameraFrameType.None or res == tempRes) then
            return true
          else
            return false
          end
        end,
        callBack = function(frameType, frameRes)
          self:changeFrame(frameType, frameRes)
        end
      },
      [2] = {
        functionId = E.CamerasysFuncType.Sticker,
        operate = function()
          return self.photoEditorData_:GetDecorateCount(), self.photoEditorData_.MaxDecorateCount
        end,
        callBack = function(res)
          self:addDecorateSticker(res)
        end
      },
      [3] = {
        functionId = E.CamerasysFuncType.Text,
        operate = function(type)
          if type == TextSub.OperateType.CheckCreate then
            return self.photoEditorData_:CheckCanCreateText()
          elseif type == TextSub.OperateType.CheckEditor then
            return self.photoEditorData_:CheckCanEditorText()
          elseif type == TextSub.OperateType.GetFontSize then
            return self.photoEditorData_:GetTextFontSize()
          elseif type == TextSub.OperateType.GetFontColor then
            return self.photoEditorData_:GetTextFontColor()
          elseif type == TextSub.OperateType.GetDecorateCount then
            return self.photoEditorData_:GetDecorateCount(), self.photoEditorData_.MaxDecorateCount
          elseif type == TextSub.OperateType.GetFontText then
            return self.photoEditorData_:GetText()
          end
        end,
        callBack = function(type, param)
          if type == TextSub.CallBackFunctionType.CreateText then
            self:addDecorateText(param)
          elseif type == TextSub.CallBackFunctionType.EditorText then
            self:editorDecorateText(param)
          elseif type == TextSub.CallBackFunctionType.ChangeFontSize then
            self:changeTextFontSize(param)
          elseif type == TextSub.CallBackFunctionType.ChangeFontColor then
            self:changeTextColor(param)
          end
        end
      },
      [4] = {
        functionId = E.CamerasysFuncType.Filter,
        operate = function(path)
          return path == self.photoEditorData_:GetFilter()
        end,
        callBack = function(path)
          self.photoEditorData_:SetFilter(path)
          Z.CameraFrameCtrl:SetAlbumSecondFilter(path)
        end
      },
      [5] = {
        functionId = E.CamerasysFuncType.Shotset,
        operate = function()
          return self.photoEditorData_:GetExposure(), self.photoEditorData_:GetContrast(), self.photoEditorData_:GetSaturation()
        end,
        callBack = function(type, param)
          if type == MovieScreenSub.CallBackFunctionType.ChangeExposure then
            self.photoEditorData_:SetExposure(param)
            Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Exposure, param)
          elseif type == MovieScreenSub.CallBackFunctionType.ChangeContrast then
            self.photoEditorData_:SetContrast(param)
            Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Contrast, param)
          elseif type == MovieScreenSub.CallBackFunctionType.ChangeSaturation then
            self.photoEditorData_:SetSaturation(param)
            Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Saturation, param)
          elseif type == MovieScreenSub.CallBackFunctionType.Reset then
            self.photoEditorData_:ResetExposure()
            self.photoEditorData_:ResetContrast()
            self.photoEditorData_:ResetSaturation()
          end
        end
      }
    }
  }
end

function Photo_editingView:OnActive()
  self:initBtnEvents()
end

function Photo_editingView:OnRefresh()
  if self.viewData == nil then
    return
  end
  self.photoEditorData_:InitData()
  if self.viewData.decorateInfo then
    self.photoEditorData_:DeserializeDecorateInfo(self.viewData.decorateInfo)
  end
  self:initOriginalPhoto()
  self:refreshFrame()
  self:initializeCreateDecorate()
  self:SetUIShow(true)
end

function Photo_editingView:OnDeActive()
  self.photoeditor_right_subView:DeActive()
  self.decorate_subView:DeActive()
end

function Photo_editingView:initBtnEvents()
  self.photoEditorFuncTogs_ = {
    [1] = {
      tog = self.uiBinder.uibinder_frame,
      functionId = E.CamerasysFuncType.Frame
    },
    [2] = {
      tog = self.uiBinder.uibinder_sticker,
      functionId = E.CamerasysFuncType.Sticker
    },
    [3] = {
      tog = self.uiBinder.uibinder_text,
      functionId = E.CamerasysFuncType.Text
    },
    [4] = {
      tog = self.uiBinder.uibinder_filter,
      functionId = E.CamerasysFuncType.Filter
    },
    [5] = {
      tog = self.uiBinder.uibinder_moviescreen,
      functionId = E.CamerasysFuncType.Shotset
    }
  }
  for _, tog in ipairs(self.photoEditorFuncTogs_) do
    tog.tog.group = self.uiBinder.node_toggle
  end
  self.uiBinder.node_toggle.AllowSwitchOff = true
  for key, tog in ipairs(self.photoEditorFuncTogs_) do
    tog.tog.tog:AddListener(function(isOn)
      local index = key
      self.rightSubViewData.selectIndex = index
      self.photoeditor_right_subView:Active(self.rightSubViewData, self.uiBinder.anim_setting_container)
    end)
  end
  self:AddClick(self.uiBinder.btn_return, function()
    Z.UIMgr:CloseView("photo_editing")
  end)
  self:AddAsyncClick(self.uiBinder.btn_function, function()
    self:SetUIShow(false)
    self.photoEditorData_:ActiveData(nil)
    self.decorate_subView:ActiveDecorateUnit(nil)
    Z.UIRoot:SetClickEffectIsShow(false)
    local normalScreenSize = Z.UIRoot.DESIGNSIZE_WIDTH / Z.UIRoot.DESIGNSIZE_HEIGHT
    local photoWidth = Z.UIRoot.CurScreenSize.x
    local photoHeight = Z.UIRoot.CurScreenSize.y
    local screenSize = photoWidth / photoHeight
    if normalScreenSize <= screenSize then
      photoWidth = photoHeight * normalScreenSize
    else
      photoHeight = photoWidth / normalScreenSize
    end
    photoWidth = math.floor(photoWidth)
    photoHeight = math.floor(photoHeight)
    Z.CoroUtil.create_coro_xpcall(function()
      local effectId = self:asyncTakePhotoByRect()
      local effectThumbId = Z.LuaBridge.ResizeTextureSizeForAlbum(effectId, E.NativeTextureCallToken.Camera_photo_secondary_editingView2, THUMB_WIDTH, THUMB_HEIGHT)
      local tempPhotoPath = Z.CameraFrameCtrl:SaveToCacheAlbum(E.CachePhotoType.CacheEffectPhoto, effectId)
      local tempThumbPhoto = Z.CameraFrameCtrl:SaveToCacheAlbum(E.CachePhotoType.CacheThumbPhoto, effectThumbId)
      local photoDecorateInfo = self.photoEditorData_:SerializeDecorateInfo()
      if self.viewData.saveFunc then
        self.viewData.saveFunc(tempPhotoPath, tempThumbPhoto, photoDecorateInfo)
      end
      if effectId and effectId ~= 0 then
        Z.LuaBridge.ReleaseScreenShot(effectId)
      end
      if effectThumbId and effectThumbId ~= 0 then
        Z.LuaBridge.ReleaseScreenShot(effectThumbId)
      end
      self:SetUIShow(true)
      Z.UIRoot:SetClickEffectIsShow(true)
    end)()
  end)
end

function Photo_editingView:asyncTakePhotoByRect()
  local rectTransform = self.uiBinder.node_img_icon
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  local offset = Vector2.New(Z.UIRoot.CurCanvasSize.x / 2, Z.UIRoot.CurCanvasSize.y / 2)
  local rectPosX = -rectTransform.rect.width / 2 + rectTransform.anchoredPosition.x + offset.x
  local rectPosY = -rectTransform.rect.height / 2 + rectTransform.anchoredPosition.y + offset.y
  local widthScale = Z.UIRoot.CurScreenSize.x / Z.UIRoot.CurCanvasSize.x
  local heightScale = Z.UIRoot.CurScreenSize.y / Z.UIRoot.CurCanvasSize.y
  local effectId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysView, rectPosX * widthScale, rectPosY * heightScale, rectTransform.rect.width * widthScale, rectTransform.rect.height * heightScale)
  return effectId
end

function Photo_editingView:SetUIShow(show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_function, show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_return, show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rect_toggle_editing, show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_setting_container, show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, show)
end

function Photo_editingView:SetDecorateShow(show)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, show)
end

function Photo_editingView:initOriginalPhoto()
  local shotSetData = self.photoEditorData_:GetShotSetData()
  Z.CoroUtil.create_coro_xpcall(function()
    Z.CameraFrameCtrl:ReductionPhotoAsync(self.uiBinder.rimg_photo_icon, self.viewData.url, self.viewData.albumType, shotSetData.exposure, shotSetData.contrast, shotSetData.saturation, shotSetData.filterData, self.cancelSource:CreateToken())
  end)()
end

function Photo_editingView:refreshFrame()
  local frameType, path = self.photoEditorData_:GetFrame()
  if frameType == E.CameraFrameType.None or not frameType then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  elseif frameType == E.CameraFrameType.Normal then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
    self.uiBinder.rimg_frame_layer_big:SetImage(path)
  elseif frameType == E.CameraFrameType.FillBlack then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, true)
    self.uiBinder.rimg_frame_fill_big:SetImage(path)
  end
end

function Photo_editingView:changeFrame(frameType, frameRes)
  self.photoEditorData_:ChangeFrame(frameType, frameRes)
  self:refreshFrame()
end

function Photo_editingView:initializeCreateDecorate()
  local subViewData = {
    decorateData = self.photoEditorData_:GetAllDecorateStickers(),
    isCanEditor = true,
    removeFunc = function(name)
      self:removeDecorate(name)
    end,
    changeAlpha = function(name, alpha)
      self:changeAlpha(name, alpha)
    end,
    activeUnit = function(name)
      self:activeDecorate(name)
    end
  }
  self.decorate_subView:Active(subViewData, self.uiBinder.node_decorate)
end

function Photo_editingView:removeDecorate(name)
  self.photoEditorData_:ActiveData(nil)
  self.decorate_subView:ActiveDecorateUnit(nil)
  self.photoEditorData_:RemoveDecorate(name)
  self.decorate_subView:RemoveUnit(name)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateNumberUpdate)
end

function Photo_editingView:changeAlpha(name, alpha)
  local data = self.photoEditorData_:GetDecorateData(name)
  if data then
    data.transparency = alpha
    self.decorate_subView:ChangeDecorateAlpha(data)
  end
end

function Photo_editingView:activeDecorate(name)
  local data = self.photoEditorData_:ActiveData(name)
  self.decorate_subView:ActiveDecorateUnit(data)
end

function Photo_editingView:addDecorateSticker(res)
  local data = self.photoEditorData_:AddDecorateSticker(res)
  if data then
    self.decorate_subView:AddDecorateItem(data)
  end
end

function Photo_editingView:addDecorateText(text)
  local data = self.photoEditorData_:AddDecorateText(text)
  if data then
    self.decorate_subView:AddDecorateItem(data)
  end
end

function Photo_editingView:editorDecorateText(text)
  local data = self.photoEditorData_:EditorDecorateText(text)
  if data then
    self.decorate_subView:EditorText(data)
  end
end

function Photo_editingView:changeTextFontSize(size)
  local data = self.photoEditorData_:EditorDecorateTextFontSize(size)
  if data then
    self.decorate_subView:ChangeDecorateTextFontSize(data)
  end
end

function Photo_editingView:changeTextColor(color)
  local data = self.photoEditorData_:EditorDecorateTextFontColor(color)
  if data then
    self.decorate_subView:ChangeDecorateTextFontColor(data)
  end
end

return Photo_editingView
