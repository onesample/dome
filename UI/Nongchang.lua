
-- Creator matt
-- Create Time 2017/10/17

local gt = cc.exports.gt

local Nongchang = class("Nongchang", function()
	return cc.CSLoader:createNode("NchangNode.csb")
end)

function Nongchang:ctor( parentNode )
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.msgTextCache = {}
	self.Gamestate = 1
    self.Gametime = 1

    self.timemiao = gt.seekNodeByName(self, "timemiao")
    self.Second_2 = gt.seekNodeByName(self, "Second_2")
    self.timemiao:setString("00")
--    self.timemiao:setVisible(false)
--    self.Second_2:setVisible(false)


    self.renwu1 = gt.seekNodeByName(self, "GO1_3")
    self.renwu2 = gt.seekNodeByName(self, "GO2_4")
    self.renwu1:setVisible(false)
    self.renwu2:setVisible(false)

    self.shuiguodown = 0
    --self.zhuojitime = 20
	self.m_parentNode = parentNode
end

function Nongchang:onNodeEvent(eventName)
	if "enter" == eventName then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function Nongchang:update(delta)
	if not self.Gamestate then
		return
	end

--    if self.zhuojitime%2 == 1 then 
--        self.renwu1:setVisible(false)
--        self.renwu2:setVisible(true)
--    else
--        self.renwu1:setVisible(true)
--        self.renwu2:setVisible(false)
--    end
    for j = 1 , 20 do
        --self.LightBg[j]:setVisible(false)
    end
--    local LightNum  = {}
--    for i = 1 ,4 do
--        LightNum[i] = math.random(1,20)
--        print("LightNum[i]--------------"..LightNum[i])
--        self.LightBg[LightNum[i]]:setVisible(true)
--    end

    --self.zhuojitime = self.zhuojitime - 1
--    local fennum1,timemiao1 = math.modf(self.zhuojitime/60)
--    local timemiao1 = timemiao1*60;
--    if self.zhuojitime < 0 then
--            self.zhuojitime = 20
--            self.Gamestate = 1
--            self.shuiguodown = 0
--            self:playshuiguo()
--            return
--        end

    ---gt.log("update===",fennum1,timemiao1)
    --self.timefen:setString("0"..tostring(fennum1))
    
end

function Nongchang:NcTimeUpdate(delta)
    if delta >= 10 then
        self.timemiao:setString(delta)
    else
        self.timemiao:setString("0"..delta)
    end
end
function Nongchang:showMsg(msgText, repeattimes)
	if not msgText or string.len(msgText) == 0 then
		return
	end

	table.insert(self.msgTextCache, msgText)

	if self.m_repeattimes then
		self.msgTextCache = {}
		table.insert(self.msgTextCache, msgText)
	end
	self.m_repeattimes = repeattimes
	if self.m_parentNode then
		self.m_parentNode:setVisible( true )
	end
end
--设定农场游戏 玩时状态 0 下注 1，封盘 repeattimes 周期时长。秒
function Nongchang:SetState(state,repeattimes)
	self.Gamestate = state
    self.Gametime = repeattimes

    if self.Gamestate then

    else

    end
end

--水果跑起来！
--function Nongchang:playshuiguo()
--    local shuionum = gt.string_split(self.m_parentNode[2],",")

--    for i=1,4 do
----    if i > 1 then
----        return
----    end
--        local shuiguokuang = string.format("shuiguokuang_%d", i + self.shuiguodown)
--        local shuiguoGa = gt.seekNodeByName(self, shuiguokuang)
--        local shuiguo = gt.seekNodeByName(shuiguoGa, "shuiguo")
--        --local shuiguo1 = gt.seekNodeByName(shuiguoGa, "shuiguo1")
--        local shuguonum = gt.seekNodeByName(shuiguoGa, "shuguonum")
--        shuguonum:setVisible(false)

--        local pos = cc.p(60, -48)
--        local moveTo = cc.MoveTo:create(0.1, pos)
--        local call = cc.CallFunc:create(function ()
--            local nFruitNum = math.random(1,20)
--            if nFruitNum < 10 then
--                nFruitNum = "0"..nFruitNum
--            end
--            shuiguo:setTexture("res/res/nongchang/shuiguo"..nFruitNum..".png")
--            shuiguo:setPosition(cc.p(60, 128))

--            --gt.log("playshuiguo===","res/res/nongchang/shuiguo"..math.random(1,20)..".png")
--            self:shuiguoRunAction(shuiguo,0.2,shuguonum,i+ self.shuiguodown)
--        end)
--        local spa = cc.Spawn:create(moveTo, call)
--        shuiguo:stopAllActions()
--        shuiguo:runAction(spa)

