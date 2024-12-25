local UI = Z.UI
local itemClass = require("common.item")
local super = require("ui.ui_subview_base")
local TipsPopupView = class("TipsPopupView", super)
local WIDTH_VALUE_DICT = {}
WIDTH_VALUE_DICT[E.TipsPopupStyle.Small] = 380
WIDTH_VALUE_DICT[E.TipsPopupStyle.Medium] = 448
WIDTH_VALUE_DICT[E.TipsPopupStyle.Large] = 560
WIDTH_VALUE_DICT[E.TipsPopupStyle.ExtraLarge] = 648
local DEFAULT_TITLE_COLOR = Color.New(1, 1, 1, 1)
local DEFAULT_DESC_COLOR = Color.New(1, 1, 1, 1)
local DEFAULT_BTN_COLOR = Color.New(0.23137254901960785, 0.25098039215686274, 0.28627450980392155, 1)
local loopScrollRect_ = require("ui/component/loopscrollrect")

function TipsPopupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_popup", "tips/tips_popup", UI.ECacheLv.None)
end

function TipsPopupView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      self:closeTipsView()
    end
  end, nil, nil)
  self.itemClassTab_ = {}
  self:BindEvents()
  self:bindParentPressPointCheck()
end

function TipsPopupView:OnDeActive()
  Z.CommonTipsVM.CloseUnderline()
  if not self.IsActive then
    return
  end
  Z.CommonTipsVM.CloseRichText()
  for _, itemClass in pairs(self.itemClassTab_) do
    itemClass:UnInit()
  end
  self.uiBinder.presscheck:StopCheck()
  self:UnBindEvents()
  self:unBindParentPressPointCheck()
end

function TipsPopupView:OnRefresh()
  self.viewData.extraParams = self.viewData.extraParams or {}
  self:setProperty()
  self:setStyle()
  self:setNode()
end

function TipsPopupView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.TipsRefreshNode, self.refreshNodeData, self)
  Z.EventMgr:Add(Z.ConstValue.UnderLineTipsClose, self.setProperty, self)
end

function TipsPopupView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.TipsRefreshNode, self.refreshNodeData, self)
  Z.EventMgr:Remove(Z.ConstValue.UnderLineTipsClose, self.setProperty, self)
end

function TipsPopupView:refreshNodeData()
  Z.CoroUtil.create_coro_xpcall(function()
    self.timerMgr:Clear()
    self:ClearAllUnits()
    self:asyncInitNode()
    self:setPosition()
  end)()
end

function TipsPopupView:bindParentPressPointCheck()
  if self.viewData.tipsBindPressCheckComp ~= nil then
    self.viewData.tipsBindPressCheckComp:AddChildPointPressCheck(self.uiBinder.presscheck)
  end
end

function TipsPopupView:unBindParentPressPointCheck()
  if self.viewData.tipsBindPressCheckComp ~= nil then
    self.viewData.tipsBindPressCheckComp:RemoveChildPointPressCheck(self.uiBinder.presscheck)
  end
end

function TipsPopupView:closeTipsView()
  if not self.IsActive then
    return
  end
  if self.viewData.extraParams.closeCallBack then
    self.viewData.extraParams.closeCallBack()
  end
  Z.TipsVM.CloseItemTipsView(self.viewData.tipsId)
end

function TipsPopupView:setProperty()
  if not self.viewData.extraParams.isResident then
    self.uiBinder.presscheck:StartCheck()
  else
    self.uiBinder.presscheck:StopCheck()
  end
end

function TipsPopupView:setStyle()
  local width = WIDTH_VALUE_DICT[self.viewData.style]
  self.uiBinder.img_bg_ref:SetWidth(width)
  local pivotX = self.viewData.extraParams.pivotX or 0.5
  local pivotY = self.viewData.extraParams.pivotY or 1
  self.uiBinder.img_bg_ref:SetPivot(pivotX, pivotY)
  local anchorY = self.viewData.extraParams.anchorY or 0.5
  self.uiBinder.img_bg_ref:SetAnchors(0.5, 0.5, anchorY, anchorY)
  local isShowBg = self.viewData.extraParams.isShowBg == nil or self.viewData.extraParams.isShowBg == true
  self.uiBinder.img_bg.enabled = isShowBg
