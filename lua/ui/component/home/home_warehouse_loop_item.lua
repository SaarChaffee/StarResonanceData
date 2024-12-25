local super = require("ui.component.loopscrollrectitem")
local HomeWarehouseLoopItem = class("HomeWarehouseLoopItem", super)

function HomeWarehouseLoopItem:OnInit()
  self.iconImg_ = self.uiBinder.img_icon
  self.numLab_ = self.uiBinder.lab_num
  self.bgImg_ = self.uiBinder.img_bg
  self.homeData_ = Z.DataMgr.Get("home_data")
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
end

function HomeWarehouseLoopItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if self.data_ then
    self.count_ = self.data_.count
    self.homeTtemCfgData_ = Z.TableMgr.GetTable("HousingItemsMgr").GetRow(self.data_.configId)
    self.itemCfgData_ = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.data_.configId)
    if self.itemCfgData_ then
      local itemsVm = Z.VMMgr.GetVM("items")
      self.iconImg_:SetImage(itemsVm.GetItemIcon(self.data_.configId))
      self:setCountLab()
    end
  end
end

function HomeWarehouseLoopItem:setCountLab()
  self.numLab_.text = self.count_
end

function HomeWarehouseLoopItem:OnPointerClick(go, eventData)
  if self.homeTtemCfgData_ and self.count_ > 0 then
    if self.homeData_.IsOperationState then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("HomeSwicthSelected"), function()
        Z.EventMgr:Dispatch(Z.ConstValue.Home.SaveSelectedEntity)
        Z.DIServiceMgr.HomeService:CreateEntity(self.homeTtemCfgData_.Id)
        Z.DialogViewDataMgr:CloseDialogView()
      end)
    else
      Z.DIServiceMgr.HomeService:CreateEntity(self.homeTtemCfgData_.Id)
    end
  end
end

function HomeWarehouseLoopItem:refreshCount(configId)
  if self.data_.configId == configId then
    self.count_ = self.count_ - (self.homeData_.LocalCreatHomeFurnitureDic[configId] or 0)
    self:setCountLab()
  end
end

function HomeWarehouseLoopItem:UnInit()
  Z.EventMgr:RemoveObjAll()
end

return HomeWarehouseLoopItem
