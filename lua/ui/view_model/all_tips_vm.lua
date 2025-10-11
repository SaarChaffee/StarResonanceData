local AllTipsVM = {}
local AffixColor = {
  [1] = "#62b3ff",
  [2] = "#fd6c63",
  [3] = "#ffc26d"
}
E.TipsPopupStyle = {
  Small = 1,
  Medium = 2,
  Large = 3,
  ExtraLarge = 4
}
E.TipsPopupNodeType = {
  Title = 1,
  Line = 2,
  Desc = 3,
  DescList = 4,
  DescWithIconSubTitle = 5,
  Button = 6,
  ItemList = 7,
  ItemInfo = 8,
  MonsterList = 9,
  TitleBtn = 10,
  TitleIconBg = 11,
  ItemListFuncItem = 12,
  ProficiencyInfo = 13,
  IconDesc = 14,
  BdTagList = 15,
  SkillInfo = 16,
  RemainTime = 17,
  TalentSkill = 18,
  UnlockItemList = 19,
  UnlockItemList1 = 20,
  TalentSkillDetailInfo = 21,
  ObtainWay = 22,
  TalentSkillFullInfo = 23,
  Image = 24
}

function AllTipsVM.OpenSourceTips(configId, trans, itemUuid, extraParams)
  extraParams = extraParams or {}
  extraParams.isOpenSource = true
  return AllTipsVM.ShowItemTipsView(trans, configId, itemUuid, extraParams)
end

function AllTipsVM.OpenItemTipsView(viewData)
  if viewData == nil then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.GM.GMItemView, viewData.configId)
  viewData.isOpen = true
  local itemDatas = Z.DataMgr.Get("tips_data")
  local tipsId = itemDatas:AddItemTipsData(viewData)
  if tipsId == 0 then
    return 0
  end
  Z.UIMgr:OpenView("all_item_info_tips", nil)
  return tipsId
end

function AllTipsVM.CloseItemTipsView(tipsId)
  if not Z.UIMgr:IsActive("all_item_info_tips") then
    return
  end
  if not tipsId or tipsId == 0 then
    return
  end
  local itemDatas = Z.DataMgr.Get("tips_data")
  local viewData = {tipsId = tipsId, isOpen = false}
  itemDatas:AddItemTipsData(viewData)
  Z.UIMgr:OpenView("all_item_info_tips")
end

function AllTipsVM.SetItemTipsVisible(tipsId, isVisible)
  if not Z.UIMgr:IsActive("all_item_info_tips") then
    return
  end
  if not tipsId or tipsId == 0 then
    return
  end
  local itemDatas = Z.DataMgr.Get("tips_data")
  local viewData = {tipsId = tipsId, isVisible = isVisible}
  itemDatas:AddItemTipsData(viewData)
  Z.UIMgr:OpenView("all_item_info_tips")
end

function AllTipsVM.ShowItemTipsView(trans, configId, itemUuid, extraParams)
  extraParams = extraParams or {}
  local itemTipsViewData = {
    isResident = false,
    isShowBg = true,
    parentTrans = trans,
    configId = configId,
    itemUuid = itemUuid,
    posType = extraParams.posType or E.EItemTipsPopType.Bounds,
    posOffset = extraParams.posOffset,
    screenPosition = extraParams.screenPosition,
    isIgnoreItemClick = extraParams.isIgnoreItemClick,
    itemInfo = extraParams.itemInfo,
    isHideSource = extraParams.isHideSource,
    goToCallFunc = extraParams.goToCallFunc,
    closeCallBack = extraParams.closeCallBack,
    tipsBindPressCheckComp = extraParams.tipsBindPressCheckComp,
    isBind = extraParams.isBind,
    isOpenSource = extraParams.isOpenSource
  }
  if itemUuid and 0 < itemUuid then
    itemTipsViewData.showType = E.EItemTipsShowType.Default
  else
    itemTipsViewData.showType = E.EItemTipsShowType.OnlyClient
  end
  return AllTipsVM.OpenItemTipsView(itemTipsViewData)
end

function AllTipsVM.CloseAllNoResidentTips()
  Z.EventMgr:Dispatch(Z.ConstValue.CloseAllNoResidentTips)
end

function AllTipsVM.OpenCommonPopupInput(viewData)
  Z.UIMgr:OpenView("common_popup_input", viewData)
end

function AllTipsVM.IsNum(str)
  if not str and type(str) ~= "string" then
    return false
  end
  for i = 1, #str do
    local c = string.sub(str, i, i)
    if string.byte(c) < 48 or string.byte(c) > 57 then
      return false
    end
  end
  return true
