local gt = cc.exports.gt
local Utils = cc.exports.Utils

local Utils = require("app/Utils")
local GameBase = require("app/utils/GameBase")

local PlaySceneSangong = class("PlaySceneSangong", GameBase)

PlaySceneSangong.__index = PlaySceneSangong

--[[

--]]




PlaySceneSangong.FLIMTYPE = {
	FLIMLAYER_BAR				= 1,
	FLIMLAYER_BU				= 2,
}

PlaySceneSangong.TAG = {
	FLIMLAYER_BAR				= 50,
	FLIMLAYER_BU				= 51,
}
local mjTilePerLine = 10
local GAMECHIPTAP = 3000


function PlaySceneSangong:ctor(enterRoomMsgTbl,Roomname,ChoseGameid)
    GameBase:ctor()
    GameBase:initdata()
    --保存房间信息20161125
    self.roomInfo = enterRoomMsgTbl
    self.ChoseGameid = ChoseGameid

    self.chipTap = 0
    self.delindex = 1
    self.bClickArea = false     --投注区是否可点击
    --周期
    self.zhuijiTime = GameBase.RoomMsgTbl[6]
    self.FenPanTime = GameBase.RoomMsgTbl[7]
    --买满灯
    self.LightNum = {}
    	
	self.m_numberMark = 0
	gt.log("进入PlaySceneSangong")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    self.gameMark=true
	-- 加载界面资源
	local csbNode, animation = gt.createCSAnimation("GameScene.csb")
    animation:play("animation0", true)
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
   
	-- 转盘
	local BetDownNode = gt.seekNodeByName(csbNode, "bet_down")
    BetDownNode:setVisible(false)

	-- 期号与游戏名
    GameBase.RoomMsgTbl[1]  = "三公"
    GameBase.RoomMsgTbl[3]  = self.roomInfo.issue
    GameBase.RoomMsgTbl[2]  = self.roomInfo.lottery_no
    GameBase.RoomMsgTbl[4]  = Roomname
    GameBase.RoomMsgTbl[8]  = self.ChoseGameid
	self.gametapNode = gt.seekNodeByName(csbNode, "gametap")
    self.gametapNode:setLocalZOrder(100003)
    self.gametap = require("app/views/UI/GameLayerTap"):create(self,GameBase.RoomMsgTbl,self.ChoseGameid)
	self.gametapNode:addChild(self.gametap)

    self.game_bj = gt.seekNodeByName(csbNode, "game_bj")
    self.chipLayer = cc.Layer:create()
    self.chipLayer:setPosition(csbNode:getPosition())
    self.game_bj:addChild(self.chipLayer)
    
    self.chipNewLayer = cc.Layer:create()
    self.chipNewLayer:setPosition(csbNode:getPosition())
    self.game_bj:addChild(self.chipNewLayer)
    -- 在新的版本，要判断下注的位置，每个游戏的位置不一样，写数据
    
    --self.SprIndex = {6,7,8,9,10}     --可选择的筹码
    
    --选
    GameBase.RoomMsgTbl[5] = 5
    --self.GameStatus = 0       -- 1.投注 2. 买满 3.封盘 4.开盘 5.关盘
    self.GameId = 1           -- 当前游戏ID
    self.WaitTime = 0           --等待开奖
    self.ClickArea = 0          --点击区域
    self.TChipSprite  =  {}    --输的筹码
    --self.TWinChipSprite  =  {}    --赢的筹码
    self.TWinChipSprite = {{},{},{},{},{},{},{},{},{},{},}
    self.ishiushuing = false
    self.isplaybao = true
    self.isshowPai = true
    self.WaitTimeKaijiang = 1
    self.room_bet = {0,0,0,0,0}
    self.order = {1,2,3,4,5}
    self.SprBtnBuyflag = true
    self.result_num = {}
    self.MoveMentTimes = 0  --创建输的剩余的筹码的id
    self.MoveWinTimes = 0  --移动输的筹码的id
    self.MoveActionTimes = 0    --移动间隔
    self.CreatChipId = 0
    
    --下注区域
    for i=1,8 do
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
    for i = 1 , 5 do
        local str = string.format("TouZhuNumBtn_%d", i)
        local TouZhuNumBtn = gt.seekNodeByName(csbNode, str)
        TouZhuNumBtn:addClickEventListener(function()
		    self:SendGetTouzhuRangeReq(i)
	    end)
    end

    self.SprFullAnimal = {}
    self.BetBuyFullNum = {}         --每个区域买满用的金币
    for i = 1 , 5 do
        self.SprFullAnimal[i] = gt.seekNodeByName(self.game_bj, "SprFull_"..i)
        self.SprFullAnimal[i]:setVisible(false)
        self.BetBuyFullNum[i] = 0
    end

    local KaiJiangBtn = gt.seekNodeByName(self.rootNode, "KaiJiangBtn")
    gt.addBtnPressedListener(KaiJiangBtn, handler(self, function()
        Utils.setClickEffect()
        --开奖结果
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
        local resultScene = require("app/views/Scene/ResultScene"):create(self.ChoseGameid,self.roomInfo.lottery_id)
        self:addChild(resultScene)			
	end))   


    --充值按钮
    self.recharge_but = gt.seekNodeByName(self.rootNode, "recharge_but")
    gt.addBtnPressedListener(self.recharge_but, handler(self, function()
        Utils.setClickEffect()
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
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
        Utils.setClickEffect()
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
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
    self.goldNode:setString(string.format("%.01f", gt.playerData.coin/10000))
    self.Touzhu_num = gt.seekNodeByName(self.rootNode, "Touzhu_num")
    self.Touzhu_num:setLocalZOrder(100002)

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
        gt.Gameroomid = 0
        Utils.setClickEffect()
        self:enterGameRoom(1)
	end))
    gt.addBtnPressedListener(venue_GameCQ, handler(self, function()
        gt.Gameroomid = 0
        --self:enterGameRoom(4)
        require("app/views/UI/NoticeTips"):create("提示","敬请期待！", nil, nil, true)
        Utils.setClickEffect()
	end))
    gt.addBtnPressedListener(venue_GameBall, handler(self, function()
        gt.Gameroomid = 0
        Utils.setClickEffect()
       self:enterGameRoom(2)
	end))
    gt.addBtnPressedListener(venue_GameLottery, handler(self, function()
        gt.Gameroomid = 0
        Utils.setClickEffect()
        self:enterGameRoom(3)
	end))

    self:InitBuyfull()
        
    
    --扑克飞出来
    self.PukeNum = 10
    self.CycleTimes = 0
    self.PukeBack = {}
    self.PukeSprite = {}
    for i = 1 , 15 do 
        self.PukeBack[i] = cc.Sprite:create("res/PukePai/pai_0.png")
        self.PukeBack[i]:setPosition(cc.p(850,1000))
        self.PukeBack[i]:setTag(i+10)   --11-25
        self.rootNode:addChild(self.PukeBack[i],99)

        self.PukeSprite[i] = cc.Sprite:create("res/PukePai/pai_0.png")
        self.rootNode:addChild(self.PukeSprite[i],100)
        self.PukeSprite[i]:setTag(25+i) --26-40
        self.PukeSprite[i]:setVisible(false)
    end
    self:PukeResult(false)  --显示点数结果消失
    self:initSocketregisterMsg()
        --投注明细
    local desk_bj = gt.seekNodeByName(csbNode, "desk_bj")
    desk_bj:setLocalZOrder(100005)
    self.desk_bj = desk_bj
    self.Touzhu_Layer = gt.seekNodeByName(desk_bj, "Touzhu_Layer")
    self.TouZhuMove = false
    self.MovePos = true

    local Account_name = gt.seekNodeByName(desk_bj, "Account_name")
    Account_name:setString(gt.playerData.nickname)

    --退出帐号
    local ExitloginBtn = gt.seekNodeByName(desk_bj, "Exitlogin")
	ExitloginBtn:addClickEventListener(function()
         --gt.socketClient:close()
         cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
         gt.soundEngine:stopEffect(gt.playEngineStr)
		 local LoginScene = require("app/views/Scene/LoginScene"):create(false)
		 cc.Director:getInstance():replaceScene(LoginScene)    
	end)

    
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
    -- 获取用户投注详情
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_RESP, self, self.onGetUserBetDetailResp)
end
-- 进入游戏房间
function PlaySceneSangong:enterGameRoom(sender)
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
function PlaySceneSangong:onchipClicked(butobj,tap)
    local animation = cc.RotateTo:create(0.2, 180)
    self.venue_pop:runAction(cc.RepeatForever:create(animation))
    self.betcursor:setPositionX(butobj:getPositionX())
    self.chipma = tap
