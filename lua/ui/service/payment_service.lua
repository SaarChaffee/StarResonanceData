local super = require("ui.service.service_base")
local PaymentService = class("PaymentService", super)

function PaymentService:OnInit()
  function self.currencyChangeFunc(container, dirtyKeys)
    if dirtyKeys.currencyDatas then
      local paymentData = Z.DataMgr.Get("payment_data")
      
      for k, v in pairs(dirtyKeys.currencyDatas) do
        if k == Z.SystemItem.ItemDiamond and paymentData:GetPaymentResponseEvent() then
          Z.EventMgr:Dispatch(Z.ConstValue.Shop.PaymentResponse)
          return
        end
      end
    end
  end
end

function PaymentService:OnLateInit()
end

function PaymentService:OnUnInit()
end

function PaymentService:OnLogin()
  local paymentVm = Z.VMMgr.GetVM("payment")
  paymentVm:ProcessPendingPaymentTransaction()
end

function PaymentService:initCacheData(checkFinish)
end

function PaymentService:OnSyncAllContainerData()
  Z.ContainerMgr.CharSerialize.itemCurrency.Watcher:RegWatcher(self.currencyChangeFunc)
end

function PaymentService:OnLogout()
  Z.ContainerMgr.CharSerialize.itemCurrency.Watcher:UnregWatcher(self.currencyChangeFunc)
end

function PaymentService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetRow("SceneTableMgr", sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    Z.CoroUtil.create_coro_xpcall(function()
      local paymentVm = Z.VMMgr.GetVM("payment")
      paymentVm:AsyncQueryBalance()
      paymentVm:AsyncQueryBalance(nil, Z.PbEnum("EQueryBalanceType", "EQueryBalanceTypeMonthCard"))
      paymentVm:AysncQueryProduct(nil, ZUtil.ZCancelSource.NeverCancelToken)
    end)()
  end
end

function PaymentService:OnLeaveScene()
end

return PaymentService
