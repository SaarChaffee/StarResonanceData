local super = require("ui.service.service_base")
local BubbleService = class("BubbleService", super)

function BubbleService:OnInit()
end

function BubbleService:OnUnInit()
end

function BubbleService:OnLogin()
  function self.bubbleActDataChanged_(container, dirtyKeys)
    if dirtyKeys and dirtyKeys.bubbleInfo then
      Z.EventMgr:Dispatch(Z.ConstValue.Bubble.CurrentIdChanged)
    end
  end
  
  Z.ContainerMgr.CharSerialize.bubbleActData.Watcher:RegWatcher(self.bubbleActDataChanged_)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionBtnState, self.onRefreshFunctionBtnState, self)
end

function BubbleService:OnLogout()
  Z.ContainerMgr.CharSerialize.bubbleActData.Watcher:UnregWatcher(self.bubbleActDataChanged_)
  self.bubbleActDataChanged_ = nil
  Z.EventMgr:Remove(Z.ConstValue.RefreshFunctionBtnState, self.onRefreshFunctionBtnState, self)
end

function BubbleService:onRefreshFunctionBtnState()
  local bubbleVM = Z.VMMgr.GetVM("bubble")
  local bubbleData = Z.DataMgr.Get("bubble_data")
  local curBubbleId = bubbleData:GetCurBubbleId()
  if not curBubbleId or curBubbleId == 0 then
    return
  end
  local actTableRow = Z.TableMgr.GetTable("BubbleActTableMgr").GetRow(curBubbleId, true)
  if not actTableRow then
    return
  end
  if not Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(actTableRow.FunctionId, true) then
    Z.CoroUtil.create_coro_xpcall(function()
      bubbleVM:AsyncClearBubble()
    end)()
  end
end

return BubbleService