end

function TipsPopupView:setLabelText(comp, str, color, ignoreColor)
  if str == nil or str == "" then
    comp:SetVisible(false)
  else
    comp:SetVisible(true)
    Z.RichTextHelper.SetTmpLabTextWithCommonLink(comp, str)
    if not ignoreColor then
      comp.TMPLab.color = color or DEFAULT_DESC_COLOR
    end
  end
end

function TipsPopupView:setColorText(comp, str, colorKey)
  if str == nil or str == "" then
    comp:SetVisible(false)
  else
    if colorKey then
      str = Z.RichTextHelper.ApplyStyleTag(str, colorKey)
    end
    comp.TMPLab.text = str
  end
end

function TipsPopupView:setNode()
  Z.CoroUtil.create_coro_xpcall(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_ref, false)
    self:asyncInitNode()
    self:setPosition()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    if self.uiBinder then
      self.uiBinder.scrollview_content.verticalNormalizedPosition = 1
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg_ref, true)
      self:startAnimatedShow()
    end
  end)()
end

function TipsPopupView:asyncInitNode()
  for index, nodeData in ipairs(self.viewData.nodeDataList) do
    local funcGenerate = self["generateNodeByType" .. nodeData.Type]
    if funcGenerate then
      funcGenerate(self, nodeData, index)
    end
  end
end

function TipsPopupView:setPosition()
  self.uiBinder.content_layout:ForceRebuildLayoutImmediate()
  self.uiBinder.img_layout:ForceRebuildLayoutImmediate()
  if self.viewData.extraParams.fixedPos then
    self.uiBinder.img_bg_ref.position = self.viewData.extraParams.fixedPos
  elseif self.viewData.posTrans then
    self.uiBinder.presscheck_adaptpos:UpdatePosition(self.viewData.posTrans, true)
  else
    self.uiBinder.img_bg_ref:SetLocalPos(0, 0)
  end
  if self.viewData.extraParams.posOffset then
    local posSource = self.uiBinder.img_bg_ref.localPosition
    posSource = posSource + self.viewData.extraParams.posOffset
    self.uiBinder.img_bg_ref:SetLocalPos(posSource.x, posSource.y, posSource.z)
  end
end

