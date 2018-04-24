
local gt = cc.exports.gt
local Utils = cc.exports.Utils
require("app.protocols.cmd_node_pb")
local GameRoom = class("GameRoom", function()
	return cc.Scene:create()
end)

gameListChose = 
        {
    {bj = "PaiJiu.png",bjD = "PaiJiuDi.png",play_method = 1 },
    {bj = "NiuNiu.png",bjD = "NiuNiuDi.png",play_method = 1 },
    {bj = "SanGong.png" ,bjD = "SanGongDi.png",play_method = 1},
    {bj = "BaijiaHappy.png",bjD = "BaijiaHappyDi.png", play_method = 1},
    {bj = "Danzhang.png",bjD = "DanzhangDi.png",play_method = 1 },
    {bj = "EightFruit.png",bjD = "EightFruitDi.png",play_method = 1 },
}

function GameRoom:registerTouchEvent(bSwallow, FixedPriority)
    local function onTouchBegan( touch, event )
        if nil == self.onTouchBegan then
            return false
        end
        return self:onTouchBegan(touch, event)
    end

    local function onTouchMoved(touch, event)
        if nil ~= self.onTouchMoved then
            self:onTouchMoved(touch, event)
        end
    end

    local function onTouchEnded( touch, event )
        if nil ~= self.onTouchEnded then
            self:onTouchEnded(touch, event)
        end       
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(bSwallow)
    self._listener = listener
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, FixedPriority)
end

function GameRoom:ctor(tag)
    --matt add 主界面进房间列表消息
    gt.roomidtag = tag or gt.roomidtag
    for i=1,#gt.gamelistTap do
        if gt.roomidtag == i --[[gt.gamelistTap[i].lottery_id--]] then
            self.MainroomMsgTbl = gt.gamelistTap[i]
            break
        end
    end

    if  gt.Gameroomid ~= 0 then
        gt.Gameroomid = gt.Gameroomid
    elseif gt.roomidtag == 1 or gt.roomidtag == 2 then 
        gt.Gameroomid = 1
    else
        gt.Gameroomid = 0
    end

    self.gameChoseBg = {} --选择游戏背景颜色
    self.gameChoseIco = {}
    self.QieHuanTxt = {} --选择游戏文字颜色
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local playerData = gt.playerData

	local csbNode = cc.CSLoader:createNode("Gamelist_Scene.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

    self.GameSelectBut = {"mianYong_btn","chouYong_btn","tiYan_btn"}

    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")
	-- 跑马灯
	local marqueeNode = gt.seekNodeByName(lobby_bj, "Node_marquee")
	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)
    --联系客服
	local serviceBtn = gt.seekNodeByName(lobby_bj, "service")
	gt.addBtnPressedListener(serviceBtn, function()
        Utils.setClickEffect()
		local FeedBackScene = require("app/views/Scene/FeedBackScene"):create()
        self:addChild(FeedBackScene)
	end)

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
    self.goldNode = gt.seekNodeByName(MoneyBg_1, "money_num")
	--ttf_eight:setString(playerData.coin)
    self.goldNode:setString(string.format("%.01f", playerData.coin/10000))
    
    cc.UserDefault:getInstance():setStringForKey("ttf", playerData.coin)

	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        Utils.setClickEffect()
        local MainScene = require("app/views/Scene/MainScene"):create()
        cc.Director:getInstance():replaceScene(MainScene)
        gt.Gameroomid = 0
        gt.SelectroomSite = 0
        gt.SelectroomId = 0
	end)

    self.GameRoomList = gt.seekNodeByName(csbNode, "GameList")
    self.GameRoomList:setScrollBarEnabled(false)
    self.TypeChoseList =  gt.seekNodeByName(csbNode, "ListView_2")
    self.TypeChoseList:setScrollBarEnabled(false)
        
    for i = 0 , 2 do 
        self.QieHuanTxt[i] = gt.seekNodeByName(self.rootNode, "TextShowing_"..i)
    end
    --箭头指向
    local QieHuanBg = gt.seekNodeByName(self.rootNode, "QieHuanBg_1")
    self.QieHuanBgpox = QieHuanBg:getPositionX()
    if  gt.SelectroomId ~= 0 then
       QieHuanBg:setPositionX( self.QieHuanBgpox + (gt.SelectroomId-201)*174)
       self.QieHuanTxt[gt.SelectroomId-201]:setColor(cc.c3b(52,18,32))
       self.SelectId = gt.SelectroomId
    else
       QieHuanBg:setPositionX( self.QieHuanBgpox)
       self.QieHuanTxt[0]:setColor(cc.c3b(52,18,32))
       self.SelectId =  0  --体验场/抽/免背景
    end
    --游戏房间节点列表
    self.node_listS = {}
    --选择列表
    self.ChoselistS = {}
    self.ChoseGameid = 1  --选择游戏ID
    
    
