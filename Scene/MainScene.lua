
local gt = cc.exports.gt
local Utils = cc.exports.Utils
require("app.protocols.cmd_node_pb")

--local MainScene = class("MainScene", function()
--	return cc.Scene:create()
--end)

local GameBase = require("app/utils/GameBase")
local MainScene = class("MainScene", GameBase)

MainScene.ZOrder = {
	HISTORY_RECORD			= 5,
	CREATE_ROOM				= 6,
	JOIN_ROOM				= 7,
	PLAYER_INFO_TIPS		= 9,
	TASK_INVITE				= 15,
}
DecdetaiList  = {
    {DateTime = "150270 3893",method = "三公三公三公",money = 60 ,shuying = 20},
    }

function MainScene:ctor(isNewPlayer, isRoomCreater, roomID, numberMark)

    GameBase:ctor()
	self.request = "Empty"

 	--是否开启比赛场
 	self.isOpenSport = false

    self.gameTimelist = {}

    self.DecdetailIsup = true   --投注详情是否出现

	-- 反馈数
 	if not gt.isNumberMark then
 		gt.isNumberMark = 0
 	end
 	gt.isNumberMark = gt.isNumberMark + (numberMark or 0)

	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
		-- 初始化 GameIAP
		if Utils.checkVersion(1, 0, 15) then
			-- gt.gameIAP = require("app/views/GameIAP"):create()
		end
		if Utils.checkVersion(1, 0, 17) then
			-- local ok, ret = self.luaBridge.callStaticMethod("AppController", "getEquipmentId")
			-- gt.log("IOS设备ID", ret)	
		end
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")

		-- local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getLocalMacAddress")
		if Utils.checkVersion(1, 0, 17) then
			-- local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getLocalMacAddress", nil, "()Ljava/lang/String;")
			-- gt.log("Android设备ID", ret)			
		end		
	end

    gt.isshowlading = true
	
	self.isRoomCreater = isRoomCreater
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("lobby_main.csb")
    csbNode:setName("MainScene")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
    
	local playerData = gt.playerData

    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")
    self.lobby_bj = lobby_bj

    local desk_bj = gt.seekNodeByName(csbNode, "desk_bj")
    self.desk_bj = desk_bj

    local Account_name = gt.seekNodeByName(desk_bj, "Account_name")
    Account_name:setString(playerData.nickname)
    self.Account_name = Account_name
    --退出帐号
    local ExitloginBtn = gt.seekNodeByName(desk_bj, "Exitlogin")
	ExitloginBtn:addClickEventListener(function()
         --gt.socketClient:close()
         cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
         gt.soundEngine:stopEffect(gt.playEngineStr)
		 local LoginScene = require("app/views/Scene/LoginScene"):create(false)
		 cc.Director:getInstance():replaceScene(LoginScene)    
	end)

    local AddCardSet = require("app/views/Scene/AddCardSet"):create()
	--cc.Director:getInstance():replaceScene(AddCardSet)   
    self:addChild(AddCardSet)
    AddCardSet:setVisible(false)
    self.MingxiiListView = gt.seekNodeByName(desk_bj, "MingxiiListView")
    self.MingxiiListView:setSwallowTouches(false)
    --self:initDetail()
    --卡号设置
    local CardStrBtn = gt.seekNodeByName(desk_bj, "CardStr")
	CardStrBtn:addClickEventListener(function()
        if gt.playerData.playerType == 4 then 
            function OKcallfan(args)
    		    local LoginScene = require("app/views/Scene/LoginScene"):create(false,true)
		        cc.Director:getInstance():replaceScene(LoginScene)  
            end
            require("app/views/UI/NoticeTips"):create("提示","为了体验游戏完整功能，请您先升级为正式用户！", OKcallfan, nil, false,"res/res/BegainScene/PhoneREbPresstn.png")
        else 
            AddCardSet:setVisible(true)
            AddCardSet:setCardVisible(true)
        end
	end)
    
    --更多投注
    local detail_moreBtn = gt.seekNodeByName(desk_bj, "detail_moreBtn")
    --detail_moreBtn:setVisible(false)
	detail_moreBtn:addClickEventListener(function()
        local nTime = os.time()-86400
        self:getBetDetailByRoom(os.date('%Y',nTime).."-"..os.date('%m',nTime).."-"..os.date('%d',nTime))
        local DecdetailmoreScene = require("app/views/Scene/DecdetailmoreScene"):create()
        self:addChild(DecdetailmoreScene) 
	end)

    --base64 test
	-- 玩家信息
	-- 昵称

	local nicknameLabel = gt.seekNodeByName(lobby_bj, "user_name")
	nicknameLabel:setString(playerData.nickname)
    self.nicknameLabel = nicknameLabel
    -- 修改昵称
    if gt.playerData.is_first == 1 then
        self.ChangeNameScence = require("app/views/Scene/ChangeNameScence"):create()
        self:addChild(self.ChangeNameScence)
    end
	-- 点击头像显示信息
--    local Decdetail = require("app/views/UI/TouzhuDetail"):create()
--    self:addChild(Decdetail)
    --Decdetail:setVisible(false)
    
