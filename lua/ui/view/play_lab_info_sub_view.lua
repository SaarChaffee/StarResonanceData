local UI = Z.UI
local super = require("ui.ui_subview_base")
local Play_lab_info_subView = class("Play_lab_info_subView", super)

function Play_lab_info_subView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "play_lab_info_sub", "recommendedplay/play_lab_info_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "play_lab_info_sub", "recommendedplay/play_lab_info_sub", UI.ECacheLv.None)
  end
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
end

function Play_lab_info_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.tog_care:AddListener(function(isOn)
    self.recommendedPlayData_:SaveLocalSave(self.viewData, isOn)
  end)
  local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(self.viewData)
  if config then
    self.uiBinder.lab_title.text = config.Name
    self.uiBinder.lab_info.text = config.OtherDes .. "\n" .. config.ActDes
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_care, config.OpenTimerId and config.OpenTimerId ~= 0)
    local isOn = self.recommendedPlayData_:GetLocalSave(self.viewData)
    self.uiBinder.tog_care:SetIsOnWithoutNotify(isOn)
  end
end

function Play_lab_info_subView:OnDeActive()
end

function Play_lab_info_subView:OnRefresh()
end

return Play_lab_info_subView
