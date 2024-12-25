local UI = Z.UI
local super = require("ui.ui_view_base")
local Team_custom_text_popupView = class("Team_custom_text_popupView", super)

function Team_custom_text_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_custom_text_popup")
  self.vm_ = Z.VMMgr.GetVM("team_target")
end

function Team_custom_text_popupView:initBinder()
  self.scenemask_ = self.uiBinder.scenemask
  self.btn_cancel_ = self.uiBinder.btn_cancel
  self.btn_affirm_ = self.uiBinder.btn_affirm
  self.input_ = self.uiBinder.input_content
  self.lab_num_ = self.uiBinder.lab_num
  self.lab_title_ = self.uiBinder.lab_title
end

function Team_custom_text_popupView:OnActive()
  self:initBinder()
  self.myUuid_ = Z.EntityMgr.PlayerUuid
  self.scenemask_:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.btn_cancel_, function()
    self.vm_.CloseCustomTextView()
  end)
  self.lab_title_.text = Lang("AddText")
  self.inputDesMaxCount_ = Z.Global.TeamInputDescMax
  self:AddClick(self.input_, function(str)
    local len = string.zlen(str)
    if len <= self.inputDesMaxCount_ then
      self.targetDes_ = str
    else
      self.input_.text = self.targetDes_
      len = string.zlen(self.targetDes_)
    end
    self:setDesLen(len)
  end)
  self:setDesc(self.viewData.lab, self.viewData.labText, self.viewData.key)
end

function Team_custom_text_popupView:setDesc(lab, desc, key)
  self.input_.text = desc
  self:setDesLen(string.zlen(desc))
  self:AddAsyncClick(self.btn_affirm_, function()
    local vm = Z.VMMgr.GetVM("screenword")
    vm.CheckScreenWord(self.input_.text, E.TextCheckSceneType.TextCheckTeamTargetInfo, self.cancelSource:CreateToken(), function()
      Z.LocalUserDataMgr.SetString(key, self.input_.text)
      lab.text = self.input_.text
      self.vm_.CloseCustomTextView()
    end)
  end)
end

function Team_custom_text_popupView:setDesLen(len)
  local paramExp = {
    value1 = len,
    value2 = self.inputDesMaxCount_
  }
  self.lab_num_.text = Lang("degreeExpValue", paramExp)
end

function Team_custom_text_popupView:OnDeActive()
end

function Team_custom_text_popupView:OnRefresh()
end

return Team_custom_text_popupView
