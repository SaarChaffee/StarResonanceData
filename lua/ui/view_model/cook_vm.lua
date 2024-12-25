local itemsVM = Z.VMMgr.GetVM("items")
local WorldProxy = require("zproxy.world_proxy")
local ErrCookMaterialNotMatch = Z.PbEnum("EErrorCode", "ErrCookMaterialNotMatch")
local itemShowVm = Z.VMMgr.GetVM("item_show")
local openCookView = function(cameraId)
  Z.UIMgr:OpenView("cook_main", tonumber(cameraId))
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
  if Z.ContainerMgr.CharSerialize.cookList.bookData[id] then
    return true
  end
  return false
end
local getCookBookCreateTime = function(id)
  if Z.ContainerMgr.CharSerialize.cookList.bookData[id] then
    return Z.ContainerMgr.CharSerialize.cookList.bookData[id].createTime
  end
  return 0
end
local getUnLockCookBookList = function()
  local data = {}
  local cookData = Z.DataMgr.Get("cook_data")
  for k, id in pairs(cookData.DefaultUnlockCookIds) do
    local row = Z.TableMgr.GetTable("CookRecipeTableMgr").GetRow(id, true)
    if row then
      data[#data + 1] = row
    end
  end
  for k, v in pairs(Z.ContainerMgr.CharSerialize.cookList.bookData) do
    if not cookData.DefaultUnlockCookIds[k] then
      local row = Z.TableMgr.GetTable("CookRecipeTableMgr").GetRow(k, true)
      if row then
        data[#data + 1] = row
      end
    end
  end
  table.sort(data, function(a, b)
    if a.SortId == b.SortId then
      return a.Id < b.Id
    end
    return a.SortId < b.SortId
  end)
  return data
end
local gerCookBookList = function()
  local cookData = Z.DataMgr.Get("cook_data")
  local data = {}
  for _, cfg in pairs(cookData.CookRecipeTableRows) do
    data[#data + 1] = cfg
  end
  table.sort(data, function(a, b)
    local unlockA = isUnlockCookBook(a.Id) and 1 or 0
    local unlockB = isUnlockCookBook(b.Id) and 1 or 0
    if unlockA ~= unlockB then
      return unlockA > unlockB
    else
      return a.Quality > b.Quality
    end
  end)
  return data
end
local getExchangeNum = function(slot1Id, slot3Id, slot4Id, config)
  if not config or slot1Id == nil or slot1Id == 0 then
    return 0
  end
  local num = itemsVM.GetItemTotalCount(slot1Id) / config.QuickMakeMaterialExpend[1]
  if slot3Id and slot3Id ~= 0 then
    local slot3Num = itemsVM.GetItemTotalCount(slot3Id) / config.QuickMakeMaterialExpend[2]
    if num > slot3Num then
      num = slot3Num
    end
  end
  if slot4Id and slot4Id ~= 0 then
    local slot4Num = itemsVM.GetItemTotalCount(slot4Id) / config.QuickMakeMaterialExpend[3]
    if num > slot4Num then
      num = slot4Num
    end
  end
  return math.floor(num)
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
  local vInfo = {
    bookId = bookId,
    count = count,
    mainMaterials = mainMaterials,
    cookMethods = cookMethods
  }
  local ret = WorldProxy.FastCook(vInfo, cancelToken)
  Z.TipsVM.ShowTips(ret)
  return ret
end
local openItemShowPopup = function(recipeId, foodId)
  local count = 1
  if foodId == 0 then
    return
  end
  local awardList = {}
  local name
  if recipeId == 0 then
    name = Lang("UnLockCookFail")
  elseif recipeId and not isUnlockCookBook(recipeId) then
    name = Lang("UnLockNewCookBook")
  end
  local itemInfo = {
    configId = foodId,
    count = count,
    name = name
  }
  local cookRecipeTableRow = Z.TableMgr.GetTable("CookRecipeTableMgr").GetRow(recipeId)
  if cookRecipeTableRow then
    itemInfo.iconPath = cookRecipeTableRow.Icon
    itemInfo.qualityPath = Z.ConstValue.Item.ItemQualityPath .. cookRecipeTableRow.Quality
    itemInfo.lab = cookRecipeTableRow.RecipeName
  end
  awardList[1] = itemInfo
  itemShowVm.OpenItemShowView(awardList, "sys_general_award_fail")
end
local asyncRdCook = function(mainMaterials, cookMethods, cancelToken)
  local vInfo = {mainMaterials = mainMaterials, cookMethods = cookMethods}
  local ret = WorldProxy.RdCook(vInfo, cancelToken)
  if ret.errorCode == 0 then
    openItemShowPopup(ret.recipeId, ret.foodId)
  elseif ret.errorCode == ErrCookMaterialNotMatch then
    openItemShowPopup(0, Z.Global.BasicDish)
  else
    Z.TipsVM.ShowTips(ret.errorCode)
  end
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
local getRecipeId = function(data)
  if data == nil then
    return 0
  end
  local cookData = Z.DataMgr.Get("cook_data")
  local recipeCfgDatas = {}
  for _, recipeCfgData in pairs(cookData.CookRecipeTableRows) do
    local tab = {}
    for _, value in pairs(recipeCfgData.ConsumableId) do
      tab[value[1]] = value[2]
    end
    if 0 < table.zcount(tab) then
      recipeCfgDatas[recipeCfgData.Id] = tab
    end
  end
  for id, recipeCfgData in pairs(recipeCfgDatas) do
    if table.zcount(recipeCfgData) == table.zcount(data) then
      local flag = true
      for key, value in pairs(data) do
        if not recipeCfgData[value.foodId] or recipeCfgData[value.foodId] ~= value.count then
          flag = false
          break
        end
      end
      if flag then
        return id
      end
    end
  end
  return 0
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
local getRecipeIdByTypeId = function(type)
  local cookData = Z.DataMgr.Get("cook_data")
  local itemTablrMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local data = cookData.CookMaterialData[type]
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
local setDefultUnlockCookData = function()
  local cookData = Z.DataMgr.Get("cook_data")
  if table.zcount(cookData.DefaultUnlockCookIds) > 0 then
    return
  end
  local ids = {}
  for k, v in pairs(cookData.CookRecipeTableRows) do
    if v.Unlock then
      ids[v.Id] = v.Id
    end
  end
  cookData.DefaultUnlockCookIds = ids
end
local setCookMaterialData = function()
  setDefultUnlockCookData()
  local cookData = Z.DataMgr.Get("cook_data")
  local data = {}
  for k, v in pairs(cookData.CookMaterialTableDatas) do
    if not data[v.TypeB] then
      data[v.TypeB] = {}
    end
    data[v.TypeB][#data[v.TypeB] + 1] = v
  end
  cookData.CookMaterialData = data
end
local getCuisineRandom = function(quality)
  local tab = {}
  local cookCuisineRandomRow = Z.TableMgr.GetRow("CookCuisineRandomTableMgr", quality)
  if cookCuisineRandomRow then
    tab[1] = cookCuisineRandomRow.Lv1Probability
    tab[2] = cookCuisineRandomRow.Lv2Probability
    tab[3] = cookCuisineRandomRow.Lv3Probability
  end
  return tab
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
  GerCookBookList = gerCookBookList,
  IsUnlockCookBook = isUnlockCookBook,
  AsyncFastCook = asyncFastCook,
  AsyncRdCook = asyncRdCook,
  GetCookBookCreateTime = getCookBookCreateTime,
  SwitchEntityShow = switchEntityShow,
  GetRecipeId = getRecipeId,
  SetCookMaterialData = setCookMaterialData,
  GetRecipeIdByTypeId = getRecipeIdByTypeId,
  GetCuisineRandom = getCuisineRandom,
  GetFilterCookMaterialData = getFilterCookMaterialData,
  GetBuffDesById = getBuffDesById
}
return res
