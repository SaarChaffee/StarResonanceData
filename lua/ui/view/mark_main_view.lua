local UI = Z.UI
local super = require("ui.ui_view_base")
local Mark_mainView = class("Mark_mainView", super)

function Mark_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mark_main")
  self.gmData_ = Z.DataMgr.Get("gm_data")
end

function Mark_mainView:OnActive()
  self:BindEvents()
  self:refresh()
end

function Mark_mainView:OnDeActive()
end

function Mark_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.GM.IsOpenMake, self.isOpenMake, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.OnSelectChar, self.onSelectChar, self)
end

function Mark_mainView:refresh()
  self.uiBinder.Ref:SetVisible(self.uiBinder.content, self.gmData_.IsOpenWateMark)
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPath = self.uiBinder.prefab_cache:GetString("mark_tpl")
    for i = 1, 72 do
      local item = self:AsyncLoadUiUnit(itemPath, "mark_tpl" .. i, self.uiBinder.content)
      local str = string.zconcat("ID:", self.viewData.key)
      item.lab_mark.text = str
    end
  end)()
end

function Mark_mainView:isOpenMake(isOpen)
  self.uiBinder.content:SetVisible(isOpen)
end

function Mark_mainView:onSelectChar(charId)
  local str = string.zconcat("ID:", charId)
  for i = 1, 72 do
    local item = self.units["mark_tpl" .. i]
    item.lab_mark.text = str
  end
end

return Mark_mainView