end

function PlaySceneSangong:onJettonAreaClicked(sender, eventType)
    --加限额判断  总额-减投注 
    local animation = cc.RotateTo:create(0.2, 180)
    self.venue_pop:runAction(cc.RepeatForever:create(animation))
    if self.TouZhuMove then
        return
    end
    if self.GameStatus ~= 1 then
        return
    end
    if self.SprBuyfull:isVisible() == true then
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

    --gt.soundEngine:playEffect("ChipsClick",false)      --播放声音

end

function PlaySceneSangong:HiuShuChip()
   if self.chipTap == 0 then
    --清空！
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8) ,cc.CallFunc:create(function ()
            self.zhuijiTime = GameBase.RoomMsgTbl[6]
            self.FenPanTime = GameBase.RoomMsgTbl[7]
            self.Touzhu_num:setString(self.goldnum)
            self.chipLayer:removeAllChildren()
            self.MoveActionTimes = 0
            for i = 1 , 5 do
                self.SprFullAnimal[i]:setVisible(false)
            end
            for i=1,GameBase.RoomMsgTbl[5] do
                local str = string.format("bet_box_%d", i)
                local bet_box = gt.seekNodeByName(self.game_bj, str)
                local bet_num = gt.seekNodeByName(bet_box, "bet_num")
                bet_num:setString(0)
            end
        end)))
        for i = 1 , 5 do
            self.SprFullAnimal[i]:setVisible(false)
        end
        self:OnsetSettle()          --弹出结算框
        self.goldNode = gt.seekNodeByName(self.rootNode, "gold_num")
        self.goldNode:setString(string.format("%.01f", gt.playerData.coin/10000))
        return
    end
    local indexchip = 0;
    for index = 0, self.chipTap do 
        local TChipSprite = self.chipLayer:getChildByTag(self.delindex*1000 + index)
        --gt.log("chipTapnum==",self.delindex*1000 + index,self.chipTap)
        if TChipSprite then
            indexchip = indexchip + 1
            local pos = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
            if indexchip > 40  then
                indexchip = 5
            end
	        local moveTo = cc.MoveTo:create(0.3 + 0.1*indexchip, pos)
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
            end   
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8) ,cc.CallFunc:create(function ()
                self:HiuShuChip()
            end)))           
        end
    end
