local RichTextHelper = {}
E.ELinkType = {
  Simple = "simple",
  Recordclick = "recordclick",
  Imur = "imur"
}

function RichTextHelper.ClickLink(tmpLab, callback)
  tmpLab:AddListener(function(link, text)
    if link == nil then
      logError("RichText OpenUrl Fail: link is nil")
      return
    end
    local leftIndex = string.find(link, "#")
    if leftIndex == nil then
      logError("RichText OpenUrl Fail: params count invalid link is: " .. link)
      return
    end
    local linkType = string.sub(link, 1, leftIndex - 1)
    local linkContent = string.sub(link, leftIndex + 1)
    if linkType == E.ELinkType.Simple or linkType == E.ELinkType.Recordclick then
      logGreen("OpenURL URL :" .. linkContent)
      Z.SDKWebView.OpenWebView(linkContent, false)
    elseif linkType == E.ELinkType.Imur then
      logGreen("OpenURL URL :" .. linkContent)
      Z.SDKWebView.OpenWebView(linkContent, true)
    else
      logError("RichText OpenUrl Fail: params linkType invalid link is: " .. link)
      return
    end
    if callback then
      callback(linkType, linkContent, text)
    end
  end)
end

function RichTextHelper.AddTmpLabClick(tmpLab, text, func)
  if tmpLab == nil or tmpLab.TMPLab == nil then
    logError("[RichText] tmpLab is nil")
    return
  end
  tmpLab.TMPLab.text = string.zconcat("<link>", text, "</link>")
  tmpLab.TMPLab:AddListener(function()
    if func then
      func()
    end
  end)
end

