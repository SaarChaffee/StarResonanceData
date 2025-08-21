local UI = Z.UI
local super = require("ui.ui_view_base")
local Tv_acquiretip_specialView = class("Tv_acquiretip_specialView", super)
local COLOR_DEFINE = {
  [E.ItemQuality.White] = Color.New(0.9098039215686274, 0.9098039215686274, 0.9098039215686274, 1),
  [E.ItemQuality.Green] = Color.New(0.5568627450980392, 0.7411764705882353, 0.5686274509803921, 1),
  [E.ItemQuality.Blue] = Color.New(0.48627450980392156, 0.6392156862745098, 0.9098039215686274, 1),
  [E.ItemQuality.Purple] = Color.New(0.6901960784313725, 0.5411764705882353, 1.0, 1),
  [E.ItemQuality.Yellow] = Color.New(0.9372549019607843, 0.8549019607843137, 0.28627450980392155, 1),
  [E.ItemQuality.Red] = Color.New(0.8745098039215686, 0.5450980392156862, 0.3843137254901961, 1)
}
local EFFECT_PATH = {
  [E.ItemQuality.White] = "ui/uieffect/prefab/ui_sfx_tv_acquiretip_special/ui_sfx_tv_acquiretip_special_green",
  [E.ItemQuality.Green] = "ui/uieffect/prefab/ui_sfx_tv_acquiretip_special/ui_sfx_tv_acquiretip_special_green",
  [E.ItemQuality.Blue] = "ui/uieffect/prefab/ui_sfx_tv_acquiretip_special/ui_sfx_tv_acquiretip_special_bule",
  [E.ItemQuality.Purple] = "ui/uieffect/prefab/ui_sfx_tv_acquiretip_special/ui_sfx_tv_acquiretip_special_purple",
  [E.ItemQuality.Yellow] = "ui/uieffect/prefab/ui_sfx_tv_acquiretip_special/ui_sfx_tv_acquiretip_special_golden",
  [E.ItemQuality.Red] = "ui/uieffect/prefab/ui_sfx_tv_acquiretip_special/ui_sfx_tv_acquiretip_special_golden"
}
local AUDIO_DEFINE = {
  [E.ItemQuality.White] = "UI_Event_SideTip_Green",
  [E.ItemQuality.Green] = "UI_Event_SideTip_Green",
  [E.ItemQuality.Blue] = "UI_Event_SideTip_Blue",
  [E.ItemQuality.Purple] = "UI_Event_SideTip_Purple",
  [E.ItemQuality.Yellow] = "UI_Event_SideTip_Golden",
  [E.ItemQuality.Red] = "UI_Event_SideTip_Golden"
}
local ANIM_FADE_TIME = 0.2
local ANIM_MOVE_TIME = 0.5
local ANIM_HOLD_TIME = 1

function Tv_acquiretip_specialView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tv_acquiretip_special")
  self.tipsData_ = Z.DataMgr.Get("tips_data")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function Tv_acquiretip_specialView:OnActive()
  self:initData()
  self:initComp()
end

function Tv_acquiretip_specialView:OnDeActive()
  self:clearTipsEffect()
  self.itemSecondAnimTimerList_ = nil
end

function Tv_acquiretip_specialView:OnRefresh()
  for i = 1, #self.itemInfoList_ do
    self:checkItemTips()
  end
end

function Tv_acquiretip_specialView:initData()
  self.curShowNum_ = 0
  if Z.IsPCUI then
    self.posConfig_ = {17.3, 75.8}
    self.itemHeight_ = 50
  else
    self.posConfig_ = {0, 95}
    self.itemHeight_ = 76
  end
  self.itemInfoList_ = {
    [1] = {
      ShowTime = 0,
      CurHeight = 0,
      TargetHeight = 0,
      IsFirstMoving = false,
      IsWaiting = false
    },
    [2] = {
      ShowTime = 0,
      CurHeight = 0,
      TargetHeight = 0,
      IsFirstMoving = false,
      IsWaiting = false
    }
  }
  self.itemSecondAnimTimerList_ = {
    [1] = {},
    [2] = {}
  }
end

function Tv_acquiretip_specialView:initComp()
  self:SetUIVisible(self.uiBinder.item_1.Ref, false)
  self:SetUIVisible(self.uiBinder.item_2.Ref, false)
end

function Tv_acquiretip_specialView:checkItemTips()
  local itemIndex = self:getFreeItemIndex()
  if itemIndex == nil then
    return
  end
  local itemInfo = self.tipsData_:PopSpecialAcquireItemInfo()
  if itemInfo == nil then
    return
  end
  local config = Z.TableMgr.GetRow("ItemTableMgr", itemInfo.ItemConfigId)
  if config == nil then
    return
  end
  self.curShowNum_ = self.curShowNum_ + 1
  local itemBinder = self.uiBinder["item_" .. itemIndex]
  local itemStateInfo = self.itemInfoList_[itemIndex]
  itemStateInfo.ShowTime = os.time()
  itemStateInfo.CurHeight = self.posConfig_[1]
  itemStateInfo.TargetHeight = self.posConfig_[1]
  itemStateInfo.IsFirstMoving = true
  itemBinder.rimg_icon:SetImage(self.itemsVM_.GetItemIcon(itemInfo.ItemConfigId))
  itemBinder.lab_info.text = Lang("TvAcquireItemNameWithCount", {
    name = config.Name,
    count = itemInfo.ChangeCount
  })
  local curColor = COLOR_DEFINE[config.Quality]
  itemBinder.lab_info.color = curColor
  itemBinder.img_line:SetColor(curColor)
  local gradualColor = Color.New(curColor.r, curColor.g, curColor.b, 0.09019607843137255)
  itemBinder.img_gradual:SetColor(gradualColor)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(itemBinder.eff_root)
  itemBinder.eff_root:CreatEFFGO(EFFECT_PATH[config.Quality], Vector3.zero)
  Z.AudioMgr:Play(AUDIO_DEFINE[config.Quality])
  itemBinder.Trans:SetAnchorPosition(0, itemStateInfo.CurHeight)
  self:playItemFirstAnim(itemIndex, itemBinder)
  self:checkItemSecondAnim(itemIndex)
