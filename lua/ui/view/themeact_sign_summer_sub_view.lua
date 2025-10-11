local UI = Z.UI
local super = require("ui.view.themeact_sign_common_sub_view")
local Themeact_sign_summer_subView = class("Themeact_sign_summer_subView", super)
local TITLE_RIMG_PATH = "ui/textures/themeact/themeact_lab/themeact_title_02"

function Themeact_sign_summer_subView:ctor(parent)
  self.uiBinder = nil
  self.parent_ = parent
  super.ctor(self, parent, "themeact_sign_summer_sub", "themeact/themeact_sign_summer_sub")
end

function Themeact_sign_summer_subView:GetSignType()
  return E.SignActivityType.ThemeActivity2
end

function Themeact_sign_summer_subView:setRawImage()
  self.uiBinder.rimg_title:SetImage(TITLE_RIMG_PATH)
end

return Themeact_sign_summer_subView