--        --self:shuiguoRunAction(shuiguo1,0.6)

--    end
--end

----水果跑起来！
--function Nongchang:shuiguoRunAction(shuiobj,time,shuguonum,num)

--    local shuionum = gt.string_split(self.m_parentNode[2],",")

--    local pos = cc.p(60, -44)
--    local moveTo = cc.MoveTo:create(time, pos)
--    local call = cc.CallFunc:create(function ()
--        local nFruitNum = math.random(1,20)
--        if nFruitNum < 10 then
--            nFruitNum = "0"..nFruitNum
--        end
--        shuiobj:setTexture("res/res/nongchang/shuiguo"..nFruitNum..".png")

--        shuiobj:setPosition(cc.p(60, 128))
--    end)
--    local call2 = cc.CallFunc:create(function ()
--        if self.shuiguodown == 0 then
--            self.shuiguodown = 4
--            self:playshuiguo()
--        end
--            --输入最终结果值
--        shuiobj:setTexture("res/res/nongchang/shuiguo"..shuionum[num]..".png")
--        local LightNum = tonumber(shuionum[num])

--        local posz = cc.p(55, 50)
--        shuiobj:runAction(cc.Sequence:create(cc.MoveTo:create(0.4, posz),cc.CallFunc:create(function ()
--            shuguonum:setVisible(true)
--            shuguonum:setString(shuionum[num])
--        end)))
--    end)
--    local spa = cc.Sequence:create(moveTo, call)
--    local repeatAction    = cc.Repeat:create(spa,30)
--    local spa2 = cc.Sequence:create(repeatAction, call2)
--    shuiobj:stopAllActions()
--    shuiobj:runAction(spa2)
--end
--水果跑起来！
function Nongchang:playshuiguo()
    local shuionum = gt.string_split(self.m_parentNode[2],",")

    local shuiguoGa = gt.seekNodeByName(self, "shuiguokuang")
    local shuiguo = gt.seekNodeByName(shuiguoGa, "shuiguo")
    local shuguonum = gt.seekNodeByName(shuiguoGa, "shuguonum")
    shuguonum:setVisible(false)

    local pos = cc.p(97, -48)
    local moveTo = cc.MoveTo:create(0.1, pos)
    local call = cc.CallFunc:create(function ()
        local nFruitNum = math.random(1,20)
        if nFruitNum < 10 then
            nFruitNum = "0"..nFruitNum
        end
        shuiguo:setTexture("res/res/nongchang/shuiguo"..nFruitNum..".png")
        shuiguo:setPosition(cc.p(97, 67))

        --gt.log("playshuiguo===","res/res/nongchang/shuiguo"..math.random(1,20)..".png")
        self:shuiguoRunAction(shuiguo,0.2,shuguonum)
    end)
    local spa = cc.Spawn:create(moveTo, call)
    shuiguo:stopAllActions()
    shuiguo:runAction(spa)

    --self:shuiguoRunAction(shuiguo1,0.6)
end

--水果跑起来！
function Nongchang:shuiguoRunAction(shuiobj,time,shuguonum,num)
        
    local shuionum = gt.string_split(self.m_parentNode[2],",")
       
    local pos = cc.p(97, -44)
    local moveTo = cc.MoveTo:create(time, pos)
    local call = cc.CallFunc:create(function ()
        local nFruitNum = math.random(1,20)
        if nFruitNum < 10 then
            nFruitNum = "0"..nFruitNum
        end
        shuiobj:setTexture("res/res/nongchang/shuiguo"..nFruitNum..".png")

        shuiobj:setPosition(cc.p(97, 67))
    end)
    local call2 = cc.CallFunc:create(function ()
        --输入最终结果值
        shuiobj:setTexture("res/res/nongchang/shuiguo".."11"..".png")
        local LightNum = tonumber(self.m_parentNode[2])

        local posz = cc.p(97, 67)
        shuiobj:runAction(cc.Sequence:create(cc.MoveTo:create(0.4, posz),cc.CallFunc:create(function ()
            shuguonum:setVisible(true)
            shuguonum:setString(self.m_parentNode[2])
        end)))
    end)
    local spa = cc.Sequence:create(moveTo, call)
    local repeatAction    = cc.Repeat:create(spa,60)
    local spa2 = cc.Sequence:create(repeatAction, call2)
    shuiobj:stopAllActions()
    shuiobj:runAction(spa2)
end

return Nongchang