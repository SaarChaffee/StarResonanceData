local itemsVM = Z.VMMgr.GetVM("items")
local WorldProxy = require("zproxy.world_proxy")
local ErrCookMaterialNotMatch = Z.PbEnum("EErrorCode", "ErrCookMaterialNotMatch")
local itemShowVm = Z.VMMgr.GetVM("item_show")
local openCookView = function(cameraId)
  Z.UIMgr:OpenView("cook_main", {
    camID = tonumber(cameraId),
    slowCam = true
  })
end
local closeCookView = function()
  Z.UIMgr:CloseView("cook_main")
end
local openCookRejuvenationPopup = function()
  Z.UIMgr:OpenView("cook_rejuvenation_popup")
end
local closeCookRejuvenationPopup = function()
  Z.UIMgr:CloseView("cook_rejuvenation_popup")
end
local isUnlockCookBook = function(id)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  return lifeProfessionVM.IsProductUnlocked(E.ELifeProfession.Cook, id)
end
local getCookBookCreateTime = function(id)
  if Z.ContainerMgr.CharSerialize.cookList.bookData[id] then
    return Z.ContainerMgr.CharSerialize.cookList.bookData[id].createTime
  end
  return 0
end
local getUnLockCookBookList = function()
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  local data = {}
  local productionInfoTable = lifeProfessionVM.GetLifeProfessionProductnfo(E.ELifeProfession.Cook)
  for index, value in pairs(productionInfoTable) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(value.productId)
    if lifeProfessionVM.IsProductUnlocked(lifeProductionListTableRow.LifeProId, lifeProductionListTableRow.Id) then
      data[#data + 1] = value
    end
  end
  return data
end
local getExchangeNum = function(slot1Id, slot2Id, slot3Id, slot4Id, config)
  if not config or slot1Id == nil or slot1Id == 0 then
    return 0
  end
  local num = itemsVM.GetItemTotalCount(slot1Id) / config.NeedMaterial[1][2]
  if slot2Id and slot2Id ~= 0 then
    local slot2Num = itemsVM.GetItemTotalCount(slot2Id) / config.NeedMaterial[2][2]
    if num > slot2Num then
      num = slot2Num
    end
  end
  if slot3Id and slot3Id ~= 0 then
    local slot3Num = itemsVM.GetItemTotalCount(slot3Id) / config.NeedMaterial[3][2]
    if num > slot3Num then
      num = slot3Num
    end
  end
  if slot4Id and slot4Id ~= 0 then
    local slot4Num = itemsVM.GetItemTotalCount(slot4Id) / config.NeedMaterial[4][2]
    if num > slot4Num then
      num = slot4Num
    end
  end
  local maxCount = math.floor(itemsVM.GetItemTotalCount(config.Cost[1]) / config.Cost[2])
  num = math.min(num, maxCount)
  return math.min(math.floor(num), Z.Global.LifeCastMaxCnt)
end
local getCookFoodItems = function()
  local foodItems = {}
  local itemTypeMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local itemTypeTableRow = itemTypeMgr.GetRow(E.BackPackItemPackageType.CookFoodType)
  if not itemTypeTableRow then
    return foodItems
  end
  local itemPackage = Z.ContainerMgr.CharSerialize.itemPackage.packages[itemTypeTableRow.Package]
  if not itemPackage then
    return foodItems
  end
  local tab = {}
  local cookMaterialMgr = Z.TableMgr.GetTable("CookMaterialTableMgr")
  local cookMaterialRow
  for _, item in pairs(itemPackage.items) do
    if item and not tab[item.configId] then
      cookMaterialRow = cookMaterialMgr.GetRow(item.configId, true)
      if cookMaterialRow then
        tab[item.configId] = true
        foodItems[#foodItems + 1] = {
          configId = item.configId,
          count = itemsVM.GetItemTotalCount(item.configId),
          cookMaterialConfig = cookMaterialRow
        }
      end
    end
  end
  tab = nil
  table.sort(foodItems, function(a, b)
    if a.cookMaterialConfig.SortId == b.cookMaterialConfig.SortId then
      return a.cookMaterialConfig.Id < b.cookMaterialConfig.Id
    end
    return a.cookMaterialConfig.SortId < b.cookMaterialConfig.SortId
  end)
  return foodItems
end
local asyncFastCook = function(bookId, count, mainMaterials, cookMethods, cancelToken)
  local materials = table.zmerge(mainMaterials, cookMethods)
  local vInfo = {
    recipeId = bookId,
    count = count,
    materials = materials
  }
  local ret = WorldProxy.LifeProfessionCooking(vInfo, cancelToken)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
  return ret.errCode
end
local openItemShowPopup = function(ret)
  local name
  if ret.unlockRecipeId == 0 then
    name = Lang("UnLockCookFail")
  elseif ret.isUnlockRecipe then
    name = Lang("UnLockNewCookBook")
  end
  itemShowVm.OpenEquipAcquireViewByItems(ret.items, "sys_general_award_fail", name)
end
local asyncRdCook = function(mainMaterials, cookMethods, cancelToken)
  local materials = table.zmerge(mainMaterials, cookMethods)
  local vInfo = {materials = materials}
  local ret = WorldProxy.LifeProfessionRDCooking(vInfo, cancelToken)
  openItemShowPopup(ret)
end
local switchEntityShow = function(show)
  if show then
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_PLAYER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_NPC)
    Z.LuaBridge.SetHudSwitch(true)
  else
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_PLAYER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_NPC)
    Z.LuaBridge.SetHudSwitch(false)
  end