end

-- 先期收回赢家币
function PlaySceneSangong:HiuShuWinChip()
    if self.settle_money[1].settle_money == nil then
        self:HiuShuChip()
        return
    end
    self.remainMoney = self.settle_money[5].settle_money/10000
    self.begainMoney = self.settle_money[1].settle_money/10000
    self:HiuShumovechip(1,5)
end

function PlaySceneSangong:HiuShumovechip(WinIndx,Indx)
 self.MoveActionTimes = self.MoveActionTimes + 1
    print("self.MoveActionTimes = self.MoveActionTimes + 1========1==========",self.MoveActionTimes )
    print("self.begainMoney + self.remainMoney========1==========",self.settle_money[WinIndx].area_id+1 .."+"..self.settle_money[Indx].area_id+1)
    for i = 1 , 5 do
        print("self.room_bet[WinAreaId]====================",self.room_bet[i])
    end
    
    if Indx < 2 or WinIndx > 4 or WinIndx==Indx then
        self:MoveWinToHome(self.CreatChipId,0)
        self:HiuShuChip()
        return
    end
    local indexAreaId = self.settle_money[Indx].area_id+1       --输id
    local WinAreaId = self.settle_money[WinIndx].area_id+1      --赢id
    local str = string.format("bet_box_%d", indexAreaId)
    local bet_box = gt.seekNodeByName(self.game_bj, str)
    local bet_num = gt.seekNodeByName(bet_box, "bet_num")

    local Winstr = string.format("bet_box_%d", WinAreaId)
    local Win_bet_box = gt.seekNodeByName(self.game_bj, Winstr)
    local Win_bet_num = gt.seekNodeByName(Win_bet_box, "bet_num")
    --bet_num:setString(0)

    for i = 1, self.chipTap do 
        self.TChipSprite[i] = self.chipLayer:getChildByTag(indexAreaId*1000 + i-1)            --输区域
    end
    
    if self.begainMoney + self.remainMoney < 0 then     --   0  -4000
        print("self.begainMoney + self.remainMoney========2==========",self.begainMoney.."+"..self.remainMoney)
        if self.begainMoney == 0 then  
            self.begainMoney = self.settle_money[WinIndx +1].settle_money/10000
            self:HiuShumovechip(WinIndx +1,Indx)
            return
        end       
        --有剩余 移动赢的筹码
        for index = 1, self.chipTap do 
            if self.TChipSprite[index] then
                self.TChipSprite[index]:removeFromParent()      --移除输区域的筹码
            end
        end  
        self.chipNewLayer:removeAllChildren()
        self:CreatChip(self.room_bet[indexAreaId]/10000 - self.begainMoney,indexAreaId)
        self.CreatChipId = indexAreaId
        self:LoseToWin(indexAreaId,WinAreaId,self.begainMoney)
        Win_bet_num:setString(self.room_bet[WinAreaId]/10000+self.begainMoney)
        bet_num:setString(self.room_bet[indexAreaId]/10000-self.begainMoney)
        local call1 = cc.CallFunc:create(function()
            self.room_bet[WinAreaId] =  self.room_bet[WinAreaId] + self.begainMoney*10000
            self.remainMoney = self.remainMoney + self.begainMoney

            self.room_bet[indexAreaId] = self.room_bet[indexAreaId] - self.begainMoney*10000

            self.begainMoney = self.settle_money[WinIndx +1].settle_money/10000
            print("self:runAction=========33333333333333333333")
            self:HiuShumovechip(WinIndx +1,Indx)
        end)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(self.MoveActionTimes) , call1 ))
    elseif self.begainMoney + self.remainMoney == 0 then            --0  0
        
        if self.remainMoney == 0 then  
            self.remainMoney = self.settle_money[Indx-1].settle_money/10000
            self.begainMoney = self.settle_money[WinIndx +1].settle_money/10000
            self:HiuShumovechip(WinIndx +1,Indx-1)
            return
        end  
        print("self.begainMoney + self.remainMoney=========3=========",self.begainMoney.."+"..self.remainMoney)
        
        for i = 1, self.chipTap do 
            if self.TChipSprite[i] then
                self.TChipSprite[i]:removeFromParent()
            end
        end
        self.chipNewLayer:removeAllChildren()
        print("self.room_bet[indexAreaId]/10000 - self.begainMoney,indexAreaId========",self.room_bet[indexAreaId]/10000 - self.begainMoney.."+"..indexAreaId)
        self:CreatChip(self.room_bet[indexAreaId]/10000 - self.begainMoney,indexAreaId)
        self.CreatChipId = indexAreaId
        print("indexAreaId,WinAreaId========",WinAreaId..indexAreaId)
        self:LoseToWin(indexAreaId,WinAreaId,self.begainMoney)     --相等就移动下两个区域筹码
        --Win_bet_num:setString(self.settle_money[WinIndx].bet_money/10000 + self.begainMoney)
        Win_bet_num:setString(self.room_bet[WinAreaId]/10000+self.begainMoney)
        
        bet_num:setString(self.room_bet[indexAreaId]/10000 - self.begainMoney)
        local call1 = cc.CallFunc:create(function()
            self.room_bet[WinAreaId] =  self.room_bet[WinAreaId] + self.begainMoney*10000
            self.room_bet[indexAreaId] = self.room_bet[indexAreaId] - self.begainMoney*10000
            print("WinAreaId======================"..WinAreaId..self.room_bet[WinAreaId])
            if Indx - WinIndx == 1 then
                self:MoveWinToHome(self.CreatChipId,0)
                self:HiuShuChip()
            else
                self.remainMoney = self.settle_money[Indx-1].settle_money/10000
                self.begainMoney = self.settle_money[WinIndx +1].settle_money/10000
                print("self:runAction=========2222222222222222222222")
                self:HiuShumovechip(WinIndx +1,Indx-1)
            end
        end)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(self.MoveActionTimes) , call1 ))
    else                                                            --  4000  0
        print("self.begainMoney + self.remainMoney=========4=========",self.begainMoney.."+"..self.remainMoney)
        if self.remainMoney == 0 then  
            self.remainMoney = self.settle_money[Indx-1].settle_money/10000
            self:HiuShumovechip(WinIndx,Indx-1)
            return
        end  
        --没有剩余 移动输的筹码
        for index = 1, self.chipTap do 
            if self.TChipSprite[index] then
                self.TChipSprite[index]:removeFromParent()
            end
        end  
        self.chipNewLayer:removeAllChildren()
        self:LoseToWin(indexAreaId,WinAreaId,-self.remainMoney)
        Win_bet_num:setString(self.room_bet[WinAreaId]/10000-self.remainMoney)
        print("赢的不够======="..self.begainMoney.."+"..self.remainMoney)
        bet_num:setString(0)
        local call1 = cc.CallFunc:create(function()
            self.room_bet[indexAreaId] = 0
            --Win_bet_num:setString(self.settle_money[WinIndx].bet_money/10000 - self.remainMoney)
            self.begainMoney = self.room_bet[WinAreaId]/10000 + self.remainMoney
            self.room_bet[WinAreaId] =  self.room_bet[WinAreaId] - self.remainMoney*10000
            print("WinAreaId======================"..WinAreaId..self.room_bet[WinAreaId])
            
            self.remainMoney = self.settle_money[Indx-1].settle_money/10000
            print("self:runAction=========33333333333333333333")
            self:HiuShumovechip(WinIndx,Indx-1)
        end)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(self.MoveActionTimes) , call1 ))
    end
