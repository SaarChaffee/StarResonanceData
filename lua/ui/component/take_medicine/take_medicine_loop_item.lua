local TakeMedicineLoopItem = class("TakeMedicineLoopItem")
local itemBinder = require("common.item_binder")

function TakeMedicineLoopItem:ctor(parent, gameObject)
  self.parent_ = parent
  self.uiBinder = UIBinderToLua(gameObject)
  self.cd_ = 0
  self.surpluseCd_ = 0
end

function TakeMedicineLoopItem:Init()
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.itemBinder_ = itemBinder.new(self.parent_.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder.item,
    isClickOpenTips = true
  })
  self.data_ = nil
end

function TakeMedicineLoopItem:RefreshData(data)
  self.data_ = data
  self:RefreshUI()
end

function TakeMedicineLoopItem:UnInit()
  self.itemBinder_:UnInit()
  self.data_ = nil
end

function TakeMedicineLoopItem:RefreshCd(subTime)
  if self.data_ and self.cd_ > 0 and 0 < self.surpluseCd_ then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
    self.surpluseCd_ = self.surpluseCd_ - subTime
    self.surpluseCd_ = math.max(self.surpluseCd_, 0)
    self.uiBinder.lab_cd.text = string.format("%.1f", self.surpluseCd_)
    self.uiBinder.img_mask.fillAmount = self.surpluseCd_ / self.cd_
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
  end
end

function TakeMedicineLoopItem:RefreshUI()
  if self.data_ then
    local itemData = {
      configId = self.data_,
      lab = self.itemsData_:GetItemTotalCount(self.data_),
      clickCallFunc = function()
        if self.data_ == nil then
          return
        end
        self.parent_.UIView:QuickUseItem(self.data_)
      end
    }
    self.itemBinder_:RefreshByData(itemData)
    self.cd_ = 0
    self.surpluseCd_ = 0
    local itemsVM = Z.VMMgr.GetVM("items")
    local package = itemsVM.GetPackageInfobyItemId(self.data_)
    if package and next(package) then
      local cdTime, useCd = itemsVM.GetItemCd(package, self.data_)
      if cdTime and useCd then
        local serverTime = Z.ServerTime:GetServerTime()
        local diffTime = (cdTime - serverTime) / 1000
        if 0 < diffTime then
          self.cd_ = useCd
          self.surpluseCd_ = diffTime
        end
      end
    end
    self:RefreshCd(0)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
    self.itemBinder_:HideUi()
  end
end

return TakeMedicineLoopItem
