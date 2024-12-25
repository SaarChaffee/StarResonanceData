local super = require("ui.fighter_battle_res.battle_res_base")
local DotShowData = {
  [3] = {
    progressFactor = {
      0,
      0.33,
      0.656,
      1
    },
    progress = "ui/atlas/skill/skill_bar/skill_bar_3",
    bg = "ui/atlas/skill/skill_bar/skill_bar_3"
  },
  [4] = {
    progressFactor = {
      0,
      0.25,
      0.5,
      0.75,
      1
    },
    progress = "ui/atlas/skill/skill_bar/skill_bar_4",
    bg = "ui/atlas/skill/skill_bar/skill_bar_4"
  },
  [5] = {
    progressFactor = {
      0,
      0.194,
      0.409,
      0.606,
      0.798,
      1
    },
    progress = "ui/atlas/skill/skill_bar/skill_bar_5",
    bg = "ui/atlas/skill/skill_bar/skill_bar_5"
  }
}
local BattleResUIDot = class("BattleResUIDot", super)

function BattleResUIDot:ctor(view, parent, row, elemental, key)
  super:ctor(view, parent, elemental, key)
  self.resIds_ = row.ResIDs
  self.icon_ = row.BattleResIcon
end

function BattleResUIDot:RegEvent()
end

function BattleResUIDot:GetUIUnitPath()
  return "ui/prefabs/controller/controller_resource_bar_tpl"
end

function BattleResUIDot:ShowBattleUIRes()
  super:ShowBattleUIRes()
  self:Refresh()
end

function BattleResUIDot:Refresh()
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
  if 5 < progressMax then
    progressMax = 5
  end
  if progressMax < 3 then
    progressMax = 3
  end
  local curShData = DotShowData[progressMax]
  local fillAmountIdx = progressNow > progressMax and progressMax or progressNow
  local fillAmount = curShData.progressFactor[fillAmountIdx + 1]
  self.uiUnit_.img_split_progress.Img.fillAmount = fillAmount
  self.uiUnit_.img_split_progress.Img:SetImage(curShData.progress)
  self.uiUnit_.img_split_progress_bg.Img:SetImage(curShData.bg)
  self:SetColor(self.uiUnit_.img_split_progress.Img)
  if self.icon_ and 1 < #self.icon_ then
    self.uiUnit_.img_icon.Img:SetImage(self.icon_)
  end
  self.uiUnit_.img_split_progress.Ref:SetVisible(true)
  if progressNow == progressMax then
    self:PlayStartEffect()
  else
    self:RemoveEffect()
  end
end

function BattleResUIDot:Close()
  super:Close()
end

return BattleResUIDot
