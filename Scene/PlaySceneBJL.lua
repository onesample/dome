--百家乐
local gt = cc.exports.gt
require("app.protocols.cmd_node_pb")
require("app.protocols.cmd_game_pb")

local GameBase = require("app/utils/GameBase")
local PlaySceneBJL = class("PlaySceneBJL", GameBase)

PlaySceneBJL.__index = PlaySceneBJL

function PlaySceneBJL:ctor(enterRoomMsgTbl,Roomname,ChoseGameid)
    GameBase:ctor()
    GameBase:initdata()
    --初始化YVSDK
    --path = cc.FileUtils:getInstance():getWritablePath()
    --yvcc.YVTool:getInstance():initSDK("1000808",path, false)
    --语音路径
    gt.path = cc.FileUtils:getInstance():getWritablePath().."text.amr"
    --呀呀云CP登陆
    --gt.log("playerName-------"  , gt.playername)
    --gt.log("playeruseid------"  , gt.playeruid)
   if gt.isIOSPlatform() or gt.isAndroidPlatform() then
    --yvcc.YVTool:getInstance():cpLogin(gt.playername , gt.playeruid)
   end

    --保存房间信息20161125
    self.roomInfo = enterRoomMsgTbl
    self.ChoseGameid = ChoseGameid
    --print("self.roomInfo------------------"..self.roomInfo)
    self.chipTap = 0
    self.delindex = 1
    --周期
    self.zhuijiTime = GameBase.RoomMsgTbl[6]
    self.FenPanTime = GameBase.RoomMsgTbl[7]
	
	self.m_numberMark = 0
	gt.log("进入PlaySceneBJL")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	-- 加载界面资源
	local csbNode = cc.CSLoader:createNode("BjlGameScene.csb")
    self:addChild(csbNode)
	self.rootNode = csbNode

	-- 跑马灯
--	local marqueeNode = gt.seekNodeByName(csbNode, "Node_marquee")
--	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
--	marqueeNode:addChild(marqueeMsg)

    self.game_bj = gt.seekNodeByName(csbNode, "game_bj")
    self.chipLayer = cc.Layer:create()
    --self.chipLayer:setPosition(self.game_bj:getPosition())
    --self.chipLayer:setAnchorPoint(cc.p(0.5,0.5))
    self.game_bj:addChild(self.chipLayer)
    -- 在新的版本，要判断下注的位置，每个游戏的位置不一样，写数据
    --下注区域

    --self.SprIndex = {0,0,0,0,0}     --可选择的筹码
    self.showcard = ""        --初始化显示的牌
    self.CardNum = 0         --初始化牌的数量
    self.BootsId = 0         --初始化靴
    self.BootsRoundNum = 0   --初始化靴局
    --self.GameStatus = 0       -- 1.投注 2. 买满 3.封盘 4.开盘 5.关盘 0 初始化未完成
    self.GameId = 1           -- 当前游戏ID
    self.WinAreaId = {}        --获胜区域
    self.WaitTime = 0           --等待开奖
    self.WaitTimeKaijiang = 1   --等待开奖
    self.ClickArea = 0          --点击区域
    self.Gradeidx = 1
    self.bMove = true
    self.ishiushuing = false
    self.isplaybao = true
    self.showPai = true
    self.ShowPaidi = true
    self.isfapai = true
    GameBase.RoomMsgTbl[5] = 7
    self.room_bet = {0,0,0,0,0}
    self.BetSettleList = {}
    self.ShowPaiList = {}
    for i=1,7 do
        local str = string.format("bet_box_%d", i)
        local bet_box = gt.seekNodeByName(csbNode, str)
        
        local bet_num = gt.seekNodeByName(bet_box, "bet_num")
        local bet_Btton = gt.seekNodeByName(bet_box, "bet_Btton")
        bet_num:setString(0)
        if i > GameBase.RoomMsgTbl[5] then
            bet_box:setVisible(false)
        else
            bet_box:setVisible(true)
--          gt.addBtnPressedListener(bet_box, function()
--                self:onJettonAreaClicked(bet_box)
--	        end)
            --下注筹码 飞过来
--            local cbetBoxSize = bet_box:getContentSize()
--	        local cbetBox = ccui.Widget:create()
--	        cbetBox:setTag(i)
--            cbetBox:setAnchorPoint(cc.p(0.5,0.5))
--            cbetBox:setPosition(bet_box:getPosition())
--	        cbetBox:setTouchEnabled(true)
--            self.game_bj:addChild(cbetBox)
----            if i == 6 then
----                cbetBox:setContentSize(cc.size(cbetBoxSize.width-100,cbetBoxSize.height))
----            else
--            cbetBox:setContentSize(cbetBoxSize)
            --end
	        
	        bet_Btton:setTag(i)
            bet_Btton:addClickEventListener(
                handler(self, self.onJettonAreaClicked)
	        )
            bet_Btton:setSwallowTouches(false)
            --gt.addBtnPressedListener(result_but, handler(self, self.onJettonAreaClicked(bet_box)))
        end
    end
    for i = 1 , 5 do
        local str = string.format("TouZhuNumBtn_%d", i)
        local TouZhuNumBtn = gt.seekNodeByName(csbNode, str)
        TouZhuNumBtn:addClickEventListener(function()
		    self:SendGetTouzhuRangeReq(i)
	    end)
    end
        
    --发牌
    self.FapaiqiNode = gt.seekNodeByName(csbNode, "Fapaiqi")
    self.FapaiqiGame = require("app/views/UI/FapaiqiGame"):create()
    self.FapaiqiNode:addChild(self.FapaiqiGame)

    self.time_num = gt.seekNodeByName(self.rootNode, "time_num")
    self.time_num:setString(self.zhuijiTime)
    self.time_num:setVisible(false)
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
    
	-- 期号与游戏名
    GameBase.RoomMsgTbl[1]  = "百家乐"
    GameBase.RoomMsgTbl[3]  = self.roomInfo.issue
    GameBase.RoomMsgTbl[2]  = self.roomInfo.lottery_no
    GameBase.RoomMsgTbl[4]  = Roomname
    GameBase.RoomMsgTbl[8]  = self.ChoseGameid
	self.gametapNode = gt.seekNodeByName(csbNode, "gametap")
    self.gametapNode:setLocalZOrder(100003)
    self.gametap = require("app/views/UI/GameLayerTap"):create(self,GameBase.RoomMsgTbl,self.ChoseGameid)
	self.gametapNode:addChild(self.gametap)

