local super = require("ui.model.data_base")
local TipsData = class("TipsData", super)

function TipsData:ctor()
  super.ctor(self)
  self.AcquireTipsInfos = {}
  self.itemTipsId_ = 1
  self.itemTipsDtas_ = {}
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

function TipsData:AddItemTipsData(data)
  if data == nil then
    return 0
  end
  if not data.tipsId then
    data.tipsId = self.itemTipsId_
    self.itemTipsId_ = self.itemTipsId_ + 1
  end
  if self.itemTipsDtas_[data.tipsId] then
    self:doUpdate(self.itemTipsDtas_[data.tipsId], data)
  else
    self.itemTipsDtas_[data.tipsId] = data
  end
  return data.tipsId
end

function TipsData:GetItemTipsData()
  return self.itemTipsDtas_
end

function TipsData:RemoveItemTipsData(tipsId)
  self.itemTipsDtas_[tipsId] = nil
end

function TipsData:ClearItemTipsData()
  self.itemTipsDtas_ = {}
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
