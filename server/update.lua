-- GitHub 版本更新检查：资源启动时查询一次仓库最新版本，有新版本则在服务器控制台提示
-- GitHub update check: queries the repository once on resource start and prints a
-- notice to the server console when a newer version is available.
-- 版本来源：Releases latest -> 失败（例如仓库未发 Release）则回落 tags 列表
-- Source: releases/latest, falls back to the tag list when that fails (e.g. no release published).

local UPDATE = Config.UpdateCheck or {}

if UPDATE.enabled == false or not UPDATE.repository or UPDATE.repository == '' then
    return
end

local RESOURCE = GetCurrentResourceName()
local CURRENT_VERSION = GetResourceMetadata(RESOURCE, 'version', 0) or '0.0.0'

local REQUEST_HEADERS = {
    ['User-Agent'] = RESOURCE .. '-version-check',
    ['Accept'] = 'application/vnd.github+json'
}

local reported = false

local function Log(message, ...)
    if select('#', ...) > 0 then
        message = message:format(...)
    end
    print(('^3[%s]^7 %s'):format(RESOURCE, message))
end

local function Debug(message, ...)
    if UPDATE.debug then
        Log(message, ...)
    end
end

-- '2.0.1' / 'v2.0.1' / '2.0.1-beta' -> { segments = {2,0,1}, prerelease = bool }
local function ParseVersion(version)
    if type(version) ~= 'string' then
        return nil
    end

    local segments_part, suffix = version:match('^[vV]?(%d[%d%.]*)(.*)$')
    if not segments_part then
        return nil
    end

    local segments = {}
    for segment in segments_part:gmatch('%d+') do
        segments[#segments + 1] = tonumber(segment)
    end

    if #segments == 0 then
        return nil
    end

    return { segments = segments, prerelease = suffix ~= '' }
end

local function IsNewer(candidate, current)
    local newer, older = ParseVersion(candidate), ParseVersion(current)

    if not newer then
        return false
    end

    if not older then
        return true
    end

    for i = 1, math.max(#newer.segments, #older.segments) do
        local a, b = newer.segments[i] or 0, older.segments[i] or 0
        if a ~= b then
            return a > b
        end
    end

    -- 主版本相同时，正式版比预发布版新
    -- Same numbers: a stable release is newer than a prerelease
    return older.prerelease and not newer.prerelease
end

local function Report(latest, releaseUrl)
    if reported then
        return
    end
    reported = true

    local url = UPDATE.downloadUrl
    if not url or url == '' then
        url = releaseUrl
    end
    if not url or url == '' then
        url = ('https://github.com/%s/releases'):format(UPDATE.repository)
    end

    Log('发现新版本 / Update available: %s -> %s', CURRENT_VERSION, latest)
    Log('请更新资源，下载地址 / Please update, download: %s', url)
end

local function RequestJson(url, onSuccess, onFailure)
    PerformHttpRequest(url, function(status, body)
        if status ~= 200 or type(body) ~= 'string' or body == '' then
            Debug('请求失败 / Request failed (HTTP %s): %s', status, url)
            if onFailure then
                onFailure()
            end
            return
        end

        local ok, data = pcall(json.decode, body)
        if not ok or type(data) ~= 'table' then
            Debug('响应解析失败 / Failed to parse response: %s', url)
            if onFailure then
                onFailure()
            end
            return
        end

        onSuccess(data)
    end, 'GET', '', REQUEST_HEADERS)
end

local function CheckTags()
    RequestJson(('https://api.github.com/repos/%s/tags'):format(UPDATE.repository), function(tags)
        local latest
        for _, tag in ipairs(tags) do
            local name = type(tag) == 'table' and tag.name or nil
            if name and ParseVersion(name) and (not latest or IsNewer(name, latest)) then
                latest = name
            end
        end

        if latest and IsNewer(latest, CURRENT_VERSION) then
            Report(latest)
        else
            Debug('已是最新版本 / Already up to date (%s)', CURRENT_VERSION)
        end
    end)
end

local function CheckReleases()
    local url = ('https://api.github.com/repos/%s/releases/latest'):format(UPDATE.repository)

    RequestJson(url, function(release)
        local tag = release.tag_name
        if type(tag) == 'string' and IsNewer(tag, CURRENT_VERSION) then
            Report(tag, release.html_url)
        else
            Debug('已是最新版本 / Already up to date (%s)', CURRENT_VERSION)
        end
    end, CheckTags)
end

CreateThread(function()
    -- 等服务器启动完成再请求，避免拖慢启动
    -- Wait for the server to finish booting so the request does not slow it down
    Wait(5000)
    Debug('开始检查更新，当前版本 / Checking for updates, current version %s', CURRENT_VERSION)
    CheckReleases()
end)