--    if self.roomInfo.lottery_id == 4 then
--        --跑车
--        self.CartrackNode = gt.seekNodeByName(csbNode, "Cartrack")
--        self.CartrackGame = require("app/views/UI/BoattrackGame"):create(self.roomInfo.lottery_id,GameBase.RoomMsgTbl,self.gametap)
--        self.CartrackNode:addChild(self.CartrackGame)
--    else
        --跑车
        self.CartrackNode = gt.seekNodeByName(csbNode, "Cartrack")
        self.CartrackGame = require("app/views/UI/CartrackGame"):create(self.roomInfo.lottery_id,GameBase.RoomMsgTbl,self.gametap )
        self.CartrackNode:addChild(self.CartrackGame)
    --end

    --self.KaiJiangBtn = self.CartrackNode.KaiJiangBtn
    --self.KaiJiangBtn = gt.seekNodeByName(self.rootNode, "KaiJiangBtn")
    self.CartrackGame.KaiJiangBtn:setVisible(true)
    gt.addBtnPressedListener(self.CartrackGame.KaiJiangBtn, handler(self, function()
        --开奖结果
        Utils.setClickEffect()
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
        self.resultScene = require("app/views/Scene/ResultScene"):create(self.ChoseGameid,self.roomInfo.lottery_id)
        self:addChild(self.resultScene)			
	end))    

    --充值按钮
    self.recharge_but = gt.seekNodeByName(self.rootNode, "recharge_but")
    gt.addBtnPressedListener(self.recharge_but, handler(self, function()
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
        Utils.setClickEffect()
	end))
    --玩家列表按钮
    local PlayerNum_btn = gt.seekNodeByName(self.rootNode, "PlayerNum_btn")
    gt.addBtnPressedListener(PlayerNum_btn, handler(self, function()
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
        Utils.setClickEffect()
        self:SendGetUserListReq()
--		local PlayerListScene = require("app/views/Scene/PlayerListScene"):create()
--        self:addChild(PlayerListScene)
	end))
    --场馆按钮
    local venue_but = gt.seekNodeByName(self.rootNode, "venue_but")
    --venue_but:setLocalZOrder(100002)
--    local venueNode = cc.CSLoader:createNode("venue_pop.csb")
--    self:addChild(venueNode,99)
    --关闭按钮
    local venue_pop = gt.seekNodeByName(self.rootNode, "venue_pop")
    local venue_close = gt.seekNodeByName(self.rootNode, "close")
    --venue_pop:setLocalZOrder(100005)
    --venue_close:setLocalZOrder(100005)
    venue_pop:setRotation(180)
    self.venue_pop = venue_pop

    gt.addBtnPressedListener(venue_but, handler(self, function()
        local animation = cc.RotateTo:create(0.2, 0)
        venue_pop:runAction(cc.RepeatForever:create(animation))
        Utils.setClickEffect()
	end))
    gt.addBtnPressedListener(venue_close, handler(self, function()
        local animation = cc.RotateTo:create(0.2, 180)
        venue_pop:runAction(cc.RepeatForever:create(animation))
        Utils.setClickEffect()
	end))
    --切换按钮
    local venue_GameCar = gt.seekNodeByName(self.rootNode, "gamebut_1")
    local venue_GameCQ = gt.seekNodeByName(self.rootNode, "gamebut_4")
    local venue_GameBall = gt.seekNodeByName(self.rootNode, "gamebut_2")
    local venue_GameLottery = gt.seekNodeByName(self.rootNode, "gamebut_3")
    
    gt.addBtnPressedListener(venue_GameCar, handler(self, function()
        gt.Gameroomid = 0
        self:enterGameRoom(1)
        Utils.setClickEffect()
	end))
    gt.addBtnPressedListener(venue_GameCQ, handler(self, function()
        gt.Gameroomid = 0
        --self:enterGameRoom(4)
        require("app/views/UI/NoticeTips"):create("提示","敬请期待！", nil, nil, true)
        Utils.setClickEffect()
	end))
    gt.addBtnPressedListener(venue_GameBall, handler(self, function()
        gt.Gameroomid = 0
        self:enterGameRoom(2)
        Utils.setClickEffect()
	end))
    gt.addBtnPressedListener(venue_GameLottery, handler(self, function()
        gt.Gameroomid = 0
        self:enterGameRoom(3)
        Utils.setClickEffect()
	end))

    --赢动画图片
    self.WinAnima = {}
    for i = 1 , 5 do 
        self.WinAnima[i] = cc.Sprite:create("res/BjlWinAnimal/WinAnima"..i..".png")
        self.FapaiqiNode:addChild(self.WinAnima[i],9)
        --self.WinAnima[i]:setTag(20+i) --21-30
        self.WinAnima[i]:setVisible(false)
    end
    self.WinAnima[1]:setPosition(cc.p(-190,-840))
    self.WinAnima[2]:setPosition(cc.p(180,-840))
    self.WinAnima[3]:setPosition(cc.p(0,-605))
    self.WinAnima[4]:setPosition(cc.p(-248,-605))
    self.WinAnima[5]:setPosition(cc.p(238,-605))
    --self:ShowWinAnimal(3)
    --闲点数
    self.XianDiBg = gt.seekNodeByName(self.rootNode, "XianDiBg")
    self.TxtXWin_num = gt.seekNodeByName(self.rootNode, "TxtXWin_num")
    self.TxtXWin_num:setString("闲9点")
    self.XianDiBg:setVisible(false)
    --庄点数
    self.ZhuangDiBg = gt.seekNodeByName(self.rootNode, "ZhuangDiBg")
    self.TxtZWin_num = gt.seekNodeByName(self.rootNode, "TxtZWin_num")
    self.TxtZWin_num:setString("庄0点")
    self.ZhuangDiBg:setVisible(false)

    --投注明细
    local desk_bj = gt.seekNodeByName(csbNode, "desk_bj")
    desk_bj:setLocalZOrder(100005)
    self.desk_bj = desk_bj
    self.Touzhu_Layer = gt.seekNodeByName(desk_bj, "Touzhu_Layer")
    self.TouZhuMove = false
    self.MovePos = false
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
    AddCardSet:setVisible(false)
    self:addChild(AddCardSet)
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
    --self:getBetDetailByRoom()

    -- 获取用户投注详情
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_RESP, self, self.onGetUserBetDetailResp)

    --路单详情
    local grade_bj = gt.seekNodeByName(csbNode, "grade_bj")
    self.Grade_Layer = gt.seekNodeByName(grade_bj, "Grade_Layer")
    self.GradeMove = false
    self.GradeListView = gt.seekNodeByName(grade_bj, "GradeListView")
    self.GradeListView:setSwallowTouches(false)
    self.GradeListView:setScrollBarEnabled(false)