--    if  gt.SelectroomId ~= 0 then
--        self.SelectId = gt.SelectroomSite
--    else
--        self.SelectId =  0  --体验场/抽/免背景
--    end

    if  gt.SelectroomSite ~= 0 then
        self.SelectSite = gt.SelectroomSite
    else
        self.SelectSite =  0  --选择场地  体验场等
    end
    --获取子节点请求
    local cmsg = cmd_node_pb.CGetGameNodeReq()
    cmsg.node_id = self.MainroomMsgTbl.node_id
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_GAME_NODE_REQ,msgData)

    --获取用户金币信息
    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_COIN_INFO_REQ,"{}")
	-- 子节点消息回调
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_GAME_NODE_RESP, self, self.onGetGameNodeResp)
	-- 子节点消息回调
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_BACCARATTABLE_TABLE_LIST_RESP, self, self.onGetBaccartTableListResp)

    -- 游戏玩法选择
    --self:initGamesele()
    --游戏房间列表
    --self:initPaijiuRoomlist()
    --游戏类型选择
    --self:initGameTypeChose()
end

function GameRoom:Setcoin(coin)
    self.goldNode:setString(string.format("%.01f", coin/10000))
end

function GameRoom:onGetBaccartTableListResp(msgTbl)
--去掉体验场百家乐列表
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_node_pb.SGetBaccaratTableNodeListResp()
    stResp:ParseFromString(buf)
    if stResp.code == 0 then
        gt.log("onGetBaccartTableListResp:",#stResp.node_id_list)
        gt.BjlCutRoomList = stResp.node_id_list
--        for i = 1, #stResp.node_id_list do
--             gt.log("onGetBaccartTableListResp====:",stResp.node_id_list[i])
--             gt.BjlRoomList[i].node_id = stResp.node_id_list[i]
----            for j = 1, #gt.BjlRoomList do 
----                if gt.BjlRoomList[j].node_id == stResp.node_id_list[i] then
----                   gt.BjlRoomList[j].table_id = stResp.node_id_list[i].table_id 
----                   gt.log("TableList:",gt.BjlRoomList[j].table_id,gt.BjlRoomList[j].node_id)
----                   break
----                end
----            end
--        end
    end
end

function GameRoom:onGetGameNodeResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_node_pb.SGetGameNodeResp()
    stResp:ParseFromString(buf)
        gt.log("onGetGameNodeResp node_list:"..#stResp.node_list)
        --local node_listS = {}
        --dump(stResp.node_list, "游戏节点")
        local gametypeInx = 1;
        gt.BjlRoomList = {}
        for i = 1, #stResp.node_list do
            local node_list = {}
            node_list.node_id = stResp.node_list[i].node_id
            node_list.node_type = stResp.node_list[i].node_type
            node_list.parent_node = stResp.node_list[i].parent_node
            node_list.node_name = stResp.node_list[i].node_name
            node_list.number_of_people = stResp.node_list[i].number_of_people
            node_list.max_people = stResp.node_list[i].max_people
            node_list.play_method = stResp.node_list[i].play_method
            node_list.person_upper_limit = stResp.node_list[i].person_upper_limit
            node_list.pot_upper_limit = stResp.node_list[i].pot_upper_limit
            node_list.bet_area_limit = stResp.node_list[i].bet_area_limit
            
            if node_list.parent_node == self.MainroomMsgTbl.node_id then
                local cellDataidx = node_list.play_method
                if node_list.play_method ~= 0 then
                    --gt.log("node_id====:",node_list.parent_node,self.MainroomMsgTbl.node_id,cellDataidx)
                    local cellData = gameListChose[cellDataidx]
                    cellData.play_method = cellDataidx
            	    local GameItem = self:createGameTypeItem(gametypeInx, cellData)
                    gametypeInx = gametypeInx + 1
		            self.TypeChoseList:pushBackCustomItem(GameItem)
                end
            else
               if node_list.node_type == 1 then
                    table.insert( self.ChoselistS,node_list)
               end
            end

            --gt.log("node_list:",node_list.node_id,node_list.node_type,node_list.parent_node,node_list.node_name,node_list.number_of_people,node_list.play_method)
            if node_list.node_type == 2 then
                table.insert( self.node_listS,node_list)
                if node_list.play_method == 4 then
                    node_list.table_id = 0
                    table.insert(gt.BjlRoomList,node_list)
                end
            end
        end
         -- 去掉转圈
	    gt.removeLoadingTips()
        if #self.node_listS < 1 then
            return
        end

        if  gt.Gameroomid ~= 0 then
            self.ChoseGameid = gt.Gameroomid
        else
            self.ChoseGameid = self.node_listS[1].play_method
        end
        if  gt.SelectroomSite ~= 0 then
            self.SelectSite = gt.SelectroomSite
        else
            --self.SelectSite = self.ChoselistS[1].node_id
            for i = 1,#self.ChoselistS do
                if self.ChoselistS[i].play_method == self.ChoseGameid then
                    self.SelectSite = self.ChoselistS[i].node_id
                    break
                end
            end
        end
--        self.ChoseGameid = self.node_listS[1].play_method
--        self.SelectSite = self.ChoselistS[1].node_id
--        if self.node_listS[1].play_method == 0 then 
--            self.node_listS[1].play_method = 1
--        end
        if self.gameChoseBg[self.ChoseGameid] ~= nil then
            self.gameChoseBg[self.ChoseGameid]:setVisible(true)
        end
        if self.gameChoseIco[self.ChoseGameid] ~= nil then
            self.gameChoseIco[self.ChoseGameid]:setVisible(false)
        end
        self:initGameRoomlist()
        self:initGamesele()

        --获取百家乐桌子id
        local cmsg = cmd_node_pb.CGetBaccaratTableNodeListReq()
        cmsg.main_node_id = self.MainroomMsgTbl.node_id
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_BACCARATTABLE_TABLE_LIST_REQ,msgData)

end

function GameRoom:initGamesele()

    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(sender:getTag(), sender)
            self.SelectId = sender:getTag()
            gt.SelectroomId = sender:getTag()
            --gt.SelectroomSite = 0
            --gt.log("=========",self.SelectId)
        end
    end
    self.GameListBg = gt.seekNodeByName(self.rootNode, "GameListBg_1")
    local SelectButidx = 1
    gt.log("=========",gt.SelectroomSite)
    for i = 1,#self.ChoselistS do 
        if self.ChoselistS[i].play_method == self.ChoseGameid then
            SelectButidx = i
            if  gt.SelectroomId ~= 0 then
                self.SelectSite = self.ChoselistS[i + gt.SelectroomId - 201].node_id
            else
                self.SelectSite = self.ChoselistS[i].node_id
            end
            break
        end
    end

    for i=1, #self.GameSelectBut do         --选择框
    --print("=========",self.GameSelectBut[i])
        local SelectBut = gt.seekNodeByName(self.GameListBg, self.GameSelectBut[i])
        local listS_node = self.ChoselistS[SelectButidx + i - 1]
        --print("=========",listS_node.node_name,SelectButidx)
        local SelectText = gt.seekNodeByName(self.GameListBg, "TextShowing_"..i-1)
        if listS_node and listS_node.play_method == self.ChoseGameid then 
            SelectBut:setVisible(true)
            SelectText:setVisible(true)
            SelectText:setString(listS_node.node_name)
            SelectBut:setTag(200+i)
            SelectBut:addTouchEventListener(btnEvent)
        else
            SelectBut:setVisible(false)
            SelectText:setVisible(false)
        end
    end
end

function GameRoom:onButtonClickedEvent(tag, ref)  
    local tagnum = 201;
    local positionx = 0
    Utils.setClickEffect()

    if tag == 201 then
        self.QieHuanTxt[0]:setColor(cc.c3b(52,18,32))
        self.QieHuanTxt[1]:setColor(cc.c3b(183,174,141))
        self.QieHuanTxt[2]:setColor(cc.c3b(183,174,141))
    elseif tag == 202 then
        self.QieHuanTxt[1]:setColor(cc.c3b(52,18,32))
        self.QieHuanTxt[0]:setColor(cc.c3b(183,174,141))
        self.QieHuanTxt[2]:setColor(cc.c3b(183,174,141))
    elseif tag == 203 then
        self.QieHuanTxt[2]:setColor(cc.c3b(52,18,32))
        self.QieHuanTxt[0]:setColor(cc.c3b(183,174,141))
        self.QieHuanTxt[1]:setColor(cc.c3b(183,174,141))
    end
    if gt.GC_BUT_PAIGOW_CODE <= tag and  tag <= gt.GC_BUT_BACCARAT_CODE then
        --指示地方
        positionx = tag - tagnum;
        local QieHuanBg = gt.seekNodeByName(self.rootNode, "QieHuanBg_1")
        QieHuanBg:setPositionX( self.QieHuanBgpox + positionx*174)
    elseif gt.GC_BUT_BOX10_CODE <= tag and tag <= gt.GC_BUT_TIYANCHANG_CODE then
        tagnum = 3
    end

    for i = 1,#self.ChoselistS do 
        if self.ChoselistS[i].play_method == self.ChoseGameid then
            self.SelectSite = self.ChoselistS[i+positionx].node_id
            break
        end
    end

    self.GameRoomList:removeAllItems()
    self:initGameRoomlist()
end

--游戏类型选择

function GameRoom:createGameTypeItem(tag, cellData)
    local cellNode = cc.CSLoader:createNode("gameList_Chose.csb")
    -- game 图
	self.gameChoseIco[cellData.play_method] = gt.seekNodeByName(cellNode, "BaijiaHappy_1")
	self.gameChoseBg[cellData.play_method] = gt.seekNodeByName(cellNode, "DiBg_7")
    self.gameChoseBg[cellData.play_method]:setVisible(false)
    
    local str = "res/res/GameList/"..cellData.bj
    local str1 = "res/res/GameList/"..cellData.bjD
	if cc.FileUtils:getInstance():isFileExist(str) then
        self.gameChoseIco[cellData.play_method]:setTexture(str)
        self.gameChoseBg[cellData.play_method]:setTexture(str1)
    end

	local cellSize = cellNode:getContentSize()
	local cellItem = ccui.Widget:create()
	--cellItem:setTag(tag)
    cellItem:setTag(cellData.play_method)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(cellNode)
	cellItem:addClickEventListener(handler(self, self.ChoseGame))
	return cellItem
end

function GameRoom:ChoseGame(sender, eventType)
    Utils.setClickEffect()
    local gameid = sender:getTag()
    gt.log("ChoseGame== ",gameid,gameid%2)
    self.ChoseGameid = gameid
    gt.SelectroomId = 0
    for i = 1 ,#self.gameChoseBg do
        self.gameChoseBg[i]:setVisible(false)
        self.gameChoseIco[i]:setVisible(true)
    end
    self.gameChoseBg[gameid]:setVisible(true)
    self.gameChoseIco[gameid]:setVisible(false)

    local QieHuanBg = gt.seekNodeByName(self.rootNode, "QieHuanBg_1")
    QieHuanBg:setPositionX( self.QieHuanBgpox )
    self.QieHuanTxt[0]:setColor(cc.c3b(52,18,32))
    self.QieHuanTxt[1]:setColor(cc.c3b(183,174,141))
    self.QieHuanTxt[2]:setColor(cc.c3b(183,174,141))
    self:initGamesele()

    self.GameRoomList:removeAllItems()
    self:initGameRoomlist()

--    if gameid == 1 then
--        self:initPaijiuRoomlist()
--    elseif gameid == 2 then

--    else
--         self:initNiuniuRoomlist()
--    end
end
--游戏房间选择
function GameRoom:initGameRoomlist()
    --gt.log("游戏参数：",self.ChoseGameid,self.SelectSite)
	for i, cellData in ipairs(self.node_listS) do
        --self.ChoseGameid = 1  --选择游戏ID
        --self.SelectSite =  0  --选择场地  体验场等
        if self.ChoseGameid == cellData.play_method and self.SelectSite == cellData.parent_node then 
		    local GameItem = self:createGameItem(i, cellData)
		    self.GameRoomList:pushBackCustomItem(GameItem)
        end
	end
end

function GameRoom:createGameItem(tag, cellData)
	local cellNode = cc.CSLoader:createNode("gameroomList.csb")
	-- game 图
	local gametuo = gt.seekNodeByName(cellNode, "gametuo")
    local str = "res/res/GameList/"..gt.gameroombj[self.MainroomMsgTbl.lottery_id]
	if cc.FileUtils:getInstance():isFileExist(str) then
        gametuo:setTexture(str)
    end

    -- 序号
--	local numLabel = gt.seekNodeByName(cellNode, "lottery_num")
--	numLabel:setString(tostring(tag))

	-- 大标题
	local game_name = gt.seekNodeByName(cellNode, "game_name")
	game_name:setString(cellData.node_name)
	-- 小标题
--	local piaoti = gt.seekNodeByName(cellNode, "piaoti")
--	piaoti:setString(cellData.piaoti1)
	-- 人数
	local people_text = gt.seekNodeByName(cellNode, "people_text")
	people_text:setString(cellData.number_of_people.."人")
    --根据人数判断热度
    local HotNum = "res/res/GameList/"
    if cellData.number_of_people >= 0 and cellData.number_of_people < 20 then
        HotNum = HotNum.."Hot5.png" 
    elseif cellData.number_of_people >= 20 and cellData.number_of_people < 40 then
        HotNum = HotNum.."Hot4.png" 
    elseif cellData.number_of_people >= 40 and cellData.number_of_people < 60 then
        HotNum = HotNum.."Hot3.png" 
    elseif cellData.number_of_people >= 60 and cellData.number_of_people < 80 then
        HotNum = HotNum.."Hot2.png" 
    else
        HotNum = HotNum.."Hot1.png" 
    end
    local people_t = gt.seekNodeByName(cellNode, "people_t")
    if cc.FileUtils:getInstance():isFileExist(HotNum) then
        people_t:setTexture(HotNum)
    end
    --游戏类型判断
    local TxtGameType = ""
    if cellData.play_method == 1 then
        TxtGameType = "牌九"
    elseif cellData.play_method == 2 then
        TxtGameType = "牛牛"
    elseif cellData.play_method == 3 then
        TxtGameType = "三公"
    elseif cellData.play_method == 4 then
        TxtGameType = "百家乐"
    elseif cellData.play_method == 5 then
        TxtGameType = "单张"
    elseif cellData.play_method == 6 then
        TxtGameType = "番摊"
    end
    local GameType = gt.seekNodeByName(cellNode, "GameType")
    GameType:setString(TxtGameType)

    local Limit_text = gt.seekNodeByName(cellNode, "Limit_text")
    local Full_text = gt.seekNodeByName(cellNode, "Full_text")
    local Limit = gt.seekNodeByName(cellNode, "Limit")
    if cellData.play_method == 1 or cellData.play_method == 3 or cellData.play_method == 5 then
        Limit:setVisible(false)
        Limit_text:setVisible(false)
        local area_limit = cellData.bet_area_limit
        if cellData.bet_area_limit >= 1000 then 
            area_limit = cellData.bet_area_limit / 1000 .."k"
        end
        Full_text:setString(area_limit)
    else
        local upper_limit = cellData.person_upper_limit
        if cellData.person_upper_limit >= 1000 then 
            upper_limit = cellData.person_upper_limit / 1000 .."k"
        end
        Limit_text:setString(upper_limit)
        local pot_upper = cellData.person_upper_limit
        if cellData.pot_upper_limit >= 1000 then 
            pot_upper = cellData.pot_upper_limit / 1000 .."k"
        end
        Full_text:setString(pot_upper)
    end

	local cellSize = cellNode:getContentSize()
	local cellItem = ccui.Widget:create()
	--cellItem:setTag(tag)
    cellItem:setTag(cellData.node_id)
    cellItem:setName(cellData.node_name)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(cellNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	cellItem:addClickEventListener(handler(self, self.enterGame))
	return cellItem
end

function GameRoom:enterGame(sender, eventType)
    Utils.setClickEffect()
    local node_id = sender:getTag()
    gt.log("enterGame== ",node_id,self.SelectSite,self.SelectId)

    gt.EnterGameRoomId = node_id

    gt.Gameroomid = self.ChoseGameid
    gt.SelectroomSite = self.SelectSite
    gt.SelectroomId = self.SelectId
    local playScene
    if self.ChoseGameid == 4 then
        playScene = require("app/views/Scene/PlaySceneBJL"):create(self.MainroomMsgTbl,sender:getName(),self.ChoseGameid)
    elseif self.ChoseGameid == 6 then
        --playScene = require("app/views/Scene/PlaySceneJC"):create(self.MainroomMsgTbl,sender:getName(),self.ChoseGameid)
        playScene = require("app/views/Scene/PlaySceneBJHappy"):create(self.MainroomMsgTbl,sender:getName(),self.ChoseGameid)
    elseif self.ChoseGameid == 1 then
        playScene = require("app/views/Scene/PlayScenePaiJiu"):create(self.MainroomMsgTbl,sender:getName(),self.ChoseGameid)
    elseif self.ChoseGameid == 2 then
        playScene = require("app/views/Scene/PlaySceneNiuNiu"):create(self.MainroomMsgTbl,sender:getName(),self.ChoseGameid)
    elseif self.ChoseGameid == 5 then
        playScene = require("app/views/Scene/PlaySceneSSCai"):create(self.MainroomMsgTbl,sender:getName(),self.ChoseGameid)
    elseif self.ChoseGameid == 3 then
        playScene = require("app/views/Scene/PlaySceneSangong"):create(self.MainroomMsgTbl,sender:getName(),self.ChoseGameid)
    end
    cc.Director:getInstance():replaceScene(playScene)

    -- 进游戏桌子
    local cmsg = cmd_node_pb.CEnterGameReq()
    cmsg.node_id = node_id
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_ENTER_GAME_REQ,msgData)

end

function GameRoom:UpdateGameItem(tag, cellData)


end

function GameRoom:onNodeEvent(eventName)
	if "enter" == eventName then
		-- 触摸事件
        gt.log("GameRoom enter===")
        gt.showLoadingTips()
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		-- 移除触摸事件
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
        --gt.log("GameRoom exit===")
        self:unregisterAllMsgListener()
	end
end

function GameRoom:unregisterAllMsgListener()
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_NODE, cmd_net_pb.CMD_NODE_GET_GAME_NODE_RESP)
end

