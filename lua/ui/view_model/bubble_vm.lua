local BubbleVM = {}
local worldProxy = require("zproxy.world_proxy")

function BubbleVM:GetCurrentBubbleInfo()
  local bubbleData = Z.DataMgr.Get("bubble_data")
  local curBubbleId = bubbleData:GetCurBubbleId()
  if curBubbleId == 0 then
    return nil
  end
  local playData = Z.ContainerMgr.CharSerialize.bubbleActData.bubbleInfo
  if not playData or not playData[curBubbleId] then
    return nil
  end
  local actTableRow = Z.TableMgr.GetTable("BubbleActTableMgr").GetRow(curBubbleId, true)
  if not actTableRow then
    return nil
  end
  local tableRow = Z.TableMgr.GetTable("BubbleTableMgr").GetRow(actTableRow.BubbleId, true)
  if not tableRow then
    return nil
  end
  local bubbleInfo = playData[curBubbleId]
  return {tableData = tableRow, servicesData = bubbleInfo}
end

function BubbleVM:CheckBubbleInfo()
  local bubbleData = Z.DataMgr.Get("bubble_data")
  local curBubbleId = bubbleData:GetCurBubbleId()
  if curBubbleId == 0 then
    return false
  end
  local playData = Z.ContainerMgr.CharSerialize.bubbleActData
  if not playData or not playData.bubbleInfo[curBubbleId] then
    return false
  end
  local bubbleInfo = playData.bubbleInfo[curBubbleId]
  if not bubbleInfo then
    return false
  end
  return true
end

function BubbleVM:AsyncClearBubble(token)
  local bubbleData = Z.DataMgr.Get("bubble_data")
  bubbleData:SetCurBubbleId(0)
  local request = {bubbleActId = 0}
  local cancelSource = Z.CancelSource.Rent()
  worldProxy.EndBubbleAct(request, cancelSource:CreateToken())
  cancelSource:Recycle()
  Z.EventMgr:Dispatch(Z.ConstValue.Bubble.CurrentIdChanged)
end

return BubbleVM
