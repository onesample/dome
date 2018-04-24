local gt = cc.exports.gt
local Utils = cc.exports.Utils

local Utils = require("app/Utils")

local GameBase = require("app/utils/GameBase")

local PlaySceneNiuNiu = class("PlaySceneNiuNiu", GameBase)

PlaySceneNiuNiu.__index = PlaySceneNiuNiu

--[[

--]]
PlaySceneNiuNiu.FLIMTYPE = {
	FLIMLAYER_BAR				= 1,
	FLIMLAYER_BU				= 2,
}

PlaySceneNiuNiu.TAG = {
	FLIMLAYER_BAR				= 50,
	FLIMLAYER_BU				= 51,
}
local mjTilePerLine = 10
local GAMECHIPTAP = 3000

function PlaySceneNiuNiu:ctor(enterRoomMsgTbl,Roomname,ChoseGameid)
    GameBase:ctor()
    --保存房间信息20161125
    self.roomInfo = enterRoomMsgTbl
    self.ChoseGameid = ChoseGameid

    self.chipTap = 0
    self.delindex = 1

    --周期
    self.zhuijiTime = GameBase.RoomMsgTbl[6]
    self.FenPanTime = GameBase.RoomMsgTbl[7]
	
	self.m_numberMark = 0
	gt.log("进入PlaySceneNiuNiu")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    self.gameMark=true
	-- 加载界面资源
	local csbNode, animation = gt.createCSAnimation("GameScene_NiuNiu.csb")
    self:addChild(csbNode)
	self.rootNode = csbNode

	-- 跑马灯
--	local marqueeNode = gt.seekNodeByName(csbNode, "Node_marquee")
--	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
--	marqueeNode:addChild(marqueeMsg)
--    gt.marqueeMsgTemp = "数学家在不在玩！"
--	self.marqueeMsg = marqueeMsg
--	if gt.marqueeMsgTemp then
--		self.marqueeMsg:showMsg(gt.marqueeMsgTemp)
--	end
   

    self.game_bj = gt.seekNodeByName(csbNode, "game_bj")
    self.chipLayer = cc.Layer:create()
    self.chipLayer:setPosition(csbNode:getPosition())
    self.game_bj:addChild(self.chipLayer)
    -- 在新的版本，要判断下注的位置，每个游戏的位置不一样，写数据

    --self.SprIndex = {1,3,5,7,9}     --可选择的筹码
    GameBase.RoomMsgTbl[5] = 2
    self.GameStatus = 1       -- 1.投注 2. 买满 3.封盘 4.开盘 5.关盘
    self.GameId = 1           -- 当前游戏ID
    self.WaitTime = 0           --等待开奖
    self.ClickArea = 0          --点击区域
    self.BetSettleList = {}
    self.ishiushuing = true
    self.isplaybao = true
    self.isshowPai = true
    self.room_bet = {0,0}
    GameBase:initdata()

    self.WinAnima = gt.seekNodeByName(self.game_bj, "NiuNiuWinBg")
    --self.WinAnima:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
    self.WinAnima:setVisible(false)
    self.WinAnimaSpr = gt.seekNodeByName(self.game_bj, "NiuNiuWin_3")
    self.WinAnimaSpr:setVisible(false)
    --下注区域
    for i=1,2 do
        local str = string.format("bet_box_%d", i)
        local bet_box = gt.seekNodeByName(self.game_bj, str)
        local bet_num = gt.seekNodeByName(bet_box, "bet_num")
        local bet_Btton = gt.seekNodeByName(bet_box, "bet_Btton")
        bet_num:setString(0)
        if i > GameBase.RoomMsgTbl[5] then
            bet_box:setVisible(false)
        else
            bet_box:setVisible(true)
