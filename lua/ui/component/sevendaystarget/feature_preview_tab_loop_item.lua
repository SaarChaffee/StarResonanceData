local super = require("ui.component.loop_list_view_item")
local sevendaysRed = require("rednode.sevendays_target_red")
local FeaturePreviewTabLoopItem = class("FeaturePreviewTabLoopItem", super)

function FeaturePreviewTabLoopItem:ctor()
  self.switchVm = Z.VMMgr.GetVM("switch")
  self.lastFuncId_ = nil
  self.vm = Z.VMMgr.GetVM("function_preview")
end

function FeaturePreviewTabLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function FeaturePreviewTabLoopItem:OnRefresh(data)
  self.data = data
  self.uiBinder.lab_name_off.text = data.Name
  self.uiBinder.lab_name_on.text = data.Name
  self.uiBinder.img_adorn_off:SetImage(data.Icon)
  self.uiBinder.img_adorn_on:SetImage(data.Icon)
  local reasonStr = ""
  local state = self.vm.GetAwardState(data.Id)
  if state == E.FuncPreviewAwardState.CantGet then
    local reason = self.switchVm.GetLockedReason(data, false)
    if reason and reason[1] then
      reasonStr = Lang("Function" .. reason[1].error, reason[1].params)
    end
  elseif state == E.FuncPreviewAwardState.CanGet then
    reasonStr = Lang("SevendaysStargetCanGet")
  elseif state == E.FuncPreviewAwardState.Complete then
    reasonStr = Lang("HaveOpen")
  end
  self.uiBinder.canvasgroup.alpha = state == E.FuncPreviewAwardState.Complete and 0.5 or 1
  self.uiBinder.lab_grade_off.text = reasonStr
  self.uiBinder.lab_grade_on.text = reasonStr
  sevendaysRed.LoadFuncPreviewRedItem(data.Id, self.parentUIView, self.uiBinder.node_dot)
  self:SelectState()
end

function FeaturePreviewTabLoopItem:OnUnInit()
  sevendaysRed.RemoveFuncPreviewRedItem(self.data.Id, self.parentUIView)
end

function FeaturePreviewTabLoopItem:OnRecycle()
  sevendaysRed.RemoveFuncPreviewRedItem(self.data.Id, self.parentUIView)
end

function FeaturePreviewTabLoopItem:Selected(isSelected, isClick)
  if isSelected then
    self.parentUIView:OnClickTab(self:GetCurData(), isClick)
  end
  self:SelectState()
end

function FeaturePreviewTabLoopItem:SelectState()
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isSelected)
  if isSelected then
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  else
    self.uiBinder.anim:Rewind(Z.DOTweenAnimType.Open)
  end
end

function FeaturePreviewTabLoopItem:OnSelected(isSelected, isClick)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected, isClick)
end

return FeaturePreviewTabLoopItem