--	local headFrameBtn = gt.seekNodeByName(lobby_bj, "Button_Decdetail")
--	headFrameBtn:addClickEventListener(function()
--        --Decdetail:setVisible(true)
--        --Decdetail:DecdetailMove()
----		if gt.isShoppingShow then
----			local personalCenter = require("app/views/PersonalCenter"):create()
----			self:addChild(personalCenter, MainScene.ZOrder.HISTORY_RECORD)
----		else
----			local playerInfoTips = require("app/views/PlayerInfoTips"):create(gt.playerData)
----			self:addChild(playerInfoTips, MainScene.ZOrder.PLAYER_INFO_TIPS)			
----		end
--	end)

    --RechargeChose:setVisible(false)
	-- 金币
	local MoneyBg_1 = gt.seekNodeByName(lobby_bj, "MoneyBg_1")
    local AddMoneyBtn = gt.seekNodeByName(MoneyBg_1, "Button_2")
	AddMoneyBtn:addClickEventListener(function()
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
	end)
    --金币数
    self.goldNode = gt.seekNodeByName(lobby_bj, "money_num")
	--ttf_eight:setString(playerData.coin)
    self.goldNode:setString(string.format("%.01f", playerData.coin/10000))
     
    
    cc.UserDefault:getInstance():setStringForKey("ttf", playerData.coin)
   -- cc.UserDefault:getInstance():setStringForKey("diamond",playerData.roomCardsCount[4] )

	-- 跑马灯
	local marqueeNode = gt.seekNodeByName(lobby_bj, "Node_marquee")
	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)
    gt.marqueeMsgTemp = "内部测试201804231800_现网 ！"  --
	self.marqueeMsg = marqueeMsg
	if gt.marqueeMsgTemp then
		self.marqueeMsg:showMsg(gt.marqueeMsgTemp)
		-- gt.marqueeMsgTemp = nil
	end

	-- 充值中心
	local RechBtn = gt.seekNodeByName(lobby_bj, "recharge")
	gt.addBtnPressedListener(RechBtn, function()
--		local RechargeChose = require("app/views/Scene/RechargeChose"):create()
--		 cc.Director:getInstance():replaceScene(RechargeChose) 
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
	end)

	-- 提现
	local DepositBtn = gt.seekNodeByName(lobby_bj, "deposit")
	gt.addBtnPressedListener(DepositBtn, function()
        Utils.setClickEffect()
        if gt.playerData.playerType == 4 then 
		    function OKcallfan(args)
    		    local LoginScene = require("app/views/Scene/LoginScene"):create(false,true)
		        cc.Director:getInstance():replaceScene(LoginScene) 
            end
            require("app/views/UI/NoticeTips"):create("提示","为了体验游戏完整功能，请您先升级为正式用户！", OKcallfan, nil, false,"res/res/BegainScene/PhoneREbPresstn.png")
        else
		    local WithdrawalScene = require("app/views/Scene/WithdrawalScene"):create()
		    cc.Director:getInstance():replaceScene(WithdrawalScene)    
        end 
	end)

	-- 消息
	local helpBtn = gt.seekNodeByName(lobby_bj, "msger")
	gt.addBtnPressedListener(helpBtn, function()
        Utils.setClickEffect()
		--local helpLayer = require("app/views/HelpScene"):create()
		--self:addChild(helpLayer, 8)
		local SystemMsg = require("app/views/Scene/SystemMsg"):create()
		cc.Director:getInstance():replaceScene(SystemMsg)  
	end)

    -- 联系客服
	local serviceBtn = gt.seekNodeByName(lobby_bj, "service")
	gt.addBtnPressedListener(serviceBtn, function()
        Utils.setClickEffect()
		local FeedBackScene = require("app/views/Scene/FeedBackScene"):create()
        self:addChild(FeedBackScene)
	end)

	-- 小游戏
	local othergameBtn = gt.seekNodeByName(lobby_bj, "othergame")
	gt.addBtnPressedListener(othergameBtn, function()
        Utils.setClickEffect()
--		local LittleGameScene = require("app/views/Scene/LittleGameScene"):create()
--		 cc.Director:getInstance():replaceScene(LittleGameScene)     
        require("app/views/UI/NoticeTips"):create("提示","敬请期待！", nil, nil, true)
	end)

    --主游戏
    for i = 1 , 4 do 
        local MaingameBtn = gt.seekNodeByName(lobby_bj, "game_bj"..i)
        MaingameBtn:setTag(1000+i)
    end

    self.cellNodeItemS = {}

    self.GameListVw = gt.seekNodeByName(self.rootNode, "ListView_content")
    --self:initGameLater()

    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PERSON_MESSAGE_NOTIFY_REQ,{})

    require("app/utils/PriFrame"):create()

    --获取主节点请求
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_MAIN_NODE_REQ,"{}")
    --获取排行榜(上行) 空
    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_RANK_LIST_REQ,"{}")
	-- 获取排行榜(下行)
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_RANK_LIST_RESP, self, self.onGetRankListResp)
	-- 注册消息回调
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_MAIN_NODE_RESP, self, self.onGetMainNodeResp)
    -- 获取用户投注详情
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_RESP, self, self.onGetUserBetDetailResp)
    --获取修改昵称应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_CHANGCE_USER_NICKNAME_RESP, self, self.onGetNameChangeResp)
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_UPDATE_LOTTERY_NO, self, self.onUpdateLotteryResp)		
    --获取线下充值说明信息请求
    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_OFFLINE_RECHARGE_REQ,"{}") 
    --获取支付方式列表应答
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PAYWAY_RESP, self, self.onGetPaywayResp)
    --获取线下充值说明信息应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_OFFLINE_RECHARGE_RESP, self, self.onOffkineRechargeResp)
    --获取线下充值说明信息应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PERSON_MESSAGE_NOTIFY_RESP, self, self.onGetPersonMsgNotifyResp)
	--20161122
	self.serverList = {}
    self.loadingtime = 0
    self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
	self:update(300)
	-- self:showMoonFreeCard()
    self:getBetDetailByRoom(os.date("%Y-%m-%d"))
end

function MainScene:Setcoin(coin)
    self.goldNode:setString(string.format("%.01f", coin/10000))
end

function MainScene:getBetDetailByRoom(date_time)
--	local timestamp = os.time()
--	local appId = "1970010100000000"
--    local uid = gt.playerData.uid
--    local date=os.date("%Y-%m-%d")
--    --local date = self.lottery_id
--	local catStr = string.format("appId=%s&date=%s&timestamp=%s&uid=%s&key=NKZYM92tYf1OyUpoPN8Zt1UuzUjhvZ0P",appId,date,timestamp,uid)
--    gt.log("getBetDetailByRoom",catStr)
--    local sign = md5(catStr)
--	local xhr = cc.XMLHttpRequest:new()
--	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
--	local refreshTokenURL = string.format(gt.LotteryResult .."/lottery/getBetDetailByRoom")   
--    xhr:setRequestHeader("Content-Type", "application/json")
--    xhr:open("POST", refreshTokenURL)

--    local retTable = {};    --最终产生json的表
--    retTable["appId"]=appId
--    retTable["timestamp"]=timestamp
--    retTable["uid"]=uid
--    retTable["sign"]=sign
--    retTable["date"]=date
--    local sendJson = require("json").encode(retTable)

--        local function onResp()
--		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
--        	local response = xhr.response
--            --gt.log("response--",response)
--			local respJson = require("json").decode(response)
--			--dump(respJson)
--            if respJson.code == 10000 then
--                self:ShowData(respJson.data)
--            end
--            -- 去掉转圈
--		    gt.removeLoadingTips()
--        elseif xhr.readyState == 1 and xhr.status == 0 then
--            gt.log("读取历史失败！")
--        end
--        xhr:unregisterScriptHandler()
--    end

--    xhr:registerScriptHandler(onResp)
--	xhr:send(sendJson)

    local cmsg = cmd_lobby_pb.CGetUserBetDetailReq()
    --cmsg.uid = gt.playerData.uid
    cmsg.detail_id = -1
    cmsg.detail_num = 50
    --cmsg.date_time = os.date("%Y-%m-%d")
    cmsg.date_time = date_time
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_REQ,msgData)      
end


function MainScene:onGetPersonMsgNotifyResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetSystemNotifyResp()
    stResp:ParseFromString(buf)
    gt.log("onGetPersonMsgNotifyResp code:",stResp.code,stResp.notify_list.title,stResp.notify_list.content)

    if stResp.code == 0 then

    end
