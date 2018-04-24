
-- Creator wy
-- Create Time 2017/10/17

local gt = cc.exports.gt

local BJHappyNode = class("BJHappyNode", function()
	return cc.Node:create()
end)

function BJHappyNode:ctor(  )
    
    self.csbNode, self.Winanimation = gt.createCSAnimation("HappyNode.csb")
    --self.Winanimation:play("animationEnd", true)
    --self.csbNode:setVisible(false)
    self:addChild(self.csbNode)
    --开奖结果
    self.numtap = {}

	self:registerScriptHandler(handler(self, self.onNodeEvent))

    self.CarTimeBg = gt.seekNodeByName(self.csbNode, "Panel_Time")
    --self.CarTimeBg:setVisible(false)
    self.CarTimeStrip = gt.seekNodeByName(self.csbNode, "TimeOutBg_3")
    self.CarTimeTxt = gt.seekNodeByName(self.csbNode, "Text_1")
    self.CarTimeTxt:setString("20s")
    self.AnimalPanel = gt.seekNodeByName(self.csbNode, "Panel_3")
    --self.AnimalPanel:setVisible(false)
    self.TxtWinNum = gt.seekNodeByName(self.AnimalPanel, "TxtWinNum")
    self.TxtWinNum:setVisible(false)
    self.PlayActions = false
    self.BallBegain = false
    self.Ball = {}
     --水管动画
    self.WaterPipe = gt.seekNodeByName(self.csbNode, "Pipe_Panel")

    for i = 1 , 80 do 
        self.Ball[i] = gt.seekNodeByName(self.WaterPipe, "Ball_"..i)
        
    end
    self.BallSmall = {}
    for i =1 ,20 do
        self.BallSmall[i] = gt.seekNodeByName(self.csbNode, "BallSmall_"..i)
    end

    --滚球动画
    math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
end

function BJHappyNode:onNodeEvent(eventName)
	if "enter" == eventName then
	    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	    -- 触摸事件
	    local listener = cc.EventListenerTouchOneByOne:create()
	    listener:setSwallowTouches(false)
	    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0.4, false)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function BJHappyNode:update(delta)
    if not self.PlayActions then
       self.Winanimation:pause()
	end
    if self.BallBegain then
        self:BallAnimal(true)  
    end
end
function BJHappyNode:onTouchBegan(touch, event)
    self.beganPos = self:convertToNodeSpace(touch:getLocation())
--    if self.beganPos.x < -100 then
--        self:PipeAnimal()  
--    elseif self.beganPos.x > 100 then
--        self:PipeBack()
--    else
--        self:BallAnimal(false)  
--    end
    return true
end

function BJHappyNode:CarTimeUpdate(Total,delta)
    self.CarTimeTxt:setString(delta.."s")
    self.CarTimeBg:setVisible(true)
    local Rotate = Total - delta
    local animation = cc.RotateTo:create(0.2, (120/Total)*Rotate)
    self.CarTimeStrip:runAction(cc.RepeatForever:create(animation))
    
    if delta <= 6 and delta > 1 then
        gt.playEngineStr = gt.soundEngine:playEffect("DaojiShi",false)
    end
    if delta <= 0 then
        self.CarTimeBg:setVisible(false)
        --gt.soundEngine:stopEffect(gt.playEngineStr)
    else
        self.CarTimeBg:setVisible(true)
    end
end

function BJHappyNode:BallAnimal(bPlay)  
    if bPlay == true then
        for i = 1 , 80 do 
            local pos = cc.p( math.random(10,638), math.random(-321,-20))
            local Act1 = cc.MoveTo:create(0.4,pos)
            local Act2
            if i > 25 then
                Act2 = cc.RotateBy:create(0.4, -90)
            else
                Act2 = cc.RotateBy:create(0.4, 90)
            end
--            if i > 50 then
--                self.Ball[i]:setVisible(false)
--            else
--                self.Ball[i]:setVisible(true)
--            end
            local spa = cc.Spawn:create(Act1,Act2)
            self.Ball[i]:runAction(spa)
        end
    else
        self.BallBegain = false
        local pos3 = cc.p(324,491)
        local Act3 = cc.MoveTo:create(1,pos3)
        self.WaterPipe:stopAllActions()
        self.WaterPipe:runAction(Act3)
        self:ReedAnimal(false) 
        for i = 1 , 80 do 
            local pos = cc.p( math.random(10,638), math.random(-321,-280))
            local Act1 = cc.MoveTo:create(1,pos)
            local call1 = cc.CallFunc:create(function()
                self:MoveToTop()   
            end)
            local spa = cc.Sequence:create(Act1,call1)
            self.Ball[i]:stopAllActions()
            self.Ball[i]:runAction(spa)
        end
    end
