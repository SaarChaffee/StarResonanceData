local super = require("ui.model.data_base")
local HomeData = class("HomeData", super)
E.EHomeAlignType = {
  AlignMoveValue = 1,
  AlignHeightValue = 2,
  AlignAnglesValue = 3,
  RotateSpeedValue = 4
}

function HomeData:ctor()
  super.ctor(self)
end

function HomeData:Init()
  self.homeCfgDatas_ = {}
  self.homeLoadId = -1
  self.AlignMoveValue = 0
  self.AlignRotateValue = 0
  self.AlignHightValue = 0
  self.IsDrag = false
  self.IsAlign = false
  self.LangData = {}
  self.HomelandDatas = {}
  self.CommunityDatas = {}
  self.IsOperationState = false
  self.LocalCreatHomeFurnitureDic = {}
  self:InitCfgData()
end

function HomeData:InitCfgData()
  self.HousingItemsTypeGroupDatas = Z.TableMgr.GetTable("HousingItemsTypeGroupMgr").GetDatas()
  self.HousingItemsTypeDatas = Z.TableMgr.GetTable("HousingItemsTypeMgr").GetDatas()
end

function HomeData:OnLanguageChange()
  self:InitCfgData()
end

function HomeData:Clear()
end

function HomeData:UnInit()
end

function HomeData:CreatHomeFurniture(configId)
  if self.LocalCreatHomeFurnitureDic[configId] then
    self.LocalCreatHomeFurnitureDic[configId] = self.LocalCreatHomeFurnitureDic[configId] + 1
  else
    self.LocalCreatHomeFurnitureDic[configId] = 1
  end
end

function HomeData:RemoveHomeFurniture(configId)
  if self.LocalCreatHomeFurnitureDic[configId] then
    self.LocalCreatHomeFurnitureDic[configId] = self.LocalCreatHomeFurnitureDic[configId] - 1
    if self.LocalCreatHomeFurnitureDic[configId] < 0 then
      self.LocalCreatHomeFurnitureDic[configId] = 0
    end
  end
end

function HomeData:SetHomeCfgDatas(data)
  self.homeCfgDatas_ = data
end

function HomeData:GetHomeCfgDatas()
  return self.homeCfgDatas_
end

function HomeData:SetHomeLoadId(homeId)
  self.homeLoadId = homeId
end

function HomeData:GetomeLoadId()
  return self.homeLoadId
end

function HomeData:SetAlignState(state)
  self.IsAlign = state
end

function HomeData:GetAlignState()
  return self.IsAlign
end

function HomeData:SetLangData(clientUuid, itemId)
  self.LangData[clientUuid] = itemId
end

function HomeData:GetLangData(clientUuid)
  return self.LangData[clientUuid]
end

function HomeData:SetCommunityDatas(homelandDatas)
  self.CommunityDatas = homelandDatas
end

function HomeData:GetCommunityDatas()
  return self.CommunityDatas
end

function HomeData:SetHomelandDatas(homelandDatas)
  self.HomelandDatas = homelandDatas
end

function HomeData:GetHomelandDatas()
  return self.HomelandDatas
end

return HomeData