end
gt.OfflineThirdPayTypeS = {}
gt.bank_infoS = {}
function MainScene:onOffkineRechargeResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetOfflineRechargeResp()
    stResp:ParseFromString(buf)
    gt.log("onOffkineRechargeResp code:",stResp.code,#stResp.third_pay_info,#stResp.bank_info)

    if stResp.code == 0 then
    --local ThirdPay = cmd_lobby_pb.OfflineThirdPayType()
    --ThirdPay:ParseFromString(stResp.third_pay_info)
    gt.OfflineThirdPayTypeS = {}
    gt.bank_infoS = {}    
        for i = 1, #stResp.third_pay_info do
            local OfflineThirdPayType = {}
            OfflineThirdPayType.pay_type = stResp.third_pay_info[i].pay_type
            OfflineThirdPayType.pay_name = stResp.third_pay_info[i].pay_name
            OfflineThirdPayType.pay_account = stResp.third_pay_info[i].pay_account
            gt.log("第三方微信:",OfflineThirdPayType.pay_type,OfflineThirdPayType.pay_name,OfflineThirdPayType.pay_account)
            table.insert(gt.OfflineThirdPayTypeS,OfflineThirdPayType)
        end

        for i = 1, #stResp.bank_info do
            local bank_info = {}
            bank_info.account_id = stResp.bank_info[i].account_id
            bank_info.bank_of_deposit = stResp.bank_info[i].bank_of_deposit
            bank_info.bank_no = stResp.bank_info[i].bank_no
            bank_info.bank_branch_name = stResp.bank_info[i].bank_branch_name
            bank_info.payee_name = stResp.bank_info[i].payee_name
            gt.log("银行卡:",bank_info.account_id,bank_info.bank_of_deposit,bank_info.bank_no,bank_info.bank_branch_name,bank_info.payee_name)
            table.insert(gt.bank_infoS,bank_info)
        end
        
        --代充值
    end
    --银行卡线下充值
    --gt.log("BankCard =  ",BankCard.account_id,BankCard.bank_of_deposit,BankCard.bank_no,BankCard.bank_branch_name,BankCard.payee_name)
end
gt.RangelistTuhaoDay = {}
gt.RangelistTuhaoDayWeek = {}
gt.RangelistTuhaoDayMonth = {}
gt.RangelistLaomoDay = {}
gt.RangelistLaomoWeek = {}
gt.RangelistLaomoMonth = {}
gt.RangelistMvpDay = {}
gt.RangelistMvpWeek = {}
gt.RangelistMvpMonth = {}

function MainScene:onGetRankListResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetRankListResp()
    stResp:ParseFromString(buf)
    if stResp.code == 0 then
        --self:ShowData(stResp.bet_detail_list)
        --dump(stResp.tyranklistcountinfo, "tyranklistcountinfo")
        --dump(stResp.mvpranklistcountinfo, "mvpranklistcountinfo")
        --dump(stResp.modelranklistcontinfo, "modelranklistcontinfo")
        --gt.log("RankList===",#stResp.tyranklistcountinfo,#stResp.modelranklistcontinfo,#stResp.mvpranklistcountinfo) 
        for i = 1 , 10 do 
            if stResp.tyranklistcountinfo.daytyranklistinfo[i] then
                if stResp.tyranklistcountinfo.daytyranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistTuhaoDay[i] = stResp.tyranklistcountinfo.daytyranklistinfo[i]     --土豪日
                end
            end
            if stResp.tyranklistcountinfo.weektyranklistinfo[i] then
                if stResp.tyranklistcountinfo.weektyranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistTuhaoDayWeek[i] = stResp.tyranklistcountinfo.weektyranklistinfo[i]     --土豪周
                end
            end
            if stResp.tyranklistcountinfo.mothtyranklistinfo[i] then
                if stResp.tyranklistcountinfo.mothtyranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistTuhaoDayMonth[i] = stResp.tyranklistcountinfo.mothtyranklistinfo[i]     --土豪月
                end
            end
            if stResp.modelranklistcontinfo.daymodelranklistinfo[i] then
                if stResp.modelranklistcontinfo.daymodelranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistLaomoDay[i] = stResp.modelranklistcontinfo.daymodelranklistinfo[i]     --劳模日
                end
            end
            if stResp.modelranklistcontinfo.weekmodelranklistinfo[i] then
                if stResp.modelranklistcontinfo.weekmodelranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistLaomoWeek[i] = stResp.modelranklistcontinfo.weekmodelranklistinfo[i]     --劳模周
                end
            end
            if stResp.modelranklistcontinfo.mothmodelranklistinfo[i] then
                if stResp.modelranklistcontinfo.mothmodelranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistLaomoMonth[i] = stResp.modelranklistcontinfo.mothmodelranklistinfo[i]     --劳模月
                end
            end
            if stResp.mvpranklistcountinfo.daymvpranklistinfo[i] then
                if stResp.mvpranklistcountinfo.daymvpranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistMvpDay[i] = stResp.mvpranklistcountinfo.daymvpranklistinfo[i]     --MVP日
                end
            end
            if stResp.mvpranklistcountinfo.weekmvpranklistinfo[i] then
                if stResp.mvpranklistcountinfo.weekmvpranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistMvpWeek[i] = stResp.mvpranklistcountinfo.weekmvpranklistinfo[i]     --MVP周
                end
            end
            if stResp.mvpranklistcountinfo.mothmvpranklistinfo[i] then
                if stResp.mvpranklistcountinfo.mothmvpranklistinfo[i].rank_order ~= 0 then
                    gt.RangelistMvpMonth[i] = stResp.mvpranklistcountinfo.mothmvpranklistinfo[i]     --MVP月
                end
            end
        end
    end
end

--function MainScene:ShowData(loss_value,msgdata)
--    local yinkui_Num = gt.seekNodeByName(self.desk_bj, "yinkui_Num")
--    yinkui_Num:setString(string.format("%.01f", loss_value/10000))
--    local BjlareaName = {"闲(","庄(","和(","闲对(","庄对("}
--    if nil ~= msgdata and type(msgdata) == "table" then
--        for i=1, #msgdata do
--            local lottary={} 
--            lottary.DateTime = msgdata[i].create_time
--            lottary.money = msgdata[i].refund
--            local bet_chips = msgdata[i].area_id.."门(".. msgdata[i].bet_chips/10000 .. ")"
--            local play_method = ""
--            if msgdata[i].play_method == 1 then
--            play_method = "牌九"
--            elseif msgdata[i].play_method == 2 then 
--            play_method = "牛牛"
--            elseif msgdata[i].play_method == 3 then 
--            play_method = "三公"
--            elseif msgdata[i].play_method == 4 then 
--            play_method = "百家乐"
--            bet_chips = BjlareaName[msgdata[i].area_id].. msgdata[i].bet_chips/10000 .. ")"
--            elseif msgdata[i].play_method == 5 then 
--            play_method = "单张"
--            elseif msgdata[i].play_method == 6 then 
--            play_method = "番摊"
--            end

--            lottary.lottery_id = msgdata[i].lottery_id
--            lottary.money = bet_chips
--            lottary.DateTime = os.date("%H:%M:%S",msgdata[i].create_time) --msgdata[i].create_time
--            lottary.method = play_method
--            lottary.table_name = msgdata[i].table_name
--            if msgdata[i].exchange_type == 0 then
--            lottary.shuying = "未结算"
--            else
--            lottary.shuying = string.format(string.format("%.01f", msgdata[i].balance_chips/10000)) --   msgdata[i].settle_chips/10000
--            end
--            --gt.log("投注明细===",msgdata[i].table_id,msgdata[i].play_method,msgdata[i].settle_chips,msgdata[i].area_id,msgdata[i].bet_chips) 


--		    local GameItem = self:createDetailItem(i, lottary)
--		    self.MingxiiListView:pushBackCustomItem(GameItem)
--	    end
--    end
--end

function MainScene:onGetUserDayProfitResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetUserDayProfitAndLossResp()
    stResp:ParseFromString(buf)
    if stResp.code == 0 then
     local yinkui_Num = gt.seekNodeByName(self.desk_bj, "yinkui_Num")
     gt.playerData.profitValue = string.format("%.01f", stResp.profit_loss_value/10000)
     yinkui_Num:setString(gt.playerData.profitValue)
    end
end


function MainScene:onGetMainNodeResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_node_pb.SGetMainNodeResp()
    stResp:ParseFromString(buf)
        --gt.log("onGetMainNodeResp node_list:"..#stResp.node_list)
        --local node_listS = {}
        for i = 1, #stResp.node_list do
--            local node_list = {}
--            node_list.node_id = stResp.node_list[i].node_id
--            node_list.lottery_id = stResp.node_list[i].lottery_id
--            node_list.issue = stResp.node_list[i].issue
--            node_list.lottery_no = stResp.node_list[i].lottery_no
--            node_list.open_time = stResp.node_list[i].bet_time

            gt.gamelistTap[i].node_id = stResp.node_list[i].node_id
            gt.gamelistTap[i].issue = stResp.node_list[i].issue
            --gt.gamelistTap[i].lottery_no = string.gsub(stResp.node_list[i].lottery_no, ",", "") 
            gt.gamelistTap[i].lottery_no = stResp.node_list[i].lottery_no
            local open_time = stResp.node_list[i].bet_time
            --if open_time > 10 then
                gt.gamelistTap[i].open_time = open_time
            --end
            gt.gamelistTap[i].lottery_id = stResp.node_list[i].lottery_id
            gt.gamelistTap[i].status = stResp.node_list[i].status
            --print("gt.gamelistTap[i].status================="..gt.gamelistTap[i].lottery_id..gt.gamelistTap[i].status)
            gt.gamelistTap[i].bj = string.format("game_bj%d.png", stResp.node_list[i].lottery_id)

            --gt.log("node_list:",node_list.node_id,node_list.lottery_id,node_list.issue,node_list.lottery_no,node_list.open_time,stResp.node_list[i].status)
            --table.insert(node_listS,node_list)

            self:createGameItem(i, gt.gamelistTap[i])
			gt.isshowlading = false
            gt.removeLoadingTips()
        end
end

--game层显示，期数
function MainScene:UpdateGameItem(tag, cellData)
    gt.log("UpdateGameItem== ",tag,cellData.lottery_id)
--    local cellItem = self.GameListVw:getItem(tag-1)
--    if cellItem then
--        local cellNode =  cellItem:getChildByTag(cellData.lottery_id)
--        local cellNode =  cellItem:getChildByName("cellNode")
--        local qishu =  cellItem:getChildByName("qishu")
--        qishu:setString("最新开奖"..cellData.issue.."期")
--    end
    for i=1,#self.cellNodeItemS do 
        if self.cellNodeItemS[i].lottery_id == cellData.lottery_id then
            local cellNode = self.cellNodeItemS[i].cellNode;
            local qishu = gt.seekNodeByName(cellNode, "qishu")
	        qishu:setString("最新开奖"..cellData.issue.."期")
            self:Showlottery(cellNode,cellData.lottery_no)
            self.cellNodeItemS[i].open_time = cellData.open_time
            break
        end
    end
end

function MainScene:createGameItem(tag, cellData)
	local cellNode = gt.seekNodeByName(self.lobby_bj, "game_bj"..cellData.lottery_id)
    --cellNode:setName("cellNode")


	-- 期数
	local qishu = gt.seekNodeByName(cellNode, "qishu")
	--local qishu = os.date("*t", cellData.qishu)
    --qishu:setText("最新开奖"..cellData.qishu.."期")
    qishu:setName("qishu")
	qishu:setString("最新开奖"..cellData.issue.."期")

    self:Showlottery(cellNode,cellData.lottery_no)

    -- 时间
    local Timelist = {};
	local Time_bj = gt.seekNodeByName(cellNode, "Time_bj")
    Time_bj:setTag(100 + cellData.lottery_id)
    Timelist.bj = Time_bj
    Timelist.open_time = cellData.open_time
    Timelist.lottery_id = cellData.lottery_id
    table.insert(self.gameTimelist,Timelist)
    local cellNodeItem = {};
    cellNodeItem.bj = Time_bj
    cellNodeItem.open_time = cellData.open_time
    cellNodeItem.cellNode = cellNode
    cellNodeItem.lottery_id = cellData.lottery_id
    table.insert(self.cellNodeItemS,cellNodeItem)
    --print("gt.gamelistTap[i].status================="..cellData.lottery_id..cellData.status)
    --gt.log("Time222",os.date("%Y%m%d%H%M%S", os.time()),os.time())
    --gt.log("Time",os.date("%Y%m%d%H%M%S",cellData.open_time),cellData.open_time)
	--cellNode:setTouchEnabled(false)
--    gt.addBtnPressedListener(cellNode, function()
--		self:enterGameRoom(cellData.lottery_id) 
--	end)
    cellNode:addClickEventListener(function()
        Utils.setClickEffect()
		self:enterGameRoom(tag,cellData.status) 
	end)
--    cellNode:onButtonClicked(function()
--        self:enterGameRoom(cellData.lottery_id) 
--    end)
    cellNode:setSwallowTouches(false)

end

function MainScene:Showlottery(cellNode, lottery_no)
    local numtap =  gt.string_split(lottery_no,",")
	for i = 1, #numtap  do
        --local num =  string.sub(cellData.lottery_no,i,i);
        local num =  numtap[i]
		local qiuBg = gt.seekNodeByName(cellNode, "qiu" .. i)
		local lottery_num = gt.seekNodeByName(qiuBg, "lottery_num1")
--        if i > #numtap then
--            lottery_num:setVisible(false)
--            qiuBg:setVisible(false)
--        end
		lottery_num:setString(num)
	end

end

-- 进入游戏房间
function MainScene:enterGameRoom(sender,status)
    --msgTbl = gt.gamelistTap[sender]
    if status == 1 then

        require("app/views/UI/NoticeTips"):create("提示",	"休市！", nil, nil, true)

    else
--        if sender == 4 then
--            require("app/views/UI/NoticeTips"):create("提示","敬请期待！", nil, nil, true)
--        else
            local enterGameRoomlayer = require("app/views/Scene/GameRoom"):create(sender)
            cc.Director:getInstance():replaceScene(enterGameRoomlayer)
--        end
    end
end

-- 进入房间弹窗判断
function MainScene:onCallback(_type)
	if _type then
		gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
		local msgToSend = {}
		--msgToSend.m_msgId = gt.CG_JOIN_ROOM
		--msgToSend.m_deskId = roomID
		--gt.socketClient:sendMessage(msgToSend)
		msgToSend.dwRoomNum = self.requestJoinRoomID
        local customMsg={}	
        customMsg.msg = "JoinRoomRequest"		
	    customMsg.roomID = self.requestJoinRoomID
		self:OnNotify(customMsg)
		gt.log("加入房间")
	else
		-- self.isRoomCreater = false
		-- self.createRoomSpr:setVisible(true)
		-- self.backRoomSpr:setVisible(false)
		-- local joinRoomLayer = require("app/views/JoinRoom"):create()
		-- self:addChild(joinRoomLayer, MainScene.ZOrder.JOIN_ROOM)	
        -- print(" joinRoomLayer ")
		local joinRoomLayer = require("app/views/JoinRoom"):create()
		joinRoomLayer:setName("JRPanel")
		joinRoomLayer:setLobbyScene(self)
		self:addChild(joinRoomLayer, MainScene.ZOrder.JOIN_ROOM)	
	end
end

-- 断线重连,初始化数据
function MainScene:reLogin()
    --获取主节点请求
    gt.log("MainScene  reLogin ===========")
    self.loadingtime = 0
    self.cellNodeItemS = {}
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_MAIN_NODE_REQ,"{}")
    gt.socketClient:setIsStartGame(true)
end

function MainScene:onRcvLogin(msgTbl)
	if msgTbl.m_errorCode == 5 then
		-- 去掉转圈
		gt.removeLoadingTips()
		require("app/views/NoticeTips"):create("提示",	"您尚未在"..msgTbl.m_errorMsg.."退出游戏，请先退出后再登陆此游戏！", nil, nil, true)
		return
	end
	-- 去掉转圈
	gt.removeLoadingTips()

	-- 发送登录gate消息
	gt.loginSeed 		= msgTbl.m_seed
	gt.GateServer.ip 	= gt.socketClient.serverIp
	gt.GateServer.port 	= tostring(msgTbl.m_gatePort)

	gt.socketClient:close()
	gt.socketClient:connect(gt.GateServer.ip, gt.GateServer.port, true)
	local msgToSend = {}
	msgToSend.m_msgId = gt.CG_LOGIN_SERVER
	msgToSend.m_seed = msgTbl.m_seed
	msgToSend.m_id = msgTbl.m_id
	local catStr = tostring(gt.loginSeed)
	msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)
end

function MainScene:onNodeEvent(eventName)
	if "enter" == eventName then
		-- 逻辑更新定时器
		if Utils.checkVersion(1, 0, 14) then
			self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 60, false)
		else
			gt.log("需要下新包")
		end

        --要启动联网取数据！
        gt.showLoadingTips()

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		-- 触摸事件
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
		local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
									handler(self, self.onEnterBackground))
		eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
		local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
									handler(self, self.onEnterForeground))
		eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
	elseif "exit" == eventName then
		--require("app/views/sport/SportManager").getInstance():removeAllPopup()
		--if Utils.checkVersion(1, 0, 14) then
			gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		--end
			
	   --!进入场景后取消接收onRcvRoomInfo
	   --gt.socketClient:unregisterMsgListener(gt.MDM_GR_PRIVATE, gt.SUB_GF_PRIVATE_ROOM_INFO)
       self:unregisterAllMsgListener()
	end
