local DataBase = class("DataBase")

function DataBase:ctor()
end

function DataBase:UpdateData(k, v)
  if type(self[k]) ~= "table" or type(v) ~= "table" then
    self[k] = v
    return
  end
  self:doUpdate(self[k], v)
end

function DataBase:doUpdate(parentData, childData)
  for k, v in pairs(childData) do
    local typeV = type(v)
    if typeV == "table" then
      if parentData[k] == nil then
        parentData[k] = v
      else
        self:doUpdate(parentData[k], v)
      end
    else
      parentData[k] = v
    end
  end
end

function DataBase:Init()
  logGreen(self.__cname .. "data Init")
end

function DataBase:OnReconnect()
end

function DataBase:Clear()
  logGreen(self.__cname .. "data Clear")
end

function DataBase:UnInit()
  logGreen(self.__cname .. "data UnInit")
end

function DataBase:OnLanguageChange()
  logGreen(self.__cname .. "data OnLanguageChange")
end

return DataBase
