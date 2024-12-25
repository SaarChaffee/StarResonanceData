local UI = Z.UI
local super = require("ui.ui_view_base")
local Rolelevel_way_windowView = class("Rolelevel_way_windowView", super)
local rolelevelWaytplPath = "ui/prefabs/rolelevel/rolelevel_way_tpl"

function Rolelevel_way_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "rolelevel_way_window")
  self.quickJumpVm_ = Z.VMMgr.GetVM("quick_jump")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Rolelevel_way_windowView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:onStartAnimShow()
  self.dataCfg_ = self.viewData.nextLvCfg
  self:AddClick(self.uiBinder.btn_close_new, function()
    Z.UIMgr:CloseView("rolelevel_way_window")
  end)
end

function Rolelevel_way_windowView:OnDeActive()
end

function Rolelevel_way_windowView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Rolelevel_way_windowView:OnRefresh()
  if self.dataCfg_ and next(self.dataCfg_.ExpAccess) then
    Z.CoroUtil.create_coro_xpcall(function()
      for i = 1, #self.dataCfg_.ExpAccess do
        local funcBtn = self:AsyncLoadUiUnit(rolelevelWaytplPath, self.dataCfg_.ExpAccess[i], self.uiBinder.layout_btn)
        local funcRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(self.dataCfg_.ExpAccess[i])
        funcBtn.img_icon:SetImage(funcRow.Icon)
        funcBtn.btn:RemoveAllListeners()
        funcBtn.lab_content.text = funcRow.Name
        local isUnLock_ = self.gotoFuncVM_.CheckFuncCanUse(self.dataCfg_.ExpAccess[i], true)
        funcBtn.Ref:SetVisible(funcBtn.img_lock, not isUnLock_)
        self:AddClick(funcBtn.btn, function()
          if self.gotoFuncVM_.CheckFuncCanUse(self.dataCfg_.ExpAccess[i]) then
            local jumpParam_ = {}
            jumpParam_[1] = self.dataCfg_.ExpAccess[i]
            jumpParam_[2] = nil
            self.quickJumpVm_.DoJumpByConfigParam(E.QuickJumpType.Function, jumpParam_)
          end
          self:DeActive()
        end)
      end
    end)()
  end
end

return Rolelevel_way_windowView
