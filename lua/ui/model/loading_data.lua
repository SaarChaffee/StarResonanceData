local super = require("ui.model.data_base")
local LoadingData = class("LoadingData", super)
E.LoadingLabelType = {
  Default = 0,
  Mobile = 1,
  PC = 2,
  Handle = 3
}

function LoadingData:ctor()
end

function LoadingData:Init()
  self:InitLoadingRandomData()
end

function LoadingData:Clear()
  self.loadingRandomDirty_ = {}
end

function LoadingData:UnInit()
end

function LoadingData:InitLoadingRandomData()
  self.loadingRandomDirty_ = {}
  self.loadingBgList_ = {}
  self.loadingLabelData_ = {
    [E.LoadingLabelType.Default] = {},
    [E.LoadingLabelType.Mobile] = {},
    [E.LoadingLabelType.PC] = {},
    [E.LoadingLabelType.Handle] = {}
  }
  local configData = Z.TableMgr.GetTable("LoadingTableMgr").GetDatas()
  for id, config in pairs(configData) do
    if config.LoadingBg ~= "" then
      table.insert(self.loadingBgList_, config.LoadingBg)
    end
    if config.TextGeneral ~= "" and config.LoadingType >= E.LoadingLabelType.Default and config.LoadingType <= E.LoadingLabelType.Handle then
      if config.LoadingType == E.LoadingLabelType.Default then
        for type, list in pairs(self.loadingLabelData_) do
          table.insert(list, {
            id = config.Id,
            title = config.TextTitle,
            content = config.TextGeneral,
            levelRange = config.LevelRange
          })
        end
      else
        table.insert(self.loadingLabelData_[config.LoadingType], {
          id = config.Id,
          title = config.TextTitle,
          content = config.TextGeneral,
          levelRange = config.LevelRange
        })
      end
    end
  end
end

function LoadingData:GetRandomBg()
  local randomIndex = math.random(1, #self.loadingBgList_)
  local maxCount = 10
  while 0 < maxCount and self.lastBgIndex_ and randomIndex == self.lastBgIndex_ do
    randomIndex = math.random(1, #self.loadingBgList_)
    maxCount = maxCount - 1
  end
  self.lastBgIndex_ = randomIndex
  return self.loadingBgList_[randomIndex]
end

function LoadingData:GetRandomLabel()
  local list = self.loadingLabelData_[E.LoadingLabelType.Default]
  local playerData = Z.DataMgr.Get("player_data")
  if playerData.CurrentCharId ~= nil then
    local loadingType = E.LoadingLabelType.Mobile
    if Z.IsPCUI then
      if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
        loadingType = E.LoadingLabelType.Handle
      else
        loadingType = E.LoadingLabelType.PC
      end
    end
    list = self.loadingLabelData_[loadingType]
  end
  if list == nil or #list == 0 then
    return "", ""
  end
  local weightList = {}
  local roleLevel = self:getRoleLevel()
  for i, v in ipairs(list) do
    weightList[i] = 1
    if 0 < roleLevel and not self.loadingRandomDirty_[v.id] and v.levelRange ~= nil and #v.levelRange >= 2 and roleLevel >= v.levelRange[1] and roleLevel <= v.levelRange[2] then
      weightList[i] = Z.Global.LoadingLevelWeight
    end
  end
  local randomIndex = self:getRandomIndexByWeight(weightList)
  local maxCount = 10
  while 0 < maxCount and self.lastLabelIndex_ and randomIndex == self.lastLabelIndex_ do
    randomIndex = self:getRandomIndexByWeight(weightList)
    maxCount = maxCount - 1
  end
  self.lastLabelIndex_ = randomIndex
  local info = list[randomIndex]
  self.loadingRandomDirty_[info.id] = true
  local title = info.title
  local content = info.content
  return title, self:ParseLabelParam(content)
end

function LoadingData:ParseLabelParam(content)
  if self.labelParam_ == nil then
    self.labelParam_ = {
      key = {
        getKeyDesc = function(keyId)
          local keyVM = Z.VMMgr.GetVM("setting_key")
          local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(keyId)[1]
          return keyCodeDesc or ""
        end
      }
    }
  end
  return Z.Placeholder.Placeholder(content, self.labelParam_)
end

function LoadingData:OnLanguageChange()
  self:InitLoadingRandomData()
end

function LoadingData:getRandomIndexByWeight(weightList)
  local total = 0
  for _, weight in ipairs(weightList) do
    total = total + weight
  end
  local randomValue = math.random() * total
  local cumulative = 0
  for i, weight in ipairs(weightList) do
    cumulative = cumulative + weight
    if randomValue <= cumulative then
      return i
    end
  end
  return #weightList
end

function LoadingData:getRoleLevel()
  if Z.ContainerMgr.CharSerialize.roleLevel ~= nil then
    return Z.ContainerMgr.CharSerialize.roleLevel.level or 0
  end
  return 0
end

return LoadingData
