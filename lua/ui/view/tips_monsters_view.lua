local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_monstersView = class("Tips_monstersView", super)

function Tips_monstersView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_monsters")
end

function Tips_monstersView:OnActive()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContainer)
    if not isContainer then
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end, nil, nil)
  self.uiBinder.presscheck:StartCheck()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.viewData.monsterDataArray then
      local path = self.uiBinder.prefab_cache:GetString("monster")
      for key, monsterData in ipairs(self.viewData.monsterDataArray) do
        local unit = self:AsyncLoadUiUnit(path, key, self.uiBinder.rect_monster, self.cancelSource:CreateToken())
        if unit then
          if monsterData.monsterImgPath then
            unit.img_monster:SetImage(monsterData.monsterImgPath)
          end
          if monsterData.monsterName then
            unit.lab_monster_name.text = monsterData.monsterName
          end
          if monsterData.monsterGs then
            unit.lab_monster_gs.text = monsterData.monsterGs
          end
        end
      end
    end
  end)()
  self.uiBinder.presscheck_AdaptPos:UpdatePosition(self.viewData.rect, true, false, false, self.viewData.isRightFirst)
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function Tips_monstersView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

function Tips_monstersView:OnRefresh()
end

return Tips_monstersView