end

function AllTipsVM.OpenMessageView(noticeTipParam)
  if noticeTipParam == nil then
    return
  end
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  local tipsData = Z.DataMgr.Get("tips_data")
  local cfgId
  if type(noticeTipParam.configId) == "number" then
    cfgId = noticeTipParam.configId
  elseif type(noticeTipParam.configId) == "string" then
    cfgId = tonumber(noticeTipParam.configId)
  end
  local msgCfg = Z.TableMgr.GetTable("MessageTableMgr").GetRow(cfgId)
  if msgCfg == nil then
    logError("show notice tip error config id not found:" .. tostring(cfgId))
    return
  end
  local tipsType = math.floor(msgCfg.Type / 10)
  local noticeTipsView = noticeTipData:GetNoticeViewConfigKey(tipsType)
  if noticeTipsView == nil then
    logError("No panel of the corresponding type exists : {0}", cfgId)
    return
  end
  local content = Z.TableMgr.DecodeLineBreak(msgCfg.Content)
  if noticeTipParam.content then
    content = noticeTipParam.content
  end
  noticeTipParam.placeholderParam = Z.Placeholder.SetMePlaceholder(noticeTipParam.placeholderParam)
  noticeTipParam.placeholderParam = Z.Placeholder.SetNpcPlaceholder(noticeTipParam.placeholderParam)
  noticeTipParam.placeholderParam = Z.Placeholder.SetPlayerSelfPronoun(noticeTipParam.placeholderParam)
  content = Z.Placeholder.Placeholder(content, noticeTipParam.placeholderParam)
  if msgCfg.ChatName ~= nil and msgCfg.ChatName ~= "" then
    noticeTipParam.placeholderParam = Z.Placeholder.SetMePlaceholder(noticeTipParam.placeholderParam)
    local chatName = Z.Placeholder.Placeholder(msgCfg.ChatName, noticeTipParam.placeholderParam)
    content = chatName .. Lang("colon") .. content
  end
  if tipsType ~= E.TipsType.PopTip and not noticeTipParam.HasAddSystemTipInfo then
    noticeTipParam.HasAddSystemTipInfo = true
    tipsData:AddSystemTipInfo(E.ESystemTipInfoType.MessageInfo, cfgId, content)
  end
  local tipsInfo = {
    config = msgCfg,
    content = content,
    viewType = tipsType,
    param = noticeTipParam.placeholderParam
  }
  AllTipsVM.addTips(tipsType, tipsInfo)
end

function AllTipsVM.OpenMessageViewByContext(context, tipsType, config, param)
  local tipsInfo = {
    config = config,
    content = context,
    viewType = tipsType,
    param = param
  }
  AllTipsVM.addTips(tipsType, tipsInfo)
end

function AllTipsVM.OpenMessageViewByContextAndConfig(context, config)
  local msgCfg = Z.TableMgr.GetTable("MessageTableMgr").GetRow(config)
  if msgCfg == nil then
    return
  end
  local tipsType = math.floor(msgCfg.Type / 10)
  local tipsInfo = {
    config = msgCfg,
    content = context,
    viewType = tipsType
  }
  AllTipsVM.addTips(tipsType, tipsInfo)
end

function AllTipsVM.OpenMessageViewByConfig(config)
  local msgCfg = Z.TableMgr.GetTable("MessageTableMgr").GetRow(config)
  if msgCfg == nil then
    return
  end
  local tipsType = math.floor(msgCfg.Type / 10)
  local tipsInfo = {
    config = msgCfg,
    content = msgCfg.Content,
    viewType = tipsType
  }
  AllTipsVM.addTips(tipsType, tipsInfo)
end

function AllTipsVM.addTips(tipsType, tipsInfo)
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  local noticeTipsView = noticeTipData:GetNoticeViewConfigKey(tipsType)
  if noticeTipsView == nil then
    logError("No panel of the corresponding type exists : {0}", tipsInfo.config.Id)
    return
  end
  if tipsType == E.TipsType.PopTip or tipsType == E.TipsType.DungeonGreenTips or tipsType == E.TipsType.DungeonRedTips then
    noticeTipData:EnqueuePopData(tipsInfo)
    Z.UIMgr:OpenView(noticeTipsView)
  elseif tipsType == E.TipsType.CopyMode or tipsType == E.TipsType.DungeonSpecialTips or tipsType == E.TipsType.DungeonChallengeWinTips or tipsType == E.TipsType.DungeonChallengeFailTips then
    noticeTipData:EnqueueTopPopData(tipsInfo)
  elseif tipsType == E.TipsType.Captions then
    noticeTipData:EnqueueNpcData(tipsInfo)
    Z.EventMgr:Dispatch("ShowNoticeCaption")
  elseif tipsType == E.TipsType.TalkInfo then
    Z.UIMgr:OpenView(noticeTipsView, tipsInfo)
  elseif tipsType == E.TipsType.BottomTips then
    Z.UIMgr:OpenView(noticeTipsView, tipsInfo)
  elseif tipsType == E.TipsType.MiddleTips then
    noticeTipData:EnqueueMiddlePopData(tipsInfo)
    Z.UIMgr:OpenView(noticeTipsView, tipsInfo)
  elseif tipsType == E.TipsType.QuestLetter or tipsType == E.TipsType.QuestLetterWithBackground then
    Z.UIMgr:OpenView(noticeTipsView, tipsInfo)
  end
