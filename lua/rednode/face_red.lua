local FaceRed = {}
local FaceUnlockCostData = {}

function FaceRed.changeItem(item)
  if not item then
    return
  end
  for type, info in pairs(FaceUnlockCostData) do
    for i = 1, #info do
      local faceId = info[i].faceId
      local unlock = info[i].unlock
      for j = 1, #unlock do
        if unlock[j][1] == item.configId then
          if FaceRed.CheckFaceCanUnlock(unlock) then
            FaceRed.addFaceRed(type, faceId)
          end
          break
        end
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Face.FaceOptionCanUnlock)
end

function FaceRed.InitFaceUnlockCostData()
  FaceUnlockCostData = {}
  local faceTableData = Z.TableMgr.GetTable("FaceTableMgr").GetDatas()
  for faceId, info in pairs(faceTableData) do
    if #info.Unlock > 0 and FaceRed.IsShowFaceRedType(info.Type) and not FaceRed.checkFaceIsUnlock(faceId) then
      if not FaceUnlockCostData[info.Type] then
        FaceUnlockCostData[info.Type] = {}
      end
      if FaceRed.CheckFaceCanUnlock(info.Unlock) then
        FaceRed.addFaceRed(info.Type, faceId)
      end
      table.insert(FaceUnlockCostData[info.Type], {
        faceId = faceId,
        unlock = info.Unlock
      })
    end
  end
  Z.RedPointMgr.RefreshRedNodeState(E.RedType.FaceEditor)
end

function FaceRed.UpdateFaceUnlockCostData(faceId)
  local faceRow = Z.TableMgr.GetTable("FaceTableMgr").GetRow(faceId, true)
  if faceRow and FaceUnlockCostData[faceRow.Type] then
    for i = #FaceUnlockCostData[faceRow.Type], 1, -1 do
      if FaceUnlockCostData[faceRow.Type][i].faceId == faceId then
        table.remove(FaceUnlockCostData[faceRow.Type], i)
        FaceRed.removeFaceRed(faceRow.Type, faceId)
        return
      end
    end
  end
end

function FaceRed.checkFaceIsUnlock(faceId)
  return Z.ContainerMgr.CharSerialize.roleFace.unlockItemMap[faceId]
end

function FaceRed.CheckFaceCanUnlock(unlock)
  local itemVm = Z.VMMgr.GetVM("items")
  local isCanUnlock = true
  for i = 1, #unlock do
    local ownNum = itemVm.GetItemTotalCount(unlock[i][1])
    if ownNum < unlock[i][2] then
      isCanUnlock = false
      break
    end
  end
  return isCanUnlock
end

function FaceRed.IsShowFaceRedType(type)
  return type == Z.PbEnum("EFaceDataType", "HairID") or type == Z.PbEnum("EFaceDataType", "FrontHairID") or type == Z.PbEnum("EFaceDataType", "BackHairID") or type == Z.PbEnum("EFaceDataType", "DullHairID")
end

function FaceRed.addFaceRed(type, faceId)
  local redNodeName = string.zconcat("FaceUnlockRed", faceId)
  if type == Z.PbEnum("EFaceDataType", "HairID") then
    Z.RedPointMgr.AddChildNodeData(E.RedType.FaceEditorHairWhole, E.RedType.FaceEditorHairWhole, redNodeName)
  elseif type == Z.PbEnum("EFaceDataType", "FrontHairID") then
    Z.RedPointMgr.AddChildNodeData(E.RedType.FaceEditorHairCustomFront, E.RedType.FaceEditorHairCustomFront, redNodeName)
  elseif type == Z.PbEnum("EFaceDataType", "BackHairID") then
    Z.RedPointMgr.AddChildNodeData(E.RedType.FaceEditorHairCustomBack, E.RedType.FaceEditorHairCustomBack, redNodeName)
  elseif type == Z.PbEnum("EFaceDataType", "DullHairID") then
    Z.RedPointMgr.AddChildNodeData(E.RedType.FaceEditorHairCustomDull, E.RedType.FaceEditorHairCustomDull, redNodeName)
  end
  Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 1)
end

function FaceRed.removeFaceRed(type, faceId)
  local redNodeName = string.zconcat("FaceUnlockRed", faceId)
  Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 0)
  if type == Z.PbEnum("EFaceDataType", "HairID") then
    Z.RedPointMgr.RemoveChildNodeData(E.RedType.FaceEditorHairWhole, redNodeName)
  elseif type == Z.PbEnum("EFaceDataType", "FrontHairID") then
    Z.RedPointMgr.RemoveChildNodeData(E.RedType.FaceEditorHairCustomFront, redNodeName)
  elseif type == Z.PbEnum("EFaceDataType", "BackHairID") then
    Z.RedPointMgr.RemoveChildNodeData(E.RedType.FaceEditorHairCustomBack, redNodeName)
  elseif type == Z.PbEnum("EFaceDataType", "DullHairID") then
    Z.RedPointMgr.RemoveChildNodeData(E.RedType.FaceEditorHairCustomDull, redNodeName)
  end
end

function FaceRed.Init()
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, FaceRed.changeItem)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, FaceRed.changeItem)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, FaceRed.changeItem)
end

function FaceRed.UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, FaceRed.changeItem)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, FaceRed.changeItem)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, FaceRed.changeItem)
end

return FaceRed
