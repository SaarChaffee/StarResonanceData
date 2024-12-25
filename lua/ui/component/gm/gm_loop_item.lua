local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loop_list_view_item")
local GmItem = class("GmItem", super)

function GmItem:ctor()
end

function GmItem:OnInit()
end

function GmItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.tex_func.text = data.ButtonShow
  self.uiBinder.Ref:SetVisible(self.uiBinder.mark, false)
end

function GmItem:OnSelected(isSelected, isClick)
  if isSelected then
    local gmData = Z.DataMgr.Get("gm_data")
    self.uiBinder.Ref:SetVisible(self.uiBinder.mark, true)
    self.uiBinder.tex_func.text = self.data_.ButtonShow
    local cmdInfo = self.data_.Command
    if self.data_.Type == gmData.CmdType.group then
      cmdInfo = self.data_.Command
    end
    Z.VMMgr.GetVM("gm").RefreshInputField(cmdInfo .. " ")
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.mark, false)
  end
end

function GmItem:OnUnInit()
end

return GmItem
