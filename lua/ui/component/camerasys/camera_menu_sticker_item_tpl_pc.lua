local super = require("ui.component.loop_grid_view_item")
local CameraStickerItemPcTpl = class("CameraStickerItemPcTpl", super)

function CameraStickerItemPcTpl:ctor()
  self.uiBinder = nil
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
end

function CameraStickerItemPcTpl:OnInit()
  self.parentUIView_ = self.parent.UIView
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function CameraStickerItemPcTpl:Refresh(data)
  self.data_ = data
  self:setItemImg()
end

function CameraStickerItemPcTpl:OnUnInit()
end

function CameraStickerItemPcTpl:setItemImg()
  local pathPrefix = self.parentUIView_.uiBinder.prefab_cache:GetString("iconPath")
  self.uiBinder.img_frame:SetImage(string.format("%s%s", pathPrefix, self.data_.Res))
end

function CameraStickerItemPcTpl:OnPointerClick(go, eventData)
  local valueData = {}
  valueData.value = self.data_
  valueData.type = E.CamerasysFuncType.Sticker
  valueData.viewType = self.parentUIView_.viewType_
  local num = self.parentUIView_.addViewData_:GetDecoreateNum()
  local maxNum = self.cameraData_:GetDecoreateMaxNum()
  if num >= tonumber(maxNum) then
    Z.TipsVM.ShowTipsLang(1000029)
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.CreateDecorate, valueData)
end

return CameraStickerItemPcTpl
