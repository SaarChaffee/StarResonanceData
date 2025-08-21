local UI = Z.UI
local super = require("ui.ui_subview_base")
local Tips_underline_popupView = class("Tips_underline_popupView", super)

function Tips_underline_popupView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "tips_underline_popup", "tips/tips_underline_popup", UI.ECacheLv.None)
end

function Tips_underline_popupView:OnActive()
  self.togList_ = {}
  self:initFunc()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncInitSkillTags()
  end)()
end

function Tips_underline_popupView:OnDeActive()
  for i = 1, #self.togList_ do
    self.togList_[i].group = nil
    self.togList_[i]:RemoveAllListeners()
  end
  self.togList_ = nil
end

function Tips_underline_popupView:OnRefresh()
end

function Tips_underline_popupView:initFunc()
  self:EventAddAsyncListener(self.uiBinder.group_press_check.ContainGoEvent, function(isContain)
    if not isContain then
      self.uiBinder.group_press_check:StopCheck()
      Z.EventMgr:Dispatch(Z.ConstValue.UnderLineTipsClose)
      Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
    end
  end, nil, nil)
  self.uiBinder.group_press_check:StartCheck()
end

function Tips_underline_popupView:asyncInitSkillTags()
  local skillId = self.viewData.configId
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local tagTableList = weaponSkillVm:GetSkillAllTagTableList(skillId)
  local tagsGroupPath = self.uiBinder.prefab_cache:GetString("tagsGroup")
  if tagsGroupPath ~= nil and tagsGroupPath ~= "" then
    for index, tableList in ipairs(tagTableList) do
      self:asyncInitSkillTagsGroup(tagsGroupPath, index, tableList)
    end
  end
end

function Tips_underline_popupView:asyncInitSkillTagsGroup(tagsGroupPath, index, tableList)
  local node = self:AsyncLoadUiUnit(tagsGroupPath, "tagsGroup" .. index, self.uiBinder.layout_content, self.cancelSource:CreateToken())
  if node then
    local tagTogPath = self.uiBinder.prefab_cache:GetString("tagTog")
    if tagTogPath ~= nil and tagTogPath ~= "" then
      self:asyncInitSkillTagsTog(tagTogPath, node, index, tableList)
    end
  end
end

function Tips_underline_popupView:asyncInitSkillTagsTog(tagTogPath, parent, index, tableList)
  local firstTog
  for i = 1, #tableList do
    local tagNode = self:AsyncLoadUiUnit(tagTogPath, "tagTogPath" .. index .. i, parent.toggs_trans, self.cancelSource:CreateToken())
    if tagNode then
      tagNode.lab_on_title.text = tableList[i].TagName
      tagNode.lab_off_title.text = tableList[i].TagName
      tagNode.tips_tog_underline_tpl.group = parent.toggs
      tagNode.tips_tog_underline_tpl:AddListener(function(isOn)
        if isOn then
          parent.lab_info.text = tableList[i].TagString
        end
      end)
      firstTog = firstTog or tagNode.tips_tog_underline_tpl
      tagNode.Ref:SetVisible(tagNode.node_arrow, 1 < i)
      table.insert(self.togList_, tagNode.tips_tog_underline_tpl)
    end
  end
  firstTog.isOn = true
end

return Tips_underline_popupView