end


function PlaySceneSangong:OnplaygameNode()
    

end

--发送option消息
function PlaySceneSangong:onReady()

end

function PlaySceneSangong:onNodeEvent(eventName)
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
    self:unregisterAllMsgListener()
    gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:removeEventListenersForTarget(self)
    end	     
end
function PlaySceneSangong:onTouchBegan(touch, event)
    self.beganPos = self:convertToNodeSpace(touch:getLocation())
    if self.Touzhu_Layer:getPositionX() ==290 then
        self:PfbMove(true)
        self.TouZhuMove = false
    end
    return true
end
function PlaySceneSangong:onTouchMove(touch, event)
    self.MovePos = true
    return true
end
function PlaySceneSangong:onTouchEnd(touch, event)
    local animation = cc.RotateTo:create(0.2, 180)
    self.venue_pop:runAction(cc.RepeatForever:create(animation))
    self.EndPos = self:convertToNodeSpace(touch:getLocation())
    if self.MovePos then
        self.MovePos = false
        if self.EndPos.x - self.beganPos.x < -80 and self.Touzhu_Layer:getPositionX() == 870 and self.EndPos.y > 856 then
            self:PfbMove(false)
            self.TouZhuMove = true
        end
    end
    return true
end
function PlaySceneSangong:PfbMove(bVisible)
    Utils.setClickEffect()  
    
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

function PlaySceneSangong:OnSetLotteryNo(lottery_no)
    self.CartrackGame:SetLotteryNo(true)
end

function PlaySceneSangong:update(delta)
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
    if self.zhuijiTime%2 == 1 then 
        for i = 1 ,12 do
            self.LightNum[i]:setVisible(false)
        end
    else
        for i = 1 ,12 do
            self.LightNum[i]:setVisible(true)
        end
    end
    self.zhuijiTime = self.zhuijiTime - 1
    if self.zhuijiTime < 0 then
        self.zhuijiTime = 0
    end  
    self.time_num:setString(self.zhuijiTime)
    local BuyFullPlist =  self.BtnBuyfull:getChildByTag(1003)
    if self.GameStatus == 1 then
        self.DialogNode:setVisible(false)
        self.CartrackGame:CarTimeUpdate(GameBase.RoomMsgTbl[6],self.zhuijiTime)
        self.BtnBuyfull:setVisible(false)
        self.SprBtnBuy:setVisible(false)
        self.ishiushuing = true
        self.isplaybao = true
        self.isshowPai = true
        self.GameStart = true
        local ProfitScene =  self:getChildByTag(1002)
        if ProfitScene then
            ProfitScene:removeFromParent()
        end
        self.SprBtnBuyflag = true
        return
    end
     self.CartrackGame:CarTimeUpdate(GameBase.RoomMsgTbl[6],0)
    if self.GameStatus == 2 then   --买满状态
         if self.SprBtnBuyflag then
            self.BtnBuyfull:setVisible(true)
         end
        if self.BuyFullPlist == nil then
            self.BuyFullPlist = cc.ParticleSystemQuad:create("res/BuyFull/BuyFull.plist")
            local Buyfullsize = self.BtnBuyfull:getSize()
            self.BuyFullPlist:setPosition(Buyfullsize.width/2,Buyfullsize.height/2) 
            self.BtnBuyfull:addChild(self.BuyFullPlist,self.BtnBuyfull:getLocalZOrder()-1,1003) 
        end
        return
    elseif self.GameStatus == 3 then
        self.WaitTime = self.WaitTime - 1
        if self.WaitTime < 0 then
            self.WaitTime = 0
        end
        self.DialogNode:setVisible(true)
        self.DialogNodeText:setString("封盘\n等待开奖"..self.WaitTime.."s...")
    elseif self.GameStatus == 4 then
        if self.zhuijiTime < 18 then
            self.WaitTimeKaijiang = 1
            self.CartrackGame:CarBaowei()
            self.isplaybao = false
        else
            self.zhuijiTime = 30
        end

        if self.showcardFlag then
            self.FapaiqiGame:showPai(self.showcard,self.CardNum)
            self.showcardFlag = false
            self.WaitTimeKaijiang = 3
        end

        self.WaitTimeKaijiang = self.WaitTimeKaijiang - 1
        self.DialogNode:setVisible(true)
        self.DialogNodeText:setString("封盘\n等待开奖...")
        if self.WaitTimeKaijiang > 0 then
            return
        end
        self.DialogNode:setVisible(false)
        if self.isplaybao then
            self.CartrackGame:PlayCarBao()
            self.isplaybao = false
        end
        if self.isplaybao == false and self.GameBetOn and self.CartrackGame.PlayActions == false and self.isshowPai then
            self.gametap:showzhonjian(GameBase.RoomMsgTbl)
            self:faPuke()
            self.isshowPai = false
            self.GameBetOn = false
            self.ishiushuing = true
        end
    elseif self.GameStatus == 5 then
        self.DialogNode:setVisible(true)
        self.DialogNodeText:setString("封盘\n等待下局开始...")
        if self.ishiushuing then -- 只收一次
