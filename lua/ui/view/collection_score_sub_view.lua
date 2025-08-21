local UI = Z.UI
local super = require("ui.ui_subview_base")
local Collection_score_subView = class("Collection_score_subView", super)
local loopListView = require("ui.component.loop_list_view")
local score_item = require("ui.component.fashion.fashion_collection_item")
E.FashionCollectionScoreType = {
  Mission = 1,
  Cycle = 2,
  Collection = 3
}
local collection_list_bg = {
  "collection_list_on",
  "collection_list_off"
}
local collectIconPath = "ui/atlas/collection/"
local collection_icon = {
  [E.FashionCollectionScoreType.Mission] = {
    "collection_icon_1",
    "collection_icon_1_1"
  },
  [E.FashionCollectionScoreType.Cycle] = {
    "collection_icon_2",
    "collection_icon_2_1"
  },
  [E.FashionCollectionScoreType.Collection] = {
    "collection_icon_3",
    "collection_icon_3_1"
  }
}
local collection_type_name = {
  [E.FashionCollectionScoreType.Mission] = "CollectScoreMission",
  [E.FashionCollectionScoreType.Cycle] = "CollectScoreCycle",
  [E.FashionCollectionScoreType.Collection] = "CollectScoreCollection"
}

function Collection_score_subView:ctor(parent)
  self.uiBinder = nil
  self.parentNode_ = parent
  super.ctor(self, "collection_score_sub", "collection/collection_score_sub", UI.ECacheLv.None)
end

function Collection_score_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_score.node_eff)
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_integral1.node_eff)
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_integral2.node_eff)
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_integral3.node_eff)
  self:onStartAnimShow()
  self.collectionVM_ = Z.VMMgr.GetVM("collection")
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_item, score_item, "collection_list_tpl")
  self.loopList_:Init({})
  self.curSelectType_ = E.FashionCollectionScoreType.Mission
  self.uiBinder.lab_tips.text = ""
  self:refreshCollectionScore()
  self:refreshCollectionSelectIcon()
  self:refreshViewData()
  self:bindEvent()
end

function Collection_score_subView:OnDeActive()
  self.loopList_:UnInit()
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_score.node_eff)
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_integral1.node_eff)
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_integral2.node_eff)
  self.parentNode_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_integral3.node_eff)
  self.uiBinder.node_score.node_eff:SetEffectGoVisible(false)
  self:unBindEvent()
  if self.cycleTimer then
    self.cycleTimer:Stop()
    self.cycleTimer = nil
  end
  self.timerMgr:Clear()
end

function Collection_score_subView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Collection.FashionBenefitChange, self.refreshViewData, self)
  Z.EventMgr:Add(Z.ConstValue.Collection.FashionCollectionPointChange, self.refreshCollectPoint, self)
end

function Collection_score_subView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Collection.FashionBenefitChange, self.refreshViewData, self)
  Z.EventMgr:Remove(Z.ConstValue.Collection.FashionCollectionPointChange, self.refreshCollectPoint, self)
end

function Collection_score_subView:refreshViewData()
  self:refreshVIPScoreInfo()
  self:refreshScore()
  self:onSelectCollectionType()
end

function Collection_score_subView:refreshVIPScoreInfo()
  Z.CollectionScoreHelper.RefreshCollectionScoreSlider(self.uiBinder.node_score)
  Z.CollectionScoreHelper.RefreshCollectionScoreLevel(self.uiBinder.node_score)
end

function Collection_score_subView:refreshCollectionScore()
  self:refreshCollectionScoreByType(self.uiBinder.node_integral1, E.FashionCollectionScoreType.Mission)
  self:refreshCollectionScoreByType(self.uiBinder.node_integral2, E.FashionCollectionScoreType.Cycle)
  self:refreshCollectionScoreByType(self.uiBinder.node_integral3, E.FashionCollectionScoreType.Collection)
end

function Collection_score_subView:refreshCollectionScoreByType(uiBinder, type)
  local name = Lang(collection_type_name[type])
  uiBinder.lab_integral_select.text = name
  uiBinder.lab_integral_normal.text = name
  uiBinder.btn_select:AddListener(function()
    self.curSelectType_ = type
    self:onSelectCollectionType()
    self:refreshCollectionSelectIcon()
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_0)
  end)
