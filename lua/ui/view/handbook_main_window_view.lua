local UI = Z.UI
local super = require("ui.ui_view_base")
local Handbook_main_windowView = class("Handbook_main_windowView", super)
local functionRawImage = "ui/textures/handbook_item/%s"
local functionGreyRawImage = "ui/textures/handbook_item/%s_grey"
local rimg_title = "ui/textures/handbook_item/handbook_img_lab"

function Handbook_main_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "handbook_main_window")
  self.functionIds_ = {
    [1] = E.FunctionID.HandbookDictionary,
    [2] = E.FunctionID.HandbookRead,
    [3] = E.FunctionID.QuestBook,
    [4] = E.FunctionID.HandbookCharater,
    [5] = E.FunctionID.HandbookPostCard,
    [6] = E.FunctionID.HandbookMonthCard,
    [7] = E.FunctionID.ExploreMonster
  }
  self.redDot_ = {
    [E.FunctionID.ExploreMonster] = true
  }
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Handbook_main_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.rimg_lab:SetImage(rimg_title)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.addRedFunctions_ = {}
  local functionMgr = Z.TableMgr.GetTable("FunctionTableMgr")
  for _, functoinId in ipairs(self.functionIds_) do
    local uibinder = self.uiBinder[tostring(functoinId)]
    if uibinder then
      local isFunctionUnlock = self.gotoFuncVM_.CheckFuncCanUse(functoinId, true)
      if isFunctionUnlock then
        uibinder.rimg_icon:SetImage(string.format(functionRawImage, functoinId))
        uibinder.Ref:SetVisible(uibinder.img_clock, false)
      else
        uibinder.rimg_icon:SetImage(string.format(functionGreyRawImage, functoinId))
        uibinder.Ref:SetVisible(uibinder.img_clock, true)
      end
      local config = functionMgr.GetRow(functoinId)
      if config then
        uibinder.lab_name.text = config.Name
      end
      uibinder.btn:AddListener(function()
        self.gotoFuncVM_.GoToFunc(functoinId)
      end)
      if self.redDot_[functoinId] then
        Z.RedPointMgr.LoadRedDotItem(self.redDot_[functoinId], self, uibinder.Trans)
        self.addRedFunctions_[self.redDot_[functoinId]] = self.redDot_[functoinId]
      end
    end
  end
end

function Handbook_main_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  for _, red in pairs(self.redDot_) do
    Z.RedPointMgr.RemoveNodeItem(red)
  end
end

function Handbook_main_windowView:OnRefresh()
end

function Handbook_main_windowView:OnDestory()
end

return Handbook_main_windowView
