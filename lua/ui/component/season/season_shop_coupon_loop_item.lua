local super = require("ui.component.loop_list_view_item")
local SeasonShopCouponLoopItem = class("SeasonShopCouponLoopItem", super)
local item = require("common.item_binder")

function SeasonShopCouponLoopItem:OnInit()
  self.itemBinder_ = item.new(self.parent.uiView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder.item
  })
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.uiBinder.btn_reduce:AddListener(function()
    if self.data_.count <= 0 then
      return
    end
    local count = self.data_.count - 1
    self.parent.UIView:ChangeCoupon({
      uuid = self.data_.uuid,
      configId = self.data_.configId,
      count = count
    })
  end)
  self.uiBinder.btn_add:AddListener(function()
    local count = self.data_.count + 1
    if count > self.data_.maxCount then
      return
    end
    if count > self.canUseCount_ then
      return
    end
    self.parent.UIView:ChangeCoupon({
      uuid = self.data_.uuid,
      configId = self.data_.configId,
      count = count
    })
  end)
end

function SeasonShopCouponLoopItem:OnUnInit()
  self.itemBinder_:UnInit()
end

function SeasonShopCouponLoopItem:OnRefresh(data)
  self.data_ = data
  self.canUseCount_ = self.parent.UIView:GetCanUseCouponsCount(self.data_)
  local itemData = {
    uuid = data.uuid,
    configId = data.configId
  }
  self.itemBinder_:RefreshByData(itemData)
  local itemInfo = self.itemVM_.GetItemInfo(data.uuid, E.BackPackItemPackageType.Item)
  self.uiBinder.lab_have.text = Lang("ItemSourcePackageCount", {
    val = itemInfo.count
  })
  if itemInfo.expireTime and itemInfo.expireTime > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, true)
    local timeStrYMDHMS = Z.TimeFormatTools.TicksFormatTime(itemInfo.expireTime, E.TimeFormatType.YMDHMS)
    local param = {str = timeStrYMDHMS}
    self.uiBinder.lab_time.text = Lang("Tips_TimeLimit_Valid", param)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
  end
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.configId)
  if itemConfig then
    self.uiBinder.lab_name.text = itemConfig.Name
  end
  local config = Z.TableMgr.GetTable("MallCouponsTableMgr").GetRow(data.configId)
  if config then
    self.uiBinder.lab_max.text = Lang("CouponMaxLimit", {
      val = config.LimitNum
    })
  end
  self.uiBinder.lab_num.text = self.data_.count
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, self.data_.count >= self.canUseCount_ and self.data_.count == 0)
end

return SeasonShopCouponLoopItem