end

function Collection_score_subView:refreshScore()
  local missionScore = Z.CollectionScoreHelper.GetScoreByType(E.FashionCollectionScoreType.Mission)
  self.uiBinder.node_integral1.lab_score_on.text = missionScore
  self.uiBinder.node_integral1.lab_score_off.text = missionScore
  local cycleScore = Z.CollectionScoreHelper.GetScoreByType(E.FashionCollectionScoreType.Cycle)
  self.uiBinder.node_integral2.lab_score_on.text = cycleScore
  self.uiBinder.node_integral2.lab_score_off.text = cycleScore
  local collectionScore = Z.CollectionScoreHelper.GetScoreByType(E.FashionCollectionScoreType.Collection)
  self.uiBinder.node_integral3.lab_score_on.text = collectionScore
  self.uiBinder.node_integral3.lab_score_off.text = collectionScore
  local missionFailureScore = Z.CollectionScoreHelper.GetFailureScoreByType(E.FashionCollectionScoreType.Mission)
  if missionFailureScore == 0 then
    self.uiBinder.node_integral1.lab_failure_select.text = ""
    self.uiBinder.node_integral1.lab_failure_normal.text = ""
  else
    local tips = Lang("CollectionScoreFailureTips", {val = missionFailureScore})
    self.uiBinder.node_integral1.lab_failure_select.text = tips
    self.uiBinder.node_integral1.lab_failure_normal.text = tips
  end
  if self.cycleTimer then
    self.cycleTimer:Stop()
    self.cycleTimer = nil
  end
  self:refreshCollectionCycleFailure()
  self.cycleTimer = self.timerMgr:StartTimer(function()
    self:refreshCollectionCycleFailure()
  end, -1, 1)
  local collectionFailureScore = Z.CollectionScoreHelper.GetFailureScoreByType(E.FashionCollectionScoreType.Collection)
  if collectionFailureScore == 0 then
    self.uiBinder.node_integral3.lab_failure_select.text = ""
    self.uiBinder.node_integral3.lab_failure_normal.text = ""
  else
    local tips = Lang("CollectionScoreFailureTips", {val = collectionFailureScore})
    self.uiBinder.node_integral3.lab_failure_select.text = tips
    self.uiBinder.node_integral3.lab_failure_normal.text = tips
  end
end

function Collection_score_subView:refreshCollectionCycleFailure()
  local cycleFailureScore = Z.CollectionScoreHelper.GetFailureScoreByType(E.FashionCollectionScoreType.Cycle)
  if cycleFailureScore == 0 then
    self.uiBinder.node_integral2.lab_failure_select.text = ""
    self.uiBinder.node_integral2.lab_failure_normal.text = ""
  else
    local tips = Lang("CollectionCycleScoreFailureTips", {val = cycleFailureScore})
    self.uiBinder.node_integral2.lab_failure_select.text = tips
    self.uiBinder.node_integral2.lab_failure_normal.text = tips
  end
end

function Collection_score_subView:refreshCollectionSelectIcon()
  self:refreshSelectBg(self.uiBinder.node_integral1, E.FashionCollectionScoreType.Mission)
  self:refreshSelectBg(self.uiBinder.node_integral2, E.FashionCollectionScoreType.Cycle)
  self:refreshSelectBg(self.uiBinder.node_integral3, E.FashionCollectionScoreType.Collection)
end

function Collection_score_subView:refreshSelectBg(uiBinder, type)
  local isSelect = self.curSelectType_ == type
  local index = isSelect and 1 or 2
  uiBinder.rimg_bg:SetImage(string.zconcat(Z.ConstValue.Collection.CollectionTextureIconPath, collection_list_bg[index]))
  uiBinder.img_icon:SetImage(string.zconcat(collectIconPath, collection_icon[type][index]))
  uiBinder.Ref:SetVisible(uiBinder.node_num_select, isSelect)
  uiBinder.Ref:SetVisible(uiBinder.node_num_normal, not isSelect)
  uiBinder.Ref:SetVisible(uiBinder.lab_failure_select, isSelect)
  uiBinder.Ref:SetVisible(uiBinder.lab_failure_normal, not isSelect)
  uiBinder.Ref:SetVisible(uiBinder.lab_integral_select, isSelect)
  uiBinder.Ref:SetVisible(uiBinder.lab_integral_normal, not isSelect)
