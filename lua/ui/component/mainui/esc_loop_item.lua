local super = require("ui.component.loop_list_view_item")
local EscItem = class("EscItem", super)

function EscItem:OnInit()
  self.uiBinder.btn_item:AddListener(function()
    self:onItemClick()
  end)
end

function EscItem:OnRefresh(data)
  local funcRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(data.Id)
  if funcRow and Z.IsPCUI then
    self.uiBinder.lab_normal.text = funcRow.Name
  end
  local imgPath = Z.IsPCUI and data.PCIcon or data.Icon
  self.uiBinder.img_item:SetImage(imgPath)
  self.uiBinder.comp_audio:AddAudioEvent(data.Path, 3)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.comp_steer, E.DynamicSteerType.FunctionId, data.Id)
  Z.RedPointMgr.LoadRedDotItem(data.Id, self.parent.UIView, self.uiBinder.Trans)
end

function EscItem:OnUnInit()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  Z.RedPointMgr.RemoveNodeItem(curData.Id)
end

function EscItem:onItemClick()
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  local gotoVM = Z.VMMgr.GetVM("gotofunc")
  gotoVM.GoToFunc(curData.Id)
end

return EscItem
