local UnionLogoItem = class("UnionLogoItem")

function UnionLogoItem:ctor()
end

function UnionLogoItem:Init(go)
  self.uiBinder = UIBinderToLua(go)
end

function UnionLogoItem:UnInit()
  self.uiBinder = nil
end

function UnionLogoItem:SetLogo(logoData)
  if logoData == nil then
    logError("logoData is nil!")
    return
  end
  local tableInfo = Z.TableMgr.GetTable("UnionIconTableMgr")
  local frontIconCfg = tableInfo.GetRow(logoData.frontIconId)
  if frontIconCfg == nil then
    logError("UnionIconTable\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\233\133\141\231\189\174", logoData.frontIconId)
    return
  end
  local backTexCfg = tableInfo.GetRow(logoData.backIconTexId)
  if backTexCfg == nil then
    logError("UnionIconTable\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\233\133\141\231\189\174", logoData.backIconTexId)
    return
  end
  local backIconCfg = tableInfo.GetRow(logoData.backIconId)
  if backIconCfg == nil then
    logError("UnionIconTable\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\233\133\141\231\189\174", logoData.backIconId)
    return
  end
  self.uiBinder.img_small:SetImage(frontIconCfg.ShowIconRoute)
  self.uiBinder.img_small:SetColor(logoData.frontIconColor)
  self.uiBinder.rimg_large:SetMatInstanceColor("_EdgeColor", logoData.backIconColor)
  self.uiBinder.rimg_large:SetMatTexture("_BackTex", backTexCfg.ResourceRoute, function()
    if self.uiBinder then
      self.uiBinder.rimg_large:SetImage(backIconCfg.ResourceRoute)
    end
  end, nil)
end

return UnionLogoItem
