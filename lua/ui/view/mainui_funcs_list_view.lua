local UI = Z.UI
local super = require("ui.ui_view_base")
local Mainui_funcs_listView = class("Mainui_funcs_listView", super)

function Mainui_funcs_listView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mainui_funcs_list")
  self.mainUIFuncsListVm_ = Z.VMMgr.GetVM("mainui_funcs_list")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
  self.funcPreviewVM_ = Z.VMMgr.GetVM("function_preview")
  self.isInit_ = false
end

function Mainui_funcs_listView:initBinder()
  self.cont_btn_return_ = self.uiBinder.cont_btn_return.btn
  self.anim_ = self.uiBinder.anim
  self.btn_rank_condition_ = self.uiBinder.btn_rank_condition
  self.img_icon_ = self.uiBinder.img_icon
  self.lab_name_ = self.uiBinder.lab_name
  self.lab_grade_ = self.uiBinder.lab_grade
  self.itemList_ = {}
end

function Mainui_funcs_listView:OnActive()
  self:initBinder()
  self:AddClick(self.cont_btn_return_, function()
    self.mainUIFuncsListVm_.CloseView()
  end)
  self:AddClick(self.btn_rank_condition_, function()
    local funcPreviewVM = Z.VMMgr.GetVM("function_preview")
    funcPreviewVM.OpenFuncPreviewWindow()
  end)
  self:AddClick(self.uiBinder.btn_setting, function()
    Z.UIMgr:OpenView("setting")
  end)
  self:AddAsyncClick(self.uiBinder.btn_detach, function()
    local playerVM = Z.VMMgr.GetVM("player")
    playerVM:OpenUnstuckTip()
  end)
  self.funckeyDict_ = {}
  local mainFuncCfgs = Z.TableMgr.GetTable("MainIconTableMgr").GetDatas()
  for _, v in pairs(mainFuncCfgs) do
    self.funckeyDict_[v.Id] = "settingitem" .. v.Id
  end
  self:BindEvents()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, true, self.viewConfigKey)
  Z.CoroUtil.create_coro_xpcall(function()
    local dataList = self.mainUIFuncsListVm_.GetAllOpenFuncId()
    self:initBtnList(dataList)
    self:closeAllUnLockEffect()
  end)()
  if not self.isInit_ then
    self.isInit_ = true
    self.rect_loop_width_, self.rect_loop_height_ = self.uiBinder.loop_menu:GetSizeDelta(nil, nil)
    self.rect_rank_condition_width_, self.rect_rank_condition_height_ = self.uiBinder.rect_rank_condition:GetSizeDelta(nil, nil)
  end
end

function Mainui_funcs_listView:refreshLoopGridView()
  Z.CoroUtil.create_coro_xpcall(function()
    local dataList = self.mainUIFuncsListVm_.GetAllOpenFuncId()
    self:initBtnList(dataList)
  end)()
end

function Mainui_funcs_listView:unInitLoopGridView()
  self.itemList_ = nil
end

function Mainui_funcs_listView:OnDeActive()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  if self.rect_loop_width_ ~= nil and self.rect_loop_height_ ~= nil then
    self.uiBinder.loop_menu:SetSizeDelta(self.rect_loop_width_, self.rect_loop_height_)
  end
  self:unInitLoopGridView()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, false, self.viewConfigKey)
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, false)
  self.funckeyDict_ = nil
end

function Mainui_funcs_listView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionIcon, self.refreshLoopGridView, self)
  Z.EventMgr:Add(Z.ConstValue.ShowMainFeatureUnLockEffect, self.onShowUnLockEffect, self)
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
end

function Mainui_funcs_listView:OnRefresh()
  self.mainUiVm_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, true)
  local isShowCondition = self:refreshFeaturePreview()
  self:startAnimatedShow(isShowCondition)
end

function Mainui_funcs_listView:OnHideHalfScreenView(isOpen, viewConfigKey)
  if isOpen and self.viewConfigKey ~= viewConfigKey then
    self.mainUIFuncsListVm_.CloseView()
  end
end

function Mainui_funcs_listView:startAnimatedShow(isShowCondition)
  if isShowCondition then
    self.anim_:Restart(Z.DOTweenAnimType.Open)
  else
    self.anim_:Restart(Z.DOTweenAnimType.Tween_0)
  end
end