end

function MainScene:onTouchBegan(touch, event)
    --print("touch:getLocation()=========="..touch:getLocation())
	return true
end

function MainScene:onTouchEnded(touch, event)
    print("touch:getLocation()=========="..touch:getLocation())
end
function MainScene:unregisterAllMsgListener()
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_MAIN_NODE_RESP)
end

function MainScene:onEnterBackground()

end

function MainScene:onEnterForeground()
	gt.resume_time = 1
end

function MainScene:checkMWAction()
	if not Utils.checkVersion(1, 0, 21) then
		return false
	end
	local actionMessage = Utils.getMWAction()
 	if actionMessage ~= nil and actionMessage ~= "" then
 		Utils.cleanMWAction()
 		gt.log("actionMessage = " .. actionMessage)
	 	require("json")
	 	local paramTable = json.decode(actionMessage) --string.split("&")

	 	if paramTable["action"] then
	 		if paramTable["action"] == "enterroom" then
	 			self:enterRoom(paramTable)
	 		elseif paramTable["action"] == "replayhistory" then
	 			self:replay(paramTable)
	 		end
	 	end
	end
end

function MainScene:enterRoom( _data )
	if not _data["code"] then
		return
	end
	gt.showLoadingTips("正在准备进入房间...")
	--正在进入
	local sequence =  cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
		gt.removeLoadingTips()
		local codeStr = _data["code"]
		local codeNum = tonumber(codeStr)
		if codeNum then
			--绑定接收信息
			gt.socketClient:registerMsgListener(gt.GC_JOIN_ROOM, self, self.onRcvJoinRoom)

			self.mwCode = codeNum
			-- 发送进入房间消息
			local msgToSend = {}
			msgToSend.m_msgId = gt.CG_JOIN_ROOM
			msgToSend.m_deskId = codeNum
			gt.socketClient:sendMessage(msgToSend)

			gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
		else
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "房间号错误!", nil, nil, true)
		end
	end))

	self:runAction(sequence)	