function GameRoom:onTouchBegan(touch, event)
	return true
end
-- 服务器返回单把(8局)数据
function GameRoom:onRcvHistoryOne(msgTbl)
	gt.removeLoadingTips()
	if #msgTbl.m_match == 0 then
		return false
	end
	self.historyMsgTbl.m_data[self.m_sender:getTag()].m_match = msgTbl.m_match

	self:historyItemClickEvent(self.m_sender)
end

function GameRoom:onRcvHistoryRecord(msgTbl)
	dump(msgTbl)
	if #msgTbl.m_data == 0 then
		-- 没有战绩
		local emptyLabel = gt.seekNodeByName(self.rootNode, "Label_empty")
		emptyLabel:setVisible(true)
	else
		-- 显示战绩列表
		self.historyMsgTbl = msgTbl

		local historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
		for i, cellData in ipairs(msgTbl.m_data) do
			local historyItem = self:createHistoryItem(i, cellData)
			historyListVw:pushBackCustomItem(historyItem)
		end
	end
end

function GameRoom:onRcvReplay(msgTbl)
	local replayLayer = require("app/views/ReplayLayer"):create(msgTbl)
	self:addChild(replayLayer, 6)
end

-- start --
--------------------------------
-- @class function
-- @description 创建战绩条目
-- @param cellData 条目数据
-- end --
function GameRoom:createHistoryItem(tag, cellData)
	local cellNode = cc.CSLoader:createNode("HistoryCell.csb")
	-- 序号
	local numLabel = gt.seekNodeByName(cellNode, "Label_num")
	numLabel:setString(tostring(tag))
	-- 房间号
	local roomIDLabel = gt.seekNodeByName(cellNode, "Label_roomID")
	roomIDLabel:setString(gt.getLocationString("LTKey_0039", cellData.m_deskId))
	-- 对战时间
	local timeLabel = gt.seekNodeByName(cellNode, "Label_time")
	local timeTbl = os.date("*t", cellData.m_time)
	timeLabel:setString(gt.getLocationString("LTKey_0040", timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, timeTbl.sec))
	-- 玩家昵称+分数
	for i=1, 4 do
		local nicknameLabel = gt.seekNodeByName(cellNode, "Label_nickname_" .. i)
		nicknameLabel:setString("")
		local scoreLabel = gt.seekNodeByName(cellNode, "Label_score_" .. i)
		scoreLabel:setString("")
	end

	for i, v in ipairs(cellData.m_nike) do
		-- print("玩家们的分数" .. cellData.m_score[i])
		local nicknameLabel = gt.seekNodeByName(cellNode, "Label_nickname_" .. i)
		nicknameLabel:setString(v)
		local scoreLabel = gt.seekNodeByName(cellNode, "Label_score_" .. i)
		scoreLabel:setString(tostring(cellData.m_score[i]))
	end

	local cellSize = cellNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(cellNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	cellItem:addClickEventListener(handler(self, self.sendHistoryOne))

	return cellItem
end

function GameRoom:historyItemClickEvent(sender, eventType)
	-- 隐藏历史记录
	local historyListVw = gt.seekNodeByName(self.rootNode, "ListVw_content")
	historyListVw:setVisible(false)
	-- 切换标题
	local titleRoomNode = gt.seekNodeByName(self.rootNode, "Node_titleRoom")
	titleRoomNode:setVisible(true)

	local itemTag = sender:getTag()
	local cellData = self.historyMsgTbl.m_data[itemTag]
	local historyDetailNode = gt.seekNodeByName(self.rootNode, "Node_historyDetail")
	local detailPanel = cc.CSLoader:createNode("HistoryDetail.csb")
	detailPanel:setAnchorPoint(0.5, 0.5)
	historyDetailNode:addChild(detailPanel)
     --label显示框
    self.labelFrame={}
    for i=1,4 do
    	local frame=gt.seekNodeByName(detailPanel,"Image_frame" .. i)
    	table.insert(self.labelFrame,frame)
    end
	-- 初始化
	for i=1, 4 do
		local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
		nicknameLabel:setString("")
	end 
	-- 玩家昵称
	self.labelsWidth={}
	for i, v in ipairs(cellData.m_nike) do
		local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. i)
		local framenickLabel=gt.seekNodeByName()
		--v = string.gsub(v, " ", "")
        local name=gt.seekNodeByName(self.labelFrame[i],"Label_"..i)
        name:setString(v)
        self.labelFrame[i]:setContentSize(cc.size(name:getContentSize().width+8,self.labelFrame[i]:getContentSize().height))
		self.labelFrame[i]:setPosition(nicknameLabel:getPositionX()-name:getContentSize().width/2,595)
		--table.insert(self.labelsWidth,self:getStringLen(v)*36)
		nicknameLabel:setString(self:getCutName(v,8,6))
		nicknameLabel:setTouchEnabled(true)
		nicknameLabel:setTag(i)
		
		nicknameLabel.m_name = v
		    local function touchEvent(sender, eventType)
	            if eventType == ccui.TouchEventType.began then  
                          self.labelFrame[sender:getTag()]:setVisible(true)
	            	elseif eventType == ccui.TouchEventType.ended
	            		or eventType == ccui.TouchEventType.canceled then
                          self.labelFrame[sender:getTag()]:setVisible(false)
	            end
            end
        nicknameLabel:addTouchEventListener(touchEvent)
    end
	
	-- 对应详细记录信息
	local contentListVw = gt.seekNodeByName(detailPanel, "ListVw_content")
	for i, v in ipairs(cellData.m_match) do
		local detailCellNode = cc.CSLoader:createNode("HistoryDetailCell.csb")
		
		-- 序号
		local numLabel = gt.seekNodeByName(detailCellNode, "Label_num")
		numLabel:setString(tostring(i))
		-- 对战时间
		local timeLabel = gt.seekNodeByName(detailCellNode, "Label_time")
		local timeTbl = os.date("*t", v.m_time)
		timeLabel:setString(string.format("%02d-%02d %02d:%02d:%02d", timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, timeTbl.sec))
		-- 对战分数
		for i=1, 4 do
			local scoreLabel = gt.seekNodeByName(detailCellNode, "Label_score_" .. i)
			scoreLabel:setString("")
		end
		for j, score in ipairs(v.m_score) do
			local nicknameLabel = gt.seekNodeByName(detailPanel, "Label_nickname_" .. j)
			local scoreLabel = gt.seekNodeByName(detailCellNode, "Label_score_" .. j)
			scoreLabel:setPositionX(nicknameLabel:getPositionX()+20)
			scoreLabel:setString(tostring(score))
		end

		-- 查牌按钮
		local replayBtn = gt.seekNodeByName(detailCellNode, "Btn_replay")
		-- replayBtn:setVisible(false)
		-- replayBtn:setTag(v.m_videoId)
		replayBtn.videoId = v.m_videoId
		gt.addBtnPressedListener(replayBtn, function(sender)
			local btnTag = sender.videoId

			-- 请求打牌回放数据
			local msgToSend = {}
			msgToSend.m_msgId = gt.CG_REPLAY
			msgToSend.m_videoId = btnTag
			gt.socketClient:sendMessage(msgToSend)
		end)

		-- 新架构测回放
		-- local replayBtn = gt.seekNodeByName(detailCellNode, "Btn_replay")
		-- replayBtn.videoId = v.m_videoId
		-- gt.addBtnPressedListener(replayBtn, function(sender)
		-- 	local btnTag = sender.videoId
		-- 	-- 请求打牌回放数据
		-- 	local msgToSend = {}
		-- 	msgToSend.m_msgId = gt.CG_REPLAY
		-- 	msgToSend.m_videoId = btnTag
		-- 	gt.socketClient:sendMessage(msgToSend)
		-- end)


		-- 分享按钮
		local shareBtn = gt.seekNodeByName(detailCellNode, "Btn_share")
		shareBtn.data = v
		gt.addBtnPressedListener(shareBtn, function(sender)
			local data = sender.data
			local msgToSend = {}
			msgToSend.m_msgId = gt.CG_SHARE_BTN
			msgToSend.m_videoId = data.m_videoId
			gt.socketClient:sendMessage(msgToSend)
		end)
		--暂时屏蔽查看他人战绩功能start
		-- shareBtn:setVisible(false)
		-- replayBtn:setPositionX(replayBtn:getPositionX() - 50)
		--暂时屏蔽查看他人战绩功能end

		local cellSize = detailCellNode:getContentSize()
		local detailItem = ccui.Widget:create()
		detailItem:setContentSize(cellSize)
		detailItem:addChild(detailCellNode)
		contentListVw:pushBackCustomItem(detailItem)
	end
