local super = require("ui.ui_view_base")
local quest_letter_window = class("quest_letter_window", super)

function quest_letter_window:ctor()
  super.ctor(self, "quest_letter_window")
end

function quest_letter_window:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  local msgItem = self.viewData
  local messageRow = msgItem.config
  local tipsType = math.floor(messageRow.Type / 10)
  local colorStyle = "White"
  if tipsType == E.TipsType.QuestLetterWithBackground then
    colorStyle = "QuestLetter1Content"
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_info, tipsType == E.TipsType.QuestLetterWithBackground)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_middle, tipsType ~= E.TipsType.QuestLetterWithBackground)
  local decodedName = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(messageRow.ChatName, msgItem.param))
  self.uiBinder.lab_title.text = decodedName
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  local content = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(messageRow.Content, msgItem.param))
  self.contents = Z.RichTextHelper.ParseTextWithImages(content)
  if tipsType == E.TipsType.QuestLetterWithBackground then
    self.uiBinder.lab_content.text = content
  else
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
            local content = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(value.content, msgItem.param))
            binder.lab_content.text = Z.RichTextHelper.ApplyStyleTag(content, colorStyle)
          end
        end
      end
    end)()
  end
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
  if self.eventId_ then
    Z.AudioMgr:StopPlayingEvent(self.eventId_, 0.5)
  end
  self.eventId_ = nil
  Z.EPFlowBridge.OnLuaFunctionCallback(Z.ConstValue.Eplow.MessageViewClosed)
end

function quest_letter_window:playVoice(config)
  if config and config.VoiceEventName and config.VoiceControlEvent then
    self.eventId_ = Z.AudioMgr:PlayExternalVoiceWithEndCallback(config.VoiceEventName, config.VoiceControlEvent)
  end
end

function quest_letter_window:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.ExitUI then
    if not Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      Z.Delay(0.1, self.cancelSource:CreateToken())
      Z.UIMgr:CloseView("quest_letter_window")
    end)()
  end
end

return quest_letter_window
