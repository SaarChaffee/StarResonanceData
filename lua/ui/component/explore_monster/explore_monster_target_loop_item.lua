local super = require("ui.component.loop_list_view_item")
local loop_list_view = require("ui/component/loop_list_view")
local rewardItem_ = require("ui/component/explore_monster/explore_monster_reward_item")
local ColorGreen = Color.New(0.792156862745098, 0.9137254901960784, 0.5529411764705883, 0.5)
local ColorWhite = Color.New(1, 1, 1, 0.5)
local iconpath1_ = "ui/atlas/explore_monster/explore_monster_btn_box"
local iconpath2_ = "ui/atlas/pivot/pivot_img_treasure_light"
local ExploreMonsterTargetItem = class("ExploreMonsterTargetItem", super)

function ExploreMonsterTargetItem:ctor()
end

function ExploreMonsterTargetItem:OnInit()
  self.parentUIView_ = self.parent.UIView
  self:AddAsyncListener(self.uiBinder.btn_square_new, function()
    if self.canReceive_ == true then
      local d_ = self:GetCurData()
      local targetId_ = d_.index
      self.parentUIView_.vm_.GetHuntTargetAward(self.parentUIView_.curSelectMonsterData_.ExploreData.MonsterId, targetId_, function(success)
        if success then
          self.parentUIView_:OnReceiveTargetAward()
        end
      end, self.parentUIView_.cancelSource:CreateToken())
    end
  end)
  local dataList_ = {}
  self.rewardScrollRect_ = loop_list_view.new(self, self.uiBinder.loop_item, rewardItem_, "com_item_square_1_8")
  self.rewardScrollRect_:Init(dataList_)
end

function ExploreMonsterTargetItem:OnRefresh(data)
  local itemUnit = self.uiBinder
  local infoColor_, scheduleColor_ = ColorWhite, ColorWhite
  local infoStr_, scheduleStr_
  local countData = data.targetCountData
  local curtargetNum_ = 0
  local curData_
  if countData then
    curData_ = countData[data.index]
  end
  local receiveState_ = E.MonsterHuntTargetAwardState.Null
  local isFinish_ = false
  if curData_ then
    curtargetNum_ = curData_.targetNum
    receiveState_ = curData_.awardFlag
  end
  if 0 < curtargetNum_ then
    infoStr_ = data.cfg.TargetDes
    scheduleStr_ = curtargetNum_ .. "/" .. data.cfg.Num
    if curtargetNum_ >= data.cfg.Num then
      isFinish_ = true
    else
    end
  else
    local unlockcfg, preTarget_
    if data.unlock then
      preTarget_ = data.unlock
      unlockcfg = data.unlock.cfg
    end
    local unlockNum_ = 0
    if countData and unlockcfg then
      local preData_ = countData[preTarget_.index]
      if preData_ then
        unlockNum_ = preData_.targetNum
      end
    end
    if not unlockcfg or unlockNum_ >= unlockcfg.Num then
      infoStr_ = data.cfg.TargetDes
      scheduleStr_ = "0/" .. data.cfg.Num
    else
      infoStr_ = string.format(Lang("MonsterExploreTask"), data.unlockIndex)
    end
  end
  itemUnit.lab_digit.text = tostring(self.Index)
  local s_ = infoStr_
  if scheduleStr_ and 0 < string.len(scheduleStr_) then
    s_ = infoStr_ .. "\n" .. scheduleStr_
  end
  itemUnit.lab_info.text = s_
  self.canReceive_ = isFinish_ == true and receiveState_ == E.MonsterHuntTargetAwardState.Get
  local awardId = data.awardId
  local awardList_ = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardId)
  for _, value in ipairs(awardList_) do
    value.beGet = receiveState_ == E.MonsterHuntTargetAwardState.Receive
  end
  self.rewardScrollRect_:RefreshListView(awardList_)
  local hasReceiveAward_ = receiveState_ == E.MonsterHuntTargetAwardState.Receive
  if hasReceiveAward_ == false then
    local path = self.canReceive_ == true and iconpath2_ or iconpath1_
    self.uiBinder.img_icon:SetImage(path)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mark, hasReceiveAward_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.canReceive_ == true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_square_new, self.canReceive_ == true or not isFinish_)
  self:refreshBtnState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_finish, hasReceiveAward_)
end

function ExploreMonsterTargetItem:OnSelected(isSelected)
end

function ExploreMonsterTargetItem:OnUnInit()
  self.rewardScrollRect_:UnInit()
  self.rewardScrollRect_ = nil
end

function ExploreMonsterTargetItem:OnReset()
  self.isSelected_ = false
end

function ExploreMonsterTargetItem:AddAsyncClick(comp, func)
  self.parentUIView_:AddAsyncClick(comp, func)
end

function ExploreMonsterTargetItem:refreshBtnState()
  self.uiBinder.btn_square_new.interactable = self.canReceive_ == true
  self.uiBinder.img_receive.raycastTarget = self.canReceive_ == true
end

return ExploreMonsterTargetItem