end

-- 进入游戏房间
function PlaySceneBJL:enterGameRoom(sender)
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

function PlaySceneBJL:InitGameScene()
    self.CartrackGame:GetLotteryResult()
    self.FapaiqiGame:showBackPai(self.CardNum,self.BootsId,self.BootsRoundNum)
end

function PlaySceneBJL:InitchipTap()
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

function PlaySceneBJL:onchipClicked(butobj,tap)
    self.betcursor:setPositionX(butobj:getPositionX())
    self.chipma = tap
end

function PlaySceneBJL:onJettonAreaClicked(sender, eventType)
    --加限额判断  总额-减投注 
        local animation = cc.RotateTo:create(0.2, 180)
        self.venue_pop:runAction(cc.RepeatForever:create(animation))
--    if self.zhuijiTime <= 0 then
--        return
--    end  self.PfbIsBig = false
--    if self.CartrackGame.GradeNode:isVisible() == true then
--        self.CartrackGame:PfbVisible(false)
--        return
--    end
    if self.TouZhuMove or self.GradeMove then
        return
    end

    if self.GameStatus ~= 1 then
        return
    end
    
    --投注金币大于本身金币
    if gt.playerData.coin/10000 < GameBase.chiptap[self.SprIndex[1]] then
        
        if gt.playerData.playerType == 4 then 
            function OKcallfan(args)
    		    local LoginScene = require("app/views/Scene/LoginScene"):create(false,true)
		        cc.Director:getInstance():replaceScene(LoginScene) 
            end
            require("app/views/UI/NoticeTips"):create("提示","为了体验游戏完整功能，请您先升级为正式用户！", OKcallfan, nil, false,"res/res/BegainScene/PhoneREbPresstn.png")
        else 
             require("app/views/UI/NoticeTips"):create("提示","元宝不足!", nil, nil, true)
        end
        return
    end

    local senderNum = sender:getTag()
    self.ClickArea = senderNum  
    --gt.log("onJettonAreaClicked=========================",senderNum,self.SprIndex[self.chipma])
    --投注请求
    self:SendCBetReq(senderNum,self.SprIndex[self.chipma])

    --gt.soundEngine:playEffect("ChipsClick",false)
   
--    local str = string.format("res/ChouMa/chip%d.png", self.SprIndex[self.chipma])
--    local chipSprite = cc.Sprite:create(str)
--    local chipbut = gt.seekNodeByName(self.rootNode, "chip"..self.chipma)
--    chipSprite:setPosition(chipbut:getPosition())
--    local chipTapnum = 1000 * sender:getTag()
--    chipSprite:setTag(chipTapnum + self.chipTap)
--    self.chipTap = self.chipTap + 1
--    local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..sender:getTag())
--    local bet_num = gt.seekNodeByName(bet_box, "bet_num")
--    local bet_boxX,bet_boxY = bet_box:getPosition()
--    local pos
--    if senderNum == 6 then
--        pos = cc.p(bet_box:getPositionX()+ math.random(-70,30), bet_box:getPositionY()+ math.random(-70,70))
--    else
--        pos = cc.p(bet_box:getPositionX()+ math.random(-70,70), bet_box:getPositionY()+ math.random(-70,70))
--    end

--	local moveTo = cc.MoveTo:create(0.5, pos)
--	local call = cc.CallFunc:create(function ()
--        self.goldnum = self.goldnum + GameBase.chiptap[self.SprIndex[self.chipma]]
--        self.goldNode:setString(self.goldnum)
--        bet_num:setString(tonumber(bet_num:getString()) + GameBase.chiptap[self.SprIndex[self.chipma]])
--	end)
--	local spa = cc.Spawn:create(moveTo, call)
--	chipSprite:stopAllActions()
--	chipSprite:runAction(spa)

--    self.rootNode:addChild(chipSprite)
end

function PlaySceneBJL:OnplaygameNode()
    

end

function PlaySceneBJL:UpdateGameItem(tag, cellData)
    gt.log("UpdateGameItem == ",tag,cellData.lottery_id)
    if cellData.lottery_id == self.roomInfo.lottery_id then 
       --self.gametap:showzhonjian(cellData.lottery_no)
       GameBase.RoomMsgTbl[2]  = cellData.lottery_no
       GameBase.RoomMsgTbl[3]  = cellData.issue
    end