end  
function BJHappyNode:PipeAnimal()  
    
    self.AnimalPanel:setVisible(false)
    self.TxtWinNum:setVisible(false)
    local animation3 = cc.MoveTo:create(1, cc.p(324,491))
    local call1 = cc.CallFunc:create(function()
        self.BallBegain = true
    end)
    --竿旋转
    local call2 = cc.CallFunc:create(function()
        self:ReedAnimal(true)  
    end)
    local spa = cc.Sequence:create(animation3,call1,cc.DelayTime:create(0.6),call2)
    self.WaterPipe:runAction(spa)
end  
--还原界面
function BJHappyNode:PipeBack()  
    self.BallBegain = false
    local pos3 = cc.p(324,244)
    local Act3 = cc.MoveTo:create(1,pos3)
    self.WaterPipe:stopAllActions()
    self.WaterPipe:runAction(Act3)

    --self.WaterPipe:setPosition(324,244)
    self:ReedAnimal(false)  
    self.AnimalPanel:setVisible(false)
    self.TxtWinNum:setVisible(false)
    for i = 1 , 80 do
        local single = i%10
        if single == 0 then
            single = 10
        end
        local Act2= cc.RotateTo:create(1, 0)
        local tens = math.floor((i-1)/10)
        local pos = cc.p(29+(59*single),305 -(40*tens))
        local Act1 = cc.MoveTo:create(1,pos)
        local spa = cc.Spawn:create(Act1,Act2)
        self.Ball[i]:setVisible(true)
        self.Ball[i]:stopAllActions()
--        self.Ball[i]:runAction(spa)
        self.Ball[i]:setRotation(0)
        self.Ball[i]:setPosition(pos)
    end

end  
--竿旋转
function BJHappyNode:ReedAnimal(bPlay)  
    local RightRun = gt.seekNodeByName(self.csbNode, "RightRun_4")
    local LeftRun = gt.seekNodeByName(self.csbNode, "LeftRun_5")
    if bPlay then
         --转圈动画
        local animation = cc.RotateBy:create(0.2, 90)
        RightRun:runAction(cc.RepeatForever:create(animation))
        local animation2 = cc.RotateBy:create(0.2, -90)
        LeftRun:runAction(cc.RepeatForever:create(animation2))
    else
        --转圈动画
        local animation = cc.RotateTo:create(1, 0)
        RightRun:stopAllActions()
        RightRun:runAction(animation)
        local animation2 = cc.RotateTo:create(1, 0)
        LeftRun:stopAllActions()
        LeftRun:runAction(animation2)
    end
end  
--出开奖结果
function BJHappyNode:MoveToTop()  
    --local result = {11,21,33,43,55,64,76,18,39,13,41,52,73,44,45,26,17,68,29,20}
    local TxtWinNum = gt.seekNodeByName(self.csbNode, "TxtWinNum")
    TxtWinNum:setString(self.numtap[1])
    for i = 1 ,10 do
        local pos = cc.p(29+(59*i),60)
        local Act1 = cc.MoveTo:create(1,pos)
        self.Ball[self.numtap[i]]:setRotation(0)
        local call1 = cc.CallFunc:create(function()
            local call3 = cc.CallFunc:create(function()
                self.TxtWinNum:setVisible(true)
                self.PlayActions = false
            end)
            local call2 = cc.CallFunc:create(function()
                self.PlayActions = true
                self.AnimalPanel:setVisible(true)
                self.Winanimation:play("animationEnd", true)
            end)
            local pos2 = cc.p(29+(59*i),20)
            self.Ball[self.numtap[i+10]]:setRotation(0)
            self.Ball[self.numtap[i+10]]:stopAllActions()
            self.Ball[self.numtap[i+10]]:runAction( cc.Sequence:create(cc.MoveTo:create(1,pos2),call2, cc.DelayTime:create(4),call3))
        end)
        local spa = cc.Sequence:create(Act1,call1)
        self.Ball[self.numtap[i]]:stopAllActions()
        self.Ball[self.numtap[i]]:runAction(spa)

    end
end  

--开奖结果
function BJHappyNode:ResultReword(zhonjianTal)  

    local numAdd
    if zhonjianTal ~= "" then
        self.numtap =  gt.string_split(zhonjianTal,",")
    end
	for i = 1, 20  do
        local shade = gt.seekNodeByName(self.csbNode, "BallSmall_"..i)
		local shadow = gt.seekNodeByName(shade, "AtlasLabel_1")
        shadow:setString(self.numtap[i])
        self.numtap[i] = tonumber(self.numtap[i])
--        if numtap[i]%2 == 0 then
--            shade:setTexture("res/res/HappyNode/BallYellowLittle.png")
--        else
--            shade:setTexture("res/res/HappyNode/BallBuleLittle.png")
--        end
    end
end  

return BJHappyNode