local super = require("ui.component.loop_grid_view_item")
local FuncIconLoopNewItem = class("FuncIconLoopNewItem", super)

function FuncIconLoopNewItem:OnInit()
  self.uiBinder.btn:AddListener(function()
    self:onItemClick()
  end)
  Z.EventMgr:Add(Z.ConstValue.ShowMainFeatureUnLockEffect, self.onShowUnLockEffect, self)
end

function FuncIconLoopNewItem:OnRefresh(data)
  self.funcId_ = data
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.mainicon_btn_tpl, E.DynamicSteerType.FunctionId, self.funcId_)
  Z.RedPointMgr.LoadRedDotItem(self.funcId_, self.parent.UIView, self.uiBinder.Trans)
  self.uiBinder.Go.name = "item_" .. self.funcId_
  local iconRow = Z.TableMgr.GetTable("MainIconTableMgr").GetRow(self.funcId_)
  if iconRow then
    self.uiBinder.img_icon:SetImage(iconRow.Icon)
  end
  local funcRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(self.funcId_)
  if funcRow then
    self.uiBinder.lab_content.text = funcRow.Name
  end
  self.uiBinder.btn_audio:AddAudioEvent(iconRow.Path, 3)
end

function FuncIconLoopNewItem:OnUnInit()
  Z.RedPointMgr.RemoveNodeItem(self.funcId_)
  Z.EventMgr:RemoveObjAllByEvent(Z.ConstValue.ShowMainFeatureUnLockEffect, self)
end

function FuncIconLoopNewItem:onItemClick()
  local gotoVM = Z.VMMgr.GetVM("gotofunc")
  gotoVM.GoToFunc(self.funcId_)
end

function FuncIconLoopNewItem:onShowUnLockEffect(id)
  if id == self.funcId_ then
    self.uiBinder.effect:SetEffectGoVisible(true)
  end
end

return FuncIconLoopNewItem