--            gt.addBtnPressedListener(bet_box, function()
--                self:onJettonAreaClicked(bet_box)
--	        end)
            --下注筹码 飞过来
            bet_Btton:setTag(i)
            bet_Btton:addClickEventListener(
                handler(self, self.onJettonAreaClicked)
	        )
            bet_Btton:setSwallowTouches(false)
            --gt.addBtnPressedListener(result_but, handler(self, self.onJettonAreaClicked(bet_box)))
        end
    end
    --区域总投注
    for i = 1 , 2 do
        local str = string.format("TouZhuNumBtn_%d", i)
        local TouZhuNumBtn = gt.seekNodeByName(csbNode, str)
        TouZhuNumBtn:addClickEventListener(function()
		    self:SendGetTouzhuRangeReq(i)
	    end)
    end

    --充值按钮
    self.recharge_but = gt.seekNodeByName(self.rootNode, "recharge_but")
    gt.addBtnPressedListener(self.recharge_but, handler(self, function()
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
        Utils.setClickEffect()
		if gt.playerData.playerType == 4 then 
            function OKcallfan(args)
    		    local LoginScene = require("app/views/Scene/LoginScene"):create(false,true)
		        cc.Director:getInstance():replaceScene(LoginScene) 
            end
            require("app/views/UI/NoticeTips"):create("提示","为了体验游戏完整功能，请您先升级为正式用户！", OKcallfan, nil, false,"res/res/BegainScene/PhoneREbPresstn.png")
        else 
            local RechargeChose = require("app/views/Scene/RechargeChose"):create()
	        self:addChild(RechargeChose)
            RechargeChose:setVisible(true) 
        end
	end))
    --玩家列表按钮
    local PlayerNum_btn = gt.seekNodeByName(self.rootNode, "PlayerNum_btn")
    gt.addBtnPressedListener(PlayerNum_btn, handler(self, function()
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
        Utils.setClickEffect()
		self:SendGetUserListReq()
	end))

    self.time_num = gt.seekNodeByName(self.rootNode, "time_num")
    self.time_num:setVisible(false)
    self.time_num:setString(self.zhuijiTime)
    self.time_num:setLocalZOrder(100001)

    self.DialogNode = gt.seekNodeByName(self.rootNode, "DialogNode")
    self.DialogNode:setVisible(false)
    self.DialogNode:setLocalZOrder(100000)
    self.DialogNodeText = gt.seekNodeByName(self.DialogNode, "DialogText")


    --本人当前场下的总投注筹码 保存在内存中，切换时要换回来，每个游戏场都可以下，确保不同场次
    self.goldNode = gt.seekNodeByName(self.rootNode, "gold_num")
    self.goldNode:setLocalZOrder(100002)
    self.goldnum = 0
    --self.goldNode:setString(self.goldnum)
    self.goldNode:setString(string.format("%.01f", gt.playerData.coin/10000- self.goldnum))
    self.Touzhu_num = gt.seekNodeByName(self.rootNode, "Touzhu_num")
    self.Touzhu_num:setLocalZOrder(100002)

	-- 期号与游戏名
    GameBase.RoomMsgTbl[1]  = "牛牛"
    GameBase.RoomMsgTbl[3]  = self.roomInfo.issue
    GameBase.RoomMsgTbl[2]  = self.roomInfo.lottery_no
    GameBase.RoomMsgTbl[4]  = Roomname
    GameBase.RoomMsgTbl[8]  = self.ChoseGameid
	self.gametapNode = gt.seekNodeByName(csbNode, "gametap")
    self.gametapNode:setLocalZOrder(100003)
    self.gametap = require("app/views/UI/GameLayerTap"):create(self,GameBase.RoomMsgTbl,self.ChoseGameid)
	self.gametapNode:addChild(self.gametap)
    --游戏界面
    
--    if self.roomInfo.lottery_id == 4 then
--        --跑车
--        self.CartrackNode = gt.seekNodeByName(csbNode, "NchangNode")
--        self.CartrackGame = require("app/views/UI/BoattrackGame"):create(0,GameBase.RoomMsgTbl,self.gametap )
--        self.CartrackGame:setPosition(cc.p(self.CartrackGame:getPositionX(), self.CartrackGame:getPositionY() + 25 ))
--        self.CartrackNode:addChild(self.CartrackGame)
--    else
        --跑车
        self.CartrackNode = gt.seekNodeByName(csbNode, "NchangNode")
        self.CartrackGame = require("app/views/UI/CartrackGame"):create(self.roomInfo.lottery_id,GameBase.RoomMsgTbl,self.gametap )
        self.CartrackGame:setPosition(cc.p(self.CartrackGame:getPositionX(), self.CartrackGame:getPositionY() + 25 ))
        self.CartrackNode:addChild(self.CartrackGame)
--    end

    local KaiJiangBtn = gt.seekNodeByName(self.rootNode, "KaiJiangBtn")
    gt.addBtnPressedListener(KaiJiangBtn, handler(self, function()
        Utils.setClickEffect()
        --开奖结果
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
        local resultScene = require("app/views/Scene/ResultScene"):create(self.ChoseGameid,self.roomInfo.lottery_id)
        self:addChild(resultScene)			
	end))   
    --场馆按钮
    local venue_but = gt.seekNodeByName(self.rootNode, "venue_but")
--    venue_but:setLocalZOrder(100002)
--    local venueNode = cc.CSLoader:createNode("venue_pop.csb")
--    self:addChild(venueNode,99)
    --关闭按钮
    local venue_pop = gt.seekNodeByName(self.rootNode, "venue_pop")
    local venue_close = gt.seekNodeByName(self.rootNode, "close")