end
--发送option消息
function PlaySceneBJL:onReady()

end

function PlaySceneBJL:onNodeEvent(eventName)
	if "enter" == eventName then
        -- 逻辑更新定时器
        gt.log("进入PlaySceneBJL-----enter")
        --要启动联网取数据！
        gt.showLoadingTips()
        self.loadingtime = 0;
        self:initSocketregisterMsg()
        self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches( false )  -- 吞掉：触摸事件消息
        listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(handler(self, self.onTouchMove), cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(handler(self, self.onTouchEnd), cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher =  self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority( listener, self )
	elseif "exit" == eventName then
        gt.log("进入PlaySceneBJL-----exit   ")
        --self:SendGameLeaveReq()
        gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        self:unregisterAllMsgListener()
    end	     
end

function PlaySceneBJL:update(delta)	
    self:UpdateOpenTime()
    self.loadingtime = self.loadingtime + 1
    if gt.isshowlading then 
    --gt.log("update====",self.loadingtime,gt.isshowlading)
        if self.loadingtime > 10 then
            self.loadingtime = 0
            gt.isshowlading = false
             -- 去掉转圈
	        gt.removeLoadingTips()
            require("app/views/UI/NoticeTips"):create("提示","进房间失败！", function ()
                local playScene = require("app/views/Scene/MainScene"):create()
                cc.Director:getInstance():replaceScene(playScene)            
            end, nil, true)
        end
        return
    end    
    self.zhuijiTime = self.zhuijiTime - 1 
    if self.zhuijiTime < 0 then
        self.zhuijiTime = 0
    end 
    self.time_num:setString(self.zhuijiTime)
    if self.GameStatus == 1 then
        if self.isfapai then
            self.FapaiqiGame:fapai()
            self.isfapai = false
            --self.room_bet = {0,0,0,0,0}
            for i=1,5 do
                self.WinAnima[i]:stopAllActions()
                self.WinAnima[i]:setVisible(false)
            end
            self:getBetDetailByRoom(os.date("%Y-%m-%d"))
        end
        self.DialogNode:setVisible(false)
        self.CartrackGame:CarTimeUpdate(GameBase.RoomMsgTbl[6],self.zhuijiTime)
        self.ishiushuing = true
        self.isplaybao = true
        self.showPai = true
        self.ShowPaidi = true
        self.GameStart = true
        self.bMove = true
        self.WinAreaId = {}        --获胜区域
        local ProfitScene =  self:getChildByTag(1002)
        if ProfitScene then
            ProfitScene:removeFromParent()
        end
        self.FapaiqiGame:UpdateXue(self.CardNum,self.BootsId,self.BootsRoundNum)
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
        if self.CartrackGame.PlayActions == false and self.showPai and self.showcardFlag then
            --print("self.showcard==============="..self.showcard)
            self.FapaiqiGame:showPai(self.showcard,self.CardNum)

            self.showPai = false
            self.GameStart = true
            self.showcardFlag = false
        end
    elseif self.GameStatus == 4 then

        if self.zhuijiTime < 18 then
            self.WaitTimeKaijiang = 1
            self.CartrackGame:CarBaowei()
            cc.SimpleAudioEngine:getInstance():stopAllEffects()
            self.isplaybao = false
        else
            self.zhuijiTime = 40
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
            self.CartrackGame.KaiJiangBtn:setVisible(false)
            self.isplaybao = false
--            self:runAction(cc.Sequence:create(cc.DelayTime:create(14) ,cc.CallFunc:create(function ()
--                self.gametap:showzhonjian(GameBase.RoomMsgTbl)
--            end)))
        end
        --显示牌与点数
        if self.ShowPaidi and self.CartrackGame.PlayActions == false and self.GameBetOn and self.FapaiqiGame.showPaiOver then
            gt.log("show----",GameBase.RoomMsgTbl[2],GameBase.RoomMsgTbl[3])
            --self.CartrackGame:StopCarBao()
            self.gametap:showzhonjian(GameBase.RoomMsgTbl)
            local  function callback()
                for i =1, #self.BetSettleList do 
                    if self.BetSettleList[i] == 1 then
                        self:ShowWinAnimal(i,self.ShowPaiList[i].pai_list)
                        table.insert(self.WinAreaId,i)
                    end 
                end
                self.isfapai = true
            end
            self.FapaiqiGame:xiaofapai(self.ShowPaiList,callback)

            self.ShowPaidi = false
            self.GameBetOn = false
            self.ishiushuing = true
        end

    elseif self.GameStatus == 5 then
        --gt.log("GameStatus 5 = ",self.zhuijiTime,self.WaitTimeKaijiang)
        if self.CartrackGame.PlayActions == true then
--            for i =1, 10 do 
--                self.CartrackGame:PlayCarBao_Two(i)
--            end
            self.CartrackGame:SetLotteryNo(true)
            self.CartrackGame:StopCarBao()
        end

        self.DialogNodeText:setString("封盘\n等待下局开始...")
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        if self.ishiushuing then
            self.DialogNode:setVisible(false)
        else
            self.DialogNode:setVisible(true)
        end
        if self.ishiushuing and self.isfapai and  self.zhuijiTime < 18 then -- 只收一次
            self.WaitTimeKaijiang = self.WaitTimeKaijiang - 1
--            if self.zhuijiTime > 15 then
--                return
--            end 
            self.DialogNode:setVisible(true)
            for i=1,5 do
                self.WinAnima[i]:stopAllActions()
                self.WinAnima[i]:setVisible(false)
            end
            self.CartrackGame:StopCarBao()
            self.CartrackGame.KaiJiangBtn:setVisible(true)
            self.FapaiqiGame:shuofapai()
            self.ishiushuing = false
            self:HiuShuChip()
            --结算弹框出现时间
            if self.WinAreaId[1] then
                local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..self.WinAreaId[1])
                local bet_num = gt.seekNodeByName(bet_box, "bet_num")
                --print("bet_num:getString()============"..bet_num:getString())
                if bet_num:getString() == "0" then
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(1) ,cc.CallFunc:create(function ()
                        self:OnsetSettle()
                    end)))
                else
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(5.5) ,cc.CallFunc:create(function ()
                        self:OnsetSettle()
                    end)))
                end
            else
                self:runAction(cc.Sequence:create(cc.DelayTime:create(1) ,cc.CallFunc:create(function ()
                    self:OnsetSettle()
                end)))
            end

            self.isfapai = true
            self.WaitTimeKaijiang = 1
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_COIN_INFO_REQ,"{}")
            self.CartrackGame:GetLotteryResult()
        end
    end
    --self.DialogNode:setVisible(true)

