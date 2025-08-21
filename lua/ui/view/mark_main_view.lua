local UI = Z.UI
local super = require("ui.ui_view_base")
local Mark_mainView = class("Mark_mainView", super)
local ITEM_COUNT = 72

function Mark_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mark_main")
  self.markData_ = Z.DataMgr.Get("mark_data")
  self.charId_ = nil
end

function Mark_mainView:OnActive()
  self:BindEvents()
  self:createMarkItem()
end

function Mark_mainView:OnRefresh()
  self:refreshMarkUI()
end

function Mark_mainView:OnDeActive()
  self:UnBindEvents()
end

function Mark_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.GM.IsOpenMake, self.refreshMarkUI, self)
  Z.EventMgr:Add(Z.ConstValue.LoginEvt.OnSelectChar, self.onSelectChar, self)
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.refreshMarkUI, self)
end

function Mark_mainView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.GM.IsOpenMake, self.refreshMarkUI, self)
  Z.EventMgr:Remove(Z.ConstValue.LoginEvt.OnSelectChar, self.onSelectChar, self)
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.refreshMarkUI, self)
end

function Mark_mainView:isShowWatermark()
  return Z.ScreenMark and self.markData_:GetMarkState() and self:getMarkUIKey() ~= nil
end

function Mark_mainView:isShowLabelTip()
  return Z.ScreenMark and self.markData_:GetMarkState() and Z.GameContext.IsPreviewEnvironment()
end

function Mark_mainView:refreshMarkUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.content, self:isShowWatermark())
  self.uiBinder.Ref:SetVisible(self.uiBinder.content_exegesis, self:isShowLabelTip())
  self:refreshMarkItem()
end

function Mark_mainView:createMarkItem()
  if not Z.ScreenMark then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPath = self.uiBinder.prefab_cache:GetString("mark_tpl")
    self.watermarkKey_ = self:getMarkUIKey()
    for i = 1, ITEM_COUNT do
      local item = self:AsyncLoadUiUnit(itemPath, "mark_tpl" .. i, self.uiBinder.content)
      item.lab_mark.text = self.watermarkKey_ or ""
    end
  end)()
end

function Mark_mainView:refreshMarkItem()
  if not Z.ScreenMark then
    return
  end
  self.watermarkKey_ = self:getMarkUIKey()
  for i = 1, ITEM_COUNT do
    local item = self.units["mark_tpl" .. i]
    if item then
      item.lab_mark.text = self.watermarkKey_ or ""
    end
  end
end

function Mark_mainView:getMarkUIKey()
  if not Z.ScreenMark then
    return nil
  end
  local watermarkKey
  if self.charId_ then
    watermarkKey = string.zconcat("ID:", self.charId_)
  elseif self.viewData and self.viewData.key then
    watermarkKey = string.zconcat("ID:", self.viewData.key)
  end
  return watermarkKey
end

function Mark_mainView:onSelectChar(charId)
  self.charId_ = charId
  self:refreshMarkUI()
end

return Mark_mainView