end

--获得字符串的长度
function GameRoom:getStringLen(str)
	local len = 0
	local byteCount = 0
	local gap = 0
	for i = 1, string.len(str) do
		if gap > 0 then
			gap = gap - 1
		else
			local b = string.byte(string.sub(str, i, i))
			if b > 0 and b <= 127 then
		        byteCount = 1
		        len = len - 0.5
		    elseif b >= 192 and b < 223 then
		        byteCount = 2
		        len = len - 0.5
		    elseif b >= 224 and b < 239 then
		        byteCount = 3
		    elseif b >= 240 and b <= 247 then
		        byteCount = 4
		    end
		    gap = byteCount - 1
		    len = len + 1
		end
	end
	return len
end
--截取字符串
function GameRoom:getCutName(sName,nMaxCount,nShowCount)
    if sName == nil or nMaxCount == nil then
        return
    end
    local sStr = sName
    local tCode = {}
    local tName = {}
    local nLenInByte = #sStr
    local nWidth = 0
    if nShowCount == nil then
       nShowCount = nMaxCount - 3
    end
    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1)
            i = i + byteCount -1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tName,char)
            table.insert(tCode,1)
            
        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tName,char)
            table.insert(tCode,2)
        end
    end
    
    if nWidth > nMaxCount then
        local _sN = ""
        local _len = 0
        for i=1,#tName do
            _sN = _sN .. tName[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        sName = _sN .. ".."
    end
    return sName
end

--接受到服务器返回的回放码
function GameRoom:onRcvShare(msgTbl)
	if msgTbl.m_errorId == 0 then
		self.m_shareId = msgTbl.m_shareId
		if self.m_shareId and self.m_shareId ~= "" then

			local nickName = ""
			local tab = {}
			for uchar in string.gfind(gt.wxNickName, "[%z\1-\127\194-\244][\128-\191]*") do 
				tab[#tab+1] = uchar
				if #tab <= 6 then
					nickName = nickName .. uchar
				end
			end
			if #tab > 6 then
				nickName = nickName .. "..."
			end
			self.description = "玩家["..nickName.."]分享了一个回访码:"..self.m_shareId..",在大厅点击进入战绩页面,然后点击查看回访按钮,输入回访码点击确定后即可查看。"
			self.title = "闲来麻将"
			
			Utils.shareURLToHY( nil, self.title, self.description )
		else
			gt.floatText("回访码不存在")
		end
	else
		gt.floatText("录像不存在")
	end
end

return GameRoom