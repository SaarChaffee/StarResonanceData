local super = require("ui.ui_subview_base")
local SeasonCultivateMain = class("SeasonCultivateMain", super)
local CoreNodeColor = {
  [1] = Color.New(1, 1, 1, 0.2),
  [2] = Color.New(1, 1, 1, 1)
}
local SeasonCultivateNodeHelper = require("ui.view.season_cultivate.season_cultivate_node_helper")
local SeasonCultivateCore = require("ui.view.season_cultivate.season_cultivate_core_sub_view")
local SeasonCultivateNode = require("ui.view.season_cultivate.season_cultivate_node_sub_view")
local SeasonCultivateGlobal = require("ui.view.season_cultivate.season_cultivate_global_sub_view")

function SeasonCultivateMain:ctor(parent)
  self.uiRootPanel_ = parent
  super.ctor(self, "season_cultivate", "season_cultivate/season_cultivate_sub", Z.UI.ECacheLv.None, true)
  self.seasonCultivateVM_ = Z.VMMgr.GetVM("season_cultivate")
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.seasonTitleData_ = Z.DataMgr.Get("season_title_data")
end

function SeasonCultivateMain:initBinder()
  self.lockNode_ = self.uiBinder.img_badge_lock_bg
  self.badgeBg_ = self.uiBinder.img_badge_bg
  self.levelLab_ = self.uiBinder.lab_level
  self.rightSubNode_ = self.uiBinder.node_right
  self.prefabCache_ = self.uiBinder.prefab
  self.coreHoleParent_ = self.uiBinder.node_hole
  self.activeLab_ = self.uiBinder.lab_activation_info
  self.closeSubBtn_ = self.uiBinder.close_sub_btn
  self.btn_effect_ = self.uiBinder.btn_effect
  self.maskImg_ = self.uiBinder.img_mask
  self.leftNode_ = self.uiBinder.node_left
  self.entryNode_ = self.uiBinder.node_rimg_entry
  self.effectNode_ = self.uiBinder.node_effect
  self.performanceBtn_ = self.uiBinder.btn_performance
  self.closeMaskBtn_ = self.uiBinder.btn_close_mask
  self.normalNodeItem_ = {
    [1] = self.uiBinder.node_badge_item_1,
    [2] = self.uiBinder.node_badge_item_2,
    [3] = self.uiBinder.node_badge_item_3,
    [4] = self.uiBinder.node_badge_item_4,
    [5] = self.uiBinder.node_badge_item_5,
    [6] = self.uiBinder.node_badge_item_6
  }
  self.nodes_ = {
    [1] = SeasonCultivateNodeHelper.new(self, self.normalNodeItem_[1]),
    [2] = SeasonCultivateNodeHelper.new(self, self.normalNodeItem_[2]),
    [3] = SeasonCultivateNodeHelper.new(self, self.normalNodeItem_[3]),
    [4] = SeasonCultivateNodeHelper.new(self, self.normalNodeItem_[4]),
    [5] = SeasonCultivateNodeHelper.new(self, self.normalNodeItem_[5]),
    [6] = SeasonCultivateNodeHelper.new(self, self.normalNodeItem_[6])
  }
end

function SeasonCultivateMain:bindEvent()
  function self.coreHoleNodeInfoChangeFunc_(container, dirtys)
    self:coreHoleNodeInfoChangeFunc(container, dirtys)
  end
  
  Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:RegWatcher(self.coreHoleNodeInfoChangeFunc_)
  Z.EventMgr:Add(Z.ConstValue.SeasonCultivate.OnSelectNode, self.onSelectNode, self)
  Z.EventMgr:Add(Z.ConstValue.SeasonCultivate.OnUpgradeHole, self.onUpgradeHole, self)
  Z.EventMgr:Add(Z.ConstValue.SeasonCultivate.OnResetHole, self.onResetHole, self)
  Z.EventMgr:Add(Z.ConstValue.SeasonCultivate.OnSlotSubViewClose, self.onSlotSubViewClose, self)
end

