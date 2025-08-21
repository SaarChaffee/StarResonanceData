local super = require("ui.model.data_base")
local TipsData = class("TipsData", super)

function TipsData:ctor()
  super.ctor(self)
  self.AcquireTipsInfos = {}
  self.SpecialAcquireTipsInfos = {}
  self.itemTipsId_ = 1
  self.itemTipsDatas_ = {}
  self.DlgActivePreferences = {}
  self.systemTipInfoCount_ = 0
  self.systemTipInfos_ = {}
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function TipsData:Init()
end

function TipsData:Clear()
  self.systemTipInfoCount_ = 0
  self.systemTipInfos_ = {}
  self.AcquireTipsInfos = {}
  self.SpecialAcquireTipsInfos = {}
end

function TipsData:UnInit()
end

function TipsData:PushAcquireItemInfo(itemGetTipsData)
  table.insert(self.AcquireTipsInfos, itemGetTipsData)
end

function TipsData:PopAcquireItemInfo()
  if #self.AcquireTipsInfos > 0 then
    local itemInfo = self.AcquireTipsInfos[1]
    table.remove(self.AcquireTipsInfos, 1)
    return itemInfo
  end
  return nil
end

function TipsData:PushSpecialAcquireItemInfo(itemGetTipsData)
  table.insert(self.SpecialAcquireTipsInfos, itemGetTipsData)
end

function TipsData:PopSpecialAcquireItemInfo()
  if #self.SpecialAcquireTipsInfos > 0 then
    local itemInfo = self.SpecialAcquireTipsInfos[1]
    table.remove(self.SpecialAcquireTipsInfos, 1)
    return itemInfo
  end
  return nil
end

function TipsData:AddItemTipsData(data)
  if data == nil then
    return 0
  end
  if not data.tipsId then
    data.tipsId = self.itemTipsId_
    self.itemTipsId_ = self.itemTipsId_ + 1
  end
  if self.itemTipsDatas_[data.tipsId] then
    self:doUpdate(self.itemTipsDatas_[data.tipsId], data)
  else
    self.itemTipsDatas_[data.tipsId] = data
  end
  return data.tipsId
end

function TipsData:GetItemTipsData()
  return self.itemTipsDatas_
end

function TipsData:RemoveItemTipsData(tipsId)
  self.itemTipsDatas_[tipsId] = nil
end

function TipsData:ClearItemTipsData()
  self.itemTipsDatas_ = {}
end

function TipsData:AddSystemTipInfo(infoType, id, content, placeholderParam)
  if infoType == E.ESystemTipInfoType.MessageInfo then
    local messageTableMgr = Z.TableMgr.GetTable("MessageTableMgr")
    local messageTableRow = messageTableMgr.GetRow(id)
    if messageTableRow == nil or not messageTableRow.IsShowInChat then
      return
    end
    if not content then
      if placeholderParam then
        content = Z.Placeholder.Placeholder(messageTableRow.Content, placeholderParam)
      else
        content = messageTableRow.Content
      end
    end
  end
  local info = {
    Time = os.time(),
    Type = infoType,
    Id = id,
    Content = content
  }
  self.systemTipInfoCount_ = self.systemTipInfoCount_ + 1
  self.systemTipInfos_[self.systemTipInfoCount_] = info
  Z.VMMgr.GetVM("chat_main").SetReceiveSystemMsg(info)
end

function TipsData:GetSystemTipInfos()
  return self.systemTipInfos_
end

return TipsData
