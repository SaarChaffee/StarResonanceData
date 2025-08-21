local UI = Z.UI
local super = require("ui.ui_subview_base")
local Sevendaystarget_preview_subView = class("Sevendaystarget_preview_subView", super)
local loopListView = require("ui.component.loop_list_view")
local featurePreviewTabLoopItem = require("ui.component.sevendaystarget.feature_preview_tab_loop_item")

function Sevendaystarget_preview_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "sevendaystarget_preview_sub", "sevendaystarget/sevendaystarget_preview_sub", UI.ECacheLv.None)
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.vm = Z.VMMgr.GetVM("function_preview")
  self.data = Z.DataMgr.Get("function_preview_data")
  self.parent_ = parent
end

function Sevendaystarget_preview_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  if self.viewData and self.viewData.funcId then
    self.funcId = self.viewData.funcId
  else
    self.funcId = nil
  end
  self.taskItemList_ = {}
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initLoopListView()
  
  function self.onFuncDataChange_()
    self:refreshRightUI()
  end
  
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
  Z.ContainerMgr.CharSerialize.FunctionData.Watcher:RegWatcher(self.onFuncDataChange_)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
end

function Sevendaystarget_preview_subView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unInitLoopListView()
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
  Z.ContainerMgr.CharSerialize.FunctionData.Watcher:UnregWatcher(self.onFuncDataChange_)
  self.parent_.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
end

function Sevendaystarget_preview_subView:OnRefresh()
  self:refreshUI()
end

function Sevendaystarget_preview_subView:refreshUI()
  self:refreshLoopListView()
end

function Sevendaystarget_preview_subView:OnClickTab(func)
  self.showFunc = func
  self:refreshRightUI()
end

function Sevendaystarget_preview_subView:refreshRightUI()
  if self.showFunc then
    local funcPreviewCfg = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetRow(self.showFunc.Id)
    self.uiBinder.img_con:SetImage(self.showFunc.Icon)
    if funcPreviewCfg then
      self.uiBinder.rimg_picture:SetImage(funcPreviewCfg.PreviewPic)
      self.uiBinder.lab_info.text = funcPreviewCfg.PreviewText
    end
    self.uiBinder.lab_name.text = self.showFunc.Name
    local state = self.vm.GetAwardState(self.showFunc.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_canget, state == E.FuncPreviewAwardState.CanGet)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot, state == E.FuncPreviewAwardState.CanGet)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cantget, state == E.FuncPreviewAwardState.CantGet)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_complete, state == E.FuncPreviewAwardState.Complete)
    self.uiBinder.btn_canget:RemoveAllListeners()
    self.uiBinder.btn_cantget:RemoveAllListeners()
    self:AddAsyncClick(self.uiBinder.btn_canget, function()
      if self.showFunc then
        local success = self.vm.ReqGetAward(self.showFunc.Id, self.cancelSource:CreateToken())
        if success then
          self:refreshListAllShownItem()
        end
      end
    end)
    self:AddClick(self.uiBinder.btn_cantget, function()
      local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
      if self.showFunc then
        local cfgData = Z.TableMgr.GetTable("FunctionPreviewTableMgr").GetRow(self.showFunc.Id)
        if cfgData == nil then
          return
        end
        local awardList = awardPreviewVm.GetAllAwardPreListByIds(cfgData.PreviewAward)
        awardPreviewVm.OpenRewardDetailViewByListData(awardList, nil, E.DlgType.OK)
      end
    end)
    local descList_ = {}
    if self.showFunc.TimerId ~= 0 then
      local pass, error, params = self.switchVm_.CheckTime(self.showFunc)
      local desc_ = {}
      desc_.des = Lang("Function" .. error, params)
      desc_.pass = pass
      if not pass then
        table.insert(descList_, desc_)
      end
    end
    if self.showFunc.RoleLevel and 0 < self.showFunc.RoleLevel then
      local pass, error, params = self.switchVm_.CheckLevel(self.showFunc)
      local desc_ = {}
      desc_.des = Lang("Function" .. error, params)
      desc_.pass = pass
      if not pass then
        table.insert(descList_, desc_)
      end
    end
    if 0 < self.showFunc.QuestId or #self.showFunc.QuestStepId >= 2 then
      local pass, error, params = self.switchVm_.CheckQuest(self.showFunc)
      local desc_ = {}
      desc_.des = Lang("Function" .. error, params)
      desc_.pass = pass
      if not pass then
        table.insert(descList_, desc_)
      end
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_task, 0 < #descList_)
    self:createReason(descList_)
  end
end

function Sevendaystarget_preview_subView:createReason(descList)
  if self.isCreateReason_ then
    return
  end
  for _, v in ipairs(self.taskItemList_) do
    self:RemoveUiUnit(v)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.isCreateReason_ = true
    local path_ = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "tasktpl")
    for k, v in ipairs(descList) do
      local name_ = "preview_task_" .. k
      local taskBinder_ = self:AsyncLoadUiUnit(path_, name_, self.uiBinder.node_task)
      self:setTask(taskBinder_, v.des, v.pass)
      table.insert(self.taskItemList_, name_)
    end
    self.isCreateReason_ = false
  end)()
end

function Sevendaystarget_preview_subView:setTask(binder, des, isFinish)
  binder.lab_title.text = des
  binder.Ref:SetVisible(binder.img_on, isFinish)
end

function Sevendaystarget_preview_subView:initLoopListView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_first_togs, featurePreviewTabLoopItem, "feature_preview_tog_tpl")
  self.loopListView_:Init({})
end

function Sevendaystarget_preview_subView:refreshLoopListView()
  local dataListTmp_ = self.switchVm_.GetAllFeature(true)
  local dataList_ = {}
  if #dataListTmp_ > Z.Global.FunctionPreviewCount then
    for i = 1, Z.Global.FunctionPreviewCount do
      table.insert(dataList_, dataListTmp_[i])
    end
  else
    dataList_ = dataListTmp_
  end
  table.sort(dataList_, function(a, b)
    local stateA = self.vm.GetAwardState(a.Id)
    local stateB = self.vm.GetAwardState(b.Id)
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
  local startIndex = 1
  if self.funcId then
    for k, v in ipairs(dataList_) do
      if self.funcId == v.Id then
        startIndex = k
        break
      end
    end
  end
  self.loopListView_:ClearAllSelect()
  self.loopListView_:RefreshListView(dataList_)
  self.loopListView_:SetSelected(startIndex)
end

function Sevendaystarget_preview_subView:refreshListAllShownItem()
  if self.loopListView_ then
    self.loopListView_:RefreshAllShownItem()
  end
end

function Sevendaystarget_preview_subView:unInitLoopListView()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

return Sevendaystarget_preview_subView
