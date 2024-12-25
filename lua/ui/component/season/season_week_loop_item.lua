local super = require("ui.component.loopscrollrectitem")
local SeasonWeekLoopItem = class("SeasonWeekLoopItem", super)
local iClass = require("common.item")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function SeasonWeekLoopItem:ctor()
  self.vm = Z.VMMgr.GetVM("season_quest_sub")
end

function SeasonWeekLoopItem:OnInit()
  if self.initTag_ then
    return
  end
  self.itemClassTab_ = {}
  self.initTag_ = true
  self.title_lab_ = self.uiBinder.img_bg.lab_describe
  self.completemess_lab_ = self.uiBinder.img_bg.lab_completeness_num
  self.awardContent_ = self.uiBinder.img_bg.node_content
  self.get_btn_go_ = self.uiBinder.img_bg.cont_btn_get
  self.goto_btn_go_ = self.uiBinder.img_bg.cont_btn_goto
  self.underway_go_ = self.uiBinder.img_bg.lab_underway
  self.completed_go_ = self.uiBinder.img_bg.img_completed
  self.img_grey_go_ = self.uiBinder.img_bg.img_grey
  self.itemKey_ = self.goObj:GetInstanceID()
  self.awardItemTab_ = self.awardItemTab_ or {}
  self.curCreateVersion_ = 0
end

function SeasonWeekLoopItem:Refresh()
  self.curCreateVersion_ = self.curCreateVersion_ + 1
  self:AddClick(self.get_btn_go_, function()
    self.parent.uiView:GetTaskAward(self.component.Index + 1)
  end)
  self:AddClick(self.goto_btn_go_, function()
    self.parent.uiView:Goto(self.component.Index + 1)
  end)
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  local cfg = self.parent.uiView:GetTaskConfig(index)
  local targetcfg = self.parent.uiView:GetTaskTargetConfig(index)
  if targetcfg == nil then
    self.title_lab_.text = ""
    self.completemess_lab_.text = ""
  else
    self.title_lab_.text = Z.Placeholder.Placeholder(targetcfg.Describe, {
      val = targetcfg.Num
    })
    self.completemess_lab_.text = data.targetNum .. "/" .. targetcfg.Num
  end
  self:ShowBtnByState(data.award, cfg.QuickJumpType)
  Z.CoroUtil.create_coro_xpcall(function()
    self:creatAwardItem(cfg.AwardId, data.award)
  end)()
end

function SeasonWeekLoopItem:ShowBtnByState(state, jumpType)
  if self.parent.uiView:GetCurSelectDay() > self.vm.GetCurDay() then
    self:SetVisible(self.completed_go_, false)
    self:SetVisible(self.get_btn_go_, false)
    self:SetVisible(self.goto_btn_go_, false)
    self:SetVisible(self.underway_go_, true)
    self.underway_go_.text = Lang("SeasonNotOpen")
    self:SetVisible(self.img_grey_go_, false)
    return
  end
  if state == self.vm.AwardState.hasGet then
    self:SetVisible(self.completed_go_, true)
    self:SetVisible(self.get_btn_go_, false)
    self:SetVisible(self.goto_btn_go_, false)
    self:SetVisible(self.underway_go_, false)
    self:SetVisible(self.img_grey_go_, true)
  elseif state == self.vm.AwardState.canGet then
    self:SetVisible(self.completed_go_, false)
    self:SetVisible(self.get_btn_go_, true)
    self:SetVisible(self.goto_btn_go_, false)
    self:SetVisible(self.underway_go_, false)
    self:SetVisible(self.img_grey_go_, false)
  else
    self:SetVisible(self.completed_go_, false)
    self:SetVisible(self.get_btn_go_, false)
    self:SetVisible(self.img_grey_go_, false)
    if jumpType and 0 < jumpType then
      self:SetVisible(self.goto_btn_go_, true)
      self:SetVisible(self.underway_go_, false)
    else
      self:SetVisible(self.goto_btn_go_, false)
      self:SetVisible(self.underway_go_, true)
      self.underway_go_.text = Lang("InvestigationSelectNotComplete")
    end
  end
end

function SeasonWeekLoopItem:creatAwardItem(id, state)
  self.awardList_ = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(id)
  for key, _ in pairs(self.awardItemTab_) do
    self.parent.uiView:RemoveUiUnit(key)
  end
  self.awardItemTab_ = {}
  local path = self.uiBinder.prefabcache_root:GetString("item")
  if path == "" or path == nil then
    return
  end
  for i = 1, #self.awardList_ do
    local name = "season_" .. self.itemKey_ .. "award" .. i .. self.curCreateVersion_
    local item = self.parent.uiView:AsyncLoadUiUnit(path, name, self.awardContent_)
    if name ~= item.Trans.name then
      self.parent.uiView:RemoveUiUnit(name)
    else
      self.awardItemTab_[name] = item
      item:SetVisible(true)
      local itemClass = self.itemClassTab_[i]
      if itemClass == nil then
        itemClass = iClass.new(self.parent.uiView)
        self.itemClassTab_[i] = itemClass
      end
      local itemData = {
        unit = item,
        configId = self.awardList_[i].awardId,
        isShowReceive = state == self.vm.AwardState.hasGet,
        isSquareItem = true,
        PrevDropType = self.awardList_[i].PrevDropType
      }
      itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(self.awardList_[i])
      itemClass:Init(itemData)
    end
  end
end

function SeasonWeekLoopItem:OnUnInit()
  for _, itemClass in ipairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
end

function SeasonWeekLoopItem:SetVisible(comp, visible)
  self.uiBinder.img_bg.Ref:SetVisible(comp, visible)
end

return SeasonWeekLoopItem