--            if self.zhuijiTime > 20 then
--                self.DialogNode:setVisible(false)
--                return
--            end 
            if self.PukeNum < 23 then
                self.DialogNode:setVisible(false)
                return
            end
            self.CartrackGame:StopCarBao()
            self.ishiushuing = false
            self.PukeNum = 10
            self.CycleTimes = 0
            for i = 1 ,15 do
                self.PukeBack[i]:setPosition(cc.p(850,1000))
                self.PukeBack[i]:setVisible(true)
                self.PukeBack[i]:setScale(1)
                self.PukeSprite[i]:setVisible(false)
            end
--            for i = 1 , 5 do 
--                self.result_num[i]:removeFromParent()
--            end
            self:PukeResult(false)  --显示点数结果消失
            --self:HiuShuChip()
            --self:OnsetSettle()
            --self:HiuShuWinChip()
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_COIN_INFO_REQ,"{}")
        end
    end
    --self.DialogNode:setVisible(true)
    self.BtnBuyfull:setVisible(false)
    self.SprBuyfull:setVisible(false)
 
end


--买满提示框
function PlaySceneSangong:InitBuyfull()
    
    local BuyFullNode , FireAction = gt.createCSAnimation("BuyFullScene.csb")
    self.rootNode:addChild(BuyFullNode,99)
    FireAction:play("animatioFire", true)
    
    --买满按钮
    local BtnBuyfull = gt.seekNodeByName(BuyFullNode, "Button_Buyfull")
    BtnBuyfull:setPosition(cc.p(BtnBuyfull:getPositionX(), BtnBuyfull:getPositionY() ))
    BtnBuyfull:setVisible(false)
    local SprBtnBuy = gt.seekNodeByName(BuyFullNode, "BuyfullBtn_2")
    SprBtnBuy:setPosition(cc.p(SprBtnBuy:getPositionX(), SprBtnBuy:getPositionY()  ))
    SprBtnBuy:setVisible(false)
    self.BtnBuyfull = BtnBuyfull
    self.SprBtnBuy = SprBtnBuy
    --买满选择
    local SprBuyfull = gt.seekNodeByName(BuyFullNode, "SangongBuyfull_2")
    self.SprBuyfull = SprBuyfull
    SprBuyfull:setVisible(false)
    local FireAnimal = gt.seekNodeByName(SprBuyfull, "Fire1")
--    BuyFullNode:runAction(FireAnimal)
--    FireAnimal:gotoFrameAndPlay(0, 55, true)

    for i = 1 ,12 do
        self.LightNum[i] = gt.seekNodeByName(BuyFullNode, "BigLight_"..i)
    end
    --确定选择弹框
    local SureBuyfull = gt.seekNodeByName(SprBuyfull, "Editbox_4")
    SureBuyfull:setVisible(false)
    local TxtChose = gt.seekNodeByName(SureBuyfull, "Text_7")
    local ChoseSure = gt.seekNodeByName(SureBuyfull, "Button_7")
    local ChoseQuxiao = gt.seekNodeByName(SureBuyfull, "Button_8")
    local Area_id = 1

    gt.addBtnPressedListener(BtnBuyfull, handler(self, function()
        gt.soundEngine:playEffect("BuyFullBtn",false)
        SprBuyfull:setVisible(true)
        self.bClickArea = true 
        SureBuyfull:setVisible(false)
	end))
    local BtnChose = {}
    for i= 1 ,5 do 
        BtnChose[i] = gt.seekNodeByName(SprBuyfull, "Button_"..i)
        gt.addBtnPressedListener(BtnChose[i], handler(self, function()
            Utils.setClickEffect()
            SureBuyfull:setVisible(true)
            TxtChose:setString("确定要对"..i.."号投注区买满吗？")
            Area_id = i
	    end))
    end

    gt.addBtnPressedListener(ChoseSure, handler(self, function()
        Utils.setClickEffect()
        SprBuyfull:setVisible(false)
        self:SendBuyFullReq(Area_id)
	end))
    
    gt.addBtnPressedListener(ChoseQuxiao, handler(self, function()
        Utils.setClickEffect()
        SprBuyfull:setVisible(false)
        self.bClickArea = false 
	end))