end

function Collection_score_subView:onSelectCollectionType()
  if self.curSelectType_ == E.FashionCollectionScoreType.Mission then
    self:showMissionData()
  elseif self.curSelectType_ == E.FashionCollectionScoreType.Cycle then
    self:showCycleData()
  elseif self.curSelectType_ == E.FashionCollectionScoreType.Collection then
    self:showCollectionData()
  end
end

local sortFunc = function(left, right)
  return left.row.Sort < right.row.Sort
end

function Collection_score_subView:showMissionData()
  self.uiBinder.node_schedule.Ref.UIComp:SetVisible(false)
  self.uiBinder.loop_item_ref:SetOffsetMin(-80, 92)
  self.uiBinder.loop_item_ref:SetWidth(784)
  local missionList = {}
  for _, row in pairs(Z.TableMgr.GetTable("FashionTargetTableMgr").GetDatas()) do
    missionList[#missionList + 1] = {
      row = row,
      type = E.FashionCollectionScoreType.Mission
    }
  end
  table.sort(missionList, sortFunc)
  self.loopList_:RefreshListView(missionList, false)
  self.uiBinder.lab_tips.text = Lang("CollectionScoreMissionTips", {
    val1 = Z.CollectionScoreHelper.GetScoreByType(E.FashionCollectionScoreType.Mission),
    val2 = Z.ContainerMgr.CharSerialize.fashionBenefit.maxPoints or 0
  })
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #missionList == 0)
end

function Collection_score_subView:showCycleData()
  self.uiBinder.node_schedule.Ref.UIComp:SetVisible(false)
  self.uiBinder.loop_item_ref:SetOffsetMin(-80, 92)
  self.uiBinder.loop_item_ref:SetWidth(784)
  local list = Z.ContainerMgr.CharSerialize.fashionBenefit.collectionHistory
  local cycleList = {}
  for i = #list, 1, -1 do
    cycleList[#cycleList + 1] = {
      data = list[i],
      type = E.FashionCollectionScoreType.Cycle
    }
  end
  self.loopList_:RefreshListView(cycleList, false)
  self.uiBinder.lab_tips.text = Lang("CollectionScoreCycleTips")
  self.uiBinder.lab_empty.text = Lang("NoWayObtainPoints")
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #cycleList == 0)
end

function Collection_score_subView:showCollectionData()
  self.uiBinder.node_schedule.Ref.UIComp:SetVisible(true)
  self.uiBinder.loop_item_ref:SetOffsetMin(-80, 220)
  self.uiBinder.loop_item_ref:SetWidth(784)
  self:refreshCollectPoint()
  local collectionList = {}
  local fashionReward = Z.ContainerMgr.CharSerialize.fashion.fashionReward
  for id, _ in pairs(fashionReward) do
    local row = Z.TableMgr.GetTable("FashionCollectTableMgr").GetRow(id, true)
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local awardList = awardPreviewVm.GetAllAwardPreListByIds(row.AwardId)
    local awardCount = 0
    for i = 1, #awardList do
      if awardList[i].awardId == Z.Global.FashionLevelItemId then
        awardCount = awardList[i].awardNum
        break
      end
    end
    if row and 0 < awardCount then
      collectionList[#collectionList + 1] = {
        id = id,
        type = E.FashionCollectionScoreType.Collection
      }
    end
  end
  self.loopList_:RefreshListView(collectionList, false)
  self.uiBinder.lab_tips.text = Lang("CollectionScoreCollectionTips")
  self.uiBinder.lab_empty.text = Lang("NoWayObtainCollectPoints")
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #collectionList == 0)
end

function Collection_score_subView:refreshCollectPoint()
  Z.CollectionScoreHelper.RefreshCollectionScore(self.uiBinder.node_schedule)
end

function Collection_score_subView:onStartAnimShow()
  self.uiBinder.node_score.node_eff:SetEffectGoVisible(true)
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

return Collection_score_subView
