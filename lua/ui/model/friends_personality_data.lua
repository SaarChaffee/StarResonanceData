local super = require("ui.model.data_base")
local FridensPersonalityData = class("FridensPersonalityData", super)

function FridensPersonalityData:ctor()
  super.ctor(self)
end

function FridensPersonalityData:Init()
  self:Clear()
end

function FridensPersonalityData:Clear()
  self.ShowPlayerData = {}
  self.SelectPlayerData = {}
  self.ShowPlayerData.HobbyMark = {}
  self.ShowPlayerData.TimeMark = {}
  self.ShowPlayerData.Signature = ""
  self.ShowPlayerData.ShowingPicture = ""
  self.Signature = ""
  self.IsEditState = false
  self.HobbyMark = {}
end

function FridensPersonalityData:SetEditState(state)
  self.IsEditState = state
end

function FridensPersonalityData:SetSignature(str)
  self.Signature = str
end

function FridensPersonalityData:SetHobbyMark(data)
  self.HobbyMark = data
end

function FridensPersonalityData:SetShowPlayerData(playerData)
  if playerData == nil then
    logError("\229\189\147\229\137\141\230\152\190\231\164\186\231\154\132\231\142\169\229\174\182\231\154\132\230\149\176\230\141\174\228\184\186nil")
    return
  end
  self.SelectPlayerData = playerData
  self.ShowPlayerData.HobbyMark = playerData.hobbyMark
  self.ShowPlayerData.Signature = playerData.signature
  self.ShowPlayerData.ShowingPicture = playerData.showingPicture
  self.ShowPlayerData.TimeMark = playerData.timeMark
end

function FridensPersonalityData:SetShowingPicture(showingPicture)
  self.ShowingPicture = showingPicture
end

function FridensPersonalityData:GetShowPlayerData()
  return self.ShowPlayerData
end

return FridensPersonalityData
