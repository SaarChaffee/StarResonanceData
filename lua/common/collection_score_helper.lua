local CollectionScoreHelper = {}

function CollectionScoreHelper.GetCollectionScore()
  local fashionBenefit = Z.ContainerMgr.CharSerialize.fashionBenefit
  local allScore = fashionBenefit.pointsCollection + fashionBenefit.pointsTask + fashionBenefit.pointsCycle
  return allScore
end

function CollectionScoreHelper.GetCollectionCurLevel()
  local fashionBenefit = Z.ContainerMgr.CharSerialize.fashionBenefit
  local curLevel = math.max(1, fashionBenefit.level)
  return curLevel
end

function CollectionScoreHelper.RefreshCollectionScoreSlider(uiBinder)
  local curLevel = CollectionScoreHelper.GetCollectionCurLevel()
  local fashionLevelTableList = {}
  local curFashionLevelTableRow
  for id, row in ipairs(Z.TableMgr.GetTable("FashionLevelTableMgr").GetDatas()) do
    if curLevel == id then
      curFashionLevelTableRow = row
    end
    fashionLevelTableList[#fashionLevelTableList + 1] = row
  end
  if not curFashionLevelTableRow then
    return
  end
  local maxFashionLevelTableRow = fashionLevelTableList[#fashionLevelTableList]
  local curLevel = CollectionScoreHelper.GetCollectionCurLevel()
  for i = 1, #fashionLevelTableList do
    local row = fashionLevelTableList[i]
    local node = uiBinder[string.zconcat("node_", row.Id)]
    if node then
      node.lab_name.text = row.ShortName
      node.Ref:SetVisible(node.img_top, i <= curLevel)
    end
  end
  uiBinder.slider_score.value = (curLevel - 1) / (#fashionLevelTableList - 1) * 100
  return maxFashionLevelTableRow.Id, fashionLevelTableList
end

function CollectionScoreHelper.RefreshCollectionScoreLevel(uiBinder, id)
  id = id or CollectionScoreHelper.GetCollectionCurLevel()
  local curRow = Z.TableMgr.GetTable("FashionLevelTableMgr").GetRow(id, true)
  if not curRow then
    return
  end
  local allScore = CollectionScoreHelper.GetCollectionScore()
  uiBinder.lab_name.text = curRow.Name
  uiBinder.img_grade:SetImage(string.zconcat("ui/atlas/collection/collection_grade_", id))
  if uiBinder.lab_upgrade then
    if curRow.Score <= 0 or allScore >= curRow.Score then
      uiBinder.lab_upgrade.text = Lang("CollectionScoreLevelFinishTips")
    else
      uiBinder.lab_upgrade.text = Lang("CollectionLevelUp", {
        val = curRow.Score - allScore,
        name = curRow.Name
      })
    end
  end
  if uiBinder.img_integral then
    uiBinder.Ref:SetVisible(uiBinder.img_integral, true)
    uiBinder.lab_integral.text = Lang("CollectionMemberIntergral", {val = allScore})
  end
  if uiBinder.img_cur_level then
    uiBinder.Ref:SetVisible(uiBinder.img_cur_level, id == CollectionScoreHelper.GetCollectionCurLevel())
  end
  local img = string.zconcat(Z.ConstValue.Collection.CollectionTextureIconPath, curRow.Icon)
  uiBinder.rimg_icon:SetImage(img)
  uiBinder.rimg_icon_shadow:SetImage(img)
end

function CollectionScoreHelper.RefreshCollectionScore(uiBinder, clickFunc)
  if not uiBinder then
    return
  end
  local collectionVM = Z.VMMgr.GetVM("collection")
  local score = collectionVM.GetFashionCollectionPoints()
  uiBinder.lab_lv.text = score
  local curFashionCollectRow, nextFashionCollectRow
  for _, row in pairs(Z.TableMgr.GetTable("FashionCollectTableMgr").GetDatas()) do
    if score >= row.Score then
      curFashionCollectRow = row
    else
      nextFashionCollectRow = row
      break
    end
  end
  if not curFashionCollectRow then
    if not nextFashionCollectRow then
      return
    end
    uiBinder.lab_exp.text = string.zconcat(score, "/", nextFashionCollectRow.Score)
    uiBinder.img_progress.fillAmount = score / nextFashionCollectRow.Score
  elseif not nextFashionCollectRow then
    uiBinder.lab_exp.text = curFashionCollectRow.Score
    uiBinder.img_progress.fillAmount = 1
  else
    uiBinder.lab_exp.text = string.zconcat(score, "/", nextFashionCollectRow.Score)
    uiBinder.img_progress.fillAmount = score / nextFashionCollectRow.Score
  end
  uiBinder.btn_level:AddListener(function()
    if clickFunc then
      clickFunc()
    end
    Z.UIMgr:OpenView("collection_reward_popup")
  end)
end

function CollectionScoreHelper.GetScoreByType(type)
  if type == E.FashionCollectionScoreType.Mission then
    return Z.ContainerMgr.CharSerialize.fashionBenefit.pointsTask
  elseif type == E.FashionCollectionScoreType.Cycle then
    return Z.ContainerMgr.CharSerialize.fashionBenefit.pointsCycle
  else
    return Z.ContainerMgr.CharSerialize.fashionBenefit.pointsCollection
  end
end

function CollectionScoreHelper.GetFailureScoreByType(type)
  if type == E.FashionCollectionScoreType.Mission then
    return Z.ContainerMgr.CharSerialize.fashionBenefit.pointsTask
  elseif type == E.FashionCollectionScoreType.Cycle then
    return CollectionScoreHelper.GetCycleInRemainTimeScore()
  else
    return 0
  end
end

function CollectionScoreHelper.GetCycleInRemainTimeScore()
  local list = Z.ContainerMgr.CharSerialize.fashionBenefit.collectionHistory
  local remainTimeScore = 0
  for i = #list, 1, -1 do
    local remainTime = list[i].time + Z.Global.FashionLevelScoreTime - Z.TimeTools.Now() / 1000
    if Z.Global.FashionLevelTimeRemind ~= nil and remainTime < Z.Global.FashionLevelTimeRemind then
      if list[i].type == E.CollectionHistoryType.Fashion then
        local fashionTable = Z.TableMgr.GetTable("FashionTableMgr").GetRow(list[i].fashionId, true)
        if not fashionTable then
          return
        end
        remainTimeScore = remainTimeScore + math.floor(fashionTable.Score * Z.Global.FashionScoreScale[1][2] * 1.0E-4)
      elseif list[i].type == E.CollectionHistoryType.Weapon then
        local weaponSkinTable = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(list[i].fashionId, true)
        if not weaponSkinTable then
          return
        end
        remainTimeScore = remainTimeScore + math.floor(weaponSkinTable.Score * Z.Global.FashionScoreScale[2][2] * 1.0E-4)
      elseif list[i].type == E.CollectionHistoryType.Ride then
        local vehicleBaseTable = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(list[i].fashionId, true)
        if not vehicleBaseTable then
          return
        end
        remainTimeScore = remainTimeScore + math.floor(vehicleBaseTable.Score * Z.Global.FashionScoreScale[3][2] * 1.0E-4)
      end
    end
  end
  return remainTimeScore
end

return CollectionScoreHelper