function SeasonCultivateMain:initBtns()
  self:AddClick(self.closeSubBtn_, function()
    self:closeRightTips()
  end)
  self:AddClick(self.btn_effect_, function()
    self.seasonCultivateVM_.OpenEffectPopupView()
  end)
  self:AddClick(self.uiBinder.btn_selet_none, function()
  end)
  self:AddClick(self.performanceBtn_, function()
    self.sourceTipId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.lab_num.transform, self.performanceConfigId_)
  end)
  self:AddClick(self.closeMaskBtn_, function()
    self:closeRightTips()
  end)
  self:AddClick(self.uiBinder.btn_core, function()
    local curCoreLevel = self.seasonCultivateVM_.GetCoreNodeLevel()
    if curCoreLevel == 0 then
      local isActive = self.seasonCultivateVM_.CheckUpgradeCondition(E.SeasonCultivateHole.Core, 1, true)
      if not isActive then
        return
      end
    end
    if self.seasonCultivateVM_.TryClick() then
      Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnSelectNode, E.SeasonCultivateHole.Core)
    end
  end)
end

function SeasonCultivateMain:initUi()
  Z.AudioMgr:Play("UI_Event_SeasonMedal")
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  for _, v in pairs(self.nodes_) do
    v:OnActive()
  end
  self:closeRightTips()
  local coreNodeInfo = self.seasonCultivateVM_.GetCoreNodeInfo()
  local active = next(coreNodeInfo) and 2 or 1
  self:setCoreState(active)
  for index, item in ipairs(self.normalNodeItem_) do
    Z.RedPointMgr.LoadRedDotItem("normalNodeRed" .. index, self, item.Trans)
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.SeasonCultivateCoreRed, self, self.badgeBg_.transform)
  local seasonInfo = self.seasonTitleData_:GetCurRankInfo()
  local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonInfo.curRanKStar)
  if seasonRankConfig == nil then
    return
  end
  self.uiBinder.rimg_badge_icon:SetImage(seasonRankConfig.IconBig)
  local seasonRankArmbandRow = Z.TableMgr.GetTable("SeasonRankArmbandTableMgr").GetRow(seasonRankConfig.RankId)
  if seasonRankArmbandRow then
    self.effectPath_ = seasonRankArmbandRow.FxResources
  end
end

function SeasonCultivateMain:initData()
  self.allCoreSlotItem_ = {}
  self.currentSelectHole_ = -1
  self.seasonCultivateGlobal_ = SeasonCultivateGlobal.new(self)
  self.seasonCultivateNode_ = SeasonCultivateNode.new(self)
  self.seasonCultivateCore_ = SeasonCultivateCore.new(self)
end

function SeasonCultivateMain:OnActive()
  self.uiBinder.node_level_up:SetEffectGoVisible(false)
  self:initBinder()
  self:onStartAnimShow()
  self:initBtns()
  self:bindEvent()
  self:initData()
  self:initUi()
end

function SeasonCultivateMain:setAnchorPositions(state)
  local positionConfig = {
    close = {
      pc = {
        left = {x = 238, y = -44},
        effect = {x = -46, y = -116}
      },
      mobile = {
        left = {x = 186, y = -55},
        effect = {x = -34, y = -136}
      }
    },
    open = {
      pc = {
        left = {x = 136, y = -44},
        effect = {x = -484, y = -116}
      },
      mobile = {
        left = {x = -46, y = -55},
        effect = {x = -620, y = -136}
      }
    }
  }
  local platform = Z.IsPCUI and "pc" or "mobile"
  local config = positionConfig[state][platform]
  self.leftNode_:SetAnchorPosition(config.left.x, config.left.y)
  self.entryNode_:SetAnchorPosition(config.left.x, config.left.y)
  self.effectNode_:SetAnchorPosition(config.effect.x, config.effect.y)
end

function SeasonCultivateMain:onCloseIsPcPos()
  self:setAnchorPositions("close")
end

function SeasonCultivateMain:onOpenIsPcPos()
  self:setAnchorPositions("open")
end