function Mainui_funcs_listView:refreshFeaturePreview()
  local switchVm = Z.VMMgr.GetVM("switch")
  local lockedFeature = switchVm.GetAllFeature(true)
  local isBtnRankConditionVisible = false
  if lockedFeature then
    table.sort(lockedFeature, function(a, b)
      local stateA = self.funcPreviewVM_.GetAwardState(a.Id)
      local stateB = self.funcPreviewVM_.GetAwardState(b.Id)
      local previewCfgA = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetRow(a.Id)
      local previewCfgB = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetRow(b.Id)
      if stateA ~= stateB then
        return stateA < stateB
      else
        if previewCfgA and previewCfgB then
          return previewCfgA.Preview < previewCfgB.Preview
        end
        return 1
      end
    end)
    local feature = lockedFeature[1]
    local functionPreviewVM = Z.VMMgr.GetVM("function_preview")
    local allGet = functionPreviewVM.CheckAllFuncOpen()
    if not feature or allGet then
      self.uiBinder.Ref:SetVisible(self.btn_rank_condition_, false)
      isBtnRankConditionVisible = false
    else
      self.uiBinder.Ref:SetVisible(self.btn_rank_condition_, true)
      isBtnRankConditionVisible = true
      self.img_icon_:SetImage(feature.Icon)
      self.lab_name_.text = feature.Name
      Z.RedPointMgr.LoadRedDotItem(E.RedType.FuncPreviewESC, self, self.uiBinder.preview_red_holder)
    end
  else
    self.uiBinder.Ref:SetVisible(self.btn_rank_condition_, false)
    isBtnRankConditionVisible = false
  end
  if isBtnRankConditionVisible then
    self.uiBinder.loop_menu:SetSizeDelta(self.rect_loop_width_, self.rect_loop_height_)
  else
    self.uiBinder.loop_menu:SetSizeDelta(self.rect_loop_width_, self.rect_loop_height_ + self.rect_rank_condition_height_)
  end
  return isBtnRankConditionVisible
end

function Mainui_funcs_listView:initBtnList(dataList)
  for _, v in pairs(self.funckeyDict_) do
    self:RemoveUiUnit(v)
  end
  self.itemList_ = {}
  local grayList = self.mainUiVm_.GetUnclickableFuncsInScene()
  for _, num in ipairs(dataList) do
    local iconRow = Z.TableMgr.GetTable("MainIconTableMgr").GetRow(num)
    if iconRow then
      do
        local funcId = iconRow.Id
        local iconName = iconRow.EnlargeIcon == false and "btn" or "long_btn"
        local path = self:GetPrefabCacheDataNew(self.uiBinder.prefab_root, iconName)
        if not self.itemList_[funcId] then
          self.itemList_[funcId] = self:AsyncLoadUiUnit(path, self.funckeyDict_[funcId], self.uiBinder.node_content, self.cancelSource:CreateToken())
        end
        local item = self.itemList_[funcId]
        if item then
          item.Ref:SetVisible(item.node_root, true)
          Z.GuideMgr:SetSteerIdByComp(item.mainicon_btn_tpl, E.DynamicSteerType.FunctionId, funcId)
          Z.RedPointMgr.LoadRedDotItem(funcId, self, item.Trans)
          item.img_icon:SetImage(iconRow.Icon)
          do
            local funcRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(funcId)
            if funcRow then
              item.lab_content.text = funcRow.Name
            end
            local alpha = grayList[funcId] == nil and 1 or 0.3
            item.group_btn.alpha = alpha
            item.btn.IsDisabled = grayList[funcId] ~= nil
            item.Ref:SetVisible(item.img_select, false)
            item.btn_audio:AddAudioEvent(iconRow.Path, 3)
            item.btn:AddListener(function()
              local canClick = grayList[funcId] == nil
              if canClick then
                local gotoVM = Z.VMMgr.GetVM("gotofunc")
                gotoVM.GoToFunc(iconRow.Id)
                Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvnet, string.zconcat(E.SteerGuideEventType.SelectedMainFunction, "=", iconRow.Id))
              else
                Z.TipsVM.ShowTips(1001604)
              end
            end)
          end
        end
      end
    end
  end
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.timer_ = self.timerMgr:StartFrameTimer(function()
    self.uiBinder.layout_content:SetLayoutGroup()
  end, 1, 1)
end

function Mainui_funcs_listView:onShowUnLockEffect(id)
  local item = self.itemList_[id]
  if item then
    item.effect:SetEffectGoVisible(true)
  end
end

function Mainui_funcs_listView:closeAllUnLockEffect()
  for _, item in pairs(self.itemList_) do
    item.effect:SetEffectGoVisible(false)
  end
end

return Mainui_funcs_listView