end
local getFilterCookMaterialData = function(type, configId)
  local tab = {}
  local cookData = Z.DataMgr.Get("cook_data")
  local data = cookData.CookMaterialData[type]
  if data then
    for key, value in pairs(data) do
      if value.Id ~= configId and itemsVM.GetItemTotalCount(value.Id) > 0 then
        tab[#tab + 1] = value
      end
    end
  end
  return tab
end
local getAllCookMaterialData = function(type)
  local tab = {}
  local cookData = Z.DataMgr.Get("cook_data")
  local data = cookData.CookMaterialData[type]
  if data then
    for key, value in pairs(data) do
      tab[#tab + 1] = value
    end
  end
  return tab
end
local getRecipeIdByTypeId = function(type)
  local cookData = Z.DataMgr.Get("cook_data")
  local itemTablrMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local data = cookData.CookMaterialData[type]
  if not data then
    return
  end
  table.sort(data, function(left, right)
    local leftCount = itemsVM.GetItemTotalCount(left.Id)
    local rightCount = itemsVM.GetItemTotalCount(right.Id)
    if leftCount > rightCount then
      return true
    elseif leftCount < rightCount then
      return false
    end
    local leftItemRow = itemTablrMgr.GetRow(left.Id)
    local rightItemRow = itemTablrMgr.GetRow(right.Id)
    if leftItemRow.Quality < rightItemRow.Quality then
      return true
    elseif leftItemRow.Quality > rightItemRow.Quality then
      return false
    end
    if left.Id > right.Id then
      return false
    elseif left.Id < right.Id then
      return true
    end
    return false
  end)
  if data and data[1] then
    return data[1].Id
  end
end
local getBuffDesById = function(id)
  local cookCuisineTableRow = Z.TableMgr.GetTable("CookCuisineTableMgr").GetRow(id, true)
  if not cookCuisineTableRow then
    return ""
  end
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local param = {}
  local des = ""
  if cookCuisineTableRow then
    for k, buffPars in ipairs(cookCuisineTableRow.BuffPar) do
      for index, buffPar in ipairs(buffPars) do
        param[index] = {buffPar}
      end
      des = des .. buffAttrParseVM.ParseBufferTips(cookCuisineTableRow.Description, param) .. "\n"
    end
  end
  return des
end
local res = {
  OpenCookView = openCookView,
  CloseCookView = closeCookView,
  OpenCookRejuvenationPopup = openCookRejuvenationPopup,
  CloseCookRejuvenationPopup = closeCookRejuvenationPopup,
  GetUnLockCookBookList = getUnLockCookBookList,
  GetExchangeNum = getExchangeNum,
  GetCookFoodItems = getCookFoodItems,
  IsUnlockCookBook = isUnlockCookBook,
  AsyncFastCook = asyncFastCook,
  AsyncRdCook = asyncRdCook,
  GetCookBookCreateTime = getCookBookCreateTime,
  SwitchEntityShow = switchEntityShow,
  GetRecipeIdByTypeId = getRecipeIdByTypeId,
  GetFilterCookMaterialData = getFilterCookMaterialData,
  GetAllCookMaterialData = getAllCookMaterialData,
  GetBuffDesById = getBuffDesById
}
return res
