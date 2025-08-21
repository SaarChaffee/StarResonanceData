local StoryMessageVM = {}

function StoryMessageVM.OpenStoryMessageView(configId)
  Z.UIMgr:OpenView("story_fade_message_window", configId)
end

return StoryMessageVM
