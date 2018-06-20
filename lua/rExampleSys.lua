-- @Author: weiyanguang
-- @Date: 2018-06-17 15:37:29
-- @Last Modified by: weiyanguang
-- @Last Modified time: 2018-06-20 17:59:40
-- @Doc: 服务器业务模板

-- -- tbPlayer 常见字段
-- tbPlayer = {
--     dSocketId = 0,
--     time_rec  = {    -- 常见时间
--         birth       = 0,
--         login       = 0,
--         offline     = 0,
--         dailyResets = {[{H,M}] = V, ...}
--         weeklyReset = 0,
--     },
--     sysA = tbAInfo, -- 某系统
--     sysB = tbBInfo, -- 某系统
-- }

-- -- 业务系统常见字段
-- tbAInfo = {
--     lastTime = 0, -- 上一次刷新时间
-- }


function born(tbPlayer)
    -- todo 创建
    -- 初始化数据，预处理数据
end

function loadData(tbPlayer)
    -- todo 获取数据
end

function saveData(tbPlayer)
    -- todo 保存数据
    -- 定时？即时
end

function onLogin(tbPlayer)
    -- todo 登录数据预处理
end


function offline(tbPlayer)
    -- todo 下线数据处理
    -- 登出/离线
end

function tsendOnLogin(tbPlayer)
    -- todo 登录协议同步
    -- 通常 dailyReset也会默认调用该函数
end

function dailyReset(tbPlayer, tbTime={dHour, dMinute})
    -- todo 每日重置
    -- 0点，也有其他时段的需求
end
