local super = require("ui.model.data_base")
local HelpsysData = class("HelpsysData", super)

function HelpsysData:ctor()
  super.ctor(self)
  self.helpLibraryTable_ = table.zvalues(Z.TableMgr.GetTable("HelpLibraryTableMgr").GetDatas())
  table.sort(self.helpLibraryTable_, function(a, b)
    return a.sortId < b.sortId
  end)
  self.mulDatas_ = {}
  self.mulEnableDatas_ = {}
  self.mulEnableDict_ = {}
  self.mixDatas_ = {}
  self.serverDataQueue_ = {}
  self.lockHelpIds_ = {}
  self:initData()
end

function HelpsysData:Init()
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function HelpsysData:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function HelpsysData:onLanguageChange()
  self.helpLibraryTable_ = table.zvalues(Z.TableMgr.GetTable("HelpLibraryTableMgr").GetDatas())
  table.sort(self.helpLibraryTable_, function(a, b)
    return a.sortId < b.sortId
  end)
  self:initData()
end

function HelpsysData:initMulDatas()
  local groupDict = {}
  self.lockHelpIds_ = {}
  local index = 1
  for key, value in ipairs(self.helpLibraryTable_) do
    if value.Type == E.HelpSysType.Mul then
      local isUnlock = true
      if value.Guideunlock ~= 0 and not Z.ContainerMgr.CharSerialize.help.completedGuide[value.Guideunlock] then
        isUnlock = false
        if self.lockHelpIds_[value.Guideunlock] == nil then
          self.lockHelpIds_[value.Guideunlock] = {}
        end
        self.lockHelpIds_[value.Guideunlock][#self.lockHelpIds_[value.Guideunlock] + 1] = value.Id
      end
      if groupDict[value.HelpGroup] == nil then
        groupDict[value.HelpGroup] = index
        self.mulDatas_[index] = {}
        self.mulDatas_[index].HelpGroup = value.HelpGroup
        self.mulDatas_[index].Id = value.Id
        self.mulDatas_[index].Icon = value.Icon
        self.mulDatas_[index].DataList = {}
        index = index + 1
      end
      if isUnlock then
        table.insert(self.mulDatas_[groupDict[value.HelpGroup]].DataList, value)
        if string.zisEmpty(self.mulDatas_[groupDict[value.HelpGroup]].GroupName) then
          self.mulDatas_[groupDict[value.HelpGroup]].GroupName = value.GroupName
        end
      end
    end
  end
  table.sort(self.mulDatas_, function(a, b)
    return a.HelpGroup < b.HelpGroup
  end)
  for i = 1, #self.mulDatas_ do
    table.sort(self.mulDatas_[i].DataList, function(a, b)
      return a.Sequence < b.Sequence
    end)
  end
end

function HelpsysData:initMixDatas()
  local tableDict = {}
  local mixIdList = {}
  for key, value in ipairs(self.helpLibraryTable_) do
    if value.Type == E.HelpSysType.Mix then
      if not table.zcontains(mixIdList, value.TypeGroup) then
        table.insert(mixIdList, value.TypeGroup)
      end
      if not tableDict[value.TypeGroup] then
        tableDict[value.TypeGroup] = {}
      end
      table.insert(tableDict[value.TypeGroup], value)
    end
  end
  for _, key in ipairs(mixIdList) do
    local mulData = {}
    local groupDict = {}
    local index = 1
    local mainTitle = ""
    for _, value in ipairs(tableDict[key]) do
      if groupDict[value.HelpGroup] == nil then
        groupDict[value.HelpGroup] = index
        mulData[index] = {}
        mulData[index].HelpGroup = value.HelpGroup
        mulData[index].Id = value.Id
        mulData[index].Icon = value.Icon
        mulData[index].DataList = {}
        table.insert(mulData[index].DataList, value)
        index = index + 1
      end
      if value.Guideunlock == 0 or self.lockHelpIds_[value.Guideunlock] == nil then
        if groupDict[value.HelpGroup] ~= nil then
          table.insert(mulData[groupDict[value.HelpGroup]].DataList, value)
        end
        if string.zisEmpty(mulData[groupDict[value.HelpGroup]].GroupName) then
          mulData[groupDict[value.HelpGroup]].GroupName = value.GroupName
        end
        if string.zisEmpty(mainTitle) then
          mainTitle = value.MainTitle
        end
      end
    end
    self.mixDatas_[key] = {}
    self.mixDatas_[key].MainTitle = mainTitle
    self.mixDatas_[key].Datas = mulData
  end
  for key, mixData in pairs(self.mixDatas_) do
    table.sort(mixData.Datas, function(a, b)
      return a.HelpGroup < b.HelpGroup
    end)
    for i = 1, #mixData.Datas do
      table.sort(mixData.Datas[i].DataList, function(a, b)
        return a.Id < b.Id
      end)
    end
  end
end

function HelpsysData:initData()
  self:initMulDatas()
  self:initMixDatas()
end

function HelpsysData:GetMulData()
  return self.mulDatas_
end

function HelpsysData:GetEnableMulData(isAll)
  if isAll then
    return self.mulDatas_
  end
  local showDict = Z.ContainerMgr.CharSerialize.help.displayedHelperList
  local isSame = true
  for key, value in pairs(showDict) do
    if self.mulEnableDict_[key] == nil then
      isSame = false
      break
    end
  end
  if isSame then
    return self.mulEnableDatas_
  end
  self.mulEnableDict_ = table.zclone(showDict)
  self.mulEnableDatas_ = {}
  for i = 1, #self.mulDatas_ do
    local isExist = false
    local tmp = {}
    for _, value in ipairs(self.mulDatas_[i].DataList) do
      if showDict[value.Id] then
        if not isExist then
          isExist = true
          tmp.HelpGroup = value.HelpGroup
          tmp.Id = value.Id
          tmp.GroupName = self.mulDatas_[i].GroupName
          tmp.Icon = value.Icon
          tmp.DataList = {}
        end
        table.insert(tmp.DataList, value)
      end
    end
    if isExist then
      table.insert(self.mulEnableDatas_, tmp)
    end
  end
  return self.mulEnableDatas_
end

function HelpsysData:GetMixDataByType(type)
  return self.mixDatas_[type]
end

function HelpsysData:GetOtherDataById(id)
  local data = Z.TableMgr.GetTable("HelpLibraryTableMgr").GetRow(id)
  if data == nil then
    return nil
  end
  return data
end

function HelpsysData:DequeuePopData()
  if #self.serverDataQueue_ == 0 then
    return 0
  end
  return table.remove(self.serverDataQueue_, 1)
end

function HelpsysData:EnqueuePopData(id)
  table.insert(self.serverDataQueue_, id)
end

function HelpsysData:QueueLen()
  return #self.serverDataQueue_
end

function HelpsysData:GetTableSegmentationDataById(data)
  if data == nil then
    return nil
  end
  local dataTable = {}
  local num = 1
  for i, v in ipairs(data.Content) do
    if i % 2 == 1 then
      dataTable[num] = {}
      dataTable[num].type = v
    else
      dataTable[num].value = v
      num = num + 1
    end
  end
  return dataTable
end

function HelpsysData:UnlockHelpsys(guideId)
  if self.lockHelpIds_[guideId] then
    for i, heplId in ipairs(self.lockHelpIds_[guideId]) do
      local row = self:GetOtherDataById(heplId)
      if row then
        local tabRedName = E.RedType.HelpsysTabRed .. "group" .. row.HelpGroup
        Z.RedPointMgr.AddChildNodeData(E.RedType.HelpsysRed, E.RedType.HelpsysTabRed, tabRedName)
        Z.RedPointMgr.AddChildNodeData(tabRedName, E.RedType.HelpsysItemRed, E.RedType.HelpsysItemRed .. heplId)
        Z.RedPointMgr.UpdateNodeCount(E.RedType.HelpsysItemRed .. heplId, 1)
        for k, v in ipairs(self.mulDatas_) do
          if v.HelpGroup == row.HelpGroup then
            table.insert(v.DataList, row)
          end
        end
        for i = 1, #self.mulDatas_ do
          table.sort(self.mulDatas_[i].DataList, function(a, b)
            return a.Sequence < b.Sequence
          end)
        end
        for k, mixData in ipairs(self.mixDatas_) do
          for k, v in ipairs(mixData.Datas) do
            if v.HelpGroup == row.HelpGroup then
              table.insert(v.DataList, row)
            end
          end
          for i = 1, #mixData.Datas do
            table.sort(mixData.Datas[i].DataList, function(a, b)
              return a.Id < b.Id
            end)
          end
        end
      end
    end
  end
end

return HelpsysData
