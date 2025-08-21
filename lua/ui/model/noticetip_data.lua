local super = require("ui.model.data_base")
local NoticeTipData = class("NoticeTipData", super)
local checkConfigRepeat = function(checkMsgTable, msgItem)
  local messageTableMgr = Z.TableMgr.GetTable("MessageTableMgr")
  local messageTableRow = messageTableMgr.GetRow(msgItem.config.Id)
  if messageTableRow == nil or not messageTableRow.FilterRule then
    return false
  end
  for _, v in pairs(checkMsgTable) do
    local opDataRepeat = msgItem.content == v.content
    if v.config.Id == msgItem.config.Id and opDataRepeat then
      return true
    end
  end
  return false
end

function NoticeTipData:ctor()
  super.ctor(self)
  self.pop_msg_data = {}
  self.npc_msg_data = {}
  self.middle_pop_data = {}
  self.top_pop_data = {}
  self.TopPopShowingState = false
  self.noticeView = {
    [E.TipsType.PopTip] = "noticetip_pop",
    [E.TipsType.CopyMode] = "noticetip_copy",
    [E.TipsType.Captions] = "noticetip_captions",
    [E.TipsType.TalkInfo] = "talk_info_window",
    [E.TipsType.DungeonSpecialTips] = "noticetip_pop",
    [E.TipsType.DungeonChallengeWinTips] = "noticetip_pop",
    [E.TipsType.DungeonChallengeFailTips] = "noticetip_pop",
    [E.TipsType.BottomTips] = "noticetip_pop",
    [E.TipsType.MiddleTips] = "noticetip_middle_popup",
    [E.TipsType.QuestLetter] = "quest_letter_window",
    [E.TipsType.DungeonRedTips] = "noticetip_pop",
    [E.TipsType.DungeonGreenTips] = "noticetip_pop",
    [E.TipsType.QuestLetterWithBackground] = "quest_letter_window"
  }
  self.CopyTextShowingState = false
  self.NpcShowingState = false
  self.Copy_tip = nil
end

function NoticeTipData:Clear()
end

function NoticeTipData:DequeuePopData()
  return table.remove(self.pop_msg_data, 1)
end

function NoticeTipData:EnqueuePopData(msgItem)
  local isRepeat = checkConfigRepeat(self.pop_msg_data, msgItem)
  if isRepeat then
    return
  end
  table.insert(self.pop_msg_data, msgItem)
end

function NoticeTipData:EnqueueNpcData(msgItem)
  local isRepeat = checkConfigRepeat(self.npc_msg_data, msgItem)
  if isRepeat then
    return
  end
  local messageTableMgr = Z.TableMgr.GetTable("MessageTableMgr")
  local messageTableRow = messageTableMgr.GetRow(msgItem.config.Id)
  if messageTableRow == nil or messageTableRow.Interrupt == nil then
    return
  end
  if messageTableRow.Interrupt == 1 then
    self.npc_msg_data = {}
    self.NpcShowingState = false
  end
  table.insert(self.npc_msg_data, msgItem)
end

function NoticeTipData:DequeueNpcData()
  return table.remove(self.npc_msg_data, 1)
end

function NoticeTipData:CheckNpcDataCount()
  return #self.npc_msg_data
end

function NoticeTipData:ClearNpcData(tosceneId)
  if tosceneId == nil then
    logError("NoticeTipsData clearNpcData toSceneId is nil!")
    self:clearNoticeCaptionData()
    return
  end
  local sceneCfg = Z.TableMgr.GetTable("SceneTableMgr").GetRow(tosceneId)
  if sceneCfg == nil or sceneCfg.SceneSubType ~= E.SceneSubType.Mirror then
    self:clearNoticeCaptionData()
  end
end

function NoticeTipData:clearNoticeCaptionData()
  self.npc_msg_data = {}
  Z.EventMgr:Dispatch("ShowNoticeCaption")
end

function NoticeTipData:EnqueueMiddlePopData(msgItem)
  table.insert(self.middle_pop_data, msgItem)
end

function NoticeTipData:DequeueMiddlePopData()
  return table.remove(self.middle_pop_data, 1)
end

function NoticeTipData:GetMiddlePopDataCount()
  return table.zcount(self.middle_pop_data)
end

function NoticeTipData:EnqueueTopPopData(msgItem)
  table.insert(self.top_pop_data, msgItem)
  if self.TopPopShowingState == false then
    Z.EventMgr:Dispatch(Z.ConstValue.TipsShowNextTopPop)
  end
end

function NoticeTipData:DequeueTopPopData()
  return table.remove(self.top_pop_data, 1)
end

function NoticeTipData:GetTopPopDataCount()
  return table.zcount(self.top_pop_data)
end

function NoticeTipData:ClearTopPopData()
  self.top_pop_data = {}
end

function NoticeTipData:CheckConfigRepeat(checkMsgTable, msgItem)
  return checkConfigRepeat(checkMsgTable, msgItem)
end

function NoticeTipData:GetNoticeViewConfigKey(tipsType)
  return self.noticeView[tipsType]
end

return NoticeTipData
