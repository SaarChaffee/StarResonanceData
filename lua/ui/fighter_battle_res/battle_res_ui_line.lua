local super = require("ui.fighter_battle_res.battle_res_base")
local BattleResUILine = class("BattleResUILine", super)

function BattleResUILine:ctor(view, parent, row, elemental, key)
  super:ctor(view, parent, elemental, key)
  self.lineParam_ = row.InnerRingFactor
  self.resIds_ = row.ResIDs
  if #row.InnerColor == 3 then
    self.innerColor_ = Color.New(row.InnerColor[1] / 255, row.InnerColor[2] / 255, row.InnerColor[3] / 255, 1)
  else
    self.innerColor_ = nil
  end
  self.icon_ = row.BattleResIcon
end

function BattleResUILine:RegEvent()
end

function BattleResUILine:GetUIUnitPath()
  return "ui/prefabs/controller/controller_resource_bar_tpl"
end

function BattleResUILine:ShowBattleUIRes()
  super:ShowBattleUIRes()
  self:Refresh()
end

function BattleResUILine:Refresh()
  if self.uiUnit_ == nil then
    return
  end
  if #self.resIds_ <= 0 then
    logError("battle Res Id is nil !")
    return
  end
  self:SetVisible(true)
  local resId = self.resIds_[1]
  local maxResId = self.resIds_[1] + self.RES_MAX_ID_OFFSET
  local progressNow = self.view_.vm:GetBattleResValue(resId)
  local progressMax = self.view_.vm:GetBattleResValue(maxResId)
  local inMax = progressMax * self.lineParam_
  local outMax = progressMax * (1 - self.lineParam_)
  local fillAmountOut = progressNow / outMax + 1.0E-4
  local fillAmountIn = inMax <= 0 and 0 or (progressNow - outMax) / inMax + 1.0E-4
  if self.icon_ and 1 < #self.icon_ then
    self.uiUnit_.img_icon.Img:SetImage(self.icon_)
  end
  self.uiUnit_.img_line_progress_out.Img.fillAmount = fillAmountOut
  self.uiUnit_.img_line_progress_in.Img.fillAmount = fillAmountIn
  if self.innerColor_ then
    self.uiUnit_.img_line_progress_in.Img:SetColor(self.innerColor_)
  else
    self:SetColor(self.uiUnit_.img_line_progress_in.Img)
  end
  self.uiUnit_.img_line_progress_out_single.Ref:SetVisible(false)
  self.uiUnit_.img_line_progress_out.Ref:SetVisible(false)
  self.uiUnit_.img_line_progress_in.Ref:SetVisible(false)
  if inMax <= 0 then
    self:SetColor(self.uiUnit_.img_line_progress_out_single.Img)
    self.uiUnit_.img_line_progress_out_single.Img.fillAmount = fillAmountOut
    self.uiUnit_.img_line_progress_out_single.Ref:SetVisible(true)
  else
    self:SetColor(self.uiUnit_.img_line_progress_out.Img)
    self.uiUnit_.img_line_progress_out.Img.fillAmount = fillAmountOut
    self.uiUnit_.img_line_progress_out.Ref:SetVisible(true)
  end
  self.uiUnit_.img_line_progress_in.Ref:SetVisible(true)
  if progressNow == progressMax then
    self:PlayStartEffect()
  else
    self:RemoveEffect()
  end
end

function BattleResUILine:Close()
  super:Close()
end

return BattleResUILine
