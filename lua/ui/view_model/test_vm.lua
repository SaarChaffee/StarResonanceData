local ret = {}

function ret.TestAwards(awardPackageId)
  local awardpreview = Z.VMMgr.GetVM("awardpreview")
  local awardData = awardpreview.GetAllAwardPreListByIds(awardPackageId)
  if awardData == nil or #awardData < 1 then
    logError("awardData is nil or empty")
  end
  for i = 1, #awardData do
    local itemId = awardData[i].awardId
    local awardNum = awardData[i].awardNum
    logError("[awardTest] awardPackageId = " .. awardPackageId .. "   itemId = " .. itemId .. "    awardNum = " .. awardNum)
  end
end

function ret.TestAwardsEquipProfessionLimit()
  ret.TestAwards(9000)
end

function ret.TestAwardsTimerLimit()
  ret.TestAwards(10700010)
end

function ret.PrintRedDotTree(...)
  local redDotTest = require("rednode.core.test.reddot_test")
  redDotTest.PrintRedDotTree()
end

function ret.ShowChapterWind(...)
  local viewData = {EpisodeId = 101, IsStart = true}
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.Episode, "quest_chapter_window", viewData)
end

function ret.xxxx()
  local testVm = Z.VMMgr.GetVM("test")
  testVm.TestAwardsTimerLimit()
  local timerMgr = Z.TimerMgr.new()
  timerMgr:StartTimer(function()
    local interactionData_ = Z.DataMgr.Get("interaction_data")
    local handleDataList = interactionData_:GetData()
    local count = #handleDataList
    if count < 1 then
      return
    end
    if count == 1 then
      handleDataList[1]:OnBtnClick()
      return
    end
    if count == 2 then
      handleDataList[2]:OnBtnClick()
      return
    end
  end, 1, -1)
  Z.EventMgr:Add(Z.ConstValue.RefreshIdCard, function(recvCharIdList)
    local charIdList = recvCharIdList
    if not charIdList or charIdList.count == 0 then
      logError("charIdList is nil or empty")
      return
    end
    for i = 0, charIdList.count do
      local uuid = charIdList[i]
      local entityVm = Z.VMMgr.GetVM("entity")
      local charID = entityVm.UuidToEntId(uuid)
      logError("uuid = " .. uuid .. "  charID = " .. charID)
    end
  end)
end

return ret
