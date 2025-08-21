local HandbookVM = {}
local handbookDefine = require("ui.model.handbook_define")

function HandbookVM.OpenMainView()
  Z.UIMgr:OpenView("handbook_main_window")
end

function HandbookVM.OpenHandbookDictionaries()
  Z.UIMgr:OpenView("handbook_dictionaries_window")
end

function HandbookVM.OpenHandbookReading()
  Z.UIMgr:OpenView("handbook_read_window")
end

function HandbookVM.OpenHandbookPostcard()
  Z.UIMgr:OpenView("handbook_postcard_window")
end

function HandbookVM.OpenHandbookMonthCard()
  Z.UIMgr:OpenView("monthly_reward_card_list")
end

function HandbookVM.OpenHandbookCharacter()
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, "handbook_character_window", function()
    Z.UnrealSceneMgr:SwitchGroupReflection(true)
    Z.UIMgr:OpenView("handbook_character_window")
  end, Z.ConstValue.UnrealSceneConfigPaths.Role)
end

function HandbookVM.IsNew(type, id)
  local isUnlock = HandbookVM.IsUnlock(type, id)
  if not isUnlock then
    return false
  end
  local key = string.format("%s_%s", type, id)
  local isNew = Z.DataMgr.Get("handbook_data").LocalSave[key] == nil
  return isNew
end

function HandbookVM.SetNotNew(type, id)
  local isUnlock = HandbookVM.IsUnlock(type, id)
  if not isUnlock then
    return
  end
  local key = string.format("%s_%s", type, id)
  Z.DataMgr.Get("handbook_data").LocalSave[key] = false
  Z.DataMgr.Get("handbook_data"):SaveLocalSave()
end

function HandbookVM.IsUnlock(type, id)
  local isUnlock = false
  if type == handbookDefine.HandbookType.Dictionary then
    isUnlock = Z.ContainerMgr.CharSerialize.handbookData.unlockNoteDictionaryMap[id] ~= nil
  elseif type == handbookDefine.HandbookType.Read then
    isUnlock = Z.ContainerMgr.CharSerialize.handbookData.unlockNoteReadingBookMap[id] ~= nil
  elseif type == handbookDefine.HandbookType.Character then
    isUnlock = Z.ContainerMgr.CharSerialize.handbookData.unlockNoteImportantRoleMap[id] ~= nil
  elseif type == handbookDefine.HandbookType.Postcard then
    isUnlock = Z.ContainerMgr.CharSerialize.handbookData.unlockNotePostCardMap[id] ~= nil
  elseif type == handbookDefine.HandbookType.MonthlyCard then
    isUnlock = Z.ContainerMgr.CharSerialize.handbookData.unlockNoteMonthCardMap[id] ~= nil
  end
  return isUnlock
end

function HandbookVM.GetUnitUISortState(type, key)
  local state = 0
  if HandbookVM.IsUnlock(type, key) then
    if HandbookVM.IsNew(type, key) then
      state = handbookDefine.UnitState.IsNew
    else
      state = handbookDefine.UnitState.IsUnlock
    end
  else
    state = handbookDefine.UnitState.IsLock
  end
  return state
end

return HandbookVM