function SeasonCultivateMain:closeRightTips()
  self:onCloseIsPcPos()
  self.uiBinder.Ref:SetVisible(self.rightSubNode_, false)
  self.uiBinder.Ref:SetVisible(self.maskImg_, false)
  self.uiBinder.Ref:SetVisible(self.closeMaskBtn_, false)
  self.seasonCultivateCore_:DeActive()
  self.seasonCultivateNode_:DeActive()
  self.seasonCultivateGlobal_:DeActive()
  self.currentSelectHole_ = nil
end

function SeasonCultivateMain:loadItem()
  local itemPath = self.prefabCache_:GetString("coreHoleItem")
  if itemPath and itemPath ~= "" then
    Z.CoroUtil.create_coro_xpcall(function()
      self.slotData_, self.maxSlotCount_ = self.seasonCultivateVM_.GetCoreEffectiveNodeData()
      self.coroHoleIndex_ = nil
      for i = 1, self.maxSlotCount_ do
        local item = self:AsyncLoadUiUnit(itemPath, "coreHoleItem" .. i, self.coreHoleParent_.transform)
        self.allCoreSlotItem_[i] = item
        Z.RedPointMgr.LoadRedDotItem("coreSlotRed" .. i, self, item.Trans)
        self:AddClick(item.img_btn, function()
          local curCoreLevel = self.seasonCultivateVM_.GetCoreNodeLevel()
          local unlock = self.slotData_[i] and curCoreLevel > self.slotData_[i] or false
          if not unlock then
            Z.TipsVM.ShowTips(124012, {
              val = self.slotData_[i] + 1
            })
            return
          end
          self.coroHoleIndex_ = i
          if self.currentSelectHole_ == 0 then
            self.seasonCultivateGlobal_:Active(self.coroHoleIndex_, self.uiBinder.node_right_sub.transform)
          else
            Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnSelectNode, 0)
          end
          self:setCoreSoltState()
        end)
      end
      self:setCoreSoltState()
    end)()
  end
end

function SeasonCultivateMain:loadEffect()
  local curCoreLevel = self.seasonCultivateVM_.GetCoreNodeLevel()
  if self.effectUuid_ then
    return
  end
  if self.effectPath_ then
    self.effectUuid_ = Z.UnrealSceneMgr:NewCreatEffect(self.effectPath_, "season_cultitave")
  end
end

function SeasonCultivateMain:setEffect()
  if self.effectUuid_ then
    local createPos = Z.UnrealSceneMgr:GetTransPos("pos")
    local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.uiBinder.rimg_badge_icon.transform.position)
    local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, createPos))
    local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
    Z.UnrealSceneMgr:SetEffectPosition(self.effectUuid_, worldPosition.x - createPos.x - 0.02, worldPosition.y - createPos.y + 0.04, worldPosition.z - createPos.z)
  end
end

function SeasonCultivateMain:OnRefresh()
  local normalNodeInfo = self.seasonCultivateVM_.GetAllNormalNodeInfo()
  for i, v in pairs(self.nodes_) do
    if normalNodeInfo[i] then
      v:OnRefresh(normalNodeInfo[i])
    end
  end
  self:setCoreUi()
  self:loadItem()
  self:resetExpInfo()
end

function SeasonCultivateMain:OnDeActive()
  self.currentSelectHole_ = nil
  self.effectPath_ = nil
  for _, v in pairs(self.nodes_) do
    v:OnDeActive()
  end
  self.nodes_ = nil
  if self.effectUuid_ then
    Z.UnrealSceneMgr:ClearEffect(self.effectUuid_)
    self.effectUuid_ = nil
  end
  self.seasonCultivateGlobal_:DeActive()
  self.seasonCultivateGlobal_ = nil
  self.seasonCultivateNode_:DeActive()
  self.seasonCultivateNode_ = nil
  self.seasonCultivateCore_:DeActive()
  self.seasonCultivateCore_ = nil
  if self.coreHoleNodeInfoChangeFunc_ then
    Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:UnregWatcher(self.coreHoleNodeInfoChangeFunc_)
    self.coreHoleNodeInfoChangeFunc_ = nil
  end
  if self.sourceTipId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipId_)
    self.sourceTipId_ = nil
  end
  Z.EventMgr:RemoveObjAll(self)
