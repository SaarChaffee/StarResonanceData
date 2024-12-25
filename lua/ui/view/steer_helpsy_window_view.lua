local UI = Z.UI
local super = require("ui.ui_view_base")
local Steer_helpsy_windowView = class("Steer_helpsy_windowView", super)

function Steer_helpsy_windowView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.steer_helpsy_window.PrefabPath = "steer/steer_helpsy_window_pc"
  else
    Z.UIConfig.steer_helpsy_window.PrefabPath = "steer/steer_helpsy_window"
  end
  super.ctor(self, "steer_helpsy_window")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
end

function Steer_helpsy_windowView:initUIBinders()
  self.group_video = self.uiBinder.group_video
  self.btn_play = self.uiBinder.btn_play
  self.node_btn_close = self.uiBinder.node_btn_close
  self.btn_arrow_right = self.uiBinder.btn_arrow_right
  self.btn_arrow_left = self.uiBinder.btn_arrow_left
  self.lab_title = self.uiBinder.lab_title
  self.lab_content = self.uiBinder.lab_content
  self.group_rimg = self.uiBinder.group_rimg
  self.scrollview_lab = self.uiBinder.scrollview_lab
  self.scenemask = self.uiBinder.scenemask
  self.dotParent_ = self.uiBinder.node_pages
  self.prefabCache_ = self.uiBinder.prefab_cache
end

function Steer_helpsy_windowView:OnActive()
  self:initUIBinders()
  self.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.dataList_ = {}
  self.dotUnits_ = {}
  self.group_video:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.btn_play, false)
  end, function()
    self.uiBinder.Ref:SetVisible(self.btn_play, true)
  end)
  self:AddClick(self.node_btn_close.btn, function()
    self.helpsysVM_.CloseSteerHelpsyView()
  end)
  self:AddAsyncClick(self.btn_play, function()
    self.uiBinder.Ref:SetVisible(self.btn_play, false)
    self.group_video:PlayCurrent(true)
  end)
  self:AddClick(self.btn_arrow_right, function()
    self:setDotTplState(self.selectIndex_, false)
    self:SelectShow(self.selectIndex_ + 1)
  end)
  self:AddClick(self.btn_arrow_left, function()
    self:setDotTplState(self.selectIndex_, false)
    self:SelectShow(self.selectIndex_ - 1)
  end)
end

function Steer_helpsy_windowView:loadDotTpl()
  local dotPath = self.prefabCache_:GetString("dot_tpl")
  if dotPath and dotPath ~= "" then
    Z.CoroUtil.create_coro_xpcall(function()
      for index, value in ipairs(self.dataList_) do
        local unit = self:AsyncLoadUiUnit(dotPath, "dot_tpl" .. index, self.dotParent_.transform)
        if unit then
          self.dotUnits_[index] = unit
          self:setDotTplState(index, false)
        end
      end
      self:setDotTplState(self.selectIndex_, true)
    end)()
  end
end

function Steer_helpsy_windowView:setDotTplState(index, isSelected)
  local unit = self.dotUnits_[index]
  if unit then
    unit.Ref:SetVisible(unit.img_dot_on, isSelected)
    unit.Ref:SetVisible(unit.img_dot_off, not isSelected)
  end
end

function Steer_helpsy_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
end

function Steer_helpsy_windowView:OnRefresh()
  self.lab_title.text = Z.TableMgr.DecodeLineBreak(self.viewData.Title)
  local content = self.viewData.Content
  local res = self.viewData.Res
  self.dataList_ = {}
  for i = 1, #content do
    local item = {}
    item.content = content[i]
    item.res = res[i]
    table.insert(self.dataList_, item)
  end
  self:loadDotTpl()
  self.uiBinder.Ref:SetVisible(self.btn_arrow_left, false)
  self.uiBinder.Ref:SetVisible(self.btn_arrow_right, false)
  self:SelectShow(1)
end

function Steer_helpsy_windowView:SelectShow(index)
  if index < 1 or index > #self.dataList_ then
    return
  end
  self:setDotTplState(index, true)
  if 1 < #self.dataList_ then
    self.uiBinder.Ref:SetVisible(self.btn_arrow_left, index ~= 1)
    self.uiBinder.Ref:SetVisible(self.btn_arrow_right, #self.dataList_ ~= index)
  end
  self.selectIndex_ = index
  local data = self.dataList_[index]
  self.lab_content.text = Z.TableMgr.DecodeLineBreak(data.content)
  if data.res == "" or data.res == nil then
    self.uiBinder.Ref:SetVisible(self.group_video, false)
    self.uiBinder.Ref:SetVisible(self.group_rimg, false)
  elseif string.find(data.res, "video") then
    self:playVideo(data.res)
  else
    self:showImage(data.res)
  end
  self.scrollview_lab.verticalNormalizedPosition = 1
end

function Steer_helpsy_windowView:playVideo(path)
  self.uiBinder.Ref:SetVisible(self.btn_play, false)
  self.uiBinder.Ref:SetVisible(self.group_rimg, false)
  self.uiBinder.Ref:SetVisible(self.group_video, true)
  self.group_video:Prepare("helpsys/" .. path .. ".mp4", false, true)
end

function Steer_helpsy_windowView:showImage(path)
  self.uiBinder.Ref:SetVisible(self.group_rimg, true)
  self.uiBinder.Ref:SetVisible(self.group_video, false)
  self.group_rimg:SetImage("ui/textures/helpsys/" .. path)
end

return Steer_helpsy_windowView
