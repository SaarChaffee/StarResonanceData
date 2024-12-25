local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_approachView = class("Tips_approachView", super)

function Tips_approachView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_approach")
end

function Tips_approachView:OnActive()
  self.uiBinder.Ref.UIComp:SetVisible(false)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.viewData.approachDatas then
      local path = self.uiBinder.prefab_cache:GetString("item")
      for key, approachData in pairs(self.viewData.approachDatas) do
        local unit = self:AsyncLoadUiUnit(path, key, self.uiBinder.rect_approach, self.cancelSource:CreateToken())
        if unit then
          unit.img_icon:SetImage(approachData.icon)
          unit.lab_gameplay.text = approachData.name
          self:AddAsyncClick(unit.btn_bg, function()
            local itemSourceVm = Z.VMMgr.GetVM("item_source")
            itemSourceVm.JumpToSource(approachData)
          end)
        end
      end
    end
    self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
    self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
    self.uiBinder.Ref.UIComp:SetVisible(true)
  end)()
end

function Tips_approachView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

function Tips_approachView:OnRefresh()
end

return Tips_approachView
