local UI = Z.UI
local super = require("ui.ui_view_base")
local Common_skill_tipsView = class("Common_skill_tipsView", super)

function Common_skill_tipsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "common_skill_tips")
end

function Common_skill_tipsView:OnActive()
  self.curSkillId_ = self.viewData.skillId
  if self.viewData.pivot then
    self.uiBinder.root.pivot = self.viewData.pivot
  else
    self.uiBinder.root.pivot = Vector2.New(0.5, 0.5)
  end
  if self.viewData.position then
    self.uiBinder.root:SetAnchorPosition(self.viewData.position.x, self.viewData.position.y)
  else
    self.uiBinder.root:SetAnchorPosition(0, 0)
  end
  self.tagUnitsName_ = {}
  self.uiBinder.presscheck:StopCheck()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:DeActive()
    end
  end, nil, nil)
end

function Common_skill_tipsView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Common_skill_tipsView:OnRefresh()
  self.uiBinder.presscheck:StartCheck()
  self:refreshSkillDesc()
end

function Common_skill_tipsView:refreshSkillDesc()
  local skillId = self.curSkillId_
  local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  local content = ""
  local skillName = ""
  if config ~= nil then
    content = Z.TableMgr.DecodeLineBreak(config.Desc)
    skillName = config.Name
  end
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_info, content)
  self.uiBinder.lab_title.text = skillName
  for _, value in ipairs(self.tagUnitsName_) do
    self:RemoveUiUnit(value)
  end
  self.tagUnitsName_ = {}
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local tagIds = weaponSkillVm:GetSkillAllTag(skillId)
  local parent = self.uiBinder.group_title_rect
  local unitPath = self.uiBinder.prefab_cache:GetString("skill_tag_unit")
  Z.CoroUtil.create_coro_xpcall(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, false)
    for _, value in ipairs(tagIds) do
      local tagTab = Z.TableMgr.GetTable("BdTagTableMgr").GetRow(value)
      if tagTab then
        local name = "SkillTagUnit" .. tostring(value)
        local unit = self:AsyncLoadUiUnit(unitPath, name, parent, self.cancelSource:CreateToken())
        if unit then
          Z.RichTextHelper.AddTmpLabClick(unit.lab_title, tagTab.TagName, function()
            Z.CommonTipsVM.OpenUnderline(skillId)
          end)
        end
        table.insert(self.tagUnitsName_, name)
      end
    end
    if self.tagTimer_ then
      self.timerMgr:StopFrameTimer(self.tagTimer_)
      self.tagTimer_ = nil
    end
    self.tagTimer_ = self.timerMgr:StartFrameTimer(function()
      self.uiBinder.group_title:SetLayoutGroup()
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, true)
    end, 1, 1)
  end)()
end

return Common_skill_tipsView
