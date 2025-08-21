local super = require("ui.component.loop_list_view_item")
local EscBannerItem = class("EscBannerItem", super)
local FUNC_PREVIEW_BG = "ui/textures/large_ui/mainui/main_rank_condition"
local FUNC_PREVIEW_BG_PC = "ui/textures/large_ui/mainui/main_rank_condition_pc"

function EscBannerItem:OnInit()
end

function EscBannerItem:OnRefresh(data)
  if data.type == E.MenuBannerType.FuncPreview then
    local config = data.config
    self.uiBinder.rimg_bottom:SetImage(Z.IsPCUI and FUNC_PREVIEW_BG_PC or FUNC_PREVIEW_BG)
    self.uiBinder.img_icon:SetImage(config.Icon)
    self.uiBinder.lab_title.text = Lang("FunctionPreview")
    self.uiBinder.lab_name.text = config.Name
  elseif data.type == E.MenuBannerType.Theme then
    local config = data.config
    local funcConfig = Z.TableMgr.GetRow("FunctionTableMgr", config.FunctionId)
    if funcConfig == nil then
      return
    end
    self.uiBinder.rimg_bottom:SetImage(Z.IsPCUI and config.EscBannerPic or config.EscBannerPicM)
    self.uiBinder.img_icon:SetImage(funcConfig.Icon)
    self.uiBinder.lab_title.text = Lang("ThemeActivity")
    self.uiBinder.lab_name.text = config.Name
  end
end

function EscBannerItem:OnUnInit()
end

function EscBannerItem:OnPointerClick()
  local data = self:GetCurData()
  if data == nil then
    return
  end
  if data.type == E.MenuBannerType.FuncPreview then
    local funcPreviewVM = Z.VMMgr.GetVM("function_preview")
    funcPreviewVM.OpenFuncPreviewWindow()
  elseif data.type == E.MenuBannerType.Theme then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.ThemePlay, data.config.Id)
  end
end

return EscBannerItem
