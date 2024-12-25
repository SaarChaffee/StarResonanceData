local super = require("ui.model.data_base")
local PersonalZoneData = class("PersonalZoneData", super)
local DEFINE = require("ui.model.personalzone_define")

function PersonalZoneData:ctor()
  super.ctor(self)
  self.showPhotos_ = {}
  self.showPhotosCount_ = 0
  self.profileImageConfig_ = {}
  self.defaultProfileImageConfig_ = {}
  self.unlockTargetConfig_ = {}
  self.addItemRedDot_ = {}
  self.mainViewData_ = nil
  self.ignorePopup = false
end

function PersonalZoneData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self:InitConfig()
end

function PersonalZoneData:UnInit()
  self.CancelSource:Recycle()
end

function PersonalZoneData:Clear()
  self.mainViewData_ = nil
  self.addItemRedDot_ = {}
  self.showPhotos_ = {}
  self.showPhotosCount_ = 0
  for _, config in pairs(self.unlockTargetConfig_) do
    config.currentNum = 0
  end
  self.ignorePopup = false
end

function PersonalZoneData:InitConfig()
  self.personalTags_ = {}
  local unionTagTableMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  local datas = unionTagTableMgr.GetDatas()
  for _, value in pairs(datas) do
    if value.IsHide and value.IsHide == 0 then
      if self.personalTags_[value.Type] == nil then
        self.personalTags_[value.Type] = {}
      end
      table.insert(self.personalTags_[value.Type], value)
    end
  end
  for _, value in pairs(self.personalTags_) do
    table.sort(value, function(a, b)
      if a.ShowSort == b.ShowSort then
        return a.Id < b.Id
      else
        return a.ShowSort < b.ShowSort
      end
    end)
  end
  self.profileImageConfig_ = {}
  self.unlockTargetConfig_ = {}
  local profileImageConfigs = Z.TableMgr.GetTable("ProfileImageTableMgr").GetDatas()
  local profileTargetTableMgr = Z.TableMgr.GetTable("ProfileImageTargetTableMgr")
  for _, data in pairs(profileImageConfigs) do
    if self.profileImageConfig_[data.Type] == nil then
      self.profileImageConfig_[data.Type] = {}
    end
    table.insert(self.profileImageConfig_[data.Type], data)
    if data.Unlock and data.Unlock == 1 then
      self.defaultProfileImageConfig_[data.Type] = data
    elseif data.TargetId and data.TargetId ~= 0 then
      self.unlockTargetConfig_[data.Id] = {
        isProfileImageConfig = true,
        profileImageConfig = data,
        profileImageTargetConfig = profileTargetTableMgr.GetRow(data.TargetId),
        currentNum = 0
      }
    end
  end
  self.medalConfig_ = {}
  local medalConfigs = Z.TableMgr.GetTable("MedalTableMgr").GetDatas()
  for _, data in pairs(medalConfigs) do
    if data.IsHide == nil or data.IsHide == 0 then
      if self.medalConfig_[data.Type] == nil then
        self.medalConfig_[data.Type] = {}
      end
      table.insert(self.medalConfig_[data.Type], data)
      if data.TargetId and data.TargetId ~= 0 then
        self.unlockTargetConfig_[data.Id] = {
          isProfileImageConfig = false,
          profileImageConfig = data,
          profileImageTargetConfig = profileTargetTableMgr.GetRow(data.TargetId),
          currentNum = 0
        }
      end
    end
  end
end

function PersonalZoneData:GetTagsByType(type)
  return self.personalTags_[type]
end

function PersonalZoneData:InitShowPhotoData()
  self.showPhotos_ = {}
  self.showPhotosCount_ = 0
  if Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.photos then
    local photos = Z.ContainerMgr.CharSerialize.personalZone.photos
    for key, photo in pairs(photos) do
      if photo ~= 0 then
        self.showPhotos_[key] = photo
        self.showPhotosCount_ = self.showPhotosCount_ + 1
      end
    end
  end
end

function PersonalZoneData:GetEmptyPhotoIndex()
  if self.showPhotosCount_ >= DEFINE.ShowPhotoMaxCount then
    return -1
  end
  for i = 1, DEFINE.ShowPhotoMaxCount do
    if self.showPhotos_[i] == nil or self.showPhotos_[i] == 0 then
      return i
    end
  end
  return -1
end

function PersonalZoneData:GetShowPhotoCount()
  return self.showPhotosCount_
end

function PersonalZoneData:SetShowPhoto(index, photoId)
  if self:IsContainPhotoId(photoId) then
    return
  end
  self.showPhotos_[index] = photoId
  self.showPhotosCount_ = self.showPhotosCount_ + 1
end

function PersonalZoneData:RemoveShowPhoto(photoId)
  local index = -1
  for key, value in pairs(self.showPhotos_) do
    if value == photoId then
      index = key
      self.showPhotos_[key] = nil
      self.showPhotosCount_ = self.showPhotosCount_ - 1
      break
    end
  end
  if index ~= -1 then
    for i = index, DEFINE.ShowPhotoMaxCount - 1 do
      self.showPhotos_[i] = self.showPhotos_[i + 1]
    end
    self.showPhotos_[DEFINE.ShowPhotoMaxCount] = nil
  end
end

function PersonalZoneData:IsContainPhotoId(photoId)
  for _, photo in pairs(self.showPhotos_) do
    if photo == photoId then
      return true
    end
  end
  return false
end

function PersonalZoneData:GetShowPhoto()
  return self.showPhotos_
end

function PersonalZoneData:GetProfileImageConfigsByType(type)
  return self.profileImageConfig_[type]
end

function PersonalZoneData:GetDefaultProfileImageConfigByType(type)
  return self.defaultProfileImageConfig_[type].Id
end

function PersonalZoneData:SetCurPreviewPersonalZoneData(viewData)
  self.mainViewData_ = viewData
end

function PersonalZoneData:GetCurPreviewPersonalZoneData()
  return self.mainViewData_
end

function PersonalZoneData:GetProfileImageTarget(id)
  return self.unlockTargetConfig_[id]
end

function PersonalZoneData:SetProfileImageTarget(id, num)
  if self.unlockTargetConfig_[id] then
    self.unlockTargetConfig_[id].currentNum = num
  end
end

function PersonalZoneData:GetAllProfileImageTargets()
  return self.unlockTargetConfig_
end

function PersonalZoneData:AddPersonalzoneItem(id)
  self.addItemRedDot_[id] = id
end

function PersonalZoneData:RemovePersonalzoneItem(id)
  self.addItemRedDot_[id] = nil
end

function PersonalZoneData:ClearMedalAddReddot()
  local medalTableMgr = Z.TableMgr.GetTable("MedalTableMgr")
  for key, id in pairs(self.addItemRedDot_) do
    if medalTableMgr.GetRow(id, true) ~= nil then
      self.addItemRedDot_[key] = nil
    end
  end
end

function PersonalZoneData:GetAllRedDotItem()
  return self.addItemRedDot_
end

function PersonalZoneData:GetAllMedalConfig()
  return self.medalConfig_
end

function PersonalZoneData:GetMedalConfig(type)
  return self.medalConfig_[type]
end

function PersonalZoneData:SetIgnorePopup(isIgnore)
  self.ignorePopup = isIgnore
end

function PersonalZoneData:IsIgnorePopup()
  return self.ignorePopup
end

return PersonalZoneData