end

function SeasonCultivateMain:onSelectNode(holeId)
  if self.currentSelectHole_ == holeId then
    return
  end
  self.currentSelectHole_ = holeId
  local coreNodeInfo = self.seasonCultivateVM_.GetCoreNodeInfo()
  local active = next(coreNodeInfo) and 2 or 1
  self:setCoreState(active)
  self.uiBinder.Ref:SetVisible(self.rightSubNode_, true)
  self:onStartSelectAnimShow()
  self:onOpenIsPcPos()
  self.uiBinder.Ref:SetVisible(self.maskImg_, holeId == 0)
  self.uiBinder.Ref:SetVisible(self.closeMaskBtn_, holeId == 0)
  if holeId == 0 then
    self.seasonCultivateCore_:DeActive()
    self.seasonCultivateNode_:DeActive()
    self.seasonCultivateGlobal_:Active(self.coroHoleIndex_, self.uiBinder.node_right_sub.transform)
  elseif holeId == E.SeasonCultivateHole.Core then
    self.seasonCultivateGlobal_:DeActive()
    self.seasonCultivateNode_:DeActive()
    self.seasonCultivateCore_:Active(nil, self.uiBinder.node_right_sub.transform)
  elseif 1 <= holeId and holeId <= 6 then
    self.seasonCultivateGlobal_:DeActive()
    self.seasonCultivateCore_:DeActive()
    local all = self.seasonCultivateVM_.GetAllNormalNodeInfo()
    self.seasonCultivateNode_:Active(all[holeId], self.uiBinder.node_right_sub.transform)
  end
end

function SeasonCultivateMain:setCoreState(active)
  if CoreNodeColor[active] then
    self.uiBinder.rimg_badge_icon:SetColor(CoreNodeColor[active])
  end
end

function SeasonCultivateMain:onUpgradeHole(holeId)
  self.uiBinder.node_level_up:SetEffectGoVisible(false)
  if holeId == E.SeasonCultivateHole.Core then
    self:setCoreState(2)
    self:onStartUnlockAnimShow()
  else
    local normalNodeInfo = self.seasonCultivateVM_.GetAllNormalNodeInfo()
    if normalNodeInfo[holeId] and self.nodes_[holeId] then
      self.nodes_[holeId]:OnRefresh(normalNodeInfo[holeId], true)
      self.nodes_[holeId]:OnLevelUpNodeEffShow()
    end
  end
  self:resetExpInfo()
end

function SeasonCultivateMain:onResetHole(holeId)
  if self.nodes_[holeId] then
    local normalNodeInfo = self.seasonCultivateVM_.GetAllNormalNodeInfo()
    if normalNodeInfo[holeId] then
      self.nodes_[holeId]:OnRefresh(normalNodeInfo[holeId], true)
    end
  end
  self:resetExpInfo()
end

function SeasonCultivateMain:resetExpInfo()
  local hasExp = 0
  local config = Z.Global.ProgressValueItem
  self.performanceConfigId_ = config[1][2]
  for _, v in pairs(config) do
    if v[1] == self.seasonVM_.GetCurrentSeasonId() then
      local count = self.itemVM_.GetItemTotalCount(v[2])
      hasExp = hasExp + count * v[3]
    end
  end
  local usedExp = 0
  for i = 1, 6 do
    usedExp = usedExp + self.seasonCultivateVM_.GetHoleExpTotalCurrent(i)
  end
  self.uiBinder.lab_num.text = _formatStr("{0}/{1}", hasExp, hasExp + usedExp)
end