end

function AllTipsVM.ShowTopPopTips(tipsInfo)
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  local noticeTipsView = noticeTipData:GetNoticeViewConfigKey(tipsInfo.viewType)
  if tipsInfo.viewType == E.TipsType.CopyMode then
    noticeTipData.Copy_tip = tipsInfo
    Z.UIMgr:OpenView(noticeTipsView)
  elseif tipsInfo.viewType == E.TipsType.DungeonChallengeWinTips or tipsInfo.viewType == E.TipsType.DungeonChallengeFailTips or tipsInfo.viewType == E.TipsType.DungeonSpecialTips or tipsInfo.viewType == E.TipsType.DungeonGreenTips or tipsInfo.viewType == E.TipsType.DungeonRedTips then
    Z.UIMgr:OpenView(noticeTipsView, tipsInfo)
  end
  noticeTipData.TopPopShowingState = true
end

function AllTipsVM.GetMessageContent(messageId, messageParam)
  local msgCfg = Z.TableMgr.GetTable("MessageTableMgr").GetRow(messageId)
  if msgCfg == nil then
    logError("show notice tip error config id not found:" .. messageId)
    return ""
  end
  local content = Z.TableMgr.DecodeLineBreak(msgCfg.Content)
  local placeholderParam = Z.Placeholder.SetMePlaceholder(messageParam)
  placeholderParam = Z.Placeholder.SetNpcPlaceholder(placeholderParam)
  placeholderParam = Z.Placeholder.SetPlayerSelfPronoun(placeholderParam)
  content = Z.Placeholder.Placeholder(content, placeholderParam)
  if msgCfg.ChatName ~= nil and msgCfg.ChatName ~= "" then
    placeholderParam = Z.Placeholder.SetMePlaceholder(placeholderParam)
    local chatName = Z.Placeholder.Placeholder(msgCfg.ChatName, placeholderParam)
    content = chatName .. Lang("colon") .. content
  end
  return content
end

function AllTipsVM.OpenViewById(configId, placeholderParam)
  local msg = {}
  msg.configId = configId
  if placeholderParam ~= nil then
    msg.placeholderParam = placeholderParam
  end
  AllTipsVM.OpenMessageView(msg)
end

function AllTipsVM.OpenViewByContent(content)
  local params = {}
  params.content = content
  params.configId = 1
  AllTipsVM.OpenMessageView(params)
end

function AllTipsVM.ShowTips(configIdOrContent, placeholderParam)
  if type(configIdOrContent) == "string" then
    local configId = string.gsub(configIdOrContent, " ", "")
    if AllTipsVM.IsNum(configId) then
      AllTipsVM.OpenViewById(tonumber(configId), placeholderParam)
      return
    end
    logError("MessageId={0}\228\184\141\229\173\152\229\156\168,\232\129\148\231\179\187\231\173\150\229\136\146\230\183\187\229\138\160", configId)
  elseif configIdOrContent == 0 then
    return
  elseif configIdOrContent == Z.PbEnum("EErrorCode", "ErrItemPackageGridNotEnough") then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("BackPackFull"), function()
      Z.VMMgr.GetVM("gotofunc").GoToFunc(E.BackpackFuncId.Backpack)
    end)
  else
    AllTipsVM.OpenViewById(configIdOrContent, placeholderParam)
  end
end

function AllTipsVM.ShowTipsLang(configIdOrLang, param)
  if type(configIdOrLang) == "string" then
    AllTipsVM.ShowTips(Lang(configIdOrLang), param)
  else
    AllTipsVM.ShowTips(configIdOrLang, param)
  end
end

function AllTipsVM.OpenGameBroadcast(message)
  Z.UIMgr:OpenView("tips_game_broadcast", message)
end

return AllTipsVM