--    --时间到。封盘  回收chip
--    if self.FenPanTime > 0 then
--        if self.FenPanTime == GameBase.RoomMsgTbl[7] then

--        end
--        self.DialogNode:setVisible(true)
--        self.FenPanTime = self.FenPanTime - 1 
--        return
--    else
--    end
end

function PlaySceneBJL:OnSetLotteryNo(lottery_no)
    self.CartrackGame:SetLotteryNo(true)
end

function PlaySceneBJL:OnBetSettleResp(order)
--    self.CartrackGame:StopCarBao()
--    self.gametap:showzhonjian(GameBase.RoomMsgTbl)
--    self.FapaiqiGame:xiaofapai(self.ShowPaiList)
end

function PlaySceneBJL:HiuShuChip()
    if self.chipTap == 0 then
    --清空！
    --gt.log("------HiuShuChip!")
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8) ,cc.CallFunc:create(function ()
            self.zhuijiTime = GameBase.RoomMsgTbl[6]
            self.FenPanTime = GameBase.RoomMsgTbl[7]
            self.Touzhu_num:setString(self.goldnum)
            self.chipLayer:removeAllChildren()
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
        if self.WinAreaId then
            for j = 1 ,#self.WinAreaId do
                --print("self.WinAreaId[j]................."..self.WinAreaId[j])
                if self.delindex ~= self.WinAreaId[j] then
                    local TChipSprite = self.chipLayer:getChildByTag(self.delindex*1000 + index)
                    --gt.log("chipTapnum==",self.delindex*1000 + index,self.chipTap,TChipSprite)
                    if TChipSprite then
                        local pos = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
	                    local moveTo = cc.MoveTo:create(1, pos)
                        local call1 = cc.CallFunc:create(function()
                            TChipSprite:removeFromParent()
                            self:OnsetSettle()
                        end)
                        local spa = cc.Sequence:create(moveTo, cc.DelayTime:create(4),call1)
	                    TChipSprite:stopAllActions()
	                    TChipSprite:runAction(spa)
                    end
                end
            end
        else
            local TChipSprite = self.chipLayer:getChildByTag(self.delindex*1000 + index)
            --gt.log("chipTapnum==",self.delindex*1000 + index,self.chipTap,TChipSprite)
            if TChipSprite then
                local pos = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
	            local moveTo = cc.MoveTo:create(1, pos)
                local call1 = cc.CallFunc:create(function()
                    TChipSprite:removeFromParent()
                    self:OnsetSettle()
                end)
                local spa = cc.Sequence:create(moveTo, cc.DelayTime:create(4),call1)
	            TChipSprite:stopAllActions()
	            TChipSprite:runAction(spa)
            end
        end

        if index == self.chipTap then
            self.delindex = self.delindex + 1
            --gt.log("------HiuShuChip!",self.delindex,GameBase.RoomMsgTbl[5])
            if self.delindex > GameBase.RoomMsgTbl[5] then
                --全部清空结束了，要给个方法
                    --判断是否有人赢
                    if self.WinAreaId[1] then
                        local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..self.WinAreaId[1])
                        local bet_num = gt.seekNodeByName(bet_box, "bet_num")
                        if bet_num:getString() == 0 then
                            self.chipTap = 0
                            self.delindex =  1
                            self.goldnum = 0
                        else
                            self:runAction(cc.Sequence:create(cc.DelayTime:create(2) ,cc.CallFunc:create(function ()
                                self:MoveWinChip()
                            end)))
                        end
                    else
                        self.chipTap = 0
                        self.delindex =  1
                        self.goldnum = 0
                        self.Touzhu_num:setString(self.goldnum)
                        self.chipLayer:removeAllChildren()
                        for i=1,GameBase.RoomMsgTbl[5] do
                            local str = string.format("bet_box_%d", i)
                            local bet_box = gt.seekNodeByName(self.game_bj, str)
                            local bet_num = gt.seekNodeByName(bet_box, "bet_num")
                            bet_num:setString(0)
                        end
                    end
            end   
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1) ,cc.CallFunc:create(function ()
                self:HiuShuChip()
            end)))
        end
    end
end
function PlaySceneBJL:MoveWinChip()
    if self.WinAreaId[1] then
        for i = 1 ,#self.WinAreaId do
            local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..self.WinAreaId[i])
            local bet_num = gt.seekNodeByName(bet_box, "bet_num")

            if self.bMove == true then
                self:Onaddchip(self.WinAreaId[i]-1,tonumber(bet_num:getString()),0)
            end
            if i == #self.WinAreaId then
                self.bMove = false
            end
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(2) ,cc.CallFunc:create(function ()
            self:HiuShuChipTwo()
        end)))
    else
        self.chipLayer:removeAllChildren()
        return
    end
end

