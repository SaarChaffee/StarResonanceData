local ItemPreview = {}
local fashionVm = Z.VMMgr.GetVM("fashion")

function ItemPreview.GotoPreview(configId)
  if fashionVm.CheckIsFashion(configId) then
    ItemPreview.FashionPreview(configId)
  end
  local hasPreview, fashionList = ItemPreview.GetIsHavePreviewAward(configId)
  if hasPreview then
    ItemPreview.FashionListPreview(fashionList)
  end
end

function ItemPreview.GetIsHavePreview(configId)
  if fashionVm.CheckIsFashion(configId) then
    return true
  end
  local hasPreview, _ = ItemPreview.GetIsHavePreviewAward(configId)
  return hasPreview
end

function ItemPreview.GetIsHavePreviewAward(configId)
  local hasPreview = false
  local previewFashionList = {}
  local itemFunctionTable = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local itemFunctionTableRow = itemFunctionTable.GetRow(configId, true)
  if not itemFunctionTableRow or itemFunctionTableRow.Type ~= E.ItemFunctionType.Gift then
    return hasPreview, previewFashionList
  end
  local awardId = tonumber(itemFunctionTableRow.Parameter[1])
  local awardTable = Z.TableMgr.GetTable("AwardPackageTableMgr")
  local awardTableRow = awardTable.GetRow(awardId)
  if awardTableRow == nil then
    return hasPreview, previewFashionList
  end
  if awardTableRow.HidePreview == 1 then
    return hasPreview, previewFashionList
  else
    local awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
    local awardList = awardPreviewVM_.GetAllAwardPreListByIds(awardId)
    if awardList == nil or next(awardList) == nil then
      return hasPreview, previewFashionList
    end
    local isProbability = false
    for i, v in ipairs(awardList) do
      if v.PrevDropType == E.AwardPrevDropType.Probability then
        isProbability = true
        break
      end
    end
    if awardTableRow.PackType == Z.PbEnum("EAwardType", "EAwardTypeSelect") or isProbability then
      return hasPreview, previewFashionList
    else
      for index, itemData in ipairs(awardList) do
        if fashionVm.CheckIsFashion(itemData.awardId) then
          hasPreview = true
          table.insert(previewFashionList, itemData.awardId)
        end
      end
      return hasPreview, previewFashionList
    end
  end
  return hasPreview, previewFashionList
end

function ItemPreview.FashionPreview(configId)
  fashionVm.GotoFashionView(configId)
end

function ItemPreview.FashionListPreview(configIdList)
  fashionVm.GotoFashionListView(configIdList)
end

return ItemPreview
