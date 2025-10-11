local DownloadVM = {}

function DownloadVM:GetPicture(fileName, url, token, callback, foldName)
  if not callback then
    logError("GetPicture callback is empty!")
    return
  end
  if string.zisEmpty(fileName) or string.zisEmpty(url) then
    logError("GetPicture param is empty!")
    callback(-1)
    return
  end
  Z.DownloadManager:GetPicture(fileName, url, token, callback, foldName)
end

function DownloadVM:GetFileName(charId, version, type)
  local name = charId .. "_" .. type .. "_" .. version
  return name
end

return DownloadVM