function PlaySceneBJL:HiuShuChipTwo()
    
    for index = 0, self.chipTap do 
        
        local TChipSprite = self.chipLayer:getChildByTag(self.WinAreaId[1]*1000 + index)
        --gt.log("chipTapnum==",self.delindex*1000 + index,self.chipTap,TChipSprite)
        if TChipSprite then
            local pos = cc.p(self.recharge_but:getPositionX(), self.recharge_but:getPositionY())
	        local moveTo = cc.MoveTo:create(1, pos)
            local call1 = cc.CallFunc:create(function()
                TChipSprite:removeFromParent()
                self:OnsetSettle()
            end)
            local spa = cc.Sequence:create(moveTo, cc.DelayTime:create(0.5),call1)
	        TChipSprite:stopAllActions()
	        TChipSprite:runAction(spa)
        end
        

        if index == self.chipTap then
            self.WinAreaId[1] = self.WinAreaId[1] + 1
            --gt.log("------HiuShuChip!",self.delindex,GameBase.RoomMsgTbl[5])
            if self.WinAreaId[1] > GameBase.RoomMsgTbl[5] then
                --全部清空结束了，要给个方法
                    self.chipTap = 0
                    self.delindex =  1
                    self.goldnum = 0
                    self:HiuShuChip()
            end   
        end
    end
end

function PlaySceneBJL:onTouchBegan(touch, event)
    self.beganPos = self:convertToNodeSpace(touch:getLocation())
    if self.Touzhu_Layer:getPositionX() ==290 then
        self:PfbMove(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1) ,cc.CallFunc:create(function ()
            self.TouZhuMove = false
            end)))
    elseif self.Grade_Layer:getPositionX() ==295 then
        self:GradeLayerMove(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1) ,cc.CallFunc:create(function ()
            self.GradeMove = false
            end)))
    end
    return true
end
function PlaySceneBJL:onTouchMove(touch, event)
    self.MovePos = true
    return true
end
function PlaySceneBJL:onTouchEnd(touch, event)
    local animation = cc.RotateTo:create(0.2, 180)
    self.venue_pop:runAction(cc.RepeatForever:create(animation))
    self.EndPos = self:convertToNodeSpace(touch:getLocation())
    if self.MovePos then
        self.MovePos = false
        if self.EndPos.x - self.beganPos.x < -80 and self.Touzhu_Layer:getPositionX() == 870 and self.GradeMove == false and self.EndPos.y > 606 then
            self:PfbMove(false)
            self.TouZhuMove = true
        elseif self.EndPos.x - self.beganPos.x > 80 and self.Grade_Layer:getPositionX() == -305 and self.TouZhuMove == false and self.EndPos.y > 606 then
            self:GradeLayerMove(false)
            self.GradeMove = true
        end
    end
    return true
end
function PlaySceneBJL:PfbMove(bVisible)
    Utils.setClickEffect()   
    
    local pos
    if bVisible then
        pos= cc.p(self.Touzhu_Layer:getPositionX()+580, self.Touzhu_Layer:getPositionY())
        --gt.log("move+++++++")
    else
        pos= cc.p(self.Touzhu_Layer:getPositionX()-580, self.Touzhu_Layer:getPositionY())
        --gt.log("move-------")
        self:getBetDetailByRoom(os.date("%Y-%m-%d"))
    end
    local moveTo = cc.MoveTo:create(0.5, pos)
	local call = cc.CallFunc:create(function ()
        
	end)
	local spa = cc.Sequence:create(moveTo,cc.DelayTime:create(0.5), call)
    self.Touzhu_Layer:stopAllActions()
    self.Touzhu_Layer:runAction(spa)    
end

function PlaySceneBJL:GradeLayerMove(bVisible)
    Utils.setClickEffect()   
    
    local pos
    if bVisible then
        pos= cc.p(self.Grade_Layer:getPositionX()-600, self.Grade_Layer:getPositionY())
        --self.GradeListView:removeAllItems()
    else
        pos= cc.p(self.Grade_Layer:getPositionX()+600, self.Grade_Layer:getPositionY())
        --self:ShowGrade()
        self.GradeListView:removeAllItems()
        for i=1,#gt.BjlCutRoomList do
            if gt.BjlCutRoomList[i] ~= gt.EnterGameRoomId then
                self:SendBaccTableIdReq(gt.BjlCutRoomList[i],i)
                break
            end
        end
    end
    local moveTo = cc.MoveTo:create(0.5, pos)
	local call = cc.CallFunc:create(function ()
        
	end)
	local spa = cc.Sequence:create(moveTo,cc.DelayTime:create(0.5), call)
    self.Grade_Layer:stopAllActions()
    self.Grade_Layer:runAction(spa)    
end

--投注结算广播
function PlaySceneBJL:OnsetSettle()
    if #self.ranking < 1 then
        return
    end
    for i=1,5 do
        self.WinAnima[i]:stopAllActions()
        self.WinAnima[i]:setVisible(false)
    end

    local ProfitScene =  self:getChildByTag(1002)
    if ProfitScene then
        ProfitScene:UdatCellItem(self.earnings,self.ranking)
    else
        ProfitScene = require("app/views/Scene/ProfitScene"):create(self.earnings,self.ranking)
        self:addChild(ProfitScene,100,1002)
    end
end

--同步加币效果  区域：area_id,  要加的金币：chip,issend 是否是发送返回 0为否，
function PlaySceneBJL:Onaddchip(area_id,chip,issend)
    if chip > 0 then
        gt.soundEngine:playEffect("ChipsClick",false)
    end
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
            --gt.log("Onaddchip=====",chip1,chipNum,self.SprIndex[6-i])  
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

