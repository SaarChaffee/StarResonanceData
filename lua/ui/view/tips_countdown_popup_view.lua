local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_countdown_popupView = class("Tips_countdown_popupView", super)

function Tips_countdown_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_countdown_popup")
  self.viewData = nil
end

function Tips_countdown_popupView:OnActive()
  self:initComp()
end

function Tips_countdown_popupView:initComp()
  self.countDownPrefab = nil
end

function Tips_countdown_popupView:OnDeActive()
  if self.timerMgr then
    self.timerMgr:Clear()
  end
end

function Tips_countdown_popupView:OnRefresh()
  if not self.viewData then
    return
  end
  self:setLabeData()
  self:startCountDown()
end

function Tips_countdown_popupView:setLabeData()
  local itemData = self.viewData
  if not itemData then
    return
  end
  local msgCfg = Z.TableMgr.GetTable("MessageTableMgr").GetRow(itemData.cfgId)
  if msgCfg == nil then
    logWarning("show notice tip error config id not found:" .. tostring(itemData.cfgId))
    return
  end
  local msg = {}
  msg.configId = itemData.configId
  local content = Z.TableMgr.DecodeLineBreak(msgCfg.Content)
  if itemData.placeholderParam then
    content = Z.Placeholder.Placeholder(content, itemData.placeholderParam)
  end
  msg.content = content
  self.uiBinder.lab_content.text = msg.content
end

function Tips_countdown_popupView:startCountDown()
  if not self.viewData then
    return
  end
  local detailTime = self.viewData.countdownTime
  if detailTime <= 0 then
    return
  end
  self.uiBinder.lab_num.text = detailTime
  self.timerMgr:Clear()
  self.timerMgr:StartTimer(function()
    detailTime = detailTime - 1
    self.uiBinder.lab_num.text = detailTime
  end, 1, detailTime, true)
end

return Tips_countdown_popupView