--    venue_pop:setLocalZOrder(100005)
--    venue_close:setLocalZOrder(100005)
    venue_pop:setRotation(180)
    self.venue_pop = venue_pop

    gt.addBtnPressedListener(venue_but, handler(self, function()
        Utils.setClickEffect()
        local animation = cc.RotateTo:create(0.2, 0)
        venue_pop:runAction(cc.RepeatForever:create(animation))
	end))
    gt.addBtnPressedListener(venue_close, handler(self, function()
        Utils.setClickEffect()
        local animation = cc.RotateTo:create(0.2, 180)
        venue_pop:runAction(cc.RepeatForever:create(animation))
	end))
    --切换按钮

    local venue_GameCar = gt.seekNodeByName(self.rootNode, "gamebut_1")
    local venue_GameCQ = gt.seekNodeByName(self.rootNode, "gamebut_4")
    local venue_GameBall = gt.seekNodeByName(self.rootNode, "gamebut_2")
    local venue_GameLottery = gt.seekNodeByName(self.rootNode, "gamebut_3")

    gt.addBtnPressedListener(venue_GameCar, handler(self, function()
        Utils.setClickEffect()
        self:enterGameRoom(1)
	end))
    gt.addBtnPressedListener(venue_GameCQ, handler(self, function()
        --self:enterGameRoom(4)
        require("app/views/UI/NoticeTips"):create("提示","敬请期待！", nil, nil, true)
        Utils.setClickEffect()
	end))
    gt.addBtnPressedListener(venue_GameBall, handler(self, function()
        Utils.setClickEffect()
        self:enterGameRoom(2)
	end))
    gt.addBtnPressedListener(venue_GameLottery, handler(self, function()
        Utils.setClickEffect()
        self:enterGameRoom(3)
	end))
    
    
    --扑克飞出来
    self.PukeNum = 10
    self.PukeBack = {}
    self.PukeSprite = {}
    for i = 1 , 10 do 
        self.PukeBack[i] = cc.Sprite:create("res/PukePai/pai_0.png")
        self.PukeBack[i]:setPosition(cc.p(850,1000))
        self.PukeBack[i]:setTag(i+10)   --11-20
        self.rootNode:addChild(self.PukeBack[i],99)

        self.PukeSprite[i] = cc.Sprite:create("res/PukePai/pai_0.png")
        self.rootNode:addChild(self.PukeSprite[i],100)
        self.PukeSprite[i]:setTag(20+i) --21-30
        self.PukeSprite[i]:setVisible(false)
    end

    self:initSocketregisterMsg()
        --投注明细
    local desk_bj = gt.seekNodeByName(csbNode, "desk_bj")
    desk_bj:setLocalZOrder(100005)
    self.desk_bj = desk_bj
    self.Touzhu_Layer = gt.seekNodeByName(desk_bj, "Touzhu_Layer")
    self.TouZhuMove = false
    self.MovePos = true

    --退出帐号
    local ExitloginBtn = gt.seekNodeByName(desk_bj, "Exitlogin")
	ExitloginBtn:addClickEventListener(function()
         --gt.socketClient:close()
         cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
         gt.soundEngine:stopEffect(gt.playEngineStr)
		 local LoginScene = require("app/views/Scene/LoginScene"):create(false)
		 cc.Director:getInstance():replaceScene(LoginScene)    
	end)


    local Account_name = gt.seekNodeByName(desk_bj, "Account_name")
    Account_name:setString(gt.playerData.nickname)
    
    self.MingxiiListView = gt.seekNodeByName(desk_bj, "MingxiiListView")
    self.MingxiiListView:setSwallowTouches(false)
    --self:initDetail()
    --卡号设置
   local AddCardSet = require("app/views/Scene/AddCardSet"):create()
    self:addChild(AddCardSet)
    AddCardSet:setVisible(false)
    local CardStrBtn = gt.seekNodeByName(desk_bj, "CardStr")
	CardStrBtn:addClickEventListener(function()
        if gt.playerData.playerType == 4 then 
            self:isVisitorLog()  
        else 
            AddCardSet:setVisible(true)
            AddCardSet:setCardVisible(true)
        end
	end)
    
    --更多投注
    local detail_moreBtn = gt.seekNodeByName(desk_bj, "detail_moreBtn")
	detail_moreBtn:addClickEventListener(function()
        local nTime = os.time() - 86400
        self:getBetDetailByRoom(os.date('%Y',nTime).."-"..os.date('%m',nTime).."-"..os.date('%d',nTime))
        local DecdetailmoreScene = require("app/views/Scene/DecdetailmoreScene"):create()
        self:addChild(DecdetailmoreScene) 
	end)
    self:getBetDetailByRoom(os.date("%Y-%m-%d"))

    --获取用户今日盈亏请求（上行）
    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_DAY_PROFIT_AND_LOSS_REQ,"{}")
	-- 获取用户今日盈亏应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_DAY_PROFIT_AND_LOSS_RESP, self, self.onGetUserDayProfitResp)
