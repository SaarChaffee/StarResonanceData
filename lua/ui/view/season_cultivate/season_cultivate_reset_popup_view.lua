local super = require("ui.ui_view_base")
local SeasonCultivateReset = class("SeasonCultivateResetView", super)
local ItemUnitPath = GetLoadAssetPath("ItemUnitPath")
local ItemClass = require("common.item")

function SeasonCultivateReset:ctor()
  super.ctor(self, "season_cultivate_reset_popup")
  self.seasonCultivateVM_ = Z.VMMgr.GetVM("season_cultivate")
  self.itemVM_ = Z.VMMgr.GetVM("items")
end

function SeasonCultivateReset:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.itemClass_ = {}
  self.needItems_ = {}
  local temp = Z.Global.NodeResetConsumption
  self.needItems_[temp[1]] = temp[2]
  self.canReset_ = false
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_confirm, function()
    if self.canReset_ then
      Z.EventMgr:Dispatch(Z.ConstValue.SeasonCultivate.OnConfirmReset)
    end
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
end

function SeasonCultivateReset:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self.canReset_ = true
    for itemId, need in pairs(self.needItems_) do
      local unit = self:AsyncLoadUiUnit(ItemUnitPath, _formatStr("item_{0}", id), self.uiBinder.node_item.transform, self.cancelSource:CreateToken())
      if unit then
        unit.cont_info.img_prob_bg:SetVisible(false)
        local count = self.itemVM_.GetItemTotalCount(itemId)
        if need > count then
          self.canReset_ = false
        end
        local datas = {
          unit = unit,
          configId = itemId,
          isShowZero = true,
          lab = count,
          isShowOne = true
        }
        self.itemClass_[itemId] = ItemClass.new(self)
        self.itemClass_[itemId]:Init(datas)
        self.itemClass_[itemId]:SetExpendCount(count, need)
      end
    end
  end)()
end

function SeasonCultivateReset:OnDeActive()
  for itemId, itemClass in pairs(self.itemClass_) do
    itemClass:UnInit()
  end
  self.needItems_ = nil
  self.canReset_ = nil
end

return SeasonCultivateReset
