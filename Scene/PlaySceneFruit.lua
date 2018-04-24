
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local PlaySceneFruit = class("PlaySceneFruit", function()
	return cc.Scene:create()
end)

function PlaySceneFruit:ctor()
    self.bMove = false
    self:registerScriptHandler(handler(self, self.onNodeEvent))
	local csbNode = nil
	csbNode = cc.CSLoader:createNode("LittleGame_Fruit.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    
    local lobby_bj = gt.seekNodeByName(csbNode, "GameFruitBg_1")
    self.lobby_bj = lobby_bj
	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        Utils.setClickEffect()
        local LittleGameScene = require("app/views/Scene/LittleGameScene"):create()
		 cc.Director:getInstance():replaceScene(LittleGameScene)     
	end)
    
	-- 返回按钮
	local StartBtn = gt.seekNodeByName(lobby_bj, "Button_Go")
	gt.addBtnPressedListener(StartBtn, function()
        Utils.setClickEffect()
        self.bMove = true
	end)

    local SprBackLight = gt.seekNodeByName(lobby_bj, "SprLight_2")
    self.SprBackLight = SprBackLight
    self.LightX = {}
    self.LightY = {}
    local FruitUpY = 1017
    local FruitDownY = 483
    local FruitLeftX = 108
    local FruitRightX = 642
    for i = 1 , 7 do
        self.LightX[i] = 19 + 89*i
        self.LightY[i] = 394 + 89*i
    end

end
local Move = 0 
local StopMove = 0
local tima = 0
local resultMove = math.random(240,264)
function PlaySceneFruit:onNodeEvent(eventName)
	if "enter" == eventName then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0.02, false)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function PlaySceneFruit:update(delta)
    local DataTiam = os.time()
    --print("=========",DataTiam)
    if self.bMove == true then
        if tima == 0 then
            self:MoveAction()
        else
            if tima%10 == 0 then
                self:MoveAction()
            end
        end
    end
    if StopMove+12 > resultMove then
        tima = tima+1
    end
    if StopMove == resultMove  then
        self:CleanMove()
    end
end

function PlaySceneFruit:CleanMove()
    Move = 0 
    StopMove = 0
    MoveIndex = 1
    tima = 0
    resultMove = math.random(144,168)
    self.bMove = false
end

function PlaySceneFruit:MoveAction()
    if StopMove < resultMove then
        Move = Move+1
        StopMove= StopMove +1
    else
        Move = resultMove - 240
    end
    if Move < 8 then
        self.SprBackLight:setPosition(self.LightX[Move],483)
    end
    if Move >=8 and Move < 14 then
        self.SprBackLight:setPosition(642,self.LightY[Move-6])
    end
    if Move >=14 and Move < 20 then
        self.SprBackLight:setPosition(self.LightX[20-Move],1017)
    end
    if Move >=20 and Move < 25 then
        self.SprBackLight:setPosition(108,self.LightY[26-Move])
    end
    if Move>23 then
        Move = 0
    end
end

-- 断线重连,初始化数据
function PlaySceneFruit:reLogin()
    -- 进游戏桌子
    local cmsg = cmd_node_pb.CEnterGameReq()
    cmsg.node_id = gt.EnterGameRoomId
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_ENTER_GAME_REQ,msgData)
    --要启动联网取数据！
    --gt.showLoadingTips()
    gt.isshowlading = true
    GameBase:initdata()
end
return PlaySceneFruit

