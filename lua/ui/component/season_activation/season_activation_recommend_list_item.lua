local super = require("ui.component.loop_list_view_item")
local SeasonActivationRecommendListItem = class("SeasonActivationRecommendListItem", super)
local imageTable = Z.Global.ActivationTimesIcon
local rateAnim = {
  [5] = Z.DOTweenAnimType.Open,
  [2] = Z.DOTweenAnimType.Tween_1
}

function SeasonActivationRecommendListItem:OnInit()
  if Z.IsPCUI then
    self.itemList_ = {
      self.uiBinder.node_item_1,
      self.uiBinder.node_item_2,
      self.uiBinder.node_item_3
    }
  else
    self.itemList_ = {
      self.uiBinder.node_item_1,
      self.uiBinder.node_item_2
    }
  end
  self.quickJumpVm_ = Z.VMMgr.GetVM("quick_jump")
  self.seasonActivationVm_ = Z.VMMgr.GetVM("season_activation")
  self.privilegesData_ = Z.DataMgr.Get("privileges_data")
end

function SeasonActivationRecommendListItem:OnRefresh(data)
  self.itemData_ = data
  self:refreshItemList()
end

function SeasonActivationRecommendListItem:refreshItemList()
  for k, v in pairs(self.itemList_) do
    if k > #self.itemData_ then
      self.uiBinder.Ref:SetVisible(v.Trans, false)
    else
      self.uiBinder.Ref:SetVisible(v.Trans, true)
      self:setItemData(self.itemData_[k], v)
    end
  end
end

function SeasonActivationRecommendListItem:setItemData(data, item)
  local tableData = Z.TableMgr.GetTable("ActivationTableMgr").GetRow(data.id)
  item.btn_jump:RemoveAllListeners()
  item.btn_jump:AddListener(function()
    self:onItemClick(tableData)
  end)
  local progress = Lang("season_achievement_progress", {
    val1 = data.progress,
    val2 = tableData.Num
  })
  item.lab_info.text = Z.Placeholder.Placeholder(tableData.TargetDes, {
    val = tableData.Num,
    val2 = progress
  })
  self:resetItemState(item)
  if data.rewardRate and data.rewardRate > 100 then
    local imgIndex = math.ceil(data.rewardRate)
    local imgPath = self.seasonActivationVm_.GetImageDatePath()
    if imgIndex > #imgPath then
      imgIndex = #imgPath
    end
    if imgPath[imgIndex] then
      item.img_rate_bg:SetImage(imgPath[imgIndex].imagePath)
      item.lab_rate.color = imgPath[imgIndex].colorText
      self:onStartAnimShow(item, imgIndex)
    end
    local activation = tableData.Activation
    local privilegesRate = self.privilegesData_:GetPrivilegesDataByFunction(E.PrivilegeSourceType.BattlePass, E.PrivilegeEffectType.DailyActivityBonus)
    if privilegesRate then
      activation = math.floor(activation * (1 + privilegesRate.value / 10000))
    end
    item.lab_num.text = activation
    item.lab_new_num.text = math.ceil(data.rewardRate / 100 * activation)
    item.lab_rate.text = string.format("%d%%", data.rewardRate)
  end
  if 1 <= tableData.Cycle then
    item.Ref:SetVisible(item.img_update, true)
  else
    item.Ref:SetVisible(item.img_finish, data.progress == tableData.Num)
  end
end

function SeasonActivationRecommendListItem:resetItemState(item)
  item.Ref:SetVisible(item.img_update, false)
  item.Ref:SetVisible(item.img_finish, false)
end

function SeasonActivationRecommendListItem:onItemClick(tableData)
  if not tableData or not next(tableData) then
    return
  end
  local quickjumpVm = Z.VMMgr.GetVM("quick_jump")
  quickjumpVm.DoJumpByConfigParam(tableData.QuickJumpType, tableData.QuickJump)
end

function SeasonActivationRecommendListItem:OnUnInit()
  self.itemList_ = {}
end

function SeasonActivationRecommendListItem:onStartAnimShow(itemPrefab, index)
  itemPrefab.Ref:SetVisible(itemPrefab.img_glow_01, index == 5)
  itemPrefab.Ref:SetVisible(itemPrefab.img_glow_02, index == 2)
  itemPrefab.anim:Restart(rateAnim[index])
end

return SeasonActivationRecommendListItem