function PlaySceneBJL:MoveChip(area_id,chipid,issend)
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
    --print("area_id=====",area_id,bet_box:getPositionX(),bet_box:getPositionY())
    local area_idS = area_id
    if self.ClickArea < 3 and area_idS < 3 then
        pos = cc.p(bet_box:getPositionX()+ math.random(-120,120), bet_box:getPositionY()+ math.random(-20,100))
    else
        pos = cc.p(bet_box:getPositionX()+ math.random(-60,60), bet_box:getPositionY()+ math.random(-30,15))
    end
    
	local moveTo = cc.MoveTo:create(0.5, pos)
    local FadeTo = cc.FadeTo:create(0.5,255)
	local call = cc.CallFunc:create(function ()
        if issend > 0 then
            self.goldnum = self.goldnum + GameBase.chiptap[self.SprIndex[self.chipma]]
            self.Touzhu_num:setString(self.goldnum)
            local MyCoin = string.format("%.01f", gt.playerData.coin/10000- self.goldnum)
            --self.goldNode:setString(MyCoin)
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
    
    --self.rootNode:addChild(chipSprite)
    self.chipLayer:addChild(chipSprite)
end
function PlaySceneBJL:OnShowaddchip(area_id,chipid,isfull)
    local bet_box = gt.seekNodeByName(self.rootNode, "bet_box_"..(area_id+1))
    local bet_num = gt.seekNodeByName(bet_box, "bet_num")
    bet_num:setString(tonumber(chipid))
    self.room_bet[area_id + 1] = chipid * 10000
end

function PlaySceneBJL:OnSetTouzhuchip(chipid)
    self.Touzhu_num:setString(chipid)
end


--显示赢动画
function PlaySceneBJL:ShowWinAnimal(AreaWin,pai_list)
    --gt.log("ShowWinAnimal pai_list = ",pai_list)
    if pai_list then 
        local showpai = gt.string_split(pai_list,",")
        local diangshu = 0;
        for j=1,#showpai do 
        --gt.log("ShowWinAnimal = ",showpai[j])
        local showpai = gt.string_split(showpai[j],"-")
        diangshu = showpai[1] % 16 + diangshu
        end
        diangshu = diangshu % 10 

        if AreaWin == 1 then
            self.TxtXWin_num:setString("闲"..diangshu.."点")
            self.TxtXWin_num:setVisible(true)
        else
            --庄点数
            self.TxtZWin_num:setString("庄"..diangshu.."点")
            self.TxtZWin_num:setVisible(true)
        end
    end
    self.WinAnima[AreaWin]:setVisible(true)
    --gt.log("ShowWinAnimal===",AreaWin)
    self.WinAnima[AreaWin]:setScale(1)
    --paiSpZ:setRotation(360)
    self.WinAnima[AreaWin]:setOpacity(255)

    local ScaleTo2 = cc.ScaleTo:create(2,3,3)
    local FadeTo2 = cc.FadeTo:create(2, 50)
    local spa2 = cc.Spawn:create(ScaleTo2,FadeTo2)
    local call = cc.CallFunc:create(function ()
        self:ShowWinAnimal(AreaWin)
        self.WaitTimeKaijiang = 1
    end)
    self.WinAnima[AreaWin]:runAction(cc.Sequence:create(spa2,call))
end

-- 断线重连,初始化数据
function PlaySceneBJL:reLogin()
    -- 进游戏桌子
    self.loadingtime = 0
    gt.isshowlading = true
    --GameBase:initdata()
    gt.socketClient:setIsStartGame(true)
    
    local playScene = require("app/views/Scene/PlaySceneBJL"):create(self.roomInfo,GameBase.RoomMsgTbl[4],gt.Gameroomid)
    cc.Director:getInstance():replaceScene(playScene)

    --gt.log("reLogin===EnterGameRoomId ",gt.EnterGameRoomId)
    local cmsg = cmd_node_pb.CEnterGameReq()
    cmsg.node_id = gt.EnterGameRoomId
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_ENTER_GAME_REQ,msgData)
    --要启动联网取数据！
    --gt.showLoadingTips()

end

msgGrade = {
    {},
    {},
    {},
}
function PlaySceneBJL:ShowGrade()
    for i, cellData in ipairs(msgGrade) do
        local GameItem = self:createGradeItem(i, cellData)
		self.GradeListView:pushBackCustomItem(GameItem)
	end
end
function PlaySceneBJL:ShowGradeList(cellData)
    local GameItem = self:createGradeItem(self.Gradeidx, cellData)
	self.GradeListView:pushBackCustomItem(GameItem)
    self.Gradeidx = self.Gradeidx + 1
end

function PlaySceneBJL:createGradeItem(tag, cellData)
	local RangeNode = cc.CSLoader:createNode("GradeNode_list.csb")
    
    local TxtTime = gt.seekNodeByName(RangeNode,"TxtTime")
    --TxtTime:setString(cellData.DateTime)
    local TxtType = gt.seekNodeByName(RangeNode,"TxtType")
    TxtType:setString(gt.BjlRoomList[cellData.index].node_name)
    local TexPeriod = gt.seekNodeByName(RangeNode,"TexPeriod")
    TexPeriod:setString(cellData.boots_num.."靴")

    local Text_2 = gt.seekNodeByName(RangeNode,"Text_2")
    local person_upper = gt.BjlRoomList[cellData.index].person_upper_limit
    if person_upper >= 1000 then 
        person_upper = person_upper / 1000 .."k"
    end
    Text_2:setString(person_upper)

    local Text_1 = gt.seekNodeByName(RangeNode,"Text_1")
    local pot_upper = gt.BjlRoomList[cellData.index].pot_upper_limit
    if pot_upper >= 1000 then 
    pot_upper = pot_upper / 1000 .."k"
    end
    Text_1:setString(pot_upper)

    local cellSize = RangeNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RangeNode)
	cellItem:addClickEventListener(handler(self, function ()
         -- 进游戏桌子
        self.loadingtime = 0
        gt.isshowlading = true
        --GameBase:initdata()
        gt.socketClient:setIsStartGame(true)
        for i=1, #gt.gamelistTap do 
            if self.roomInfo.lottery_id == gt.gamelistTap[i].lottery_id then
                local playScene = require("app/views/Scene/PlaySceneBJL"):create(gt.gamelistTap[i],gt.BjlRoomList[cellData.index].node_name,gt.Gameroomid)
                cc.Director:getInstance():replaceScene(playScene)
                break
            end
        end
        gt.log("GradeItem===node_id:",gt.BjlRoomList[cellData.index].node_id,gt.Gameroomid,cellData.index)

        gt.EnterGameRoomId = gt.BjlRoomList[cellData.index].node_id
        local cmsg = cmd_node_pb.CEnterGameReq()
        cmsg.node_id = gt.EnterGameRoomId
        
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_ENTER_GAME_REQ,msgData)       
    end))

    self:showluda(RangeNode,cellData.balance_list)
	return cellItem
