local pb = require("pb2")
local SocialNtfStubImpl = {}

function SocialNtfStubImpl:OnCreateStub()
end

function SocialNtfStubImpl:NotifySocialData(call, vRequest)
  if vRequest.data then
    local socialData = Z.DataMgr.Get("social_data")
    socialData:SetSocialData(vRequest.data)
  end
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  if vRequest and vRequest.data and vRequest.data.basicData and vRequest.data.basicData.charID == Z.ContainerMgr.CharSerialize.charId then
    local curState = friendMainData:GetPlayerPersonalState()
    local newState = vRequest.data.basicData.personalState
    local isChange = false
    if #curState == #newState then
      if #curState == 0 then
        return
      end
      for i = 1, #curState do
        if curState[i] ~= newState[i] then
          isChange = true
          break
        end
      end
      if isChange == false then
        return
      end
    end
    friendMainData:SetPlayerPersonalState(vRequest.data.basicData.personalState)
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendSelfPersonalStateRefresh)
  end
end

return SocialNtfStubImpl
