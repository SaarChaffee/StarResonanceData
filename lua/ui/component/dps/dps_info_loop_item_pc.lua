local super = require("ui.component.loop_list_view_item")
local DpsInfoLoopItemPc = class("DpsInfoLoopItemPc", super)

function DpsInfoLoopItemPc:OnInit()
  self.uiView_ = self.parent.UIView
end

function DpsInfoLoopItemPc:OnReset()
end

function DpsInfoLoopItemPc:OnRefresh(data)
  local skillId = tonumber(data.damageId)
  local recountRow = Z.TableMgr.GetTable("RecountTableMgr").GetRow(skillId)
  if recountRow then
    self.uiBinder.lab_name.text = self.Index .. "." .. recountRow.RecountName
  else
    self.uiBinder.lab_name.text = self.Index .. "." .. data.damageId
  end
  local ratio = "0.0%"
  local allHit = self.uiView_:GetCutSelectedItemAllHit()
  if data.hit ~= 0 then
    ratio = string.format("%.1f", data.hit / allHit * 100) .. "%"
  end
  self.uiBinder.lab_num.text = Z.NumTools.DpsFormatNumberOverTenThousand(data.hit)
  self.uiBinder.lab_percent.text = ratio
  self.uiBinder.img_title.fillAmount = math.floor(allHit / data.hit)
end

function DpsInfoLoopItemPc:OnUnInit()
end

return DpsInfoLoopItemPc
