local super = require("ui.component.loop_list_view_item")
local loop_list_view = require("ui/component/loop_list_view")
local rewardItem_ = require("ui/component/explore_monster/explore_monster_reward_item")
local ColorGreen = Color.New(0.792156862745098, 0.9137254901960784, 0.5529411764705883, 0.5)
local ColorWhite = Color.New(1, 1, 1, 0.5)
local imgPathList = {
  "ui/atlas/explore_monster/explore_monster_list_get",
  "ui/atlas/explore_monster/explore_monster_list_not_reach"
}
local ExploreMonsterGradeItem = class("ExploreMonsterGradeItem", super)

function ExploreMonsterGradeItem:ctor()
end

function ExploreMonsterGradeItem:OnInit()
  self.parentUIView_ = self.parent.UIView
  self:AddAsyncListener(self.uiBinder.btn_get, function()
    local data = self:GetCurData()
    self.parentUIView_.vm_.GetHuntLevelAward(data.Level, function(success)
      if success then
        self.parentUIView_:RefreshRewardList()
      end
    end, self.parentUIView_.cancelSource:CreateToken())
  end)
  local dataList_ = {}
  self.rewardScrollRect_ = loop_list_view.new(self, self.uiBinder.loop_list, rewardItem_, "com_item_square_8")
  self.rewardScrollRect_:Init(dataList_)
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
end

function ExploreMonsterGradeItem:OnRefresh(data)
  self.uiBinder.lab_grade.text = data.Level
  local str_ = ""
  local curLevel_ = self.parentUIView_.vm_.GetMonsterHuntLevel()
  local showLevel_ = data.ShowLevel
  local canShow_ = curLevel_ >= showLevel_
  local hasReceive_ = false
  local receiveData_ = self.parentUIView_.vm_.GetHuntLevelAwardReceiveState()
  local curData_ = receiveData_.levelAwardFlag[data.Level]
  if curData_ ~= nil then
    hasReceive_ = curData_ == E.MonsterHuntTargetAwardState.Receive
  end
  if canShow_ then
    str_ = data.ExtraText
    local awardId = data.ItemAward
    local awardList_ = {}
    if 0 < awardId then
      awardList_ = self.awardPreviewVm_.GetAllAwardPreListByIds(awardId)
    end
    for _, value in ipairs(awardList_) do
      value.beGet = hasReceive_
    end
    self.rewardScrollRect_:RefreshListView(awardList_)
  else
    str_ = Lang("MonsterHuntLevelLimitInfo", {val = showLevel_})
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, canShow_)
  self.uiBinder.lab_content.text = str_
  self:refreshBtnState(curLevel_, hasReceive_)
end

function ExploreMonsterGradeItem:OnSelected(isSelected)
end

function ExploreMonsterGradeItem:OnUnInit()
  self.rewardScrollRect_:UnInit()
  self.rewardScrollRect_ = nil
end

function ExploreMonsterGradeItem:OnReset()
  self.isSelected_ = false
end

function ExploreMonsterGradeItem:AddAsyncClick(comp, func)
  self.parentUIView_:AddAsyncClick(comp, func)
end

function ExploreMonsterGradeItem:refreshBtnState(curLevel, hasReceive)
  local d_ = self:GetCurData()
  local levelIsEnough_ = curLevel >= d_.Level
  local hasReceive_ = hasReceive
  local canShowGetBtn_ = levelIsEnough_ == true and hasReceive_ == false
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_get, canShowGetBtn_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_completed, levelIsEnough_ == true and hasReceive_ == true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_underway, levelIsEnough_ == false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mark, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_base4, levelIsEnough_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_base4_gray, not levelIsEnough_)
end

return ExploreMonsterGradeItem
