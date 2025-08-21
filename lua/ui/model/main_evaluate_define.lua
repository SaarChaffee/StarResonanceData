local DEF = {}
DEF.COLOR_DEFINE = {
  [1] = Color.New(0.5019607843137255, 0.5019607843137255, 0.5019607843137255, 1),
  [2] = Color.New(0.396078431372549, 0.7647058823529411, 0.20784313725490197, 1),
  [3] = Color.New(0.1411764705882353, 0.7450980392156863, 0.8117647058823529, 1),
  [4] = Color.New(0.796078431372549, 0.0196078431372549, 0.9294117647058824, 1),
  [5] = Color.New(0.8784313725490196, 0.7647058823529411, 0.07450980392156863, 1),
  [6] = Color.New(0.8745098039215686, 0.5686274509803921, 0.07450980392156863, 1),
  [7] = Color.New(0.8823529411764706, 0.4117647058823529, 0.13725490196078433, 1)
}
DEF.IMAGE_DEFINE = {
  [1] = "ui/textures/main/evaluate/main_evaluate_d",
  [2] = "ui/textures/main/evaluate/main_evaluate_c",
  [3] = "ui/textures/main/evaluate/main_evaluate_b",
  [4] = "ui/textures/main/evaluate/main_evaluate_a",
  [5] = "ui/textures/main/evaluate/main_evaluate_s1",
  [6] = "ui/textures/main/evaluate/main_evaluate_s2",
  [7] = "ui/textures/main/evaluate/main_evaluate_s3"
}
DEF.START_ANIM_NAME = {
  [1] = "anim_main_evaluate_tpl_s",
  [2] = "anim_main_evaluate_tpl_s",
  [3] = "anim_main_evaluate_tpl_s",
  [4] = "anim_main_evaluate_tpl_s",
  [5] = "anim_main_evaluate_tpl_s",
  [6] = "anim_main_evaluate_tpl_ss",
  [7] = "anim_main_evaluate_tpl_sss"
}
DEF.END_ANIM_NAME = {
  [1] = "anim_main_evaluate_tpl_s_d_ed",
  [2] = "anim_main_evaluate_tpl_s_d_ed",
  [3] = "anim_main_evaluate_tpl_s_d_ed",
  [4] = "anim_main_evaluate_tpl_s_d_ed",
  [5] = "anim_main_evaluate_tpl_s_d_ed",
  [6] = "anim_main_evaluate_tpl_ss_ed",
  [7] = "anim_main_evaluate_tpl_sss_ed"
}
DEF.LOOP_ANIM_NAME = {
  [1] = "anim_main_evaluate_tpl_s_d_ed_loop",
  [2] = "anim_main_evaluate_tpl_s_d_ed_loop",
  [3] = "anim_main_evaluate_tpl_s_d_ed_loop",
  [4] = "anim_main_evaluate_tpl_s_d_ed_loop",
  [5] = "anim_main_evaluate_tpl_s_d_ed_loop",
  [6] = "anim_main_evaluate_tpl_ss_ed_loop",
  [7] = "anim_main_evaluate_tpl_sss_ed_loop"
}
DEF.PC_START_ANIM_NAME = {
  [1] = "anim_main_evaluate_tpl_s_pc",
  [2] = "anim_main_evaluate_tpl_s_pc",
  [3] = "anim_main_evaluate_tpl_s_pc",
  [4] = "anim_main_evaluate_tpl_s_pc",
  [5] = "anim_main_evaluate_tpl_s_pc",
  [6] = "anim_main_evaluate_tpl_ss_pc",
  [7] = "anim_main_evaluate_tpl_sss_pc"
}
DEF.PC_END_ANIM_NAME = {
  [1] = "anim_main_evaluate_tpl_s_d_pc_ed",
  [2] = "anim_main_evaluate_tpl_s_d_pc_ed",
  [3] = "anim_main_evaluate_tpl_s_d_pc_ed",
  [4] = "anim_main_evaluate_tpl_s_d_pc_ed",
  [5] = "anim_main_evaluate_tpl_s_d_pc_ed",
  [6] = "anim_main_evaluate_tpl_ss_pc_ed",
  [7] = "anim_main_evaluate_tpl_sss_pc_ed"
}
DEF.PC_LOOP_ANIM_NAME = {
  [1] = "anim_main_evaluate_tpl_s_d_pc_ed_loop",
  [2] = "anim_main_evaluate_tpl_s_d_pc_ed_loop",
  [3] = "anim_main_evaluate_tpl_s_d_pc_ed_loop",
  [4] = "anim_main_evaluate_tpl_s_d_pc_ed_loop",
  [5] = "anim_main_evaluate_tpl_s_d_pc_ed_loop",
  [6] = "anim_main_evaluate_tpl_ss_pc_ed_loop",
  [7] = "anim_main_evaluate_tpl_sss_pc_ed_loop"
}
DEF.START_EFFECT_PATH = {
  [1] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_d",
  [2] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_c",
  [3] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_b",
  [4] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_a",
  [5] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_s",
  [6] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_ss",
  [7] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_sss"
}
DEF.END_EFFECT_PATH = {
  [1] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_d_ed",
  [2] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_c_ed",
  [3] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_b_ed",
  [4] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_a_ed",
  [5] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_s_ed",
  [6] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_ss_ed",
  [7] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_sss_ed"
}
DEF.LOOP_EFFECT_PATH = {
  [1] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_d_loop",
  [2] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_c_loop",
  [3] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_b_loop",
  [4] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_a_loop",
  [5] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_s_loop",
  [6] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_ss_loop",
  [7] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_sss_loop"
}
DEF.PC_START_EFFECT_PATH = {
  [1] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_d_pc",
  [2] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_c_pc",
  [3] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_b_pc",
  [4] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_a_pc",
  [5] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_s_pc",
  [6] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_ss_pc",
  [7] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_sss_pc"
}
DEF.PC_END_EFFECT_PATH = {
  [1] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_d_pc_ed",
  [2] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_c_pc_ed",
  [3] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_b_pc_ed",
  [4] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_a_pc_ed",
  [5] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_s_pc_ed",
  [6] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_ss_pc_ed",
  [7] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_sss_pc_ed"
}
DEF.PC_LOOP_EFFECT_PATH = {
  [1] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_d_pc_loop",
  [2] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_c_pc_loop",
  [3] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_b_pc_loop",
  [4] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_a_pc_loop",
  [5] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_s_pc_loop",
  [6] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_ss_pc_loop",
  [7] = "ui/uieffect/prefab/ui_sfx_main_evaluate_tpl/ui_sfx_main_evaluate_tpl_sss_pc_loop"
}
return DEF
