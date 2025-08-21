local super = require("ui.component.loop_list_view_item")
local InvestigationClueItem = class("InvestigationClueItem", super)

function InvestigationClueItem:OnInit()
  self.investigationClueVm_ = Z.VMMgr.GetVM("investigationclue")
  self.investigationMainData_ = Z.DataMgr.Get("investigationclue_data")
  self.loopCount_ = 5
end

function InvestigationClueItem:OnUnInit()
  if self.parentDepth_ ~= nil and self.uiBinder then
    self.parentDepth_:RemoveChildDepth(self.uiBinder.effect_guide)
  end
  self:hideCompleteAnim()
end

function InvestigationClueItem:OnRefresh(data)
  self.data_ = data
  self.parentDepth_ = self.parent.UIView.uiBinder.uidepth
  self.parentDepth_:AddChildDepth(self.uiBinder.effect_guide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.data_.IsUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not self.data_.IsUnlock)
  self:updateShowClueInfo()
end

function InvestigationClueItem:updateShowClueInfo()
  local stepData = self.investigationMainData_:GetCurInvestigationStepData()
  local clueData = self.investigationMainData_:GetClueData(self.data_.ClueId)
  if not clueData or not stepData then
    return
  end
  local ClueList = stepData.ClueList
  local isAllUnlock = true
  for i = 1, #ClueList do
    if not ClueList[i].IsUnlock then
      isAllUnlock = false
    end
  end
  if not isAllUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.effect_guide, false)
  end
  if self.data_.IsUnlock == false then
    self.uiBinder.lab_name_not:RemoveAllListeners()
    local showContent = Z.RichTextHelper.ApplyStyleTag(clueData.ClueLockContext, E.TextStyleTag.InvestigateLockClue)
    self.uiBinder.lab_name_not.text = showContent
    self.uiBinder.lab_name_not:SetVerticesDirty()
    local size = self.uiBinder.lab_name_not:GetPreferredValues(showContent, 608, 32)
    local height = math.max(size.y, 150)
    self.uiBinder.lab_not_ref:SetHeight(height)
    self.uiBinder.img_off:SetHeight(height + 8)
    self.uiBinder.Trans:SetHeight(height + 8)
    self.loopListView:OnItemSizeChanged(self.Index)
    return
  end
  self:hideCompleteAnim()
  local showContext = clueData.ClueContext
  local needClick = false
  local isShowCompleteAnim = false
  local animKeyContext = ""
  local animKeyId
  local linkIndex = -1
  local isHaveComplete = false
  for i = 1, #clueData.ClueAnswerList do
    local keyData = clueData.ClueAnswerList[i]
    local replace = ""
    if keyData.IsComplete == true then
      if stepData.CompleteAnswerList and table.zcontains(stepData.CompleteAnswerList, keyData.AnswerId) then
        if keyData.IsShowCompleteAnim then
          isShowCompleteAnim = true
          animKeyContext = keyData.KeyContext
          animKeyId = keyData.AnswerId
          keyData.IsShowCompleteAnim = false
        else
          local color = E.ColorHexValues.InvestigateUnlockClue
          replace = string.zconcat("<mark=", color, "87>", keyData.KeyContext, "</mark>")
        end
      else
        replace = keyData.KeyContext
      end
      isHaveComplete = true
    else
      replace = string.zconcat("<link>", keyData.KeyContext, "</link>")
      needClick = true
      if table.zcontains(Z.Global.InvestigationGuideClueId, clueData.ClueId) and keyData.TapBubble and linkIndex == -1 then
        linkIndex = i - 1
      end
    end
    if replace ~= "" then
      showContext = self:replaceShowContext(showContext, replace, keyData.AnswerId)
    end
  end
  showContext = string.zreplace(showContext, "<br>", "\n")
  self.uiBinder.lab_name_ok:RemoveAllListeners()
  if isShowCompleteAnim and animKeyContext ~= "" then
    self:showCompleteAnim(showContext, animKeyContext, animKeyId)
  else
    self.uiBinder.lab_name_ok.text = showContext
  end
  if needClick then
    self.uiBinder.lab_name_ok:AddListener(function(linkId, linkText)
      if not isAllUnlock then
        return
      end
      for i = 1, #clueData.ClueAnswerList do
        local keyData = clueData.ClueAnswerList[i]
        if linkText == keyData.KeyContext then
          if keyData.IsComplete == true then
            return
          end
          self.parent.UIView:OnSelectClueAnswer(self.data_.ClueId, keyData.AnswerId, keyData.TapBubble)
          Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvent, string.zconcat(E.SteerGuideEventType.Investigation, "=", 2))
        end
      end
    end)
  end
  if isAllUnlock then
    self:checkGuide(linkIndex, isHaveComplete)
  end
  local size = self.uiBinder.lab_name_ok:GetPreferredValues(showContext, 608, 32)
  local height = math.max(size.y, 150)
  self.uiBinder.lab_ok_ref:SetHeight(height)
  self.uiBinder.img_on:SetHeight(height + 48)
  self.uiBinder.Trans:SetHeight(height + 48)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function InvestigationClueItem:replaceShowContext(showContext, replace, keyId)
  local pattern = "<tagId=(%d)>%*([^%*]+)%*"
  if keyId then
    pattern = string.zconcat("<tagId=", keyId, ">%*([^%*]+)%*")
  end
  showContext = string.gsub(showContext, pattern, replace, 1)
  return showContext
end

function InvestigationClueItem:checkGuide(linkIndex, isHaveComplete)
  if linkIndex == -1 or isHaveComplete then
    self.uiBinder.Ref:SetVisible(self.uiBinder.effect_guide, false)
    self.showEffect_ = false
    return
  end
  self.showEffect_ = true
  Z.CoroUtil.create_coro_xpcall(function()
    Z.Delay(0.1, self.parent.UIView.cancelSource:CreateToken())
    if not self.uiBinder or not self.showEffect_ then
      return
    end
    local position = self.uiBinder.lab_name_ok:GetLinkPosition(linkIndex)
    self.uiBinder.effect_guide_ref:SetLocalPos(position.x, position.y - 20)
    self.uiBinder.Ref:SetVisible(self.uiBinder.effect_guide, true)
  end)()
end

function InvestigationClueItem:showCompleteAnim(showContext, keyContext, animKeyId)
  local color = E.ColorHexValues.InvestigateUnlockClue
  local index = 0
  self:showAnimText(index, showContext, keyContext, color, animKeyId)
  self.animKey_ = string.zconcat(E.GlobalTimerTag.Investigate, self.data_.ClueId, "Investigate", animKeyId)
  Z.GlobalTimerMgr:StartTimer(self.animKey_, function()
    index = index + 1
    self:showAnimText(index, showContext, keyContext, color, animKeyId)
  end, 0.06, self.loopCount_)
end

function InvestigationClueItem:showAnimText(index, showContext, keyContext, color, animKeyId)
  local alpha = string.format("%02X", 27 * index)
  local replace = string.zconcat("<mark=", color, alpha, ">", keyContext, "</mark>")
  self.uiBinder.lab_name_ok.text = self:replaceShowContext(showContext, replace, animKeyId)
end

function InvestigationClueItem:hideCompleteAnim()
  if self.animKey_ ~= "" and self.animKey_ ~= nil then
    Z.GlobalTimerMgr:StopTimer(self.animKey_)
    self.animKey_ = ""
  end
end

return InvestigationClueItem