end
-- 进入游戏房间
function PlaySceneNiuNiu:enterGameRoom(sender)
        --gt.Gameroomid = 0
        --gt.SelectroomSite = 0
        --gt.SelectroomId = 0
    msgTbl = gt.gamelistTap[sender]
    if msgTbl.status == 1 then
        require("app/views/UI/NoticeTips"):create("提示",	"休市！", nil, nil, true)
    else
        local enterGameRoomlayer = require("app/views/Scene/GameRoom"):create(sender)
        cc.Director:getInstance():replaceScene(enterGameRoomlayer)
    end
end

function PlaySceneNiuNiu:onchipClicked(butobj,tap)
    self.betcursor:setPositionX(butobj:getPositionX())
    self.chipma = tap
end

function PlaySceneNiuNiu:onJettonAreaClicked(sender, eventType)
    --加限额判断  总额-减投注 
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
    if self.TouZhuMove then
        return
    end
    if self.GameStatus ~= 1 then
        return
    end
    --投注金币大于本身金币
    if gt.playerData.coin < GameBase.chiptap[self.SprIndex[1]] then
        require("app/views/UI/NoticeTips"):create("提示","元宝不足!", nil, nil, true)
        return
    end
    local senderNum = sender:getTag()
    self.ClickArea = senderNum  
    gt.log("onJettonAreaClicked===",senderNum,self.SprIndex[self.chipma])
    --投注请求
    self:SendCBetReq(senderNum,self.SprIndex[self.chipma])
    gt.soundEngine:playEffect("ChipsClick",false)
end

function PlaySceneNiuNiu:HiuShuChip()
     if self.chipTap == 0 then
    --清空！
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8) ,cc.CallFunc:create(function ()
            self.zhuijiTime = GameBase.RoomMsgTbl[6]
            self.FenPanTime = GameBase.RoomMsgTbl[7]
            for i=1,GameBase.RoomMsgTbl[5] do
                local str = string.format("bet_box_%d", i)
                local bet_box = gt.seekNodeByName(self.game_bj, str)
                local bet_num = gt.seekNodeByName(bet_box, "bet_num")
                bet_num:setString(0)
            end
        end)))
        self.goldNode = gt.seekNodeByName(self.rootNode, "gold_num")
        self.goldNode:setString(string.format("%.01f", gt.playerData.coin/10000))
        return
    end
    for index = 0, self.chipTap do 
        local TChipSprite = self.chipLayer:getChildByTag(self.delindex*1000 + index)
        --gt.log("chipTapnum==",self.delindex*1000 + index,self.chipTap)
        if TChipSprite then
            local pos = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
	        local moveTo = cc.MoveTo:create(0.5, pos)
            local call1 = cc.CallFunc:create(function()
                TChipSprite:removeFromParent()
            end)
            local spa = cc.Sequence:create(moveTo, cc.DelayTime:create(0.5),call1)
	        TChipSprite:stopAllActions()
	        TChipSprite:runAction(spa)
        end

        if index == self.chipTap then
            self.delindex = self.delindex + 1
            if self.delindex > GameBase.RoomMsgTbl[5] then
                --全部清空结束了，要给个方法
                    self.chipTap = 0
                    self.delindex =  1
                    self.goldnum = 0
                    self.Touzhu_num:setString(self.goldnum)
                    for i=1,GameBase.RoomMsgTbl[5] do
                        local str = string.format("bet_box_%d", i)
                        local bet_box = gt.seekNodeByName(self.game_bj, str)
                        local bet_num = gt.seekNodeByName(bet_box, "bet_num")
                        bet_num:setString(0)
                    end
                    self.chipLayer:removeAllChildren()
            else   
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8) ,cc.CallFunc:create(function ()
                    self:HiuShuChip()
                end)))
            end
        end
    end
end

function PlaySceneNiuNiu:OnplaygameNode()
    

end

--发送option消息
function PlaySceneNiuNiu:onReady()

end

