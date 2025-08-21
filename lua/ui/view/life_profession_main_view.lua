local UI = Z.UI
local super = require("ui.ui_view_base")
local Life_profession_mainView = class("Life_profession_mainView", super)

function Life_profession_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "life_profession_main")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.lifeProfessionVM_ = Z.VMMgr.GetVM("life_profession")
  self.lifeWorkVM_ = Z.VMMgr.GetVM("life_work")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.lifeProfessionWorkData = Z.DataMgr.Get("life_profession_work_data")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Life_profession_mainView:OnActive()
  self.curProfessionTableRow_ = nil
  self:initBtnClick()
  self:refreshGridView(true)
  self.uiBinder.lab_title.text = Lang("LifeProfessionMainTitle")
  self:bindEvents()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.eff_ui_loop)
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.eff_ui_loop:SetEffectGoVisible(true)
  self.uiBinder.eff_ui_loop:Play()
end

function Life_profession_mainView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionLevelChanged, self.lifeProfessionLevelChanged, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionExpChanged, self.lifeProfessionExpChanged, self)
end

function Life_profession_mainView:lifeProfessionLevelChanged(proID)
  self:refreshGridView()
  if self.curProfessionTableRow_ ~= nil and self.curProfessionTableRow_.ProId == proID then
    self:refreshRightInfo()
  end
end

function Life_profession_mainView:lifeProfessionExpChanged(proID)
  self:refreshGridView()
  if self.curProfessionTableRow_ ~= nil and self.curProfessionTableRow_.ProId == proID then
    self:refreshRightInfo()
  end
end

function Life_profession_mainView:OnDeActive()
  self.curProfessionTableRow_ = nil
  Z.EventMgr:RemoveObjAll(self)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.eff_ui_loop)
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
end

function Life_profession_mainView:OnRefresh()
end

function Life_profession_mainView:refreshGridView(isInit)
  self.proDict_ = {}
  local dataList = self.lifeProfessionVM_.GetAllProfessions()
  Z.CoroUtil.create_coro_xpcall(function()
    if isInit then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.content, false)
    end
    self:initBtnList(dataList)
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    self.uiBinder.content_layout:SetLayoutGroup()
    if isInit then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.content, true)
    end
    if self.viewData and self.viewData.professionID then
      for k, v in pairs(dataList) do
        if v.ProId == self.viewData.professionID then
          self:OnSeletItem(v)
          self.viewData.professionID = nil
          if self.viewData.showUnlockPopup and self.lifeProfessionVM_.IsLifeProfessionFuncUnlocked(self.curProfessionTableRow_.ProId, false) then
            self.lifeProfessionVM_.OpenUnlockProfessionWindow(self.curProfessionTableRow_.ProId)
            self.viewData.showUnlockPopup = nil
          end
          return
        end
      end
    end
    if self.curProfessionTableRow_ == nil then
      self:OnSeletItem(dataList[1])
    end
  end)()
end

function Life_profession_mainView:initBtnList(dataList)
  for _, v in pairs(self.proDict_) do
    self:RemoveUiUnit(v)
  end
  self.itemList_ = {}
  self.proDict_ = {}
  for _, v in pairs(dataList) do
    self.proDict_[v.ProId] = "proItem" .. tostring(v.ProId)
  end
  for _, v in pairs(dataList) do
    local proId = v.ProId
    local prefabName = v.weight == 1 and "btn" or "long_btn"
    local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, prefabName)
    if not self.itemList_[proId] then
      self.itemList_[proId] = self:AsyncLoadUiUnit(path, self.proDict_[proId], self.uiBinder.content, self.cancelSource:CreateToken())
    end
    local item = self.itemList_[proId]
    self:refreshProBtn(item, v)
  end
end

function Life_profession_mainView:refreshProBtn(item, professionData)
  item.rimg_pic:SetImage(professionData.BgPic)
  item.lab_sys_name.text = professionData.Name
  item.lab_level.text = Lang("LifeProfessionLevel", {
    val = self.lifeProfessionVM_.GetLifeProfessionLv(professionData.ProId)
  })
  local isUnlocked = self.lifeProfessionVM_.IsLifeProfessionUnlocked(professionData.ProId)
  if not isUnlocked then
    item.lab_level.text = Lang("common_lock")
  end
  item.Ref:SetVisible(item.img_lock, not isUnlocked)
  if professionData.Icon ~= "" then
    item.img_sys_icon:SetImage(professionData.Icon)
  end
  item.btn:RemoveAllListeners()
  item.btn:AddListener(function()
    self:OnSeletItem(professionData)
  end)
  local isUnlocked = self.lifeProfessionVM_.IsLifeProfessionUnlocked(professionData.ProId)
  item.Ref:SetVisible(item.lock_root, not isUnlocked)
  local proRedID = self.lifeProfessionData_:GetRedPointID(professionData.ProId)
  Z.RedPointMgr.LoadRedDotItem(proRedID, self, item.Trans)
  local proWorkRed = self.lifeProfessionWorkData:GetRedPointID(professionData.ProId)
  Z.RedPointMgr.LoadRedDotItem(proWorkRed, self, item.Trans)
end

