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
end

return ret