end

function PlaySceneSangong:OnGameBuyFull(code,msg_id,bet_money)
    if code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","购买失败，系统错误！", nil, nil, true)
    elseif code == 2 then 
        require("app/views/UI/NoticeTips"):create("提示", "购买失败，元宝不足！",nil, nil, true)
        self.BtnBuyfull:setVisible(false)
        self.SprBtnBuy:setVisible(true)
    elseif code == 3 then 
        require("app/views/UI/NoticeTips"):create("提示", "购买失败，超期！",nil, nil, true)
    elseif code == 4 then 
        require("app/views/UI/NoticeTips"):create("提示", "购买失败，已达投注区上限！",nil, nil, true)
    elseif code == 5 then 
        require("app/views/UI/NoticeTips"):create("提示", "购买失败，投注区无效！",nil, nil, true)
    elseif code == 6 then 
        require("app/views/UI/NoticeTips"):create("提示", "购买失败，玩法不支持（不支持买满）！",nil, nil, true)
    elseif code == 7 then 
        require("app/views/UI/NoticeTips"):create("提示", "购买失败，非买满时间！",nil, nil, true)
    elseif code == 10 then 
        require("app/views/UI/NoticeTips"):create("提示", "购买失败，多次买满！",nil, nil, true)
    elseif code == 0 then
        gt.soundEngine:playEffect("SureBuyFull",false)
        self.SprBuyfull:setVisible(false)
        self.BtnBuyfull:setVisible(false)
        self.SprBtnBuy:setVisible(true)
        self.SprFullAnimal[msg_id]:setVisible(true)
        self.SprBtnBuyflag = false
--        local pos = cc.p(0,0)
--        if msg_id == 1 then
--            pos = cc.p(375,659)
--        elseif msg_id == 2 then
--            pos = cc.p(620,556)
--        elseif msg_id == 3 then
--            pos = cc.p(543,306)
--        elseif msg_id == 4 then
--            pos = cc.p(249,306)
--        else
--            pos = cc.p(130,556)
--        end
--        self.SprFullAnimal:setPosition(pos)
        local str = string.format("bet_box_%d", msg_id)
        local bet_box = gt.seekNodeByName(self.game_bj, str)
        local bet_num = gt.seekNodeByName(bet_box, "bet_num")
        self.BetBuyFullNum[msg_id] = bet_money/10000
        local TotalNum = 0 
        for i = 1 ,5 do
            TotalNum = self.BetBuyFullNum[1]+self.BetBuyFullNum[2]+self.BetBuyFullNum[3]+self.BetBuyFullNum[4]+self.BetBuyFullNum[5]
        end
        bet_num:setString(bet_money/10000+ tonumber(bet_num:getString()))
        self.Touzhu_num:setString(TotalNum+self.goldnum)
    else
        require("app/views/UI/NoticeTips"):create("提示", "购买失败！",nil, nil, true)
    end
end

function PlaySceneSangong:faPuke()
    local PukeBack = {}
    local pos  = {}
    local moveTo1 = {}
    local spa1 = {}
    local Seq  = {}
    for i = 1,3 do 
        PukeBack[i] = self.rootNode:getChildByTag(self.PukeNum + i)
        PukeBack[i]:setVisible(true)
        pos[i] = cc.p( 150+110*i,1000)
        moveTo1[i] = cc.MoveTo:create(0.4, pos[i])
        spa1[i] = cc.Spawn:create(moveTo1[i])
        local call
        if i == 3 then
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

