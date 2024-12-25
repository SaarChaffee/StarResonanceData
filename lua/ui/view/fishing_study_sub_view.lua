local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fishing_study_subView = class("Fishing_study_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local fishingResearchItem = require("ui.component.fishing.fishing_research_loop_item")

function Fishing_study_subView:ctor(parent)
  self.uiBinder = nil
  self.uiRootPanel_ = parent
  super.ctor(self, "fishing_study_sub", "fishing/fishing_study_sub", UI.ECacheLv.None)
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
end

function Fishing_study_subView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.uiBinder.node_eff:SetEffectGoVisible(false)
  self.selectArea_ = self.viewData.areaId
  self.selectFish_ = self.viewData.fishParam
  self:initLoopGridView()
  Z.EventMgr:Add(Z.ConstValue.Fishing.FishingStudyLevelChange, self.onPlayEff, self)
end

function Fishing_study_subView:OnDeActive()
  self:unInitLoopGridView()
  Z.EventMgr:RemoveObjAll()
end

function Fishing_study_subView:OnRefresh()
  self:RefreshUI()
end

function Fishing_study_subView:RefreshUI()
  self:refreshLoopGridView()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_tips, self.selectFish_ ~= nil)
end

function Fishing_study_subView:initLoopGridView()
  self.loopGridView_ = loopGridView.new(self, self.uiBinder.loop_item, fishingResearchItem, "fishing_study_item_tpl")
  self.loopGridView_:Init({})
end

function Fishing_study_subView:refreshLoopGridView()
  local dataList_ = {}
  local fishingAreaCfg_ = Z.TableMgr.GetTable("FishingAreaTableMgr").GetRow(self.selectArea_)
  for _, v in ipairs(fishingAreaCfg_.FishGroup) do
    if self.fishingData_.FishRecordDict[v].FishRecord and self.fishingData_.FishRecordDict[v].FishCfg.IfResearch == 1 then
      table.insert(dataList_, v)
    end
  end
  table.sort(dataList_, function(a, b)
    local cfgA_ = self.fishingData_.FishRecordDict[a].FishCfg
    local cfgB_ = self.fishingData_.FishRecordDict[b].FishCfg
    if cfgA_.Sort == cfgB_.Sort then
      return a < b
    else
      return cfgA_.Sort > cfgB_.Sort
    end
  end)
  local startSelect_ = 1
  for k, v in ipairs(dataList_) do
    if v == self.selectFish_ then
      startSelect_ = k
      break
    end
  end
  self.loopGridView_:RefreshListView(dataList_)
  self.loopGridView_:ClearAllSelect()
  self.loopGridView_:SetSelected(startSelect_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, #dataList_ == 0)
end

function Fishing_study_subView:unInitLoopGridView()
  self.loopGridView_:UnInit()
  self.loopGridView_ = nil
end

function Fishing_study_subView:OnClickResearchItem(data)
  self.selectFish_ = data
  self:refreshRightUI()
end

function Fishing_study_subView:refreshRightUI()
  if self.selectFish_ then
    local fishCfg_ = Z.TableMgr.GetTable("FishingTableMgr").GetRow(self.selectFish_)
    self.uiBinder.lab_name.text = fishCfg_.Name
    local researchLevel_ = self.fishingData_.FishRecordDict[fishCfg_.FishId].ResearchLevel
    local canUseResearch_ = fishCfg_.IfResearch == 1 and 0 < researchLevel_
    local maxResearchLevel = #fishCfg_.FishingResearchExp
    local canshowNext = fishCfg_.IfResearch == 1 and researchLevel_ < maxResearchLevel
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content_next, canshowNext)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_title_02, canshowNext)
    self.uiBinder.lab_title_01.text = canshowNext and Lang("Currenteffect:") or Lang("CurrenteffectComplete:")
    if fishCfg_.IfResearch == 1 then
      if 0 < researchLevel_ then
        local attrRow_ = Z.TableMgr.GetTable("FishingTemplateTableMgr").GetRow(fishCfg_.FishingTemplateId[researchLevel_])
        self.uiBinder.lab_content.text = attrRow_.Describe
      else
        self.uiBinder.lab_content.text = Lang("FishingResearchNoEffect")
      end
    end
    if canshowNext then
      local attrRow_ = Z.TableMgr.GetTable("FishingTemplateTableMgr").GetRow(fishCfg_.FishingTemplateId[researchLevel_ + 1])
      self.uiBinder.lab_content_next.text = attrRow_.Describe
    end
    self.uiBinder.btn_use.IsDisabled = canUseResearch_ == false
    local researchProgress_ = self.fishingData_.FishRecordDict[fishCfg_.FishId].ResearchProgress
    self.uiBinder.img_ing.fillAmount = researchProgress_[1]
    local curResExp_ = Z.RichTextHelper.ApplyColorTag(researchProgress_[2], "#ffc45d")
    self.uiBinder.lab_schedule.text = curResExp_ .. "/" .. researchProgress_[3]
    self.uiBinder.lab_research.text = researchLevel_
    self.uiBinder.rimg_icon:SetImage(fishCfg_.FishingIcon)
    self:AddAsyncClick(self.uiBinder.btn_study, function()
      self.fishingVM_.OpenResearchPopWindow(self.selectFish_, self)
    end)
    self:AddAsyncClick(self.uiBinder.btn_use, function()
      if fishCfg_.IfResearch == 1 and 0 < researchLevel_ then
        self.fishingVM_.UseFishingResearch(self.selectFish_, self.cancelSource:CreateToken())
        self.fishingVM_.CloseMainFuncWindow()
      end
    end)
    self:AddAsyncClick(self.uiBinder.btn_nouse, function()
      self.fishingVM_.UseFishingResearch(0, self.cancelSource:CreateToken())
      self.fishingVM_.CloseMainFuncWindow()
    end)
    local isEquip_ = self.fishingData_.QTEData.UseResearchFish == self.selectFish_
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_use, not isEquip_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_nouse, isEquip_)
  end
end

function Fishing_study_subView:onPlayEff()
  self.uiRootPanel_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.node_eff:SetEffectGoVisible(true)
end

return Fishing_study_subView