function RichTextHelper.SetTmpLabTextWithCommonLink(tmpLab, text)
  local tableMgr = Z.TableMgr.GetTable("TextDescriptionMgr")
  local keyIdList = {}
  for keyId in string.gmatch(text, "<linktext=([0-9]*)>") do
    keyIdList[#keyIdList + 1] = tonumber(keyId)
  end
  local showTable = {}
  local tableIdList = {}
  for i = 1, #keyIdList do
    if not tableIdList[keyIdList[i]] then
      tableIdList[keyIdList[i]] = true
      local textTable = tableMgr.GetRow(keyIdList[i], true)
      if textTable then
        table.insert(showTable, textTable)
      end
    end
  end
  text = string.gsub(text, "<linktext=([0-9]*)>", "<u><link>", #keyIdList)
  text = string.gsub(text, "</linktext>", "</link></u>", #keyIdList)
  tmpLab.TMPLab.text = text
  tmpLab.TMPLab:AddListener(function()
    Z.CommonTipsVM.OpenRichText(showTable)
  end)
end

function RichTextHelper.SetTmpLabTextWithCommonLinkNew(tmpLab, text)
  local tableMgr = Z.TableMgr.GetTable("TextDescriptionMgr")
  local keyIdList = {}
  for keyId in string.gmatch(text, "<linktext=([0-9]*)>") do
    keyIdList[#keyIdList + 1] = tonumber(keyId)
  end
  local showTable = {}
  local tableIdList = {}
  for i = 1, #keyIdList do
    if not tableIdList[keyIdList[i]] then
      tableIdList[keyIdList[i]] = true
      local textTable = tableMgr.GetRow(keyIdList[i], true)
      if textTable then
        table.insert(showTable, textTable)
      end
    end
  end
  text = string.gsub(text, "<linktext=([0-9]*)>", "<u><link>", #keyIdList)
  text = string.gsub(text, "</linktext>", "</link></u>", #keyIdList)
  tmpLab.text = text
  tmpLab:AddListener(function()
    Z.CommonTipsVM.OpenRichText(showTable)
  end)
end

function RichTextHelper.SetBinderTmpLabTextWithCommonLink(tmpLab, text)
  local tableMgr = Z.TableMgr.GetTable("TextDescriptionMgr")
  local keyIdList = {}
  for keyId in string.gmatch(text, "<linktext=([0-9]*)>") do
    keyIdList[#keyIdList + 1] = tonumber(keyId)
  end
  local showTable = {}
  local tableIdList = {}
  for i = 1, #keyIdList do
    if not tableIdList[keyIdList[i]] then
      tableIdList[keyIdList[i]] = true
      local textTable = tableMgr.GetRow(keyIdList[i], true)
      if textTable then
        table.insert(showTable, textTable)
      end
    end
  end
  text = string.gsub(text, "<linktext=([0-9]*)>", "<u><link>", #keyIdList)
  text = string.gsub(text, "</linktext>", "</link></u>", #keyIdList)
  tmpLab.text = text
  tmpLab:AddListener(function()
    Z.CommonTipsVM.OpenRichText(showTable)
  end)
end

function RichTextHelper.DeleteTextLink(text)
  text = string.gsub(text, "<linktext=([0-9]*)>", "")
  text = string.gsub(text, "</linktext>", "")
  return text
end

function RichTextHelper.RefreshItemExpendCountUi(haveCount, expendCount, colorKey)
  local isOverLmit = 999 < haveCount
  if expendCount and haveCount < expendCount then
    haveCount = Z.NumTools.NumberToK(haveCount)
    expendCount = Z.NumTools.NumberToK(expendCount)
    colorKey = colorKey or E.TextStyleTag.TipsRed
  else
    colorKey = E.TextStyleTag.TipsGreen
    haveCount = Z.NumTools.NumberToK(haveCount)
    expendCount = Z.NumTools.NumberToK(expendCount)
  end
  local ownStr = isOverLmit and "999+" or haveCount
  ownStr = RichTextHelper.ApplyStyleTag(ownStr, colorKey)
  return string.zconcat(ownStr, "/", expendCount)
end

function RichTextHelper.ApplyStyleTag(text, style)
  local text = string.zconcat("<style=", style, ">", text, "</style>")
  return text
end

function RichTextHelper.ApplySizeTag(text, size)
  local text = string.zconcat("<size=", size, ">", text, "</size>")
  return text
end

function RichTextHelper.ApplyColorTag(text, color)
  local text = string.zconcat("<color=", color, ">", text, "</color>")
  return text
end

function RichTextHelper.ApplyUnderLineTag(text)
  local text = string.zconcat("<u>", text, "</u>")
  return text
end

function RichTextHelper.ApplyLinkTag(linkKey, linkContent)
  local text = string.zconcat("<link=\"", linkKey, "\">", linkContent, "</link>")
  return text
end

function RichTextHelper.ParseTextWithImages(text)
  local result = {}
  local lastPos = 1
  for startPos, imgPath, endPos in text:gmatch("()<pic=(.-)>()") do
    if startPos > lastPos then
      local labelText = text:sub(lastPos, startPos - 1)
      if 0 < #labelText then
        table.insert(result, {
          contentType = E.RichTextContentType.Text,
          content = labelText
        })
      end
    end
    table.insert(result, {
      contentType = E.RichTextContentType.Image,
      content = imgPath
    })
    lastPos = endPos
  end
  if lastPos <= #text then
    local remainingText = text:sub(lastPos)
    if remainingText ~= nil and 0 < string.len(remainingText) then
      table.insert(result, {
        contentType = E.RichTextContentType.Text,
        content = remainingText
      })
    end
  end
  return result
end

function RichTextHelper.RemoveStyleTag(content)
  local text = string.gsub(content, "<style=[^>]+>", "")
  text = string.gsub(text, "</style>", "")
  return text
end

function RichTextHelper.RemoveTagsOtherThanEmojis(content)
  local text = string.gsub(content, "(<[^>]+>)", function(tag)
    if tag:match("^<sprite=%d+>$") then
      return tag
    else
      return ""
    end
  end)
  return text
end

function RichTextHelper.RmoveHrefTag(content)
  return string.gsub(content, "<a href=[^>]+>", "")
end

return RichTextHelper