end

function MainScene:onRcvJoinRoom(msgTbl)
	if msgTbl.m_errorCode ~= 0 then
		-- 进入房间失败
		gt.removeLoadingTips()
		if msgTbl.m_errorCode == 1 then
			-- 房间人已满
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0018"), nil, nil, true)
		else
			-- 房间不存在
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"),string.format("房间号%s不存在！", self.mwCode), nil, nil, true)
		end
	end
end

function MainScene:update()
	if Utils.checkVersion(1, 0, 14) then
    	-- 反馈条数
		local feebackNumber = 0
		if gt.isIOSPlatform() then
			local luaoc = require("cocos/cocos2d/luaoc")
			local ok, ret = luaoc.callStaticMethod("AppController", "actionUnreadCountFetch", {userId = ""})
			gt.log("IOS反馈数", ret)
			feebackNumber = ret
		elseif gt.isAndroidPlatform() then
			local luaoj = require("cocos/cocos2d/luaj")
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "actionUnreadCountFetch", {""}, "(Ljava/lang/String;)Ljava/lang/String;")
			gt.log("反馈数", tonumber(ret))
			feebackNumber = tonumber(ret)
		end			
		if feebackNumber > 0 then
			self.m_feedbackBg:setVisible(true)
			gt.log("反馈数的类型", type(feebackNumber))
			self.m_feedbackNum:setString(feebackNumber)
		else
			self.m_feedbackBg:setVisible(false)
		end
	end

	local curTime = os.time()
	if not self.m_lastUp or curTime - self.m_lastUp > 1 then
		self:checkMWAction()
		self.m_lastUp = curTime
	end