function TipsPopupView:generateNodeByType1(nodeData, index, targetNode)
  local titleData = nodeData
  titleData.TitleColor = titleData.TitleColor or DEFAULT_TITLE_COLOR
  titleData.TitleAdditionColor = titleData.TitleAdditionColor or DEFAULT_TITLE_COLOR
  local path = self.uiBinder.prefab_cache:GetString("titleNode")
  local node = targetNode or self:AsyncLoadUiUnit(path, "titleNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
  if node ~= nil then
    self:setLabelText(node.lab_title, titleData.Title, titleData.TitleColor)
    self:setLabelText(node.lab_title_addition, titleData.TitleAddition, titleData.TitleAdditionColor)
    node.img_bg:SetVisible(titleData.IsShowBg)
    node.lab_title_addition:SetVisible(titleData.TitleAddition and titleData.TitleAddition ~= "")
    node.Ref.LayoutElement.preferredHeight = titleData.MinHight or 34
  end
end

function TipsPopupView:generateNodeByType2(nodeData, index, targetNode)
  local lineData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("lineNode")
  local node = targetNode or self:AsyncLoadUiUnit(path, "lineNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
  if node ~= nil then
    node.Ref.LayoutElement.preferredHeight = lineData.MinHight or 26
  end
end

function TipsPopupView:generateNodeByType3(nodeData, index)
  local descData = nodeData
  descData.Color = descData.Color or DEFAULT_DESC_COLOR
  local path = self.uiBinder.prefab_cache:GetString("descNode")
  local node = self:AsyncLoadUiUnit(path, "descNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
  if node ~= nil then
    self:setLabelText(node.lab_desc, descData.Desc, descData.Color)
    node.Ref.LayoutElement.preferredHeight = descData.PreferredHeight or -1
    node.tips_desc_tpl.VLayoutGroup:SetPaddingWidth(descData.PaddingLeft, descData.PadddingRight)
  end
end

function TipsPopupView:generateNodeByType4(nodeData, index)
end

function TipsPopupView:generateNodeByType5(nodeData, index)
end

function TipsPopupView:generateNodeByType6(nodeData, index, targetNode)
  local btnData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("btnNode")
  if path ~= nil and path ~= "" then
    local node = targetNode or self:AsyncLoadUiUnit(path, "btnNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      self:setLabelText(node.lab_content, btnData.BtnText, nil, true)
      node.btn_go.Btn.IsDisabled = not btnData.Enable
      node.btn_go.Btn:AddListener(function()
        if btnData.ClickFunc then
          btnData.ClickFunc()
        end
        self:closeTipsView()
      end)
    end
  end
end

function TipsPopupView:generateNodeByType7(nodeData, index)
  local itemListData = nodeData
  if itemListData.ItemDataArray ~= nil and #itemListData.ItemDataArray > 0 then
    local path = self.uiBinder.prefab_cache:GetString("itemListNode")
    if path ~= nil and path ~= "" then
      local node = self:AsyncLoadUiUnit(path, "itemListNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
      if node ~= nil then
        local path = self.uiBinder.prefab_cache:GetString("previewItem")
        local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
        for count, itemData in ipairs(itemListData.ItemDataArray) do
          local itemName = "item" .. count
          local item = self:AsyncLoadUiUnit(path, itemName, node.Trans, self.cancelSource:CreateToken())
          if item ~= nil then
            self.itemClassTab_[itemName] = itemClass.new(self)
            local itemPreviewData = {
              unit = item,
              configId = itemData.awardId,
              isSquareItem = true,
              PrevDropType = itemData.PrevDropType
            }
            itemPreviewData.labType, itemPreviewData.lab = awardPreviewVm.GetPreviewShowNum(itemData)
            self.itemClassTab_[itemName]:Init(itemPreviewData)
          end
        end
      end
    end
  end
end

function TipsPopupView:generateNodeByType8(nodeData, index)
  local itemInfoData = nodeData
  local itemTableData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemInfoData.ConfigId)
  if itemTableData == nil then
    logError("ItemTable\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\233\133\141\231\189\174", itemInfoData.ConfigId)
    return
  end
  local itemTypeTableData = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemTableData.Type)
  if itemTypeTableData == nil then
    logError("ItemTypeTable\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\233\133\141\231\189\174", itemTableData.Type)
    return
  end
  local path = self.uiBinder.prefab_cache:GetString("itemInfoNode")
  local node = self:AsyncLoadUiUnit(path, "itemInfoNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
  if node ~= nil then
    node.group_assemble:SetVisible(false)
    node.layout_num_extend:SetVisible(false)
    node.lab_type.TMPLab.text = itemTypeTableData.Name
    local itemsVM = Z.VMMgr.GetVM("items")
    node.img_icon.Img:SetImage(itemsVM.GetItemIcon(itemInfoData.ConfigId))
    node.img_bg_quality.Img:SetImage(Z.ConstValue.QualityImgTipsBg .. itemTableData.Quality)
    local itemsVm = Z.VMMgr.GetVM("items")
    if itemInfoData.ShowType == E.EItemTipsShowType.Default then
      local itemPackageInfo = itemsVm.GetItemInfobyItemId(itemInfoData.ItemUuid, itemInfoData.ConfigId)
      node.lab_count.TMPLab.text = Lang("Count") .. ": " .. itemPackageInfo.count
    elseif itemInfoData.ShowType == E.EItemTipsShowType.OnlyClient then
      node.lab_count.TMPLab.text = ""
    end
  end
end

function TipsPopupView:generateNodeByType9(nodeData, index)
  local monsterListData = nodeData
  if monsterListData.MonsterDataArray ~= nil and #monsterListData.MonsterDataArray > 0 then
    local path = self.uiBinder.prefab_cache:GetString("monsterListNode")
    if path ~= nil and path ~= "" then
      local node = self:AsyncLoadUiUnit(path, "monsterListNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
      if node ~= nil then
        local monsterPath = self.uiBinder.prefab_cache:GetString("monster")
        for i, monsterData in ipairs(monsterListData.MonsterDataArray) do
          local monster = self:AsyncLoadUiUnit(monsterPath, "monster" .. i, node.Trans, self.cancelSource:CreateToken())
          if monster ~= nil then
            if monsterData.monsterImgPath then
              monster.img_monster:SetImage(monsterData.monsterImgPath)
            end
            if monsterData.monsterName then
              monster.lab_monster_name.text = monsterData.monsterName
            end
            if monsterData.monsterGs then
              monster.lab_monster_gs.text = monsterData.monsterGs
            end
          end
        end
      end
    end
  end
end

function TipsPopupView:generateNodeByType10(nodeData, index)
  local titleBtnData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("titleBtnNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "titleBtnNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      titleBtnData.TitleColor = titleBtnData.TitleColor or DEFAULT_TITLE_COLOR
      self:setLabelText(node.lab_name, titleBtnData.Title, titleBtnData.TitleColor)
      node.btn_add.Img:SetImage(titleBtnData.BtnImagePath)
      node.btn_add.Btn:AddListener(function()
        if titleBtnData.ClickFunc then
          titleBtnData.ClickFunc()
        end
      end)
    end
  end
end

function TipsPopupView:generateNodeByType11(nodeData, index)
  local titleIconBgData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("titleIconBgNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "titleIconBgNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      titleIconBgData.TitleColor = titleIconBgData.TitleColor or DEFAULT_TITLE_COLOR
      self:setColorText(node.lab_title, titleIconBgData.Title, titleIconBgData.ColorKey, titleIconBgData.UiStyle)
      if titleIconBgData.IconCacheKey then
        local iconPath = self.uiBinder.prefab_cache:GetString(titleIconBgData.IconCacheKey)
        if iconPath then
          node.img_icon:SetVisible(true)
          node.img_icon.Img:SetImage(iconPath)
          if titleIconBgData.Height and titleIconBgData.Weight then
            node.img_icon.Ref:SetWidth(titleIconBgData.Weight)
            node.img_icon.Ref:SetHeight(titleIconBgData.Height)
          end
        else
          node.img_icon:SetVisible(false)
        end
      end
      node.layout_content.HLayoutGroup:SetPaddingWidth(titleIconBgData.PaddingLeft, titleIconBgData.PadddingRight)
      if titleIconBgData.TitleBgPath then
        node.img_bg:SetVisible(true)
        node.img_bg.Img:SetImage(titleIconBgData.TitleBgPath)
      else
        node.img_bg:SetVisible(false)
      end
    end
  end
end

function TipsPopupView:generateNodeByType12(nodeData, index)
  local itemListFuncData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("itemListFuncNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "titleIconBgNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node == nil then
      return
    end
    local itemPath = self.uiBinder.prefab_cache:GetString("item")
    if itemPath ~= nil then
      local itemsVm = Z.VMMgr.GetVM("items")
      local isOn = true
      for i, itmeData in pairs(itemListFuncData.ItemDataArray) do
        local itemName = "monster" .. i
        local itemUnit = self:AsyncLoadUiUnit(itemPath, itemName, node.node_cont.Trans, self.cancelSource:CreateToken())
        if itemUnit then
          local expendCount = itmeData.Count
          local haveCount = itemsVm.GetItemTotalCount(itmeData.ConfigId)
          if expendCount > haveCount then
            isOn = false
          end
          self.itemClassTab_[itemName] = itemClass.new(self)
          local itemClassData = {
            unit = itemUnit,
            configId = itmeData.ConfigId,
            labType = E.ItemLabType.Expend,
            lab = haveCount,
            expendCount = expendCount,
            colorKey = itemListFuncData.ColorKey
          }
          self.itemClassTab_[itemName]:Init(itemClassData)
        end
      end
      local alpha = 1
      if itemListFuncData.FuncType == E.TipsItemFuncType.Unlock then
        alpha = isOn and 1 or 0.4
      end
      if itemListFuncData.FunBtnIconCacheKay and itemListFuncData.FunBtnIconCacheKay ~= "" then
        local iconPath = self.uiBinder.prefab_cache:GetString(itemListFuncData.FunBtnIconCacheKay)
        if iconPath then
          node.img_btn_icon.Img:SetImage(iconPath)
        end
      end
      node.btn_check.Ref.CanvasGroup.alpha = alpha
      if itemListFuncData.CallFunc then
        self:AddAsyncClick(node.btn_check.Btn, itemListFuncData.CallFunc)
      end
      self:setColorText(node.lab_reward_name, itemListFuncData.FuncBtnName)
    end
  end
end

function TipsPopupView:generateNodeByType13(nodeData, index)
  local proficiencyData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("buffInfoNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "buffInfoNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node == nil then
      return
    end
    local buffCfgData = Z.TableMgr.GetTable("BuffTableMgr").GetRow(proficiencyData.BuffId)
    local str = ""
    if proficiencyData.Level then
      local param = {
        val = proficiencyData.Level
      }
      str = Lang("Grade", param)
    end
    self:setColorText(node.lab_level, str, proficiencyData.LevelColorKey, proficiencyData.LeveluiStyle)
    local proficiencyVm_ = Z.VMMgr.GetVM("proficiency")
    if buffCfgData then
      self:setColorText(node.lab_name, "", proficiencyData.BuffColorKey, proficiencyData.BuffuiStyle)
      node.proficiency_skill_tpl.img_icon.Img:SetImage(buffCfgData.Icon)
    end
  end
end

function TipsPopupView:generateNodeByType14(nodeData, index)
  local iconDescData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("iconDescNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "iconDescNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      iconDescData.Color = iconDescData.Color or DEFAULT_TITLE_COLOR
      self:setLabelText(node.lab_desc, iconDescData.Desc, iconDescData.Color)
      if iconDescData.IconPath then
        node.img_icon:SetVisible(true)
        node.img_icon.Img:SetImage(iconDescData.IconPath)
        node.img_icon.Ref.LayoutElement.preferredWidth = iconDescData.IconWidth or -1
        node.img_icon.Ref.LayoutElement.preferredHeight = iconDescData.IconHeight or -1
      else
        node.img_icon:SetVisible(false)
      end
    end
  end
end

function TipsPopupView:generateNodeByType15(nodeData, index)
  local bdTagListData = nodeData
  if bdTagListData.BdTagDataArray ~= nil and #bdTagListData.BdTagDataArray > 0 then
    local path = self.uiBinder.prefab_cache:GetString("bdTagListNode")
    if path ~= nil and path ~= "" then
      local node = self:AsyncLoadUiUnit(path, "bdTagListNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
      if node ~= nil then
        local bdTagPath = self.uiBinder.prefab_cache:GetString("bdTagNode")
        for count, bdTagBase in ipairs(bdTagListData.BdTagDataArray) do
          local tag = self:AsyncLoadUiUnit(bdTagPath, "bdTagNode" .. count, node.layout_content.Trans, self.cancelSource:CreateToken())
          if tag ~= nil then
            Z.RichTextHelper.AddTmpLabClick(tag.lab_title, bdTagBase.TagName, function()
              Z.CommonTipsVM.OpenUnderline(bdTagListData.SkillId)
              self.uiBinder.presscheck:StopCheck()
            end)
          end
        end
        local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
        coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
        node.layout_content.unevenLayoutEx.MaxWidth = WIDTH_VALUE_DICT[self.viewData.style] - 36
        node.layout_content.unevenLayoutEx:SetLayoutGroup()
      end
    end
  end
end

function TipsPopupView:generateNodeByType16(nodeData, index)
  local skillData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("skillInfoNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "skillInfoNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      node.img_icon.Img:SetImage(skillData.IconPath)
      node.img_bg_quality.Img:SetImage(skillData.QualityPath)
      node.lab_title.TMPLab.text = skillData.Title
      node.lab_titile_extend.TMPLab.text = skillData.TitleExtend
      node.lab_desc.TMPLab.text = skillData.Desc
      self:setLabelText(node.lab_desc, skillData.Desc, skillData.DescColor)
    end
  end
end

function TipsPopupView:generateNodeByType17(nodeData, index)
  local timeData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("remainTimeNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "remainTimeNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      do
        local setTimeLabel = function(count)
          node.lab_title.TMPLab.text = Lang("RemainTime") .. Z.TimeTools.FormatToDHM(count)
        end
        if timeData.IsUseTimer then
          local count = timeData.RemainTime
          self.timerMgr:StartTimer(function()
            count = count - 1
            setTimeLabel(count)
          end, 1, timeData.RemainTime)
          setTimeLabel(count)
        else
          setTimeLabel(timeData.RemainTime)
        end
      end
    end
  end
end

function TipsPopupView:generateNodeByType19(nodeData, index)
  local itemListData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("unlockItemListNode")
  if path ~= nil and path ~= "" then
    local node = self:AsyncLoadUiUnit(path, "unlockItemListNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      if itemListData.ItemDataArray ~= nil and #itemListData.ItemDataArray > 0 then
        local itemPath = self.uiBinder.prefab_cache:GetString("item")
        local itemsVm = Z.VMMgr.GetVM("items")
        for count, itemData in ipairs(itemListData.ItemDataArray) do
          local itemName = "item" .. count
          local item = self:AsyncLoadUiUnit(itemPath, itemName, node.layout_content.Trans, self.cancelSource:CreateToken())
          if item ~= nil then
            self.itemClassTab_[itemName] = itemClass.new(self)
            local unlockItemData = {
              unit = item,
              configId = itemData.ItemId,
              expendCount = itemData.ItemNum,
              lab = itemsVm.GetItemTotalCount(itemData.ItemId),
              labType = E.ItemLabType.Expend
            }
            self.itemClassTab_[itemName]:Init(unlockItemData)
          end
        end
        node.loopscroll_unlock:SetVisible(true)
      else
        node.loopscroll_unlock:SetVisible(false)
      end
      if itemListData.DescDataArray ~= nil and 0 < #itemListData.DescDataArray then
        local itemPath = self.uiBinder.prefab_cache:GetString("unlockItemNode")
        for count, itemData in ipairs(itemListData.DescDataArray) do
          local itemName = "unlockItem" .. count
          local item = self:AsyncLoadUiUnit(itemPath, itemName, node.layout_content_label.Trans, self.cancelSource:CreateToken())
          if item ~= nil then
            item.lab_task_name.TMPLab.text = itemData.Desc
            item.lab_num.TMPLab.text = itemData.Progress
            item.img_on:SetVisible(itemData.IsUnlock)
          end
        end
        node.layout_content_label:SetVisible(true)
      else
        node.layout_content_label:SetVisible(false)
      end
    end
  end
end

function TipsPopupView:generateNodeByType20(nodeData, index, targetNode)
  local itemListData = nodeData
  local path = self.uiBinder.prefab_cache:GetString("unlockItemListNode")
  if path ~= nil and path ~= "" then
    local node = targetNode or self:AsyncLoadUiUnit(path, "unlockItemListNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if node ~= nil then
      node.node_unlock_title:SetVisible(false)
      if itemListData.ItemDataArray ~= nil and #itemListData.ItemDataArray > 0 then
        local itemPath = self.uiBinder.prefab_cache:GetString("item2")
        local itemsVm = Z.VMMgr.GetVM("items")
        for count, itemData in ipairs(itemListData.ItemDataArray) do
          local itemName = "item" .. count
          local item = self:AsyncLoadUiUnit(itemPath, itemName, node.layout_content.Trans, self.cancelSource:CreateToken())
          if item ~= nil then
            self.itemClassTab_[itemName] = itemClass.new(self)
            local unlockItemData = {
              unit = item,
              configId = itemData.ItemId,
              expendCount = itemData.ItemNum,
              lab = itemsVm.GetItemTotalCount(itemData.ItemId),
              labType = E.ItemLabType.Expend,
              isSquareItem = true
            }
            self.itemClassTab_[itemName]:Init(unlockItemData)
            item.cont_info.img_prob_bg:SetVisible(false)
          end
        end
        node.loopscroll_unlock:SetVisible(true)
      else
        node.loopscroll_unlock:SetVisible(false)
      end
      if itemListData.DescDataArray ~= nil and 0 < #itemListData.DescDataArray then
        local itemPath = self.uiBinder.prefab_cache:GetString("unlockItemNode2")
        for count, itemData in ipairs(itemListData.DescDataArray) do
          local itemName = "unlockItem" .. count
          local item = self:AsyncLoadUiUnit(itemPath, itemName, node.layout_content_label.Trans, self.cancelSource:CreateToken())
          if item ~= nil then
            item.lab_task_name.TMPLab.text = itemData.Desc
            item.lab_num.TMPLab.text = itemData.Progress
            item.img_on:SetVisible(itemData.IsUnlock)
          end
        end
        node.layout_content_label:SetVisible(true)
      else
        node.layout_content_label:SetVisible(false)
      end
    end
  end
end

function TipsPopupView:generateNodeByType21(nodeData, index, targetNode)
  local path = self.uiBinder.prefab_cache:GetString("skillDetailNode")
  if path and path ~= "" then
    local skillDetailNode = targetNode or self:AsyncLoadUiUnit(path, "skillDetailNode" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if skillDetailNode then
      do
        local hasDes = nodeData.SkillDes and nodeData.SkillDes ~= ""
        skillDetailNode.cont_tips_desc:SetVisible(hasDes)
        if hasDes then
          Z.RichTextHelper.SetTmpLabTextWithCommonLink(skillDetailNode.lab_desc, nodeData.SkillDes)
        end
        local hasTrait = nodeData.SkillTrait ~= nil
        skillDetailNode.tips_line_tpl:SetVisible(hasTrait)
        skillDetailNode.lab_title2:SetVisible(hasTrait)
        skillDetailNode.lab_des_info:SetVisible(hasTrait)
        if hasTrait then
          Z.RichTextHelper.SetTmpLabTextWithCommonLink(skillDetailNode.lab_des_info, nodeData.SkillTrait)
        end
        if nodeData.Tags and #nodeData.Tags > 0 then
          local bdTagPath = self.uiBinder.prefab_cache:GetString("bdTagNode")
          for i, bdTagBase in ipairs(nodeData.Tags) do
            local tag = self:AsyncLoadUiUnit(bdTagPath, "bdTagNode" .. i, skillDetailNode.layout_content.Trans, self.cancelSource:CreateToken())
            if tag ~= nil then
              Z.RichTextHelper.AddTmpLabClick(tag.lab_title, bdTagBase.TagName, function()
                Z.CommonTipsVM.OpenUnderline(nodeData.SkillId)
                self.uiBinder.presscheck:StopCheck()
              end)
            end
          end
          local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
          coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
          skillDetailNode.layout_content.unevenLayoutEx.MaxWidth = WIDTH_VALUE_DICT[self.viewData.style] - 36
          skillDetailNode.layout_content.unevenLayoutEx:SetLayoutGroup()
        end
        local hasDatas = nodeData.Attrs and 0 < #nodeData.Attrs
        skillDetailNode.tog_data:SetVisible(hasDatas)
        if hasDatas then
          local attrNodePath = self.uiBinder.prefab_cache:GetString("skillAttrNode")
          for i, attr in pairs(nodeData.Attrs) do
            local attrNode = self:AsyncLoadUiUnit(attrNodePath, "skillAttrNode" .. i, skillDetailNode.group_equip_base_arr.Trans, self.cancelSource:CreateToken())
            if attrNode ~= nil then
              attrNode.lab_name.text = attr.Dec
              attrNode.lab_num.text = attr.Num
            end
          end
        end
        local togGroup = skillDetailNode.node_togs.TogGroup
        local togDes = skillDetailNode.tog_description.Tog
        local togData = skillDetailNode.tog_data.Tog
        togDes:SetIsOnWithoutCallBack(false)
        togData:SetIsOnWithoutCallBack(false)
        togDes.group = togGroup
        togData.group = togGroup
        self:AddClick(togDes, function(isOn)
          if isOn then
            skillDetailNode.node_small_skill:SetVisible(true)
            skillDetailNode.node_main_attr:SetVisible(false)
          end
        end)
        self:AddClick(togData, function(isOn)
          if isOn then
            skillDetailNode.node_small_skill:SetVisible(false)
            skillDetailNode.node_main_attr:SetVisible(true)
          end
        end)
        togDes.isOn = true
      end
    end
  end
end

function TipsPopupView:generateNodeByType22(nodeData, index)
  local path = self.uiBinder.prefab_cache:GetString("acquisitionOfType")
  local node = self:AsyncLoadUiUnit(path, "acquisitionOfType" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
  if node ~= nil then
    if nodeData.way.icon ~= "" then
      node.img_icon.Img:SetImage(nodeData.way.icon)
    end
    node.lab_gameplay.TMPLab.text = nodeData.way.name
    node.lab_level_open.TMPLab.text = ""
    self:AddClick(node.img_bg.Btn, function()
      local itemSourceVm = Z.VMMgr.GetVM("item_source")
      itemSourceVm.JumpToSource(nodeData.way)
    end)
  end
end

function TipsPopupView:generateNodeByType23(nodeData, index)
  local commonVm = Z.VMMgr.GetVM("common")
  local path = self.uiBinder.prefab_cache:GetString("talentSkillFullInfo")
  if path and path ~= "" then
    local skillFullInfoNode = self:AsyncLoadUiUnit(path, "talentSkillFullInfo" .. index, self.uiBinder.content, self.cancelSource:CreateToken())
    if skillFullInfoNode then
      local node1 = skillFullInfoNode.tips_title_tpl
      if node1 then
        self:generateNodeByType1(nodeData.titleData, 0, node1)
      end
      local node2 = skillFullInfoNode.tips_skill_detail_info_tpl
      if node2 then
        self:generateNodeByType22(nodeData.skillDetailData, nil, node2)
        local tagHeight = node2.layout_content.Ref.RectTransform.sizeDelta.y
        node2.node_small_skill.ContentSizeFitter.MaxHeight = nodeData.btnData ~= nil and 353 or 694 - tagHeight
        node2.node_main_attr.ContentSizeFitter.MaxHeight = nodeData.btnData ~= nil and 353 or 694 - tagHeight
      end
      local node3 = skillFullInfoNode.tips_item_unlock
      if node3 then
        local data = nodeData.unlockItemData
        if data then
          node3:SetVisible(true)
          self:generateNodeByType21(data, nil, node3)
        else
          node3:SetVisible(false)
        end
      end
      local node4 = skillFullInfoNode.tips_line_tpl
      if node4 then
        local data = nodeData.lineData
        if data then
          node4:SetVisible(true)
          self:generateNodeByType2(data, nil, node4)
        else
          node4:SetVisible(false)
        end
      end
      local node5 = skillFullInfoNode.tips_btn_tpl
      if node5 then
        local data = nodeData.btnData
        if data then
          node5:SetVisible(true)
          self:generateNodeByType6(data, nil, node5)
        else
          node5:SetVisible(false)
        end
      end
    end
  end
end

function TipsPopupView:generateNodeByType24(nodeData)
  local path = self.uiBinder.prefab_cache:GetString("tip_image")
  if path and path ~= "" then
    local imgNode = self:AsyncLoadUiUnit(path, "tip_image", self.uiBinder.content, self.cancelSource:CreateToken())
    if imgNode then
      imgNode.img_icon.Img:SetImage(nodeData.imagePath)
    end
  end
end

function TipsPopupView:startAnimatedShow()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_001")
end

function TipsPopupView:startAnimatedHide()
  self.uiBinder.anim:PlayOnce("anim_iteminfo_tips_002")
end

return TipsPopupView
