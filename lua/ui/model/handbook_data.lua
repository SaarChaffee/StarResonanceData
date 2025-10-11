local super = require("ui.model.data_base")
local HandbookData = class("HandbookData", super)
local handbookDefine = require("ui.model.handbook_define")
local cjson = require("cjson")

function HandbookData:ctor()
  super.ctor(self)
end

function HandbookData:Init()
end

function HandbookData:UnInit()
end

function HandbookData:Clear()
end

function HandbookData:OnReconnect()
end

function HandbookData:InitLocalSave()
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, handbookDefine.LocalSaveKey) then
    local str = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, handbookDefine.LocalSaveKey)
    self.LocalSave = cjson.decode(str)
    if type(self.LocalSave) == "userdata" then
      logError("Handbook New Decode Error To UserData, LocalSave : " .. str)
      self.LocalSave = {}
    end
  else
    self.LocalSave = {}
  end
end

function HandbookData:SaveLocalSave()
  local localSave = cjson.encode(self.LocalSave)
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, handbookDefine.LocalSaveKey, localSave)
end

return HandbookData