end

function Tv_acquiretip_specialView:playItemFirstAnim(itemIndex, itemBinder)
  local showIndex = self:getItemShowIndex()
  local delay = 0
  if self.curShowNum_ >= 2 and showIndex ~= itemIndex then
    if self.itemInfoList_[showIndex].IsFirstMoving then
      delay = ANIM_FADE_TIME + ANIM_MOVE_TIME
    elseif self.itemInfoList_[showIndex].IsWaiting then
      delay = ANIM_MOVE_TIME
    end
  end
  self.timerMgr:StartTimer(function()
    local itemStateInfo = self.itemInfoList_[itemIndex]
    self:SetUIVisible(itemBinder.Ref, true)
    local dotweenComp = self.uiBinder["anim_main_" .. itemIndex]
    dotweenComp:Rewind(Z.DOTweenAnimType.Tween_2)
    dotweenComp:Restart(Z.DOTweenAnimType.Tween_2)
    self.timerMgr:StartTimer(function()
      itemStateInfo.IsFirstMoving = false
      self:playItemSecondAnim(itemIndex)
    end, ANIM_MOVE_TIME, 1)
  end, delay, 1)
end

function Tv_acquiretip_specialView:playItemSecondAnim(itemIndex)
  local itemStateInfo = self.itemInfoList_[itemIndex]
  local itemBinder = self.uiBinder["item_" .. itemIndex]
  local dotweenComp = self.uiBinder["anim_main_" .. itemIndex]
  self:stopItemSecondAnim(itemIndex)
  local delay = 0
  local showIndex = self:getItemShowIndex()
  if showIndex == itemIndex and self.curShowNum_ >= 2 then
    itemStateInfo.TargetHeight = self.posConfig_[2]
    local targetPos = Vector2.New(0, itemStateInfo.TargetHeight)
    itemBinder.comp_dotween:DoAnchorPosMove(targetPos, ANIM_MOVE_TIME)
    delay = ANIM_MOVE_TIME
  end
  self.timerMgr:StartTimer(function()
    itemStateInfo.IsWaiting = true
  end, delay, 1)
  local animTimer1 = self.timerMgr:StartTimer(function()
    itemStateInfo.IsWaiting = false
    dotweenComp:Rewind(Z.DOTweenAnimType.Tween_3)
    dotweenComp:Restart(Z.DOTweenAnimType.Tween_3)
  end, ANIM_HOLD_TIME + delay, 1)
  table.insert(self.itemSecondAnimTimerList_[itemIndex], animTimer1)
  local animTimer2 = self.timerMgr:StartTimer(function()
    self.curShowNum_ = self.curShowNum_ - 1
    itemStateInfo.ShowTime = 0
    itemBinder.eff_root:ReleseEffGo()
    self:SetUIVisible(itemBinder.Ref, false)
    self:checkItemTips()
  end, ANIM_FADE_TIME + ANIM_HOLD_TIME + delay, 1)
  table.insert(self.itemSecondAnimTimerList_[itemIndex], animTimer2)
end

function Tv_acquiretip_specialView:stopItemSecondAnim(itemIndex)
  for _, timer in ipairs(self.itemSecondAnimTimerList_[itemIndex]) do
    timer:Stop()
  end
  self.itemSecondAnimTimerList_[itemIndex] = {}
end

function Tv_acquiretip_specialView:checkItemSecondAnim(currentItemIndex)
  local otherItemIndex = currentItemIndex == 1 and 2 or 1
  local itemStateInfo = self.itemInfoList_[otherItemIndex]
  if itemStateInfo.ShowTime > 0 and not itemStateInfo.IsFirstMoving and itemStateInfo.IsWaiting then
    self:playItemSecondAnim(otherItemIndex)
  end
end

function Tv_acquiretip_specialView:getFreeItemIndex()
  for index, info in ipairs(self.itemInfoList_) do
    if info.ShowTime == 0 then
      return index
    end
  end
end

function Tv_acquiretip_specialView:getItemShowIndex()
  local showTime1 = self.itemInfoList_[1].ShowTime
  local showTime2 = self.itemInfoList_[2].ShowTime
  if showTime1 == 0 and showTime2 == 0 then
    return 0
  elseif showTime1 == 0 then
    return 2
  elseif showTime2 == 0 then
    return 1
  else
    return showTime1 <= showTime2 and 1 or 2
  end
end

function Tv_acquiretip_specialView:clearTipsEffect()
  for index, info in ipairs(self.itemInfoList_) do
    local item = self.uiBinder["item_" .. index]
    item.eff_root:ReleseEffGo()
  end
end

return Tv_acquiretip_specialView