function Life_profession_mainView:OnSeletItem(professionData)
  if self.curProfessionTableRow_ ~= nil and self.curProfessionTableRow_.ProId == professionData.ProId then
    return
  end
  self.curProfessionTableRow_ = professionData
  self:refreshRightInfo()
  for k, v in pairs(self.proDict_) do
    self.units[v].anim:Rewind(Z.DOTweenAnimType.Open)
    if k == professionData.ProId then
      self.units[v].anim:Restart(Z.DOTweenAnimType.Open)
    end
    self.units[v].Ref:SetVisible(self.units[v].img_select, k == professionData.ProId)
  end
end

function Life_profession_mainView:refreshRightInfo()
  if self.curProfessionTableRow_ == nil then
    return
  end
  self.uiBinder.rimg_pic:SetImage(self.curProfessionTableRow_.BgPic)
  self.uiBinder.img_sys_icon:SetImage(self.curProfessionTableRow_.Icon)
  self.uiBinder.lab_sys_name.text = self.curProfessionTableRow_.Name
  self.uiBinder.lab_level.text = Lang("LifeProfessionLevel", {
    val = self.lifeProfessionVM_.GetLifeProfessionLv(self.curProfessionTableRow_.ProId)
  })
  local curExp, maxExp = self.lifeProfessionVM_.GetLifeProfessionExp(self.curProfessionTableRow_.ProId)
  local isNowMaxLevel = self.lifeProfessionVM_.IsLifeProfessionMaxLevel(self.curProfessionTableRow_.ProId)
  self.uiBinder.lab_exp.text = isNowMaxLevel and Lang("LifeProfessionMaxLevel") or Lang("LifeProfessionExp", {cur = curExp, max = maxExp})
  self.uiBinder.img_slider_bar.fillAmount = maxExp == 0 and 1 or curExp / maxExp
  local isUnlocked = self.lifeProfessionVM_.IsLifeProfessionUnlocked(self.curProfessionTableRow_.ProId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_exp, isUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_slider_bar_bg, isUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, isUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock, not isUnlocked)
  local proRedID = self.lifeProfessionData_:GetRedPointID(self.curProfessionTableRow_.ProId)
  local showRP = Z.RedPointMgr.GetRedState(proRedID)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, showRP)
  local proWorkRed = self.lifeProfessionWorkData:GetRedPointID(self.curProfessionTableRow_.ProId)
  local showWorkRP = Z.RedPointMgr.GetRedState(proWorkRed)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot_work, showWorkRP)
  self.uiBinder.lab_desc.text = self.curProfessionTableRow_.Des
  if not isUnlocked then
    local allPass = self:refreshUnlockConditions()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, allPass)
  end
end

function Life_profession_mainView:refreshUnlockConditions()
  local showFunc = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(self.curProfessionTableRow_.FunctionId)
  if showFunc == nil then
    return
  end
  local descList_ = {}
  local allPass = true
  if showFunc.TimerId ~= 0 then
    local pass, error, params = self.switchVm_.CheckTime(showFunc)
    table.insert(descList_, self:getConditionData(pass, error, params))
    if not pass then
      allPass = false
    end
  end
  if showFunc.RoleLevel and 0 < showFunc.RoleLevel then
    local pass, error, params = self.switchVm_.CheckLevel(showFunc)
    table.insert(descList_, self:getConditionData(pass, error, params))
    if not pass then
      allPass = false
    end
  end
  if 0 < showFunc.QuestId or #showFunc.QuestStepId >= 2 then
    local pass, error, params = self.switchVm_.CheckQuest(showFunc)
    table.insert(descList_, self:getConditionData(pass, error, params))
    if not pass then
      allPass = false
    end
  end
  self:createCondition(descList_)
  return allPass
end

function Life_profession_mainView:getConditionData(pass, error, params)
  local desc = {}
  desc.des = Lang("Function" .. error, params)
  desc.pass = pass
  return desc
end

function Life_profession_mainView:createCondition(descList)
  if self.confitionDict ~= nil then
    for _, v in pairs(self.confitionDict) do
      self:RemoveUiUnit(v)
    end
  end
  self.confitionDict = {}
  for i = 1, #descList do
    table.insert(self.confitionDict, "cond_" .. i)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local path_ = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "condition_tpl")
    for k, v in pairs(descList) do
      local name_ = self.confitionDict[k]
      local condition = self:AsyncLoadUiUnit(path_, name_, self.uiBinder.node_conditions)
      condition.lab_unlock_conditions.text = v.des
      condition.Ref:SetVisible(condition.img_off, not v.pass)
      condition.Ref:SetVisible(condition.img_on, v.pass)
    end
  end)()
end

function Life_profession_mainView:initBtnClick()
  self:AddClick(self.uiBinder.btn_detail, function()
    self.lifeProfessionVM_.OpenLifeProfessionInfoView(self.curProfessionTableRow_.ProId)
  end)
  self:AddClick(self.uiBinder.btn_guide, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(2101)
  end)
  self:AddClick(self.uiBinder.node_btn_close, function()
    self.lifeProfessionVM_.CloseLifeProfessionMainView()
  end)
  self:AddClick(self.uiBinder.btn_work, function()
    self.lifeWorkVM_.OpenLifeWorkView()
  end)
  self:AddClick(self.uiBinder.btn_unlock, function()
    if not self.lifeProfessionVM_.IsLifeProfessionFuncUnlocked(self.curProfessionTableRow_.ProId, false) then
      return
    end
    self.lifeProfessionVM_.OpenUnlockProfessionWindow(self.curProfessionTableRow_.ProId)
  end)
end

return Life_profession_mainView
