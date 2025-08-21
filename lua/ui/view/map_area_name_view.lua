local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_area_nameView = class("Map_area_nameView", super)
local LOADING_VIEW_KEY = "loading_window"

function Map_area_nameView:ctor()
  self.uiBinder = nil
  super.ctor(self, "map_area_name_window", "map/map_area_name_window", UI.ECacheLv.None, true)
end

function Map_area_nameView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onViewCloseEvent, self)
  Z.EventMgr:Add(Z.ConstValue.MapAreaChange, self.checkAreaNameShow, self)
  Z.EventMgr:Add(Z.ConstValue.VisualLayerChange, self.checkAreaNameShow, self)
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.isAnimPlaying_ = false
  Z.MiniMapManager:ForceUpdatePlayerPosAndRot()
end

function Map_area_nameView:OnRefresh()
  self:checkAreaNameShow()
end

function Map_area_nameView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.UIClose, self.onViewCloseEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.MapAreaChange, self.checkAreaNameShow, self)
  Z.EventMgr:Remove(Z.ConstValue.VisualLayerChange, self.checkAreaNameShow, self)
  if Z.IsPCUI then
    self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  end
end

function Map_area_nameView:checkAreaNameShow()
  if self.isAnimPlaying_ then
    return
  end
  self:SetUIVisible(self.uiBinder.node_content, false)
  if self.mapData_.IsHadShownAreaName then
    return
  end
  if Z.UIMgr:IsActive(LOADING_VIEW_KEY) then
    return
  end
  local playerEnt = Z.EntityMgr.PlayerEnt
  if playerEnt == nil then
    return
  end
  local visualLayerUid = playerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  if 0 < visualLayerUid then
    self.mapData_:ResetMapAreaData()
    return
  end
  self:playAnim()
  self.mapData_.IsHadShownAreaName = true
end

function Map_area_nameView:playAnim()
  local areaName = self:getCurAreaName()
  if areaName ~= "" and areaName ~= self.uiBinder.lab_name.text then
    logGreen("[MapAreaName] ShowAreaName = " .. areaName)
    self:SetUIVisible(self.uiBinder.node_content, true)
    local nameArray = string.split(areaName, "<br>")
    self.uiBinder.lab_name.text = nameArray[1]
    self.uiBinder.lab_level.text = nameArray[2]
    local token = self.cancelSource:CreateToken()
    local animName
    if Z.IsPCUI then
      animName = "anim_map_area_name_window_pc_open"
      self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
    else
      animName = "anim_map_area_name_tpl_001"
    end
    self.isAnimPlaying_ = true
    self.uiBinder.anim_main:CoroPlayOnce(animName, token, function()
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