function PlaySceneSangong:showPai(PukeNum)
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
--    if PukeNum ==22 then
--        self.CycleTimes = 4
--    end
    --gt.soundEngine:playEffect("xianhua",false)
    local paiSp = {}
    local paiSpZ ={}
    for i = 1 ,3 do 
        local MsgNum = (PukeNum-10-self.CycleTimes)+i
        if MsgNum == 11 then
            MsgNum = 1
        end
    
        paiSp[i] = self.rootNode:getChildByTag(PukeNum+i)
        paiSpZ[i] = self.rootNode:getChildByTag(PukeNum +15+i)
        paiSpZ[i]:setTexture("res/PukePai/PukePai_1_"..MsgTbl[MsgNum].."_"..math.random(0,3)..".png")
        paiSpZ[i]:setPosition(paiSp[i]:getPosition())
        --paiSp:setScaleX(0)
        --paiSpZ:setVisible(true)
        paiSpZ[i]:setScaleX(0.2)
        paiSpZ[i]:setScaleY(1)
        paiSpZ[i]:setRotation(360)
        paiSpZ[i]:setOpacity(255)
        local call = cc.CallFunc:create(function ()
            local call3
            if i == 3 then
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

function PlaySceneSangong:MovePukePai()
    local MaJNum1 = {}
    local paiSpZ ={}
    local moveTo ={}
    local ScaleTo ={}
    local spa ={}
    local pos1 ={}
    local Seq = {}
    for i = 1 , 3 do

        MaJNum1[i] = self.PukeNum + 15 + i 
        --print("+++++++++++++++++++++"..self.PukeNum)
        paiSpZ[i] = self.rootNode:getChildByTag(MaJNum1[i])
        if self.PukeNum == 10 then
            pos1[i] = cc.p(270+40*i,630)
        elseif self.PukeNum == 13 then
            pos1[i] = cc.p(517+40*i,527)
        elseif self.PukeNum == 16 then
            pos1[i] = cc.p(397+40*i,285)
        elseif self.PukeNum == 19 then
            pos1[i] = cc.p(147+40*i,285)
        elseif self.PukeNum == 22 then
            pos1[i] = cc.p(27+40*i,527)
        end
	    
        moveTo[i] = cc.MoveTo:create(0.2*i, pos1[i])
        ScaleTo[i] = cc.ScaleTo:create(0.2*i,0.5)
        spa[i] = cc.Spawn:create(moveTo[i],ScaleTo[i])

        local call2 
        if i == 3 then
            call2 = cc.CallFunc:create(function ()
            
                self.PukeNum = self.PukeNum +3
                self.CycleTimes = self.CycleTimes+1
                if self.PukeNum < 23 then
                    self:faPuke()
                else
                    self:PukeResult(true)       --显示点数结果
                    self:HiuShuWinChip()
                end 
	        end)
            paiSpZ[i]:stopAllActions()
        end
        Seq[i] = cc.Sequence:create(spa[i],call2)
	    paiSpZ[i]:runAction(Seq[i])
    end    
end
function PlaySceneSangong:PukeResult(bVisible)
    local MsgTbl = gt.string_split(GameBase.RoomMsgTbl[2],",")
    for i = 1, 10  do
        if MsgTbl[i] == "10" then
            MsgTbl[i] = "0"
        else
            for w in string.gmatch(MsgTbl[i], "[^%z]") do
                MsgTbl[i] = w
            end
        end
        MsgTbl[i] = tonumber(MsgTbl[i])
    end
    
    for i=1,5 do
        local num
        if i == 5 then
            num = (MsgTbl[i*2-1]+MsgTbl[1]+MsgTbl[i*2])%10
        else
            num = (MsgTbl[i*2-1]+MsgTbl[i*2]+MsgTbl[i*2+1])%10
        end
        local str = string.format("bet_box_%d", i)
        local bet_box = gt.seekNodeByName(self.game_bj, str)
        local result_num = gt.createTTFLabel("抓鸟", 40)
        result_num:setVisible(bVisible)
        result_num:setString(num.."点")
        if i == 1 then
            result_num:setPosition(450,753)
        elseif i == 2 then
            result_num:setPosition(700,650)
        elseif i == 3 then
            result_num:setPosition(577,407)
        elseif i == 4 then
            result_num:setPosition(330,407)
        else
            result_num:setPosition(210,650)
        end
        self.result_num[i] = result_num
        self.chipLayer:addChild(result_num,2)

        local strPng = string.format("res/RangeList/"..self.order[i].."nd.png")
        local paiSpNd = cc.Sprite:create(strPng)
        paiSpNd:setPosition(-110,20)
        paiSpNd:setScale(2)
        result_num:addChild(paiSpNd,2)

    end
end
function PlaySceneSangong:UpdateGameItem(tag, cellData)
    gt.log("UpdateGameItem == ",tag,cellData.lottery_id,cellData.lottery_no)
    if cellData.lottery_id == self.roomInfo.lottery_id then 
       --self.gametap:showzhonjian(cellData.lottery_no)
       GameBase.RoomMsgTbl[2]  = cellData.lottery_no
       GameBase.RoomMsgTbl[3]  = cellData.issue
    end
end
function PlaySceneSangong:InitGameScene()
    
end
function PlaySceneSangong:InitchipTap()
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
function PlaySceneSangong:OnsetSettle()
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
function PlaySceneSangong:Onaddchip(area_id,chip,issend)
    if chip > 0 then
        gt.soundEngine:playEffect("ChipsClick",false)
    end
    --gt.log("Onaddchip=====",area_id,chip,issend) 
    gt.soundEngine:playEffect("ChipsClick",false)
    --gt.log("Onaddchip=====",area_id,chip,issend) 
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

function PlaySceneSangong:MoveChip(area_id,chipid,issend)
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
        pos = cc.p(bet_box:getPositionX()+ math.random(-70,70), bet_box:getPositionY()+ math.random(-60,70))
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

--创建输区域的筹码
function PlaySceneSangong:CreatChip(chipid,lose_id)
    local chipNum = chipid
    for i=1 ,5 do
        if chipNum == 0 then
            break
        end
        local chip2 =  math.fmod(chipNum,GameBase.chiptap[self.SprIndex[6-i]])
        local chip1 =  math.floor(chipNum/GameBase.chiptap[self.SprIndex[6-i]])
        for j=1 ,chip1 do
            self:CreatChip2(self.SprIndex[6-i],lose_id)
        end
        chipNum = chip2
    end 
end
function PlaySceneSangong:CreatChip2(chipid,lose_id)
    local str = string.format("res/ChouMa/chip%d.png", chipid)
    local loseChipSprite = cc.Sprite:create(str)
    local move_box = gt.seekNodeByName(self.rootNode, "bet_box_"..lose_id)
    loseChipSprite:setPosition(move_box:getPositionX()+ math.random(-70,70), move_box:getPositionY()+ math.random(-70,60))
    self.MoveMentTimes =  self.MoveMentTimes + 1
    loseChipSprite:setTag(lose_id*100000+self.MoveMentTimes)
    print("MoveWinToHome*100000+i==========================="..lose_id*100000+self.MoveMentTimes)
    self.chipNewLayer:addChild(loseChipSprite)
end

--移动输区域的筹码
function PlaySceneSangong:LoseToWin(move_id,area_id,chipid,bMove)
    local chipNum = chipid
    for i=1 ,5 do
        if chipNum == 0 then
            break
        end
        local chip2 =  math.fmod(chipNum,GameBase.chiptap[self.SprIndex[6-i]])
        local chip1 =  math.floor(chipNum/GameBase.chiptap[self.SprIndex[6-i]])
        for j=1 ,chip1 do
            self:MoveWinChip(move_id,area_id,self.SprIndex[6-i],bMove,j)
        end
        chipNum = chip2
    end
end

function PlaySceneSangong:MoveWinChip(move_id,area_id,chipid,bMove,nChip)
    local str = string.format("res/ChouMa/chip%d.png", chipid)
    local SprmoveWin = cc.Sprite:create(str)
    local move_box = gt.seekNodeByName(self.rootNode, "bet_box_"..move_id)
    SprmoveWin:setPosition(move_box:getPosition())
    self.MoveWinTimes = self.MoveWinTimes + 1
    SprmoveWin:setTag((area_id+5)*1000+self.MoveWinTimes)
	local moveTo = nil
    local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..area_id)
    local bet_boxX,bet_boxY = bet_box:getPosition()
    local pos = cc.p(bet_box:getPositionX()+ math.random(-70,70), bet_box:getPositionY()+ math.random(-70,60))
    moveTo = cc.MoveTo:create(0.3 + 0.1*nChip, pos)

    local FadeTo = cc.FadeTo:create(0.8,0)
    local pos2 = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
	local moveTo2 = cc.MoveTo:create(0.8, pos2)
    if bMove then
        moveTo2 = nil
    end
	local call = cc.CallFunc:create(function ()
        
    end)
	local spa = cc.Sequence:create(moveTo)
	SprmoveWin:stopAllActions()
	SprmoveWin:runAction(spa)
    self.chipLayer:addChild(SprmoveWin)
