Config = {}

-- 框架：'auto' | 'esx' | 'qb' | 'qbox' | 'standalone'
-- Framework: 'auto' | 'esx' | 'qb' | 'qbox' | 'standalone'
-- auto 会按已启动资源自动识别（qbx_core > qb-core > es_extended）
-- 'auto' detects the framework from started resources (qbx_core > qb-core > es_extended)
Config.Framework = 'auto'

-- osp_ambulance / qbx_medical 流血与骨折集成
-- osp_ambulance / qbx_medical bleeding & bone-break integration
Config.UseQbxMedical = false

-- 车祸触发骨折的速度骤降阈值 (m/s)
-- Speed drop threshold (m/s) that triggers a bone break on crash
Config.CrashSpeedThreshold = 15.0

-- 自动出血的生命值阈值
-- Health threshold below which bleeding starts automatically
Config.BleedingHealthThreshold = 140

-- GitHub 更新检查：资源启动时查询一次，有新版本则输出到服务器控制台
-- GitHub update check: queried once on resource start, prints to the server console when a newer version exists
Config.UpdateCheck = {
    enabled = true,
    -- GitHub 仓库（owner/repo），留空则关闭检查
    -- GitHub repository (owner/repo), empty disables the check
    repository = '3597722621/mirage_hud',
    -- 提示里的下载地址，留空则自动使用仓库 Releases 页
    -- Download URL shown in the notice, empty uses the repository releases page
    downloadUrl = '',
    -- 输出请求失败 / 已是最新的日志，排查用
    -- Log request failures / "already up to date", useful for troubleshooting
    debug = false,
}

-- 治疗/复活后清除出血与骨折的事件（ESX + QB 常见事件）
-- Events that clear bleeding & bone break after healing/revive (common ESX + QB events)
Config.HealingEvents = {
    -- ESX / ambulance
    'hospital:client:Revive',
    'hospital:client:HealInjuries',
    'hospital:client:TreatWounds',
    'esx_ambulancejob:revive',
    'osp_ambulance:partialRevive',
    'esx:onPlayerSpawn',
    -- QB / Qbox
    'QBCore:Client:OnPlayerLoaded',
    'hospital:client:Revive',
    'qbx_medical:client:playerRevived',
}
