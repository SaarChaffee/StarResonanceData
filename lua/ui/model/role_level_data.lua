local super = require("ui.model.data_base")
local RoleLevelData = class("RoleLevelData", super)

function RoleLevelData:ctor()
  super.ctor(self)
end

function RoleLevelData:Init()
  self.roleLeve_ = Z.ContainerMgr.CharSerialize.roleLevel.level
  self.refresServerRedLevel_ = 0
  self:InitCfgData()
  self.AnimName = {
    mobile = {
      [1] = {
        start = "rolelevel_acquire_window_node_lv_an_001_start",
        ["end"] = "rolelevel_acquire_window_node_lv_an_001_end"
      },
      [2] = {
        start = "rolelevel_acquire_window_start_node_nature_an",
        ["end"] = "rolelevel_acquire_window_end_node_nature_an"
      },
      [3] = {
        start = "rolelevel_acquire_window_node_gift_an_001_start",
        ["end"] = "rolelevel_acquire_window_node_gift_an_001_end"
      }
    },
    pc = {
      [1] = {
        start = "rolelevel_acquire_window_node_lv_an_001_start_pc",
        ["end"] = "rolelevel_acquire_window_node_lv_an_001_end_pc"
      },
      [2] = {
        start = "rolelevel_acquire_window_start_node_nature_an_pc",
        ["end"] = "rolelevel_acquire_window_end_node_nature_an_pc"
      },
      [3] = {
        start = "rolelevel_acquire_window_node_gift_an_001_start_pc",
        ["end"] = "rolelevel_acquire_window_node_gift_an_001_end_pc"
      }
    }
  }
end

function RoleLevelData:InitCfgData()
  self.PlayerLevelTableDatas = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetDatas()
  self.MaxPlayerLevel = #self.PlayerLevelTableDatas
end

function RoleLevelData:OnLanguageChange()
  self:InitCfgData()
end

function RoleLevelData:Clear()
  self.roleLeve_ = 0
  self.refresServerRedLevel_ = 0
end

function RoleLevelData:SetRoleLevel(level)
  self.roleLeve_ = level
end

function RoleLevelData:GetRoleLevel()
  return self.roleLeve_
end

function RoleLevelData:SetRedLevel(level)
  self.refresServerRedLevel_ = level
end

function RoleLevelData:GetRedLevel()
  return self.refresServerRedLevel_
end

function RoleLevelData:GetMaxLevel()
  local max = 0
  for k, v in pairs(self.PlayerLevelTableDatas) do
    if max < v.Level then
      max = v.Level
    end
  end
  return max
end

function RoleLevelData:UnInit()
  self.roleLeve_ = 0
  self.refresServerRedLevel_ = 0
end

function RoleLevelData:OnInit()
  self.roleLeve = 0
  self.refresServerRedLevel = 0
end

return RoleLevelData