function PlaySceneNiuNiu:onNodeEvent(eventName)
	if "enter" == eventName then
    --要启动联网取数据！
    gt.showLoadingTips()
    self.loadingtime = 0;
    self:initSocketregisterMsg()
    -- 逻辑更新定时器
        self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches( false )  -- 吞掉：触摸事件消息
        listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(handler(self, self.onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher =  self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority( listener, self )
	elseif "exit" == eventName then
        --self:SendGameLeaveReq()
        --self:unregisterAllMsgListener()
        gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	    local eventDispatcher = self:getEventDispatcher()
	    eventDispatcher:removeEventListenersForTarget(self)
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        self:unregisterAllMsgListener()
    end	     
end
function PlaySceneNiuNiu:onTouchBegan(touch, event)
    self.beganPos = self:convertToNodeSpace(touch:getLocation())
    if self.Touzhu_Layer:getPositionX() ==290 then
        self:PfbMove(true)
        self.TouZhuMove = false
    end
    return true
end
function PlaySceneNiuNiu:onTouchMove(touch, event)
    self.MovePos = true
    return true
end
function PlaySceneNiuNiu:onTouchEnd(touch, event)
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
    self.EndPos = self:convertToNodeSpace(touch:getLocation())
    if self.MovePos then
        self.MovePos = false
        if self.EndPos.x - self.beganPos.x < -80 and self.Touzhu_Layer:getPositionX() == 870 and self.EndPos.y > 860 then
            self:PfbMove(false)
            self.TouZhuMove = true
        end
    end
    return true
end
function PlaySceneNiuNiu:PfbMove(bVisible)
    Utils.setClickEffect()  
    self.TouZhuMove = true
    local pos
    if bVisible then
        pos= cc.p(self.Touzhu_Layer:getPositionX()+580, self.Touzhu_Layer:getPositionY())
    else
        pos= cc.p(self.Touzhu_Layer:getPositionX()-580, self.Touzhu_Layer:getPositionY())
        self:getBetDetailByRoom(os.date("%Y-%m-%d"))
    end
    local moveTo = cc.MoveTo:create(0.5, pos)
	local call = cc.CallFunc:create(function ()
        
	end)
	local spa = cc.Sequence:create(moveTo,cc.DelayTime:create(0.5), call)
    self.Touzhu_Layer:stopAllActions()
    self.Touzhu_Layer:runAction(spa)
end
function PlaySceneNiuNiu:update(delta)
    self:UpdateOpenTime()
    self.loadingtime = self.loadingtime + 1
    if self.loadingtime > 10 and gt.isshowlading then 
        self.loadingtime = 0
        gt.isshowlading = false
         -- 去掉转圈
	    gt.removeLoadingTips()
        require("app/views/UI/NoticeTips"):create("提示",	"进房间失败！", function ()
            local playScene = require("app/views/Scene/GameRoom"):create()
            cc.Director:getInstance():replaceScene(playScene)            
        end, nil, true)
        return
    end     
    self.zhuijiTime = self.zhuijiTime - 1 
    if self.zhuijiTime < 0 then
        self.zhuijiTime = 0
    end 
    self.time_num:setString(self.zhuijiTime)

    if self.GameStatus == 1 then
        self.DialogNode:setVisible(false)
        self.WinAnima:setVisible(false)
        self.CartrackGame:CarTimeUpdate(GameBase.RoomMsgTbl[6],self.zhuijiTime)
        self.ishiushuing = true
        self.isplaybao = true
        self.isshowPai = true
        self.GameStart = true
        local ProfitScene =  self:getChildByTag(1002)
        if ProfitScene then
            ProfitScene:removeFromParent()
        end
        return
    end

    self.CartrackGame:CarTimeUpdate(GameBase.RoomMsgTbl[6],0)
    if self.GameStatus == 3 then
        self.WaitTime = self.WaitTime - 1
        if self.WaitTime < 0 then
            self.WaitTime = 0
        end
        self.DialogNode:setVisible(true)
        self.DialogNodeText:setString("封盘\n等待开奖"..self.WaitTime.."s...")
    elseif self.GameStatus == 4 then
        self.DialogNode:setVisible(false)
        --self.DialogNodeText:setString("开奖中。。。")
        if self.isplaybao and self.GameStart then
            self.CartrackGame:PlayCarBao()
            self.isplaybao = false
        end
        if self.isplaybao == false and self.CartrackGame.PlayActions == false and self.isshowPai and self.GameBetOn and self.GameStart then
            self.gametap:showzhonjian(GameBase.RoomMsgTbl)
            self:faPuke()
--            self:runAction(cc.Sequence:create(cc.DelayTime:create(4) ,cc.CallFunc:create(function ()
--                for i =1, #self.BetSettleList do 
--                    if self.BetSettleList[i] == 1 then
--                        self.WinAnima:setVisible(true)
--                        self.WinAnima:setPosition(375,845-245*i)
--                    end 
--                end
--            end)))
            for i =1, #self.BetSettleList do 
                if self.BetSettleList[i] == 1 then
                    self.WinAnima:setVisible(true)
                    self.WinAnima:setPosition(375,845-245*i)
                end 
            end
            self.isshowPai = false
            self.GameBetOn = false
        end
    elseif self.GameStatus == 5 then
        self.DialogNode:setVisible(true)
        self.DialogNodeText:setString("封盘\n等待下局开始...")
        if self.ishiushuing and self.GameStart then -- 只收一次
            self.CartrackGame:StopCarBao()
            self.ishiushuing = false
            self.PukeNum = 10
            for i = 1 ,10 do
                self.PukeBack[i]:setPosition(cc.p(850,1000))
                self.PukeBack[i]:setVisible(true)
                self.PukeBack[i]:setScale(1)
                self.PukeSprite[i]:setVisible(false)
            end
            self:HiuShuChip()
            self:OnsetSettle()
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_COIN_INFO_REQ,"{}")
        end
    end
    --self.DialogNode:setVisible(true)

    --时间到。封盘  回收chip
--    if self.FenPanTime > 0 then
--        if self.FenPanTime == GameBase.RoomMsgTbl[7] then
--            self.CartrackGame:PlayCarBao()
--        end
--        self.DialogNode:setVisible(true)
--        self.FenPanTime = self.FenPanTime - 1 
--        if self.FenPanTime == 19 then
--             self:faPuke()
--        end
--        return
--    else
--        self.DialogNode:setVisible(false)
--        self.CartrackGame:StopCarBao()
--        self.PukeNum = 10
--        for i = 1 ,10 do
--            self.PukeBack[i]:setPosition(cc.p(850,1000))
--            self.PukeBack[i]:setVisible(true)
--            self.PukeBack[i]:setScale(1)
--            self.PukeSprite[i]:setVisible(false)
--        end
--    end

--    self:HiuShuChip()

end

function PlaySceneNiuNiu:faPuke()
    local PukeBack = {}
    local pos  = {}
    local moveTo1 = {}
    local spa1 = {}
    local Seq  = {}
    for i = 1,5 do 
        PukeBack[i] = self.rootNode:getChildByTag(self.PukeNum + i)
        PukeBack[i]:setVisible(true)
        pos[i] = cc.p( 40+110*i,1000)
        moveTo1[i] = cc.MoveTo:create(0.4, pos[i])
        spa1[i] = cc.Spawn:create(moveTo1[i])
        local call
        if i == 5 then
            call = cc.CallFunc:create(function ()
                self:showPai(self.PukeNum)
	        end)
            PukeBack[i]:stopAllActions()
        else
            call = nil
        end
        Seq[i] = cc.Sequence:create(spa1[i],call)
        --PukeBack[i]:stopAllActions()
        PukeBack[i]:runAction(Seq[i])
    end
end

function PlaySceneNiuNiu:showPai(PukeNum)
    local MsgTbl = gt.string_split(GameBase.RoomMsgTbl[2],",")
    --dump(MsgTbl)
    for i = 1, 10  do
        if MsgTbl[i] == "10" then
            MsgTbl[i] = "0"
        else
            for w in string.gmatch(MsgTbl[i], "[^%z]") do
                MsgTbl[i] = w
            end
        end
    end
    
    --gt.soundEngine:playEffect("xianhua",false)
    local paiSp = {}
    local paiSpZ ={}
    for i = 1 ,5 do 
    
        paiSp[i] = self.rootNode:getChildByTag(PukeNum+i)
        paiSpZ[i] = self.rootNode:getChildByTag(PukeNum +10+i)
        paiSpZ[i]:setTexture("res/PukePai/PukePai_1_"..MsgTbl[PukeNum+i-10].."_"..math.random(0,3)..".png")
        paiSpZ[i]:setPosition(paiSp[i]:getPosition())
        --paiSp:setScaleX(0)
        --paiSpZ:setVisible(true)
        paiSpZ[i]:setScaleX(0.2)
        paiSpZ[i]:setScaleY(1)
        paiSpZ[i]:setRotation(360)
        paiSpZ[i]:setOpacity(255)
        local call = cc.CallFunc:create(function ()
            local call3
            if i == 5 then
                call3 = cc.CallFunc:create(function ()
                    self:MovePukePai()
	            end)
            else
                call3 = nil
            end

            paiSp[i]:setVisible(false)
            paiSpZ[i]:setVisible(true)
            paiSpZ[i]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,1,1),call3))
        end)
        paiSp[i]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,0.2,1),call))
    end
