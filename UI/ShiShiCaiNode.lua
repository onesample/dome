
-- Creator matt
-- Create Time 2017/10/17

local gt = cc.exports.gt

local ShiShiCaiNode = class("ShiShiCaiNode", function()
	return cc.CSLoader:createNode("SSCaiNode.csb")
end)

function ShiShiCaiNode:ctor( parentNode )
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.msgTextCache = {}
	self.Gamestate = 1
    self.Gametime = 1
    self.PlayActions = false
    self.stopflag = false

    self.CarTimeBg = gt.seekNodeByName(self, "Panel_Time")
    self.CarTimeStrip = gt.seekNodeByName(self, "TimeOutBg_3")
    self.CarTimeTxt = gt.seekNodeByName(self, "Text_1")
    self.CarTimeTxt:setString("20s")

    --self.zhuojitime = 20
	self.m_parentNode = parentNode

    local shuionum = gt.string_split(self.m_parentNode[2],",")
    for i=1,5 do 
        local shuiguokuang = string.format("Panel_%d", i)
        local shuiguoGa = gt.seekNodeByName(self, shuiguokuang)
        local shuiguo = gt.seekNodeByName(shuiguoGa, "FiguresNum1")
        shuiguo:setString(shuionum[i])
    end
end

function ShiShiCaiNode:onNodeEvent(eventName)
	if "enter" == eventName then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function ShiShiCaiNode:update(delta)
	if not self.Gamestate then
		return
	end

--    self.zhuojitime = self.zhuojitime - 1

--    if self.zhuojitime < 0 then
--            self.zhuojitime = 20
--            self.Gamestate = 1
--            self.shuiguodown = 0
--            self:playshuiguo()
--            return
--        end
end

function ShiShiCaiNode:CarTimeUpdate(Total,delta)
    self.CarTimeTxt:setString(delta.."s")
    self.CarTimeBg:setVisible(true)
    local Rotate = Total - delta
    local animation = cc.RotateTo:create(0.2, (120/Total)*Rotate)
    self.CarTimeStrip:runAction(cc.RepeatForever:create(animation))
    local DaojiShi
    if delta <= 5 then
        DaojiShi = gt.soundEngine:playEffect("DaojiShi",false)
    end
    if delta <= 0 then
        self.CarTimeBg:setVisible(false)
        gt.soundEngine:stopEffect(DaojiShi)
    else
        self.CarTimeBg:setVisible(true)
    end
end
--水果跑起来！
function ShiShiCaiNode:playshuiguo()
    local shuionum = gt.string_split(self.m_parentNode[2],",")
    
    self.PlayActions = true
    for i=1,5 do 
        local shuiguokuang = string.format("Panel_%d", i)
        local shuiguoGa = gt.seekNodeByName(self, shuiguokuang)
        local shuiguo = gt.seekNodeByName(shuiguoGa, "FiguresNum1")

        local pos = cc.p(40, -48)
        local moveTo = cc.MoveTo:create(0.1, pos)
        local call = cc.CallFunc:create(function ()
            shuiguo:setString(math.random(0,9))
            shuiguo:setPosition(cc.p(40, 128))
            
            self:shuiguoRunAction(shuiguo,0.2,i)
        end)
        local spa = cc.Spawn:create(moveTo, call)
        shuiguo:stopAllActions()
        shuiguo:runAction(spa)

    end
end

function ShiShiCaiNode:SetLotteryNo(lotteryNo)
    self.stopflag = true
end

--水果跑起来！
function ShiShiCaiNode:shuiguoRunAction(shuiobj,time,num)
        local pos = cc.p(40, -44)
        if self.stopflag then 
            pos = cc.p(40, 128)
        else
            pos = cc.p(40, -44)
        end
        local moveTo = cc.MoveTo:create(time, pos)
        local call = cc.CallFunc:create(function ()
            if self.stopflag then
                --输入最终结果值
                local shuionum = gt.string_split(self.m_parentNode[2],",")
                shuiobj:setString(shuionum[num])
                local posz = cc.p(35, 50)
                shuiobj:runAction(cc.Sequence:create(cc.MoveTo:create(0.4, posz),cc.CallFunc:create(function ()
                    self.PlayActions = false
                    self.stopflag = false
                end)))
            else
                shuiobj:setString(math.random(0,9))
                shuiobj:setPosition(cc.p(40,128))
                self:shuiguoRunAction(shuiobj,0.2,num)
            end
        end)
        local spa = cc.Sequence:create(moveTo, call)
        shuiobj:stopAllActions()
        shuiobj:runAction(spa)
end

--水果跑起来！
function ShiShiCaiNode:shuiguoRunAction_one(shuiobj,time,num)
        
        local shuionum = gt.string_split(self.m_parentNode[2],",")
        local pos = cc.p(40, -44)
        local moveTo = cc.MoveTo:create(time, pos)
        local call = cc.CallFunc:create(function ()
            shuiobj:setString(math.random(0,9))
            shuiobj:setPosition(cc.p(40, 128))

        end)
        local call2 = cc.CallFunc:create(function ()
             --输入最终结果值
            shuiobj:setString(shuionum[num])
            local posz = cc.p(35, 50)
            shuiobj:runAction(cc.Sequence:create(cc.MoveTo:create(0.4, posz),cc.CallFunc:create(function ()
                self.PlayActions = false
            end)))
        end)
        local spa = cc.Sequence:create(moveTo, call)
        local repeatAction    = cc.Repeat:create(spa,30)
        local spa2 = cc.Sequence:create(repeatAction, call2)
        shuiobj:stopAllActions()
        shuiobj:runAction(spa2)
end


return ShiShiCaiNode