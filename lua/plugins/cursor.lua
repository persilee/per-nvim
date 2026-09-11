return {
  "sphamba/smear-cursor.nvim",

  opts = {
    -- ========== 核心动画参数（解决抖动最关键） ==========
    -- 光标头部跟随速度：越高越跟手，太高会生硬
    stiffness = 0.7,
    -- 光标尾部跟随速度：越高拖尾越短，抖动越少
    trailing_stiffness = 0.5,
    -- 阻尼系数：越高越无回弹、越丝滑；默认0.85偏低会抖
    damping = 0.90,
    -- 插入模式下的阻尼，同样调高避免插入时抖
    damping_insert_mode = 0.90,
    -- 动画停止阈值：大于0.3就基本不会微颤，默认0.1太小
    distance_stop_animating = 0.3,

    -- ========== 帧率优化（解决卡顿式抖动） ==========
    -- 绘制间隔，默认17ms（约60帧），调低到7ms提升流畅度
    time_interval = 7,

    -- ========== 版本兼容修复（解决命令模式后抖一下） ==========
    -- Neovim 0.11.x 必须加，修复退出命令行后光标瞬移抖动
    delay_event_to_smear = 10,

    -- ========== 可选优化 ==========
    -- 关闭跨缓冲区动画，减少不必要的大幅跳动
    smear_between_buffers = false,
    -- 关闭命令行的 smear，避免命令行光标异常
    smear_to_cmd = false,
  },
}
