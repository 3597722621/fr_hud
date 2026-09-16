Config = {}

-- 框架：'auto' | 'esx' | 'qb' | 'qbox' | 'standalone'
-- auto 会按已启动资源自动识别（qbx_core > qb-core > es_extended）
Config.Framework = 'auto'

-- osp_ambulance / qbx_medical 流血与骨折集成
Config.UseQbxMedical = false

-- 车祸触发骨折的速度骤降阈值 (m/s)
Config.CrashSpeedThreshold = 15.0

-- 自动出血的生命值阈值
Config.BleedingHealthThreshold = 140

-- 治疗/复活后清除出血与骨折的事件（ESX + QB 常见事件）
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