end

function PlaySceneNiuNiu:OnSetLotteryNo(lottery_no)
    self.CartrackGame:SetLotteryNo(true)
end

function PlaySceneNiuNiu:MovePukePai()


    local MaJNum1 = {}
    local paiSpZ ={}
    local moveTo ={}
    local ScaleTo ={}
    local spa ={}
    local pos1 ={}
    local Seq = {}
    for i = 1 , 5 do

        MaJNum1[i] = self.PukeNum + 10+i 
        --print("+++++++++++++++++++++"..self.PukeNum)
        paiSpZ[i] = self.rootNode:getChildByTag(MaJNum1[i])
        if self.PukeNum == 10 then
            pos1[i] = cc.p(200+50*i,560)
        elseif self.PukeNum == 15 then
            pos1[i] = cc.p(200+50*i,290)
        end
	    
        moveTo[i] = cc.MoveTo:create(0.2*i, pos1[i])
        ScaleTo[i] = cc.ScaleTo:create(0.2*i,0.5)
        spa[i] = cc.Spawn:create(moveTo[i],ScaleTo[i])

        local call2 
        if i == 5 then
            call2 = cc.CallFunc:create(function ()
            
                self.PukeNum = self.PukeNum +5
                if self.PukeNum < 16 then
                    self:faPuke()
                end 
	        end)
            paiSpZ[i]:stopAllActions()
        end
        Seq[i] = cc.Sequence:create(spa[i],call2)
	    paiSpZ[i]:runAction(Seq[i])
    end    

