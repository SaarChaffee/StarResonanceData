local super = require("ui.ui_view_base")
local Cutscene_mainView = class("Cutscene_mainView", super)
local questTaskBtnCom = require("ui/view/quest_task/quest_task_btns_com")

function Cutscene_mainView:ctor()
  self.panel = nil
  super.ctor(self, "cutscene_main")
  self.vm_ = Z.VMMgr.GetVM("cutscene")
  self.quest_task_btn_com_ = questTaskBtnCom.new()
  self.uiBinder = nil
end

function Cutscene_mainView:OnActive()
  self.quest_task_btn_com_:Init(E.QuestTaskBtnsSource.Cutscene, self.uiBinder.talk_btns_binder, self.viewConfigKey)
end

function Cutscene_mainView:OnDeActive()
  self.quest_task_btn_com_:UnInit()
end

function Cutscene_mainView:OnRefresh()
  self.quest_task_btn_com_:Refresh(self.viewData.IsInFlow, self.viewData.CutsceneId)
  self:refreshPromptText()
end

function Cutscene_mainView:refreshPromptText()
  self.uiBinder.talk_btns_binder.lab_prompt.text = Lang("Long_Press_Skip_PromptDefault")
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCode = keyVM.GetKeyCodeListByKeyId(1)[1]
  if keyCode then
    local contrastRow = Z.TableMgr.GetRow("SetKeyboardContrastTableMgr", keyCode)
    if contrastRow then
      self.uiBinder.talk_btns_binder.lab_prompt.text = Lang("Long_Press_Skip_Prompt", {
        val = contrastRow.Keyboard
      })
    end
  end
end

return Cutscene_mainView
