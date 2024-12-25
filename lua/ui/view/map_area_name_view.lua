local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_area_nameView = class("Map_area_nameView", super)
local LOADING_VIEW_KEY = "loading_window"

function Map_area_nameView:ctor()
  self.panel = nil
  local assetPath = Z.IsPCUI and "map/map_area_name_window_pc" or "map/map_area_name_window"
  super.ctor(self, "map_area_name_window", assetPath, UI.ECacheLv.None)
end

function Map_area_nameView:OnActive()
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onViewCloseEvent, self)
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.isAnimPlaying_ = false
end

function Map_area_nameView:OnRefresh()
  self:checkAreaNameShow()
end

function Map_area_nameView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.UIClose, self.onViewCloseEvent, self)
end

function Map_area_nameView:checkAreaNameShow()
  if self.isAnimPlaying_ then
    return
  end
  self.panel.node_content:SetVisible(false)
  if self.mapData_.IsHadShownAreaName then
    return
  end
  if Z.UIMgr:IsActive(LOADING_VIEW_KEY) then
    return
  end
  self:playAnim()
  self.mapData_.IsShownNameAfterChangeScene = true
  self.mapData_.IsHadShownAreaName = true
end

function Map_area_nameView:playAnim()
  local areaName = self:getCurAreaName()
  if areaName ~= "" and areaName ~= self.panel.lab_name.TMPLab.text then
    logGreen("[MapAreaName] ShowAreaName = " .. areaName)
    self.panel.node_content:SetVisible(true)
    self.panel.lab_name.TMPLab.text = areaName
    self.isAnimPlaying_ = true
    local token = self.cancelSource:CreateToken()
    self.panel.anim.anim:CoroPlayOnce("anim_map_area_name_tpl_001", token, function()
      self.isAnimPlaying_ = false
    end, function(err)
      self.isAnimPlaying_ = false
      if err ~= Z.CancelException then
        logError(err)
      end
    end)
  end
end

function Map_area_nameView:getCurAreaName()
  local row = Z.TableMgr.GetTable("SceneAreaTableMgr").GetRow(self.mapData_.CurAreaId, true)
  if row then
    return row.Name
  else
    return ""
  end
end

function Map_area_nameView:onViewCloseEvent(viewConfigKey)
  if viewConfigKey and viewConfigKey == LOADING_VIEW_KEY then
    Z.MiniMapManager:ForceUpdatePlayerPosAndRot()
    self:checkAreaNameShow()
  end
end

return Map_area_nameView