end

Dgradetu = {"gradblue.png","gradred.png","gradgreen.png","bluedi.png","reddi.png"}
function PlaySceneBJL:showluda(RangeNode,balance)
        local GradeNode = RangeNode
        local temp_j = 0
        local temp_j1 = 0
        local Iszhuang = 0
        local temp_i = 0
        local Dt1 = 0 
        local Dt2 = 0 
        local Dt3 = 0
        local MaxDt = 0;
        local TempMaxDt = 0;
        local MaxLen = 5
        local luidNum = {0,0,0,0,0}
        local xiaoluilist = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        self.dayanlunum = 0
        self.xiaolunum = 0
        self.gadzadnum = 0

        local daluPanel = gt.seekNodeByName(GradeNode, "daluPanel")
        daluPanel:removeAllChildren()

    for i=1,#balance do
        --gt.log("===round_order:"..balance[i].round_order..";issue = "..balance[i].issue..";balance="..balance[i].balance)         
        local balancestr = gt.string_split(balance[i].balance,",")
        for j = 1, #balancestr  do
        --gt.log("balance_1===",balancestr[j])
            if balancestr[j] ~= "" and balancestr[j] then
                local balance_1 = gt.string_split(balancestr[j],"-");
                --local num =  string.sub(cellData.balance,i,i);
                local t1,t2 = math.modf((i-1)/6)
                --gt.log("showludaPos=",18 + 35*(t1),18 + (t2*6)*35,balance_1[2],j)
                if balance_1[2] == "1" then
                    luidNum[j] = luidNum[j] + 1
                    local DpaiSp = cc.Sprite:create("res/gradetu/"..Dgradetu[j])

                    if i > 1 and temp_i ~= i then
                        --gt.log("showludaPos=",i,j,temp_i,temp_j)
                        temp_i = i
                        if temp_j == j or j == 3 or ( temp_j1 == 3 and temp_j == 0) then  
                            Dt2 = Dt2 + 1
                            if Dt2 > MaxLen then 
                                Dt2 = MaxLen
                                Dt1 = Dt1 + 1                          
                                TempMaxDt = TempMaxDt + 1
                                if MaxDt < TempMaxDt then
                                    MaxDt = TempMaxDt
                                end
                            end
                        else
                            if Dt2 > MaxLen then
                                MaxLen = MaxLen -1
                            else
                                MaxLen = 5
                            end
                            if Dt2 == MaxLen and MaxDt > 0 then 
                                MaxDt = MaxDt - 1
                                if MaxDt < 0 then
                                    MaxDt = 0
                                end
                                Dt1 = Dt1 - MaxDt
                            else
                                Dt1 = Dt1 + 1
                            end
                            TempMaxDt = 0
                            Dt2 = 0
                            Dt3 = Dt3 + 1
                        end
                    end
                    if j < 4 then
--                        local paiSp = cc.Sprite:create("res/gradetu/"..gradetu[j])
--                        paiSp:setPosition(cc.p(25 + 62*(t1),336 - (t2*6)*62)) 
--                        paiSp:setScale(1.5)
--                        self.zhupanPanel:addChild(paiSp)
                        --gt.log("Dt1;Dt2 =",Dt1,Dt2)
                        if j ~= 3 then 
                            xiaoluilist[Dt3+1] = xiaoluilist[Dt3+1] +1
                            --小路规则显示
                            --self.showxiaolui(self.xiaoluilist,j==temp_j)
                        end
                        if temp_j ~= j and j ~= 3 then
                            temp_j = j
                            if j == 1 then
                                Iszhuang = 0
                            else
                                Iszhuang = 1
                            end
                        end
                        temp_j1 = j
                    end
                    DpaiSp:setPosition(cc.p(6 + 17.5*(Dt1),93 - (Dt2)*17))
                    DpaiSp:setScale(0.6)
                    daluPanel:addChild(DpaiSp)
                end
            end
        end       
    end
    --dump(xiaoluilist, "xiaoluilist")
    for i=1,5 do
        local shownum = luidNum[i]
        if i==1 then 
            shownum = luidNum[2]
        elseif i==2 then
            shownum = luidNum[1]
        end
--        if i==4 then 
--            shownum = luidNum[5]
--        elseif i==5 then
--            shownum = luidNum[4]
--        end
        local luidNum = gt.seekNodeByName(GradeNode, "Txt_luidNum"..i)
        luidNum:setString(shownum)
    end
end

--取投注明细
--date 日期  格式:2017-12-05
--function PlaySceneBJL:getBetDetailByRoom()
--    local cmsg = cmd_lobby_pb.CGetUserBetDetailReq()
--    --cmsg.uid = gt.playerData.uid
--    cmsg.detail_id = -1
--    cmsg.detail_num = 50
--    cmsg.date_time = os.date("%Y-%m-%d")
--    local msgData = cmsg:SerializeToString()
--    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_REQ,msgData)        
--end

return PlaySceneBJL
