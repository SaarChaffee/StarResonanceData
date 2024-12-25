local NoticeTipPopItem = class("NoticeTipPopItem")
local bgNames = {
  [0] = "bg_0",
  [1] = "bg_1",
  [2] = "bg_2"
}

function NoticeTipPopItem:ctor(uiBinder, parent)
  self.uiBinder_ = uiBinder
  self.goName_ = self.uiBinder_.Ref.name
  self.transform_ = self.uiBinder_.Trans
  self.parent_ = parent
  self.timerMgr_ = self.parent_.timerMgr
  self.msgItem_ = nil
  self.OnEnd = nil
  self.timers_ = {}
  self.cancelTokens_ = nil
end

function NoticeTipPopItem:Init(msgItem)
  self.msgItem_ = msgItem
  self.config = self.msgItem_.config
  self.transform_:SetLocalPos(0, 0, 0)
  self.uiBinder_.Ref.UIComp:SetVisible(true)
  local typeS = self.config.Type % 10
  local bgCheckIndex = 0
  self.bgCurIndex_ = 0
  local name = bgNames[bgCheckIndex]
  repeat
    name = bgNames[bgCheckIndex]
    if self.uiBinder_[name] ~= nil then
      local curState = typeS == bgCheckIndex
      self.uiBinder_[name].Ref.UIComp:SetVisible(curState)
      if curState == true then
        self.bgCurIndex_ = bgCheckIndex
      end
    end
    bgCheckIndex = bgCheckIndex + 1
  until self.uiBinder_[name] == nil
  local bgBinder = self.uiBinder_[bgNames[self.bgCurIndex_]]
  local labInfo = bgBinder.lab_info
  local contentSizeFitter = bgBinder.lab_info_content_size
  labInfo.text = ""
  if contentSizeFitter then
    contentSizeFitter:SetLayoutHorizontal()
  end
  self.uiBinder_.Trans:SetScale(1, 0)
  self.uiBinder_.dotween:ClearAll()
  Z.CoroUtil.create_coro_xpcall(function()
    self.cancelTokens_ = self.parent_.cancelSource:CreateToken()
    local text = string.gsub(self.msgItem_.content, "\\n", "\n")
    labInfo.text = text
    self.uiBinder_.dotween:DoScale(Vector3.New(1, 1, 1), 0.3)
    Z.Delay(self.config.DurationTime, self.cancelTokens_)
    self.uiBinder_.dotween:DoScale(Vector3.New(1, 0, 1), 0.3)
    self.uiBinder_.Ref.UIComp:SetVisible(false)
    self:UnInit()
  end)()
end

function NoticeTipPopItem:UnInit(ForceStop)
  self.msgItem_ = nil
  Z.CancelSource.ReleaseToken(self.cancelTokens_)
  self.cancelTokens_ = nil
  self.uiBinder_.dotween:ClearAll()
  if self.OnEnd then
    self.OnEnd(ForceStop)
  end
end

function NoticeTipPopItem:ForceStop()
  self.uiBinder_.Ref.UIComp:SetVisible(false)
  self:UnInit(true)
end

function NoticeTipPopItem:PopToIndexPosition(toIndex)
  self.transform_:SetLocalPos(0, toIndex * 35, 0)
end

return NoticeTipPopItem
