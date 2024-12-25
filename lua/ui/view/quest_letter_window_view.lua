local super = require("ui.ui_view_base")
local quest_letter_window = class("quest_letter_window", super)

function quest_letter_window:ctor()
  super.ctor(self, "quest_letter_window")
  
  function self.exitUIFunc_()
    if not Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
      return
    end
    if Z.UIMgr:GetFocusViewConfigKey() == self.viewConfigKey then
      return
    end
    Z.UIMgr:CloseView("quest_letter_window")
  end
end

function quest_letter_window:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  local msgItem = self.viewData
  local messageRow = msgItem.config
  local decodedName = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(messageRow.ChatName, msgItem.param))
  self.uiBinder.lab_title.text = decodedName
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.contents = Z.RichTextHelper.ParseTextWithImages(messageRow.Content)
  Z.InputMgr:AddInputEventDelegate(self.exitUIFunc_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.ExitUI)
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(self.contents) do
      local path, binder
      if value.contentType == E.RichTextContentType.Image then
        path = GetLoadAssetPath("QuestLetterImageItem")
        binder = self:AsyncLoadUiUnit(path, tostring(index), self.uiBinder.group_content, self.cancelSource:CreateToken())
        if binder then
          binder.rimg:SetImage(value.content)
        end
      elseif value.contentType == E.RichTextContentType.Text then
        path = GetLoadAssetPath("QuestLetterTextItem")
        binder = self:AsyncLoadUiUnit(path, tostring(index), self.uiBinder.group_content, self.cancelSource:CreateToken())
        if binder then
          binder.lab_content.text = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(value.content, msgItem.param))
        end
      end
    end
  end)()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("quest_letter_window")
  end)
end

function quest_letter_window:OnRefresh()
  local msgItem = self.viewData
  local messageRow = msgItem.config
  self:playVoice(messageRow)
end

function quest_letter_window:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.InputMgr:RemoveInputEventDelegate(self.exitUIFunc_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.ExitUI)
  if self.eventId_ then
    Z.AudioMgr:StopPlayingEvent(self.eventId_, 0.5)
  end
  self.eventId_ = nil
end

function quest_letter_window:playVoice(config)
  if config and config.VoiceEventName and config.VoiceControlEvent then
    self.eventId_ = Z.AudioMgr:PlayExternalVoiceWithEndCallback(config.VoiceEventName, config.VoiceControlEvent)
  end
end

return quest_letter_window
