local ItemTraceVm = {}
local itemTraceData = Z.DataMgr.Get("item_trace_data")

function ItemTraceVm.ShowTraceView(configId, traceItemList)
  itemTraceData:SetTraceItemData(configId, traceItemList)
  Z.EventMgr:Dispatch(Z.ConstValue.RefreshItemTrace)
  Z.TipsVM.ShowTips(122024)
end

function ItemTraceVm.CloseTraceView()
  itemTraceData:CancelTraceCurTraceItem()
  Z.EventMgr:Dispatch(Z.ConstValue.RefreshItemTrace)
end

function ItemTraceVm.TraceExchangeItem(configId, consumables)
  local data = {}
  for index, value in ipairs(consumables) do
    data[index] = {
      ItemId = value.id,
      ItemNum = value.consumeNum,
      LabType = E.ItemLabType.Expend,
      IsOpenSource = true
    }
  end
  ItemTraceVm.ShowTraceView(configId, data)
end

function ItemTraceVm.OpenTracePopup()
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", itemTraceData.CurTraceItemId)
  if itemRow == nil then
    return
  end
  local data = {
    dlgType = E.DlgType.YesNo,
    labOK = Lang("BtnYes"),
    labNo = Lang("StopTrace"),
    labTitle = Lang("MaterialTracking"),
    labDesc = Lang("MakeItemTips", {
      val = itemRow.Name
    }),
    onCancel = function()
      ItemTraceVm.CloseTraceView()
    end,
    itemList = itemTraceData.CurTraceMaterialList
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

return ItemTraceVm
