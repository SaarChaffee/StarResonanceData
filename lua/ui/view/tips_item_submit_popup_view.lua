local UI = Z.UI
local super = require("ui.ui_view_base")
local ItemClass = require("common.item_binder")
local Tips_item_submit_popupView = class("Tips_item_submit_popupView", super)

function Tips_item_submit_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_item_submit_popup")
  self.submitVM_ = Z.VMMgr.GetVM("item_submit")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function Tips_item_submit_popupView:OnActive()
  self.itemClassDict_ = {}
  self.submitType_ = self.viewData.SubmitType
  self:AddClick(self.uiBinder.btn_cancel, function()
    self:closeView()
  end)
  self:AddClick(self.uiBinder.cont_submit, function()
    if self.uiBinder.cont_submit.IsDisabled then
      Z.TipsVM.ShowTipsLang(100002)
    elseif self.submitType_ == E.TalkItemSubmitType.Submit then
      Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.TalkSubmitItemCheck)
    else
      Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.TalkShowItemCheck)
    end
  end)
  self:refreshAll()
  if self.submitType_ == E.TalkItemSubmitType.Submit then
    Z.EventMgr:Add(Z.ConstValue.NpcTalk.TalkSubmitItemSuccess, self.onSubmitItemSuccess, self)
  else
    Z.EventMgr:Add(Z.ConstValue.NpcTalk.TalkShowItemSuccess, self.onShowItemSuccess, self)
  end
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemCountChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.OnSkipTalk, self.onSkipTalk, self)
end

function Tips_item_submit_popupView:closeView()
  local talkData = Z.DataMgr.Get("talk_data")
  local flowId = talkData:GetTalkCurFlow()
  Z.EPFlowBridge.StopFlow(flowId)
  self.submitVM_.CloseItemSubmitView()
end

function Tips_item_submit_popupView:OnDeActive()
  for _, item in pairs(self.itemClassDict_) do
    item:UnInit()
  end
  self.itemClassDict_ = nil
end

function Tips_item_submit_popupView:refreshAll()
  self:initItemUI()
  self:refreshSubmitBtn()
  local title, btnText
  if self.submitType_ == E.TalkItemSubmitType.Submit then
    title = Lang("TalkSubmitItem")
    btnText = Lang("Submit")
  else
    title = Lang("TalkShowItem")
    btnText = Lang("Show")
  end
  self.uiBinder.lab_name.text = title
  self.uiBinder.lab_content.text = btnText
end

function Tips_item_submit_popupView:initItemUI()
  local dataList = self:getItemDataList()
  local prefabPath = self.uiBinder.prefab_cache:GetString("item")
  Z.CoroUtil.create_coro_xpcall(function()
    for _, data in ipairs(dataList) do
      local configId = data.ConfigId
      local ownNum = self.itemsVM_.GetItemTotalCount(configId)
      local unit = self:AsyncLoadUiUnit(prefabPath, configId, self.uiBinder.node_item_list)
      if unit then
        local item = ItemClass.new(self)
        local info = {
          uiBinder = unit,
          configId = configId,
          isSquareItem = true,
          labType = E.ItemLabType.Expend,
          lab = ownNum,
          expendCount = data.Num,
          goToCallFunc = function()
            self:closeView()
          end
        }
        item:Init(info)
        self.itemClassDict_[configId] = item
      end
    end
  end)()
end

function Tips_item_submit_popupView:getItemDataList()
  local talkData = Z.DataMgr.Get("talk_data")
  local flowId = talkData:GetTalkCurFlow()
  local dataList
  if self.submitType_ == E.TalkItemSubmitType.Submit then
    dataList = talkData:GetFlowSubmitItem(flowId)
  else
    dataList = talkData:GetFlowShowItem(flowId)
  end
  return dataList
end

function Tips_item_submit_popupView:refreshSubmitBtn()
  local isEnough = true
  local dataList = self:getItemDataList()
  for _, data in ipairs(dataList) do
    local ownNum = self.itemsVM_.GetItemTotalCount(data.ConfigId)
    if ownNum < data.Num then
      isEnough = false
      break
    end
  end
  self.uiBinder.cont_submit.IsDisabled = not isEnough
end

function Tips_item_submit_popupView:onSkipTalk()
  self.submitVM_.CloseItemSubmitView()
end

function Tips_item_submit_popupView:onSubmitItemSuccess()
  Z.EPFlowBridge.OnLuaFunctionCallback("OPEN_TALK_ITEM_SUBMIT")
  self.submitVM_.CloseItemSubmitView()
end

function Tips_item_submit_popupView:onShowItemSuccess()
  Z.EPFlowBridge.OnLuaFunctionCallback("OPEN_TALK_ITEM_SHOW")
  self.submitVM_.CloseItemSubmitView()
end

function Tips_item_submit_popupView:onItemCountChange(changeItem)
  self:refreshSubmitBtn()
  local item = self.itemClassDict_[changeItem.configId]
  if item then
    local ownNum = self.itemsVM_.GetItemTotalCount(changeItem.configId)
    item:SetExpendCount(ownNum)
  end
end

function Tips_item_submit_popupView:OnRefresh()
  self:startAnimatedShow()
end

function Tips_item_submit_popupView:startAnimatedShow()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

return Tips_item_submit_popupView