end

function PlaySceneSangong:MoveWinToHome(area_id,nDelayTime)
    for i = 1 , self.MoveMentTimes do
        local WinToHome = self.chipNewLayer:getChildByTag(area_id*100000+i) 
        if WinToHome then
            local FadeTo = cc.FadeTo:create(1.2,0)
            local pos2 = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
	        local moveTo2 = cc.MoveTo:create(0.5 + 0.1*i, pos2)
	        local spa = cc.Sequence:create(cc.DelayTime:create(nDelayTime),moveTo2,FadeTo)
	        WinToHome:stopAllActions()
	        WinToHome:runAction(spa)
        end
    end
    for i = 1 , 10 do
        for j = 1 , self.chipTap do
             self.TWinChipSprite[i][j] = self.chipLayer:getChildByTag(i*1000 + j-1)      --赢区域
             if self.TWinChipSprite[i][j] then
                local FadeTo = cc.FadeTo:create(1.2,0)
                local pos2 = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
	            local moveTo2 = cc.MoveTo:create(1.2, pos2)
	            local spa = cc.Sequence:create(cc.DelayTime:create(nDelayTime),moveTo2,FadeTo)
	            self.TWinChipSprite[i][j]:stopAllActions()
	            self.TWinChipSprite[i][j]:runAction(spa)
            end
        end
    end
   
end

function PlaySceneSangong:OnShowaddchip(area_id,chipid,isfull)
    local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..(area_id+1))
    local bet_num = gt.seekNodeByName(bet_box, "bet_num")
    bet_num:setString(tonumber(chipid))
    self.room_bet[area_id + 1] = chipid * 10000
     if isfull==1 then
        self.SprFullAnimal[area_id+1]:setVisible(true)
     end
end

function PlaySceneSangong:OnSetTouzhuchip(chipid)
    self.Touzhu_num:setString(chipid)
end

-- 断线重连,初始化数据
function PlaySceneSangong:reLogin()
    -- 进游戏桌子
    self.loadingtime = 0
    gt.isshowlading = true
    --GameBase:initdata()
    gt.socketClient:setIsStartGame(true)
    
    local playScene = require("app/views/Scene/PlaySceneSangong"):create(self.roomInfo,GameBase.RoomMsgTbl[4],gt.Gameroomid)
    cc.Director:getInstance():replaceScene(playScene)

    --gt.log("reLogin===EnterGameRoomId ",gt.EnterGameRoomId)
    local cmsg = cmd_node_pb.CEnterGameReq()
    cmsg.node_id = gt.EnterGameRoomId
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_ENTER_GAME_REQ,msgData)
end
function PlaySceneSangong:OnBetSettleResp(Lorder)
--    self.CartrackGame:StopCarBao()
--    self.gametap:showzhonjian(GameBase.RoomMsgTbl)
--    self.FapaiqiGame:xiaofapai(self.ShowPaiList)
      self.order = Lorder
end
--投注明细


--取投注明细
--date 日期  格式:2017-12-05
--function PlaySceneSangong:getBetDetailByRoom()
--    local cmsg = cmd_lobby_pb.CGetUserBetDetailReq()
--    --cmsg.uid = gt.playerData.uid
--    cmsg.detail_id = -1
--    cmsg.detail_num = 50
--    cmsg.date_time = os.date("%Y-%m-%d")
--    local msgData = cmsg:SerializeToString()
--    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_REQ,msgData)        
--end

return PlaySceneSangong
