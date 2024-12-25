local super = require("ui.model.data_base")
local ActionExpressionData = class("ActionExpressionData", super)

function ActionExpressionData:ctor()
  super.ctor(self)
end

function ActionExpressionData:Init()
end

function ActionExpressionData:Clear()
end

function ActionExpressionData:UnInit()
end

function ActionExpressionData:SetCurPlayRowData(emoteId)
  if emoteId < 0 then
    self.curPlayEmoteRow_ = nil
    return
  end
  local emoteTableMgr = Z.TableMgr.GetTable("EmoteTableMgr")
  self.curPlayEmoteRow_ = emoteTableMgr.GetRow(emoteId)
end

function ActionExpressionData:GetCurPlayId()
  if self.curPlayEmoteRow_ == nil then
    return -1
  end
  return self.curPlayEmoteRow_.Id
end

function ActionExpressionData:GetCurPlayType()
  if self.curPlayEmoteRow_ == nil then
    return 0
  end
  return self.curPlayEmoteRow_.Type
end

return ActionExpressionData
