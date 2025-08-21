local super = require("ui.component.loop_list_view_item")
local DpsLoopItemPc = class("DpsLoopItemPc", super)

function DpsLoopItemPc:ctor()
  self.entityVM_ = Z.VMMgr.GetVM("entity")
  self.teamData_ = Z.DataMgr.Get("team_data")
end

function DpsLoopItemPc:OnInit()
  self.uiView_ = self.parent.UIView
end

function DpsLoopItemPc:OnReset()
end

function DpsLoopItemPc:OnRefresh(data)
  self.data_ = data
  local time = data.time
  local allHit = self.uiView_:GetAllHit() or 1
  local ratio = "0.0%"
  if self.data_.allHit ~= 0 then
    ratio = string.format("%.1f", self.data_.allHit / allHit * 100) .. "%"
  end
  local charId = self.data_.charId
  local name = ""
  local professionId = 0
  if charId == Z.ContainerMgr.CharSerialize.charId then
    name = Z.ContainerMgr.CharSerialize.charBase.name
    professionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  else
    local memberInfo = self.teamData_.TeamInfo.members[charId]
    if memberInfo then
      name = memberInfo.socialData.basicData.name .. "."
      professionId = memberInfo.socialData.professionData.professionId
    end
  end
  local dps = math.floor(self.data_.allHit / time + 0.5)
  self.uiBinder.lab_num_total.text = Z.NumTools.DpsFormatNumberOverTenThousand(self.data_.allHit)
  self.uiBinder.lab_name.text = self.Index .. "." .. name
  self.uiBinder.lab_num.text = Z.NumTools.DpsFormatNumberOverTenThousand(dps)
  self.uiBinder.lab_percent.text = ratio
  self.uiBinder.img_progress.fillAmount = self.data_.allHit / allHit
  local professionRow = Z.TableMgr.GetRow("ProfessionTableMgr", professionId)
  if professionRow then
    self.uiBinder.img_icon:SetImage(professionRow.ProfessionIcon)
    self.uiBinder.img_progress:SetColorByHex(professionRow.DpsPanelColor)
  end
end

function DpsLoopItemPc:OnPointerClick()
  self.uiView_:OnClickGroupItem(self.data_)
end

function DpsLoopItemPc:OnUnInit()
end

return DpsLoopItemPc
