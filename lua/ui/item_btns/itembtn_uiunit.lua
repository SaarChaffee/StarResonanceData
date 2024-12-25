local ItemBtnUnit = class("ItemOperatBtnView")

function ItemBtnUnit:ctor()
  self.view_ = nil
  self.btnInfo_ = nil
  self.btnBinder_ = nil
  self.btn_ = nil
  self.line_ = nil
  self.unit = nil
  self.cancelToken = nil
  self.itemUuId_ = nil
  self.configId_ = nil
  self.IsLoad = false
end

function ItemBtnUnit:AsyncInit_Go(view, itemUuId, configId, btnInfos, parent, hidLine, data)
  self.view_ = view
  self.btnInfo_ = btnInfos
  self.itemUuId_ = itemUuId
  self.configId_ = configId
  self.data_ = data
  self.IsLoad = true
end

function ItemBtnUnit:Init_Go(view, itemUuId, configId, btnInfos, uiBinder, data)
  self.view_ = view
  self.itemUuId_ = itemUuId
  self.configId_ = configId
  self.btnInfo_ = btnInfos
  self.IsLoad = false
  self.data_ = data
  self.IsLoad = false
  self.uiBinder_ = uiBinder
  self.btn_ = uiBinder.btn
  self.btnBinder_ = uiBinder
  self:refresh()
end

function ItemBtnUnit:refresh()
  local isShow = self.btnInfo_.state ~= E.ItemBtnState.Hide
  if self.unit then
    self.unit:SetVisible(isShow)
  end
  if self.uiBinder_ then
    self.uiBinder_.Ref.UIComp:SetVisible(isShow)
  end
  self.redName_ = Z.ItemOperatBtnMgr.LoadRedNode(self.btnInfo_.key, self.itemUuId_, self.configId_)
  if self.redName_ then
    Z.RedPointMgr.LoadRedDotItem(self.redName_, self.view_, self.uiBinder_.Trans)
  end
  self.view_:AddAsyncClick(self.btn_, function()
    local data = self.data_
    data.cancelToken = self.data_.cancelSource:CreateToken()
    Z.ItemOperatBtnMgr.OnClick(self.btnInfo_.key, self.itemUuId_, self.configId_, data)
  end, nil, nil)
  self.btnBinder_.lab_content.text = Z.ItemOperatBtnMgr.GetBtnName(self.btnInfo_.key, self.itemUuId_, self.configId_, self.data_)
end

function ItemBtnUnit:UnInit()
  if self.cancelToken then
    self.view_.cancelSource:CancelToken(self.cancelToken)
  end
  if self.unit then
    self.view_:RemoveUiUnit(self.unitName_)
  end
  if self.btn_ then
    self.btn_:RemoveAllListeners()
  end
  self.view_ = nil
  self.btnInfo_ = nil
  self.btnBinder_ = nil
  self.btn_ = nil
  self.timer = nil
  self.unit = nil
  self.cancelToken = nil
  self.itemUuId_ = nil
  self.configId_ = nil
end

return ItemBtnUnit