end

-- 服务器推送活动信息
function MainScene:onRecvLotteryInfo( msgTbl )
	if self.m_activityBtn then
		self.m_activityBtn:setVisible(false)  --隐藏
	end
	gt.lotteryInfoTab	= {}
	gt.lotteryInfoTab.m_activeID 		= msgTbl.m_activeID
	gt.lotteryInfoTab.m_RewardID  		= msgTbl.m_RewardID
	gt.lotteryInfoTab.m_LastJoinDate 	= msgTbl.m_LastJoinDate
	-- gt.lotteryInfoTab.m_LastGiftState 	= msgTbl.m_LastGiftState
	gt.lotteryInfoTab.m_activeLogId     = msgTbl.m_activeLogId
	gt.lotteryInfoTab.m_NeedPhoneNum 	= msgTbl.m_NeedPhoneNum
	gt.lotteryInfoTab.m_gifts           = msgTbl.m_gifts

	for k,v in pairs(gt.lotteryInfoTab.m_gifts) do
		-- gt.log("打印的值", v.m_name)
	end

	local activityMotherDayLayer = require("app/views/Activities/ActivityMotherDay"):create()
	self:addChild(activityMotherDayLayer, 8)
end

-- 当有活动时,向服务器请求活动信息
function MainScene:sendGetActivities()
	if gt.lotteryInfoTab then
		local activityMotherDayLayer = require("app/views/Activities/ActivityMotherDay"):create()
		self:addChild(activityMotherDayLayer, 8)
	else
		if gt.m_activeID and gt.m_activeID ~= -1 then
			local msgToSend = {}
			msgToSend.m_msgId = gt.CG_GET_ACTIVITIES
			msgToSend.m_activeID = gt.m_activeID
			gt.socketClient:sendMessage(msgToSend)
			gt.log("#######请求信的活动信息##########")
		else
			require("app/views/UI/NoticeTips"):create("提示", "无活动信息", nil, nil, true)
		end
	end
end

-- 进入游戏 服务器推送是否有活动
function MainScene:onRecvIsActivities(msgTbl)
	gt.m_activeID = msgTbl.m_activeID
	-- gt.lotteryInfoTab = nil
	-- 苹果审核 无活动
	if gt.isInReview then
		gt.m_activeID = -1
	end
	if gt.m_activeID > -1 and self.m_activityBtn then
		self.m_activityBtn:setVisible(false)  --隐藏
	end
end

function MainScene:onRcvLoginServer(msgTbl)
	--登录服务器时间
	gt.loginServerTime = msgTbl.m_serverTime or os.time()
	--登录本地时间
	gt.loginLocalTime = os.time()
    --gt.log("555555")
	-- 去除正在返回游戏提示
	gt.removeLoadingTips()
	gt.floatText("重新连接服务器成功")
	if self:getChildByName("JRPanel") ~= nil then
		gt.log("加入房间面板已打开")
		self:getChildByName("JRPanel"):sendAgain()
	else
		gt.log("加入房间面板不存在")
	end
end

