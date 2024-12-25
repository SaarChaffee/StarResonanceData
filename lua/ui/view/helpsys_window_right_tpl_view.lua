local UI = Z.UI
local super = require("ui.ui_subview_base")
local Helpsys_window_right_tplView = class("Helpsys_window_right_tplView", super)

function Helpsys_window_right_tplView:ctor(parent)
  self.uiBinder = nil
  local path = ""
  if Z.IsPCUI then
    path = "helpsys/helpsys_window_sub_pc"
  else
    path = "helpsys/helpsys_window_sub"
  end
  super.ctor(self, "helpsys_window_sub", path, UI.ECacheLv.None)
  self.parentView_ = parent
  self.helpSysVm_ = Z.VMMgr.GetVM("helpsys")
  self.dataList_ = {}
end

function Helpsys_window_right_tplView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.uiBinder.group_video:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, false)
  end, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, true)
  end)
  self:AddAsyncClick(self.uiBinder.btn_play, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, false)
    self.uiBinder.group_video:PlayCurrent(true)
  end)
  self.subTipsIdList_ = {}
end

function Helpsys_window_right_tplView:OnDeActive()
  Z.CommonTipsVM.CloseRichText()
  for _, tipsId in pairs(self.subTipsIdList_) do
    Z.TipsVM.CloseItemTipsView(tipsId)
  end
  self.subTipsIdList_ = {}
end

function Helpsys_window_right_tplView:OnRefresh()
  local content = self.viewData.Content
  local res = self.viewData.Res
  self.dataList_ = {}
  for i = 1, #content do
    local item = {}
    item.content = content[i]
    item.res = res[i]
    table.insert(self.dataList_, item)
  end
  self:SelectShow(1)
end

function Helpsys_window_right_tplView:SelectShow(index)
  if index < 1 or index > #self.dataList_ then
    return
  end
  local data = self.dataList_[index]
  local commonVM = Z.VMMgr.GetVM("common")
  local desc = Z.TableMgr.DecodeLineBreak(data.content)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_content, desc)
  if data.res == "" or data.res == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_rimg.Ref, false)
  elseif string.find(data.res, "video") then
    self:playVideo(data.res)
  else
    self:showImage(data.res)
  end
  self.uiBinder.scrollview_lab.verticalNormalizedPosition = 1
end

function Helpsys_window_right_tplView:playVideo(path)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_rimg.Ref, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, false)
  self.uiBinder.group_video:Prepare("helpsys/" .. path .. ".mp4", false, true)
end

function Helpsys_window_right_tplView:showImage(path)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_video, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_rimg.Ref, true)
  self.uiBinder.group_rimg.rimg:SetImage("ui/textures/helpsys/" .. path)
end

return Helpsys_window_right_tplView
