local super = require("ui.component.loopscrollrectitem")
local UnionEventListItem = class("UnionEventListItem", super)

function UnionEventListItem:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function UnionEventListItem:OnInit()
  self.buffTableMgr_ = Z.TableMgr.GetTable("BuffTableMgr")
  self.unionTimelinessBuffTableMgr_ = Z.TableMgr.GetTable("UnionTimelinessBuffTableMgr")
  self:Selected(false)
end

function UnionEventListItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if self.data_ == nil then
    return
  end
  local config = Z.TableMgr.GetTable("UnionEventTableMgr").GetRow(self.data_.eventId)
  if config == nil then
    return
  end
  if self.data_.eventParam == nil then
    return
  end
  local param = {
    player = {},
    guild = {}
  }
  if self.data_.eventId == 7 then
    param.player.name = self.data_.eventParam[1]
    param.guild.rank = self.unionVM_:GetOfficialName(tonumber(self.data_.eventParam[2]))
  elseif self.data_.eventId == 9 then
    local buildId = tonumber(self.data_.eventParam[1])
    local buildConfig = self.unionVM_:GetUnionBuildConfig(buildId)
    param.union = {
      build = buildConfig.BuildingName
    }
    param.val = self.data_.eventParam[2]
  elseif self.data_.eventId == 10 then
    param.player.name = self.data_.eventParam[1]
    local buildId = tonumber(self.data_.eventParam[2])
    local buildConfig = self.unionVM_:GetUnionBuildConfig(buildId)
    param.union = {
      build = buildConfig.BuildingName
    }
    param.val = math.floor(tonumber(self.data_.eventParam[3]) / 60)
  elseif self.data_.eventId == 11 or self.data_.eventId == 12 then
    local buffId = tonumber(self.data_.eventParam[1])
    local unionBuffConfig = self.unionTimelinessBuffTableMgr_.GetRow(buffId)
    if unionBuffConfig then
      local buffConfig = self.buffTableMgr_.GetRow(unionBuffConfig.Buff)
      local buffName = buffConfig and buffConfig.Name or ""
      param.buff = {name = buffName}
      if #self.data_.eventParam == 2 then
        param.val = self.data_.eventParam[2]
      end
    end
  else
    local paramCount = #self.data_.eventParam
    if paramCount == 1 then
      param.player.name = self.data_.eventParam[1]
    elseif paramCount == 2 then
      param.player.names = {
        self.data_.eventParam[1],
        self.data_.eventParam[2]
      }
      param.guild.rank = self.data_.eventParam[2]
    elseif paramCount == 3 then
      param.player.names = {
        self.data_.eventParam[1],
        self.data_.eventParam[2]
      }
      param.guild.rank = self.unionVM_:GetOfficialName(tonumber(self.data_.eventParam[3]))
    end
  end
  self.unit.lab_content.TMPLab.text = Z.Placeholder.Placeholder(config.Content, param)
  self.unit.lab_time.TMPLab.text = self.unionVM_:GetLastTimeDesignText(self.data_.eventTime)
end

function UnionEventListItem:Selected(isSelected)
end

function UnionEventListItem:OnPointerClick(go, eventData)
end

function UnionEventListItem:OnUnInit()
end

function UnionEventListItem:OnReset()
end

return UnionEventListItem