-- start --
--------------------------------
-- @class function
-- @description 进入房间消息
-- @param msgTbl 消息体
-- end --
function MainScene:onRcvEnterRoom(msgTbl)
	if self.sportDialog then
		self.sportDialog:destroy()
		self.sportDialog = nil
	end

	gt.removeLoadingTips()

	gt.removeTargetAllEventListener(self)

	if msgTbl.m_sportId and msgTbl.m_sportId ~= 0 then
		local sportInfo = require("app/views/sport/SportManager").getInstance().curSportInfo
		sportInfo.m_sportId = msgTbl.m_sportId
		local playScene = require("app/views/sport/SportScene"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	else
		local playScene = require("app/views/PlaySceneCS"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收房卡信息
-- @param msgTbl 消息体
-- end --
function MainScene:onRcvRoomCard(msgTbl)
	local playerData = gt.playerData
	playerData.roomCardsCount = {msgTbl.m_card1, msgTbl.m_card2, msgTbl.m_card3, msgTbl.m_diamondNum or 0}
	-- 玩家信息
	local playerInfoNode = gt.seekNodeByName(self.rootNode, "Node_playerInfo")
	-- 房卡信息
	local ttf_eight = gt.seekNodeByName(playerInfoNode, "Txt_numbereight")
	ttf_eight:setString(playerData.roomCardsCount[2])
	-- 钻石数量
	local diamondsNum = gt.seekNodeByName(playerInfoNode, "diamonds_num")
	diamondsNum:setString(playerData.roomCardsCount[4])	
    gt.dispatchEvent("REFRESH_FANGKA")
end

-- start --
--------------------------------
-- @class function
-- @description 接收跑马灯消息
-- @param msgTbl 消息体
-- end --
function MainScene:onRcvMarquee(msgTbl)
	if gt.isIOSPlatform() and gt.isInReview then
		local str_des = gt.getLocationString("LTKey_0048")
		self.marqueeMsg:showMsg(str_des)
	else
		self.marqueeMsg:showMsg(msgTbl.m_str)
		gt.marqueeMsgTemp = msgTbl.m_str
	end
end

function MainScene:gmCheckHistoryEvt(eventType, uid)
	local historyRecord = require("app/views/HistoryRecord"):create(uid)
	self:addChild(historyRecord, MainScene.ZOrder.HISTORY_RECORD)
end

-- 好友加入房间
function MainScene:onFriendJoinRoom(msgTbl)
	if msgTbl.m_ready >= 3 then
		-- 直接进入房间
		self:onCallback(true)
		return
	end
	local data = {name = msgTbl.m_nike, playerNum = msgTbl.m_ready + 1}
	local joinRoomLayer = require("app/views/JoinRoomPopup"):create("playerJoin", data, function()
		self:onCallback(true)
	end)
	self:addChild(joinRoomLayer, MainScene.ZOrder.JOIN_ROOM)
end

function MainScene:onShoppingCallback()
	-- 去个人中心
	local personalCenter = require("app/views/PersonalCenter"):create(true)
	self:addChild(personalCenter, MainScene.ZOrder.HISTORY_RECORD)	
end

-- 请求热更版本
function MainScene:requestVersion()
	local ver_filename  = "version.manifest"
    local remoteVersionUrl = nil
    self.curVersion = nil
    local cpath = cc.FileUtils:getInstance():isFileExist(ver_filename)
    if cpath then
        local fileData = cc.FileUtils:getInstance():getStringFromFile(ver_filename)
        require("json")
        local filelist = json.decode(fileData)
        if filelist then
            remoteVersionUrl = filelist.remoteVersionUrl
            self.curVersion = gt.resVersion
        end
    end
    if remoteVersionUrl == nil then
        remoteVersionUrl = "http://www.ixianlai.com/client/version.manifest"
    end
    
    if not self.xhr then
	    self.xhr = cc.XMLHttpRequest:new()
	    self.xhr:retain()
	    self.xhr.timeout = 30 -- 设置超时时间
    end
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    self.xhr:open("GET", remoteVersionUrl)
    self.xhr:registerScriptHandler(handler(self,self.onResp))
    self.xhr:send()
end

function MainScene:onResp()
	if not self.xhr then
		return
	end
    if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
        local data = json.decode(self.xhr.response)
        if data.version ~= self.curVersion then
        	local function ok()
        		gt.socketClient:setIsStartGame(false)
				gt.socketClient:close()
        		self:clearLoadedFiles()
        		local updateScene = require("app/views/UpdateScene"):create()
        		cc.Director:getInstance():replaceScene(updateScene)
        	end
        	--require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "游戏版本过低，点击【确定】按钮，系统会自动为您更新至最新版本哦!", ok, nil, true)
        end
    elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
        -- 网络问题,异常断开
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
    end
    self.xhr:unregisterScriptHandler()
end

function MainScene:clearLoadedFiles()
	for k, v in pairs(package.loaded) do
		if string.sub(k, 1, 4) == "app/" then
			package.loaded[k] = nil
		end 
	end
	cc.SpriteFrameCache:getInstance():removeSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
end

MainScene.isShowMoonFreeCard = false
function MainScene:showMoonFreeCard()
	if not MainScene.isShowMoonFreeCard then
		MainScene.isShowMoonFreeCard = true

		local startTime = os.time({year=2016, month=9, day=14, hour=0,min=0,sec=0,isdst=false})
		local endTime = os.time({year=2016, month=9, day=18, hour=24,min=0,sec=0,isdst=false})
		local curTime = gt.loginServerTime + (os.time() - gt.loginLocalTime)
		if curTime >= startTime and curTime <= endTime then
			local dialog = gt.createMaskLayer()
			self:addChild(dialog, 1000)

			local rootNode = ccui.Layout:create()
			rootNode:setPosition(gt.winCenter)
			dialog:addChild(rootNode)

			local moonBg = cc.Sprite:create("images/otherImages/moon_bg.png")
			rootNode:addChild(moonBg)

			local iknowBtn = ccui.Button:create("fangkaxiaobeijing.png","","",1)
			iknowBtn:setPosition(cc.p(4, -205))
			iknowBtn:setOpacity(0)
			iknowBtn:setScale9Enabled(true)
			iknowBtn:setCapInsets(cc.rect(10,10,10,10))
			iknowBtn:setContentSize(cc.size(200, 66))
			rootNode:addChild(iknowBtn)
			iknowBtn:addClickEventListener(function(sender)
				dialog:removeFromParentAndCleanup(true)
			end)
		end
	end
end

function MainScene:update(delta)
--   gt.socketClient:close()
--   gt.socketClient:connect(gt.TestLoginServer.ip, gt.TestLoginServer.port, true)
--   gt.log("请求服务器连接地址")
--   gt.socketClient:sendMessage(gt.MDM_WX_LIST, gt.SUB_WX_GET_LIST)

    --local curdate = os.date()
    self.loadingtime = self.loadingtime + 1
    --print("self.loadingtime"..self.loadingtime)
    if self.loadingtime > 10 and gt.isshowlading then 
        self.loadingtime = 0
        gt.isshowlading = false
         -- 去掉转圈
	    gt.removeLoadingTips()
        --require("app/views/UI/NoticeTips"):create("提示",	"进房间失败！请重登录。",nil, nil, true)
        return
    end    
    for i=1,#self.cellNodeItemS do
        local Time_bj = self.cellNodeItemS[i].bj
        --gt.log("Time111:=",os.date(),os.time())
        --local time = self.cellNodeItemS[i].open_time - os.time()
        local time = self.cellNodeItemS[i].open_time - 1
        --gt.log("Time:===",time,self.cellNodeItemS[i].open_time)
        self.cellNodeItemS[i].open_time = self.cellNodeItemS[i].open_time - 1
        if self.cellNodeItemS[i].open_time < 0 then
           --gt.log("open_time == ",i)
           self.cellNodeItemS[i].open_time = 0 --gt.gamelistTap[i].open_time
        end
        if Time_bj then
            local time_fen = gt.seekNodeByName(Time_bj, "time_fen")
            local time_miao = gt.seekNodeByName(Time_bj, "time_miao")
            if time < 0 then 
                --time_fen:setString(os.date("%M"))
                --time_miao:setString(os.date("%S"))
                time_fen:setString("00")
                time_miao:setString("00")
            else
                local t1,t2 = math.modf(time/60)   -- gt.gamelistTap[i].open_time
                
                if t1 < 10 then
                    t1 = "0"..t1
                end

                if t2 < 0.16 then
                    t2 = "0"..t2*60
                else
                    t2 = t2*60
                end
                time_fen:setString(t1)
                time_miao:setString(t2)
            end
        end
    end
end

function MainScene:onRcvListServerStart(msgTbl)
    self.serverList = {}
    gt.dump(msgTbl)
end

function MainScene:onRcvListServer(msgTbl)
    --gt.dump(msgTbl)
    self.serverList[#self.serverList+1] = msgTbl

    gt.dump(self.serverList)
end

function MainScene:onRcvListServerFinish(msgTbl)
    gt.dump(msgTbl)
    gt.socketClient.close()
end

function MainScene:onRcvLogonSuccess(msgTbl)
       gt.dump(msgTbl)	   
      self:DispatchLoginRoomSuccess(msgTbl)
end

function MainScene:DispatchLoginRoomSuccess(msgTbl)
      --如果当前处于创建房间请求
	   if self.request == "CreateRoomRequest" then
	     local msgToSend = {}
         msgToSend.cbGameType = 0
	     msgToSend.bGameRuleIdex = 0
	     msgToSend.bGameTypeIdex = 0
	     msgToSend.bPlayCoutIdex = 1
        --创建房间请求
	    gt.socketClient:sendMessage(gt.MDM_GR_PRIVATE, gt.SUB_GR_CREATE_PRIVATE, msgToSend)
	   elseif self.request == "JoinRoomRequest" then
	     local msgToSend = {}
	     msgToSend.dwRoomNum = self.requestJoinRoomID		 
	     gt.socketClient:sendMessage(gt.MDM_GR_PRIVATE ,gt.SUB_GR_JOIN_PRIVATE,msgToSend)	  
	   end
end

function MainScene:onRcvLogonFailure(msgTbl)
   -- gt.dump(msgTbl)
end

function MainScene:onRcvCreateSuccess(msgTbl)
   -- gt.dump(msgTbl)
end

--收到房间信息说明登入房间成功
function MainScene:onRcvRoomInfo(msgTbl)
    gt.dump(msgTbl)
	gt.log("onRcvRoomInfqqqqqqqqqqqq")
	gt.removeLoadingTips()

	gt.removeTargetAllEventListener(self)
    --房间类型
	gt.roomState = tonumber(msgTbl.cbRoomType)
	
	msgTbl.m_maxCircle = msgTbl.dwPlayTotal
	msgTbl.m_deskId    = msgTbl.dwRoomNum
	msgTbl.m_maxFan    = 1
	msgTbl.m_playtype  = {20,23}--玩法
	msgTbl.m_pos       = 1
	msgTbl.m_state     = msgTbl.cbRoomType
	msgTbl.m_roomOwner = msgTbl.dwCreateUserID
	if(msgTbl.m_roomOwner == gt.playerData.userid )then
	   msgTbl.m_pos = 0
	   gt.log("房主进入房间"..gt.playerData.userid)
	 else
	   gt.log("进入他人房间进入他人房间")
	 end
	if tonumber(msgTbl.cbRoomType) == 0 then
		gt.log("=======XL...")
		local playScene = require("app/views/PlaySceneCS"):create(msgTbl)
		cc.Director:getInstance():replaceScene(playScene)
	end

end


function MainScene:OnNotify(customMsg)
    if(customMsg.msg == "JoinRoomRequest") then	 	  	 
		 --customMsg.roomID%10000		
		-- print(#self.serverList)
		-- print(self.serverList[1])
		 
		 local ip   = self.serverList[1].strServerAddr
		 local port = self.serverList[1].wServerPort
		 print("ip:"..ip.."port:"..port)
		 gt.socketClient:close()
         gt.socketClient:connect(ip ,port,true)
	
	    self.request ="JoinRoomRequest" 
		self.requestJoinRoomID = customMsg.roomID
		--创建房间前先发送登入请求消息
		local msgToSend = {}
        msgToSend.dwUserID  = gt.playerData.userid
		msgToSend.dwToken  = gt.playerData.token
        msgToSend.dwSession = 0
        msgToSend.strMachineID = ""
		gt.socketClient:sendMessage(gt.MDM_GR_PRIVATE, gt.SUB_GR_PRIVATE_LOGON, msgToSend)
	elseif(customMsg.msg == "CreateRoomRequest") then
	
		 local ip   = self.serverList[1].strServerAddr
		 local port = self.serverList[1].wServerPort
		 print("ip:"..ip.."port:"..port)
		 gt.socketClient:close()
         gt.socketClient:connect(ip ,port,true)
		 
	    self.request ="CreateRoomRequest" 
	    local msgToSend = {}
        msgToSend.dwUserID  = gt.playerData.userid
		msgToSend.dwToken  = gt.playerData.token
        msgToSend.dwSession = 0
        msgToSend.strMachineID = ""
		gt.socketClient:sendMessage(gt.MDM_GR_PRIVATE, gt.SUB_GR_PRIVATE_LOGON, msgToSend)
	
		 --开始接收房间消息
		--gt.socketClient:registerMsgListener(gt.MDM_GR_PRIVATE, gt.SUB_GF_PRIVATE_ROOM_INFO,self, self.onRcvRoomInfo)
		
		-- local msgToSend = {}
		-- msgToSend.dwRoomNum = roomID
		-- gt.socketClient:sendMessage(gt.MDM_GR_PRIVATE ,gt.SUB_GR_JOIN_PRIVATE,msgToSend)
		 
         --gt.socketClient:sendMessage(gt.MDM_GF_FRAME ,gt.SUB_GF_GAME_OPTION,  msgToSend)
	end
	
   -- gt.dump(msgTbl)
end

--function MainScene:createDetailItem(tag, cellData)
--	local RangeNode = cc.CSLoader:createNode("Decdetail_list.csb")

--    local DetailListBg = gt.seekNodeByName(RangeNode,"DetailListBg")
--    if tag%2 == 0 then
--        DetailListBg:setTexture("res/res/LobbyHall/DetailListBg.png")
--    else
--        DetailListBg:setTexture("")
--    end

--    local gametuo = gt.seekNodeByName(RangeNode, "gametuo")
--    local str = "res/res/GameList/"..gt.gameroombj[cellData.lottery_id]
--	if cc.FileUtils:getInstance():isFileExist(str) then
--        gametuo:setTexture(str)
--    end

--    local GameType = gt.seekNodeByName(RangeNode, "GameType")
--    GameType:setString(cellData.method)
--    local TxtTime = gt.seekNodeByName(RangeNode,"TxtTime")
--    TxtTime:setString(cellData.DateTime)
--    local TxtName = gt.seekNodeByName(RangeNode,"TxtName")
--    TxtName:setString(cellData.table_name)
--    local TxtMoney = gt.seekNodeByName(RangeNode,"TxtMoney")
--    TxtMoney:setString(cellData.money)
--    local TxtShuying = gt.seekNodeByName(RangeNode,"TxtShuying")
--    TxtShuying:setString(cellData.shuying)

--    local cellSize = RangeNode:getContentSize()
--	local cellItem = ccui.Widget:create()
--	cellItem:setTag(tag)
--	cellItem:setTouchEnabled(true)
--	cellItem:setContentSize(cellSize)
--	cellItem:addChild(RangeNode)
--	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))

--	return cellItem
--end

function MainScene:onRcvUserEnter(msgTbl)
    --gt.dump(msgTbl)
end

function MainScene:onRcvUserScore(msgTbl)
    --gt.dump(msgTbl)
end

function MainScene:onRcvUserStatus(msgTbl)
   -- gt.dump(msgTbl)
end
function MainScene:onGetNameChangeResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SChangceUserNicknameResp()
    stResp:ParseFromString(buf)
    gt.log("onGetOfflineOrderResp code:"..stResp.code)
    if stResp.code == 0 then
        require("app/views/UI/NoticeTips"):create("恭喜您","修改成功", nil, nil, true)
        gt.playerData.is_first = 0
        self.nicknameLabel:setString(gt.playerData.nickname)
        self.Account_name:setString(gt.playerData.nickname)
        self.ChangeNameScence:removeFromParent()
    elseif stResp.code == 1 then
       require("app/views/UI/NoticeTips"):create("请重试","系统错误！", nil, nil, true)
    elseif stResp.code == 2 then
       require("app/views/UI/NoticeTips"):create("请重试","昵称为空！", nil, nil, true)
    elseif stResp.code == 3 then
       require("app/views/UI/NoticeTips"):create("请重试","昵称重复！", nil, nil, true)
    elseif stResp.code == 4 then
       require("app/views/UI/NoticeTips"):create("请重试","昵称过长！", nil, nil, true)
    end
end

return MainScene

