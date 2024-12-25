local BattleResUIBase = class("BattleResUIBase")

function BattleResUIBase:ctor(view, parent, elemental, key)
  self.isShowed = false
  self.view_ = view
  self.parent_ = parent
  self.cancelSource_ = self.view_.cancelSource
  self.key_ = key
  self.uiUnit_ = nil
  self.RES_MAX_ID_OFFSET = 6
  self.isVisible_ = true
  self.elemental_ = elemental
  self.isPlayingEffect_ = false
end

function BattleResUIBase:RegEvent()
end

function BattleResUIBase:GetUIUnitPath()
  return ""
end

function BattleResUIBase:Create()
  Z.CoroUtil.create_coro_xpcall(function()
    local cancelSource = self.cancelSource_:CreateToken()
    if not self.uiUnit_ then
      self.uiUnit_ = self.view_:AsyncLoadUiUnit(self:GetUIUnitPath(), self.key_, self.parent_.Trans)
      if Z.CancelSource.IsCanceled(cancelSource) or not self.uiUnit_ then
        return
      end
    end
    if self.uiUnit_ ~= nil then
      self:SetVisible(false)
      self.uiUnit_.img_line_progress_out.Ref:SetVisible(false)
      self.uiUnit_.img_line_progress_out_single.Ref:SetVisible(false)
      self.uiUnit_.img_line_progress_in.Ref:SetVisible(false)
      self.uiUnit_.img_split_progress_bg.Ref:SetVisible(false)
      self.uiUnit_.img_split_progress.Ref:SetVisible(false)
      self:ShowBattleUIRes()
    end
  end)()
end

function BattleResUIBase:SetVisible(flag)
  self.isVisible_ = flag
  if self.uiUnit_ ~= nil then
    local alpha = flag and 1 or 0
    self.uiUnit_.Ref.CanvasGroup.alpha = alpha
    self.uiUnit_.Ref.CanvasGroup.blocksRaycasts = false
    self.uiUnit_.Ref.CanvasGroup.interactable = false
  end
end

function BattleResUIBase:ShowBattleUIRes()
  self.isShowed = true
end

function BattleResUIBase:Refresh()
end

function BattleResUIBase:PlayStartEffect()
  if self.isPlayingEffect_ then
    return
  end
  local effectName
  local formatStr = "ui/uieffect/prefab/ui_sfx_skillprompt_001/"
  if self.elemental_ == 1 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_huo_start"
  elseif self.elemental_ == 2 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_bing_start"
  elseif self.elemental_ == 3 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_lei_start"
  elseif self.elemental_ == 4 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_seng_start"
  elseif self.elemental_ == 5 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_feng_start"
  elseif self.elemental_ == 6 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_yan_start"
  elseif self.elemental_ == 7 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_guang_start"
  elseif self.elemental_ == 8 then
    effectName = formatStr .. "ui_sfx_group_skillprompt_031_an_start"
  end
  if effectName then
    self.isPlayingEffect_ = true
    self.uiUnit_.effect_point.ZEff:CreatEFFGO(effectName, Vector3.zero, true)
  end
end

function BattleResUIBase:RemoveEffect()
  self.isPlayingEffect_ = false
  self.uiUnit_.effect_point.ZEff:ReleseEffGo()
end

function BattleResUIBase:SetColor(img)
  local color
  if self.elemental_ == 1 then
    color = Color.New(1, 0.5058823529411764, 0, 1)
  elseif self.elemental_ == 2 then
    color = Color.New(0.5764705882352941, 0.9333333333333333, 0.8784313725490196, 1)
  elseif self.elemental_ == 3 then
    color = Color.New(0.6470588235294118, 0.5019607843137255, 0.9294117647058824, 1)
  elseif self.elemental_ == 4 then
    color = Color.New(0.7764705882352941, 0.9215686274509803, 0.07450980392156863, 1)
  elseif self.elemental_ == 5 then
    color = Color.New(0.08235294117647059, 0.8784313725490196, 0.9372549019607843, 1)
  elseif self.elemental_ == 6 then
    color = Color.New(0.9137254901960784, 0.7254901960784313, 0.058823529411764705, 1)
  elseif self.elemental_ == 7 then
    color = Color.New(0.7764705882352941, 0.9215686274509803, 0.07450980392156863, 1)
  elseif self.elemental_ == 8 then
    color = Color.New(0.6470588235294118, 0.5019607843137255, 0.9294117647058824, 1)
  end
  if color ~= nil then
    img:SetColor(color)
  end
end

function BattleResUIBase:Close()
  self.isShowed = false
  self.view_:RemoveUiUnit(self.key_)
end

return BattleResUIBase