function SeasonCultivateMain:setCoreUi()
  local curCoreLevel = self.seasonCultivateVM_.GetCoreNodeLevel()
  local str = ""
  local isActive = false
  if curCoreLevel == 0 then
    local isLock = self.seasonCultivateVM_.CheckUpgradeCondition(E.SeasonCultivateHole.Core, 1)
    self.uiBinder.Ref:SetVisible(self.lockNode_, not isLock)
    if isLock then
    end
    str = Lang("Unactivat")
  else
    isActive = true
    str = Lang("AchievementLevel", {val = curCoreLevel})
    self.uiBinder.Ref:SetVisible(self.lockNode_, false)
  end
  self.levelLab_.text = str
  if not isActive then
    local limit = Z.Global.EffectiveNodeNum
    if limit and limit[1] then
      self.activeLab_.text = Lang("SeasonCultivateActiveDes", {
        val = limit[1][2]
      })
    end
  end
  self.uiBinder.Ref:SetVisible(self.activeLab_, not isActive)
  self.uiBinder.Ref:SetVisible(self.coreHoleParent_, isActive)
end

function SeasonCultivateMain:setCoreSoltState()
  local curCoreLevel = self.seasonCultivateVM_.GetCoreNodeLevel()
  if curCoreLevel == 0 then
    return
  end
  self.uiBinder.Ref:SetVisible(self.activeLab_, false)
  self.uiBinder.Ref:SetVisible(self.coreHoleParent_, true)
  for slotId, item in pairs(self.allCoreSlotItem_) do
    local unlock = self.slotData_ and curCoreLevel > self.slotData_[slotId] or false
    local data = self.seasonCultivateVM_.GetCoreNodeSlotInfoBySlotId(slotId)
    if data then
      local cfgData = self.seasonCultivateVM_.GetAttributeConfigByLevel(data.nodeId, data.nodeLevel)
      if cfgData then
        item.img_icon:SetImage(cfgData.NodeIcon)
      end
      item.Ref:SetVisible(item.img_bg, true)
      item.Ref:SetVisible(item.img_add, false)
      item.Ref:SetVisible(item.img_lock, false)
    else
      item.Ref:SetVisible(item.img_bg, false)
      item.Ref:SetVisible(item.img_add, unlock)
      item.Ref:SetVisible(item.img_lock, not unlock)
    end
    item.Ref:SetVisible(item.img_select, self.coroHoleIndex_ and self.coroHoleIndex_ == slotId)
    if self.coroHoleIndex_ and self.coroHoleIndex_ == slotId then
      item.anim:Restart(Z.DOTweenAnimType.Open)
    end
  end
end

function SeasonCultivateMain:coreHoleNodeInfoChangeFunc(container, dirtys)
  if dirtys.coreHoleNodeInfos then
    self:setCoreSoltState()
  end
  if dirtys.coreHoleInfo then
    self:setCoreSoltState()
    self:setCoreUi()
  end
end

function SeasonCultivateMain:onSlotSubViewClose()
  self.coroHoleIndex_ = nil
  self:setCoreSoltState()
end

function SeasonCultivateMain:onStartAnimShow()
  if Z.IsPCUI then
    return
  end
  self.uiBinder.anim_season:CoroPlayOnce("anim_season_cultivate_sub_open", self.cancelSource:CreateToken(), function()
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

function SeasonCultivateMain:onStartSelectAnimShow()
  if Z.IsPCUI then
    return
  end
  self.uiBinder.anim_dotween_season:Restart(Z.DOTweenAnimType.Open)
end

function SeasonCultivateMain:onStartUnlockAnimShow()
  if Z.IsPCUI then
    return
  end
  local curCoreLevel = self.seasonCultivateVM_.GetCoreNodeLevel()
  if curCoreLevel == 1 then
    self.uiBinder.anim_dotween_season:Restart(Z.DOTweenAnimType.Tween_1)
  else
    local parentUIDepth = self:GetParentUIDepth()
    if parentUIDepth then
      parentUIDepth:AddChildDepth(self.uiBinder.node_level_up)
    end
    Z.AudioMgr:Play("sys_team_created")
    self.uiBinder.node_level_up:SetEffectGoVisible(true)
  end
end

function SeasonCultivateMain:GetParentUIDepth()
  return self.uiRootPanel_:GetParentUIDepth()
end

return SeasonCultivateMain