end

function PlaySceneNiuNiu:UpdateGameItem(tag, cellData)
    gt.log("UpdateGameItem == ",tag,cellData.lottery_id,cellData.lottery_no)
    if cellData.lottery_id == self.roomInfo.lottery_id then 
       --self.gametap:showzhonjian(cellData.lottery_no)
       GameBase.RoomMsgTbl[2]  = cellData.lottery_no
       GameBase.RoomMsgTbl[3]  = cellData.issue
    end
end

function PlaySceneNiuNiu:InitGameScene()
    
end

function PlaySceneNiuNiu:InitchipTap()
    --选
    self.chipma = 1
    self.betcursor = gt.seekNodeByName(self.game_bj, "betcursor")
    self.betcursor:runAction(cc.RepeatForever:create(cc.Blink:create(1.0,1)))
    for i=1,5 do
        local str = string.format("chip%d", i)
        local chip = gt.seekNodeByName(self.game_bj, str)
        local str1 = string.format("chip%d_b", i)
        local chip1 = gt.seekNodeByName(self.game_bj, str1)
        local SprNum = self.SprIndex[i]
        if SprNum > 0 then
            chip1:setTexture("res/res/ChouMa/"..GameBase.chipSpr[self.SprIndex[i]])
            gt.addBtnPressedListener(chip, function()
                    self:onchipClicked(chip,i)
	            end)
        else
            chip:setVisible(false)
            chip1:setVisible(false)
        end
    end
end

--投注结算广播
function PlaySceneNiuNiu:OnsetSettle()
    if #self.ranking < 1 then
        return
    end

    local ProfitScene =  self:getChildByTag(1002)
    if ProfitScene then
        ProfitScene:UdatCellItem(self.earnings,self.ranking)
    else
        ProfitScene = require("app/views/Scene/ProfitScene"):create(self.earnings,self.ranking)
        self:addChild(ProfitScene,100,1002)
    end
end
--同步加币效果  区域：area_id,  要加的金币：chip
function PlaySceneNiuNiu:Onaddchip(area_id,chip,issend)
    gt.log("Onaddchip=====",area_id,chip,issend) 
    if chip > 0 then
        gt.soundEngine:playEffect("ChipsClick",false)
    end
    --取单币
    local chipNum = chip
    if issend==nil or issend==0  then 
        issend = 0
        --local chip1
        local area_id = area_id + 1
        for i=1 ,5 do
            if chipNum == 0 then
                break
            end
            local SprNum = self.SprIndex[6-i]
            if SprNum > 0 then
                local chip2 =  math.fmod(chipNum,GameBase.chiptap[self.SprIndex[6-i]])
                local chip1 =  math.floor(chipNum/GameBase.chiptap[self.SprIndex[6-i]])
                --local chip1,chip2 = math.modf(chipNum/GameBase.chiptap[self.SprIndex[6-i]])
                for j=1 ,chip1 do
                    --上币！
                    self:MoveChip(area_id,self.SprIndex[6-i],issend)
                end
                chipNum = chip2
            end
        end
    else
        for i=1,#self.SprIndex do
            if chipNum == GameBase.chiptap[self.SprIndex[i]] then
                self:MoveChip(area_id,self.SprIndex[i],issend)
                break
            end
        end
    end
end

function PlaySceneNiuNiu:MoveChip(area_id,chipid,issend)
    local str = string.format("res/ChouMa/chip%d.png", chipid)
    local chipSprite = cc.Sprite:create(str)
    chipSprite:setOpacity(30)
    if issend > 0 then
        local chipbut = gt.seekNodeByName(self.rootNode, "chip"..issend)
        chipSprite:setPosition(chipbut:getPosition())
    else
        chipSprite:setPosition(self.recharge_but:getPosition())
    end
    local chipTapnum = 1000 * area_id
    chipSprite:setTag(chipTapnum + self.chipTap)
    self.chipTap = self.chipTap + 1
    local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..area_id)
    local bet_num = gt.seekNodeByName(bet_box, "bet_num")
    local bet_boxX,bet_boxY = bet_box:getPosition()
    local pos
    if area_id == 6 then
        pos = cc.p(bet_box:getPositionX()+ math.random(-70,30), bet_box:getPositionY()+ math.random(-70,60))
    else
        pos = cc.p(bet_box:getPositionX()+ math.random(-200,200), bet_box:getPositionY()+ math.random(-70,60))
    end
    
	local moveTo = cc.MoveTo:create(0.5, pos)
    local FadeTo = cc.FadeTo:create(0.5,255)
	local call = cc.CallFunc:create(function ()
        if issend > 0 then
            self.goldnum = self.goldnum + GameBase.chiptap[self.SprIndex[self.chipma]]
            self.Touzhu_num:setString(self.goldnum)
            --self.goldNode:setString(string.format("%.01f", gt.playerData.coin/10000- self.goldnum))
            self.room_bet[area_id] = tonumber(bet_num:getString()) * 10000 + GameBase.chiptap[self.SprIndex[self.chipma]] * 10000
            bet_num:setString(tonumber(bet_num:getString()) + GameBase.chiptap[self.SprIndex[self.chipma]])
        else
        --bet_num:setString(tonumber(bet_num:getString()) + GameBase.chiptap[chipid])
        self.room_bet[area_id] = tonumber(bet_num:getString()) * 10000
        end
    end)
	local spa = cc.Spawn:create(moveTo,FadeTo,call)
	chipSprite:stopAllActions()
	chipSprite:runAction(spa)
    
    self.chipLayer:addChild(chipSprite)

end

function PlaySceneNiuNiu:OnShowaddchip(area_id,chipid,isfull)
    local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..(area_id+1))
    local bet_num = gt.seekNodeByName(bet_box, "bet_num")
    bet_num:setString(tonumber(chipid))
end
function PlaySceneNiuNiu:OnSetTouzhuchip(chipid)
    self.Touzhu_num:setString(chipid)
end

-- 断线重连,初始化数据
function PlaySceneNiuNiu:reLogin()
    -- 进游戏桌子
    self.loadingtime = 0
    gt.isshowlading = true
    --GameBase:initdata()
    gt.socketClient:setIsStartGame(true)
    
    local playScene = require("app/views/Scene/PlaySceneNiuNiu"):create(self.roomInfo,GameBase.RoomMsgTbl[4],gt.Gameroomid)
    cc.Director:getInstance():replaceScene(playScene)

    gt.log("reLogin===EnterGameRoomId ",gt.EnterGameRoomId)
    local cmsg = cmd_node_pb.CEnterGameReq()
    cmsg.node_id = gt.EnterGameRoomId
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_ENTER_GAME_REQ,msgData)
end
function PlaySceneNiuNiu:OnBetSettleResp(order)
--    self.CartrackGame:StopCarBao()
--    self.gametap:showzhonjian(GameBase.RoomMsgTbl)
--    self.FapaiqiGame:xiaofapai(self.ShowPaiList)
end

--date 日期  格式:2017-12-05
--function PlaySceneNiuNiu:getBetDetailByRoom()
--    local cmsg = cmd_lobby_pb.CGetUserBetDetailReq()
--    --cmsg.uid = gt.playerData.uid
--    cmsg.detail_id = -1
--    cmsg.detail_num = 50
--    cmsg.date_time = os.date("%Y-%m-%d")
--    local msgData = cmsg:SerializeToString()
--    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_REQ,msgData)        
--end

return PlaySceneNiuNiu
