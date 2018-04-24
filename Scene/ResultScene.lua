
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local ResultScene = class("ResultScene", function()
	return gt.createMaskLayer(160)
end)

ResultlistTap = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { periods = "639031", zhonjian = "2,0,5,3,6,5,6,7,4,8", DateTime = 1502703893,balance = "1-9,2-8,3-7,4-6,5-5" },
    { periods = "639031", zhonjian = "2,0,5,3,6,5,6,7,4,8", DateTime = 1502703893,balance = "1-9,2-8,3-7,4-6,5-5" },
    { periods = "639031", zhonjian = "2,0,5,3,6,5,6,7,4,8", DateTime = 1502703893,balance = "1-9,2-8,3-7,4-6,5-5" },
    { periods = "639031", zhonjian = "2,0,5,3,6,5,6,7,4,8", DateTime = 1502703893,balance = "1-9,2-8,3-7,4-6,5-5" },
    { periods = "639031", zhonjian = "2,0,5,3,6,5,6,7,4,8", DateTime = 1502703893,balance = "1-9,2-8,3-7,4-6,5-5" },
    { periods = "639031", zhonjian = "2,0,5,3,6,5,6,7,4,8", DateTime = 1502703893,balance = "1-9,2-8,3-7,4-6,5-5" },
        }
        
rewordlistTap = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { periods = "639031", zhonjian = "21985", DateTime = 1502703893 },
    { periods = "639031", zhonjian = "21985", DateTime = 1502703893 },
    { periods = "639031", zhonjian = "21985", DateTime = 1502703893 },
    { periods = "639031", zhonjian = "21985", DateTime = 1502703893 },
    { periods = "639031", zhonjian = "221985", DateTime = 1502703893 },
    { periods = "639031", zhonjian = "21985", DateTime = 1502703893 },
        }
RulelistTap = 
    {
        {TxtRule = "北京赛车游戏规則：\n"
        .."可在1-5編号押注，根据PK拾幵奖结果：\n"
        .."采集1, 2号车道作为第一编号幵奖结果；\n"
        .."采集3, 4号车道作为第二编号幵奖结果；\n"
        .."采集5, 6号车道作为第三编号开奖结果；\n"
        .."采集7, 8号车道作为第四编号开奖结果；\n"
        .."采集9, 10号车遥作为第五编号开奖结果；\n"
        .."根裾两个数字相加组合（双位数则取个位数），得出结果 \n"
        .."9点为最大，0点最小；\n"
        },
    }
resultBJLContent = 
    {
    {periods = "123靴\n12局", zhonjian = "0,1,0,0,0", DateTime = "1,2,3,4,5,6,7,8,9,10"},
    {periods = "123靴\n12局", zhonjian = "1,0,0,1,1", DateTime = "1,2,3,4,5,6,7,8,9,10"},
    {periods = "123靴\n12局", zhonjian = "0,0,1,1,0", DateTime = "1,2,3,4,5,6,7,8,9,10"},
    {periods = "123靴\n12局", zhonjian = "0,0,1,0,1", DateTime = "1,2,3,4,5,6,7,8,9,10"},
    
    }

function ResultScene:ctor(ChoseGameid,lottery_id)
    self.lottery_id = lottery_id
    self.ChoseGameid = ChoseGameid
    self._OfficNode = {}
    self._RuleNode = {}
    --print("ResultScene === ")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local csbNode = cc.CSLoader:createNode("Result_Layer.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
    csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	--self:setPosition(cc.p(-gt.winSize.width * 0.5, -gt.winSize.height + 57 ))
	self:addChild(csbNode)
	self.rootNode = csbNode
    --关闭按钮
    local Clsoe_but = gt.seekNodeByName(self.rootNode, "Button_Close")
    gt.addBtnPressedListener(Clsoe_but, handler(self, function()
        --gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_AUTHORITY_LOTTERY_NO_RSP)
        --gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_RSP)
        self:removeFromParent()
	end))

    self.ResultList = gt.seekNodeByName(csbNode, "ListView_Range")
    
    --self:initResultLater()
    --要启动联网取数据！
    --gt.showLoadingTips()
    --self:GetLotteryResult()
    self.MsgData = {}
    self.CommMsgData = {}
    self.BalanceInfo = {} --百家乐开奖结果
    gt.showLoadingTips()
    if self.ChoseGameid == 4 then
        self:GetLotteryResult()
    else
        gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_COMMON_BALANCE_REQ,{})
    end
    --官方开奖结果
    --gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_AUTHORITY_LOTTERY_NO_REQ,{})
    --gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_REQ,"{}")

    --家乐官方开奖结果(当天)请求 (上行) 空
    --gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_AUTHORITY_LOTTERY_NO_REQ,{})
    --官方开奖结果(当天)应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_AUTHORITY_LOTTERY_NO_RSP, self, self.onGameAuthorirtLotteryResp)
    --百家乐官方开奖结果(当天)应答 (下行)
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_AUTHORITY_LOTTERY_NO_RSP, self, self.OnGameBaccaratAuthorityRsp)

   --通用输赢(当天的输赢)应答 (下行)
--    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_COMMON_BALANCE_RSP, self, self.OnGameCommonBalanceRsp)
   --百家乐输赢（百家乐当前靴的输赢）应答
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_RSP, self, self.BaccaratBalanceRsp)

    local Reward_Result = gt.seekNodeByName(self.rootNode, "Reward_Result2")
    local Offic_Result = gt.seekNodeByName(self.rootNode, "Offic_Result2")
    local Game_rule = gt.seekNodeByName(self.rootNode, "Game_rule2")
    Offic_Result:setVisible(false)
    Game_rule:setVisible(false)
    Reward_Result:setVisible(true)
    local OfficResult = gt.seekNodeByName(self.rootNode, "Button_2")
    local RewardResult = gt.seekNodeByName(self.rootNode, "Button_1")
    local GameRule = gt.seekNodeByName(self.rootNode, "Button_3")
    gt.addBtnPressedListener(OfficResult, handler(self, function()
        Utils.setClickEffect()
        self.ResultList:removeAllItems()
        self:initResultLater()
        Reward_Result:setVisible(false)
        Offic_Result:setVisible(true)
        Game_rule:setVisible(false)
	end))
    gt.addBtnPressedListener(RewardResult, handler(self, function()
        Utils.setClickEffect()
        self.ResultList:removeAllItems()
        self:initRewardResult()
        Reward_Result:setVisible(true)
        Offic_Result:setVisible(false)
        Game_rule:setVisible(false)
	end))
    gt.addBtnPressedListener(GameRule, handler(self, function()
        Utils.setClickEffect()
        self.ResultList:removeAllItems()
        self:initGameRule()
        Reward_Result:setVisible(false)
        Offic_Result:setVisible(false)
        Game_rule:setVisible(true)
	end))

    local gameName = "";
    if self.lottery_id == 1  then
        gameName = "北京赛车PK10"
    elseif self.lottery_id == 4 then
        gameName = "幸运飞艇"
    end

    --print("self.ChoseGameid=============="..self.ChoseGameid)
    if self.ChoseGameid == 4 then
        self.TxtRule = "百家乐游戏规則：\n"
        .."每天开奖时间：09: 02-23: 57,每期5分钟，共179期；"
        ..gameName.."，分1，2，3，4，5，6，7，8，9，10十条车道；"
        .."百家乐是根据"..gameName.."官方的开奖结果采集而来，保证结果的公平性。 \n"
         .."\n"
        .."发牌：\n"
        .."百家乐开盘后发牌数为10张。由八副牌中随机抽取十张牌做为当局备选牌待PK拾开奖后。\n"
        .."\n"
        .."数牌：\n"
        .."由于"..gameName.."拾的发牌数为10张。开奖号为1到10号不重复的10个数字。"
        .."所以开奖号和发牌数可以相对应。发牌数从左到右依次为1到10的张牌位。"
        .."第1/2/3/4/5/6张牌（是否发第5第6张牌根据传统佰家乐规则确定）对应开奖号的第1/2/3/4/5/6位开奖号。\n"
        .."\n"
        .."中奖：\n"
        .."例发牌数为（10、K、8、8、6、J、6、1、7、2）\n"
        ..gameName.."开奖结果为（5、9、4、8、1、6、10、7、2、3）闲家牌6、8VS庄家牌7、1（投注庄家视为中奖）。"
    elseif self.ChoseGameid == 3 then
        self.TxtRule = "三公游戏规則：\n"
        .."每天开奖时间：09: 02-23: 57,每期5分钟，共179期,\n"
        ..gameName.."，分1，2，3，4，5，6，7，8，9，10十条车道 \n"
        .."三公（五门牌）是根据"..gameName.."官方的开奖结果采集而来，保证结果的公平性。\n"
        .."采集1, 2, 3号车道作为第一编号开奖结果；\n"
        .."采集3, 4, 5号车道作为第二编号开奖结果；\n"
        .."采集5, 6, 7号车道作为第一编号开奖结果；\n"
        .."采集7, 8, 9号车遒作为第一编号开奖结果；\n"
        .."采集9, 10, 1号车道作为第一编号开奖结果；\n"
        .."根据三个数字相加组合（双位数则取个位数得出结果\n"
        .."9点为最大，0点最小；\n"
        .."例：\n"
        .."第一门开出1, 3, 4,则为8点；\n"
        .."第二门开出4, 2, 5,则为1点；\n"
        .."第三门开出5, 6, 7则为8点；\n"
        .."第四门开出7, 8, 9则为4点；\n"
        .."第五门开出9, 10, 1则为0点；\n"
        .."则：\n"
        .."第一门开出8点，排名第二；\n"
        .."第二门开出1点，排名第四；\n"
        .."第三门开出8点，排名第一；\n"
        .."第四门开出4点，排名第三；\n"
        .."第五门开出0点，排名第五；\n"
        .."如果出现结果相同点数，如第一门采集到1，2，3，6点"
        .."第二门采集到4，5，7，6点 \n"
        .."则视哪门牌拿到最大数值单张牌，10号牌最大，1号牌最小；\n"
        .."所以，第二门拿到的数值大于第一门拿到的数值，第二门赢；\n"
    elseif self.ChoseGameid == 2 then
        self.TxtRule = "牛牛游戏规则：：\n"
        .."每天开奖时间：09: 02-23: 57,每期5分钟，共179期；\n"
        ..gameName.."，分1，2，3，4，5，6，7，8，9，10十条车道； \n"
        .."牛牛（两门牌）是根据"..gameName.."官方的开奖结果采集而来，保证结果的公平性。\n"
        .."\n"
        .."注：完全按照市面的玩法，任意组合一门3张牌；\n"
        .."如能组合为10点或10的倍数，则视为有牛。\n"
        .."剩余两张牌组合数字个位数为几，则为“牛几”。\n"
        .."如任意3张牌组合不出10点或10的倍数，则视为无牛；\n"
        .."\n"
        .."牛牛最大，如：2.3.5 1.9；\n"
        .."牛一最小，如：5.7.8 2.9；\n"
        .."无牛状态下，则比较数值大小定输蠃，10车道最大，1车道最小；\n"
        .."如：前区开出1.2.3.4.5	2+3+5 1+4,有牛，牛五；\n"
        .."后区开出6.7.8.9.10任意三张牌组合不能为10,则为无牛；\n"
        .."则：前区牛5，后区无牛，前区蠃。\n"
        .."如果出现有牛，牛数相同情况下，则开出数值有10的一方赢；\n"
        .."如果皆无牛，则开出数值有10的一方蠃；\n"
        .."牛5赢50%。\n"
    elseif self.ChoseGameid == 5 then
        self.TxtRule = "单张游戏规则：\n"
        .."开奖时间：每天10:00-22:00为日场，每十分钟开奖一次，日场为72期；\n"
        .."每天22:00-次日02:00为夜场，每五分钟开奖一次，夜场为48期；\n"
        .."每天日场和夜场共120期；\n"
        .."\n"
        .."重庆时时彩，分1，2，3，4，5，五个点数位新点数玩法，是根据重庆时时彩的官方。\n"
        .."网站开奖结果而来，保证结果的公平性。\n"
        .."分为五门牌，玩法十分简单，直接比各门采集得来的结果，数值9最大，数值0最小。\n"
        .."采集1号点为第一门；\n"
        .."采集2号点为第一门；\n"
        .."采集3号点为第一门；\n"
        .."采集4号点为第一门；\n"
        .."采集5号点为第一门；\n"
        .."例：\n"
        .."第一门开出4；\n"
        .."第二门开出8；\n"
        .."第三门开出8；\n"
        .."第四门开出2；\n"
        .."第五门开出4；\n"
        .."则：\n"
        .."第二门和第三门结果一样是8点，为最大。第二三门打和，赢一、四、五。按投注比例分配输赢额；\n"
        .."第一门和第五门结果一样是4点，第一五打和，负二三门，赢第四门，按投注比例分配输赢；\n"
        .."第四门开出结果为2，负其他四门牌，按投注比例分配输额。\n"
    elseif self.ChoseGameid == 1 then
        self.TxtRule = "牌九游戏规則：\n"
        .."每天开奖时间：09: 02-23: 57,每期5分钟，共179期；\n"
        ..gameName.."，分1，2，3，4，5，6，7，8，9，10十条车道； \n"
        .."牌九（五门牌）是根据"..gameName.."官方的开奖结果采集而来，保证结果的公平性。\n"
        .."\n"
        .."采集1, 2号车道作为第一门开奖结果；\n"
        .."采集3, 4号车道作为第二门开奖结果；\n"
        .."采集5, 6号车道作为第三门开奖结果；\n"
        .."采集7, 8号车道作为第四门开奖结果；\n"
        .."采集9, 10号车道作为第五门开奖结果；\n"
        .."根裾两个数字相加组合（双位数则取个位数），得出结果；\n"
        .."为9点最大，0点最小；\n"
        .."\n"
        .."例：\n"
        .."第一门开出1, 3,则为4点；\n"
        .."第二门开出5, 7,则为2点；\n"
        .."第三门开出9, 2,则为1点；\n"
        .."第四门开出4, 6,则为0点；\n"
        .."第五门开出8, 10,则为8点；\n"
        .."第一门开出4点，排名第二；\n"
        .."第二门开出2点，排名第三；\n"
        .."第三门开出1点，排名第四；\n"
        .."第四门开出0点，排名第五；\n"
        .."第五门开出8点，排名第一；\n"
        .."注：如果出现结果相同点数，如第一门采集到8，3，1点；\n"
        .."第二门采集到9，2，1点；\n"
        .."则视哪门牌拿到最大数值单张牌，10号牌最大，1号牌最小；\n"
        .."所以，第二门拿到的数值大于第一门拿到的数值，第二门赢；\n"
        .."当出现最小0点时，1输0.8；\n"
    elseif self.ChoseGameid == 6 then
        self.TxtRule = "番摊游戏规则：：\n"
        .."每天开奖时间：00: 04-23: 54,每期10分钟，共97期；\n"
        .."番摊是根据幸运农场官方的开奖结果采集而来，保证结果的公平性。\n"
        .."开奖号为1-20不重复的8个数字。\n"
        .."游戏共分8个房间，每个房间对应相同的开奖数字；\n"
        .."\n"
        .."例：1号房对应第一个开奖数字；\n"
        .."    2号房对应第二个开奖数字；\n"
        .."    8号房对应第八个开奖数字；\n"
        .."第一个开奖数字为13， 13÷4 余1  则为1号区域；\n"
        .."第二个开奖数字为14， 14÷4 余2  则为2号区域；\n"
        .."第三个开奖数字为15， 15÷4 余3  则为3号区域；\n"
        .."第四个开奖数字为16， 16÷4 余0  则为4号区域；\n"
        .."\n"
        .."1,2,3,4号区域每个区域1赔2.85；\n"
        .."连位1-2；2-3；3-4；1-4每个区域1赔0.95；\n"
    end
end

function ResultScene:GetLotteryResult()
   --百家乐输赢（百家乐当前靴的输赢）应答
    local cmsg = cmd_game_pb.CGetBaccaratBalanceReq()
    cmsg.msg_id = gt.EnterGameRoomId
    cmsg.node_id = gt.EnterGameRoomId
    local msgdata = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_REQ,msgdata)

--	local timestamp = os.time()
--	local appId = "1970010100000000"
--    --local uid = gt.playerData.uid
--    local lottery_id = self.lottery_id
--    local table_id = gt.EnterGameRoomId
--    local play_method = self.ChoseGameid
--    --local sign = "56D7E55DDBEB9365EDBD959382DC659C"
--	--local catStr = string.format("appId=%s&lottery_id=%s&room_id=%s&timestamp=%s&uid=%s&key=NKZYM92tYf1OyUpoPN8Zt1UuzUjhvZ0P",appId,lottery_id,room_id,timestamp,uid)
--	local catStr = string.format("appId=%s&lottery_id=%s&play_method=%s&table_id=%s&timestamp=%s&key=NKZYM92tYf1OyUpoPN8Zt1UuzUjhvZ0P",appId,lottery_id,play_method,table_id,timestamp)
--	gt.log("sendresponse",catStr)
--    --local generateMD5 = require("app/libs/md5")
--    --local sign = generateMD5.sum(catStr)
--    --local sign = cc.UtilityExtension:generateMD5(catStr)
--    local sign = md5(catStr)
--	local xhr = cc.XMLHttpRequest:new()
--	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
--	--local refreshTokenURL = string.format(gt.LotteryResult .."/lottery/getLotteryResult?appId=%s&lottery_id=%s&room_id=%s&timestamp=%s&uid=%s&sign=%s", appId, lottery_id, room_id, timestamp,uid,sign)
--	local refreshTokenURL = string.format(gt.LotteryResult .."/lottery/getLotteryResult")
--	gt.log("refreshTokenURL",refreshTokenURL)
--    xhr:setRequestHeader("Content-Type", "application/json")
--    xhr:open("POST", refreshTokenURL)

--    local retTable = {};    --最终产生json的表
--    retTable["appId"]=appId
--    retTable["lottery_id"]=lottery_id
--    retTable["timestamp"]=timestamp
--    --retTable["uid"]=uid
--    retTable["sign"]=sign
--    retTable["table_id"]=table_id
--    retTable["play_method"]=play_method
--    local sendJson = require("json").encode(retTable)
--    --dump(sendJson)

--    local function onResp()
--		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
--        	local response = xhr.response
--            --gt.log("response",response)
--			local respJson = require("json").decode(response)
--			--dump(respJson)
--            if respJson.code == 10000 then
--                self:ShowData(respJson.data)
--            end
--            -- 去掉转圈
--		    gt.removeLoadingTips()
--        elseif xhr.readyState == 1 and xhr.status == 0 then
--            gt.log("读取历史失败！")
--            -- 去掉转圈
--            function OKcallfan(args)
--    		    self:removeFromParent()
--            end
--            require("app/views/UI/NoticeTips"):create("提示","读取历史失败！", OKcallfan, nil, true)
--		    gt.removeLoadingTips()
--        end
--        xhr:unregisterScriptHandler()
--    end
--    xhr:registerScriptHandler(onResp)
--	xhr:send(sendJson)
end

function ResultScene:onGameAuthorirtLotteryResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_game_pb.SAuthorityLotteryNoResp()
    stResp:ParseFromString(buf)
    --gt.log("onGameAuthorirtLotteryResp code:"..stResp.code)
    if stResp.code == 0 then
        gt.removeLoadingTips()
        local lenlist = #stResp.lottery_no_list
        for i=1,lenlist do
            if i > 20 then
                return
            end

            local lottary={} 
            lottary.DateTime = stResp.lottery_no_list[i].datatime
            lottary.periods = stResp.lottery_no_list[i].issue
            lottary.zhonjian = stResp.lottery_no_list[i].lottery_no
            lottary.balance = stResp.lottery_no_list[i].balance
            self.LotteryNoData[i] = lottary
--            local GameItem = self:createResultItem(i, lottary)
--            self.ResultList:pushBackCustomItem(GameItem)
        end
   end
end

function ResultScene:OnGameCommonBalanceRsp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_game_pb.SCommonBalanceResp()
    stResp:ParseFromString(buf)
    --gt.log("OnGameCommonBalanceRsp code:"..stResp.code,#stResp.balance_list)
    if stResp.code == 0 then
        local lenlist = #stResp.balance_list
        for i=1,lenlist do
            if i > 20 then
                break
            end
            --gt.log("Rsp="..stResp.balance_list[i].balance,stResp.balance_list[i].issue)
            local lottary={} 
            lottary.DateTime = stResp.balance_list[i].datatime
            lottary.periods = stResp.balance_list[i].issue
            --lottary.zhonjian = stResp.balance_list[i].lottery_no
            lottary.balance = stResp.balance_list[i].balance
            self.CommMsgData[i] = lottary
            --local GameItem = self:createContentItem(i, lottary)
            --self.ResultList:pushBackCustomItem(GameItem) 
        end
        gt.removeLoadingTips()
        self.ResultList:removeAllItems()
        self:initRewardResult()
    end
end

function ResultScene:OnGameBaccaratAuthorityRsp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_game_pb.SBaccaratBalanceResp()
    stResp:ParseFromString(buf)
    --gt.log("OnGameBaccaratAuthorityRsp code:"..stResp.code)
    if stResp.code == 0 then
        --gt.removeLoadingTips()
        local lenlist = #stResp.balance_list
        for i=1,lenlist do
            local lottary={} 
            lottary.DateTime = stResp.balance_list[lenlist- i + 1].datatime
            lottary.periods = stResp.balance_list[lenlist- i + 1].issue
            lottary.zhonjian = stResp.balance_list[lenlist- i + 1].lottery_no
            lottary.balance = stResp.balance_list[lenlist- i + 1].balance
            self.CommMsgData[i] = lottary
            --local GameItem = self:createContentItem(i, lottary)
            --self.ResultList:pushBackCustomItem(GameItem) 
        end
        self.ResultList:removeAllItems()
        self:initRewardResult()
    end
end

function ResultScene:ShowData(msgdata)
    if nil ~= msgdata and type(msgdata) == "table" then
        for i=1, #msgdata do
            local lottary={} 
            lottary.DateTime = msgdata[i].period_id
            lottary.periods = msgdata[i].issue
            lottary.zhonjian = msgdata[i].lottery_number
            lottary.balance = msgdata[i].balance
            self.MsgData[i] = lottary

            if i < 8 then
                local GameItem = self:createResultItem(i, lottary)
		        self.ResultList:pushBackCustomItem(GameItem)
            end

--           if self.ChoseGameid == 4 then
--		        return
--            else
--                local GameItem = self:createContentItem(i, self.MsgData)
--		        self.ResultList:pushBackCustomItem(GameItem)
--            end
        end
    end
end


--官方结果层显示
function ResultScene:initResultLater()
	for i, cellData in ipairs(gt.LotteryNoData) do
        --if i < 8 then
		    local GameItem = self:createResultItem(i, cellData)
		    self.ResultList:pushBackCustomItem(GameItem)
        --end
	end
end

function ResultScene:createResultItem(tag, cellData)
	local OfficNode = cc.CSLoader:createNode("ResultListNode.csb")
    self._OfficNode[tag] = OfficNode
    local ReultList_Bg = gt.seekNodeByName(OfficNode, "ReultList_Bg")
    if tag%2 == 0 then
        ReultList_Bg:setTexture("res/res/RangeList/ReultList.png")
    else
        ReultList_Bg:setTexture("")
    end
--	-- 大标题
	local game_name = gt.seekNodeByName(OfficNode, "Text_1")
	game_name:setString(cellData.periods.."期")
--	-- 小标题
	local piaoti = gt.seekNodeByName(OfficNode, "Text_2")
	piaoti:setString(cellData.DateTime)
--	-- 期数
--	local qishu = gt.seekNodeByName(cellNode, "qishu")
--	--local qishu = os.date("*t", cellData.qishu)
--    --qishu:setText("最新开奖"..cellData.qishu.."期")
--	qishu:setString("最新开奖"..cellData.qishu.."期")
    numtap =  gt.string_split(cellData.zhonjian,",")
		for i = 1, 10  do
        --local num =  string.sub(RoomMsgTbl[2],i,i);
        local num =  numtap[i]
        --local sNum = ""
        if self.ChoseGameid ~= 6 then
		    local shade = gt.seekNodeByName(OfficNode, "shade_" .. i)
		    local shadow = gt.seekNodeByName(OfficNode, "shadow_" .. i)
            shadow:setVisible(false)
            shade:setPosition(80+516/(#numtap -1)*(i-1),shade:getPositionY())
            if #numtap <= 5 then
                shade:setPosition(124+394/(#numtap -1)*(i-1),shade:getPositionY())
            end
            if num == nil then
                shade:setVisible(false)
            else
                if num ~= "10" then
                    if self.ChoseGameid ~= 6 then
                        for w in string.gmatch(num, "[^%z]") do
                            num = w
                        end
                    end
                else
                    num = "0"
                end
            end
		    shade:setString(num)
        else
            local shade = gt.seekNodeByName(OfficNode, "shade_" .. i)
		    local shadow = gt.seekNodeByName(OfficNode, "shadow_" .. i)
            shade:setVisible(false)
            shadow:setPosition(80+516/(#numtap -1)*(i-1),shadow:getPositionY())
            if num == nil then
                shadow:setVisible(false)
            else
                if num ~= "10" then
                    if self.ChoseGameid ~= 6 then
                        for w in string.gmatch(num, "[^%z]") do
                            num = w
                        end
                    end
                end
            end
		    local lottery_num = gt.seekNodeByName(shadow, "lottery_num")
            lottery_num:setString(num)
        end
	end

--    -- 时间
--	local Time_bj = gt.seekNodeByName(cellNode, "Time_bj")
--    Time_bj:setTag(100 + tag)
--    table.insert(self.gamelist,Time_bj)

	local cellSize = OfficNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(OfficNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	return cellItem
end

--游戏规则层显示
function ResultScene:initGameRule()
	for i, cellData in ipairs(RulelistTap) do
		local GameItem = self:createRuleItem(i, cellData)
		self.ResultList:pushBackCustomItem(GameItem)
	end
end

function ResultScene:createRuleItem(tag, cellData)
	local RuleNode = cc.CSLoader:createNode("GameRuleLayer.csb")
    self._RuleNode[tag] = RuleNode
--	-- 大标题
	local game_name = gt.seekNodeByName(RuleNode, "Text_1")
    
	game_name:setString(self.TxtRule)

	local cellSize = RuleNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RuleNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end

--开奖结果层显示
function ResultScene:initRewardResult()
    gt.removeLoadingTips()
    if self.ChoseGameid == 4 then
        local GameItem = self:createRewordBJLItem(0, cellData)
        self.ResultList:pushBackCustomItem(GameItem)
	    --for i, cellData in ipairs(gt.BalanceInfo) do
        for i = 1,#gt.BalanceInfo do
        --if i < 8 then
            local cellData = gt.BalanceInfo[#gt.BalanceInfo - i + 1]
		    local GameItem = self:createContentBJLItem(i, cellData)
		    self.ResultList:pushBackCustomItem(GameItem)
        end
    elseif self.ChoseGameid == 2 then
        local GameItem = self:createRewordNNItem(0, cellData)
        self.ResultList:pushBackCustomItem(GameItem)
	    for i, cellData in ipairs(gt.CommMsgData) do
            local GameItem = self:createContentItem(i, cellData)
		    self.ResultList:pushBackCustomItem(GameItem)
	    end
    else
        local GameItem = self:createRewordItem(0, cellData)
        self.ResultList:pushBackCustomItem(GameItem)
	    for i, cellData in ipairs(gt.CommMsgData) do
            local GameItem = self:createContentItem(i, cellData)
		    self.ResultList:pushBackCustomItem(GameItem)
	    end
	end
end

function ResultScene:createRewordItem(tag, cellData)
	local RuleNode = cc.CSLoader:createNode("ReworldTitle.csb")
--	-- 大标题
	local cellSize = RuleNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RuleNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	return cellItem
end
function ResultScene:createRewordNNItem(tag, cellData)
	local RuleNode = cc.CSLoader:createNode("ReworldTitle_NiuNiu.csb")
--	-- 大标题
	local cellSize = RuleNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RuleNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	return cellItem
end
function ResultScene:createRewordBJLItem(tag, cellData)
	local RuleNode = cc.CSLoader:createNode("ReworldTitle_Bjl.csb")
--	-- 大标题
	local cellSize = RuleNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RuleNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	return cellItem
end

function ResultScene:createContentItem(tag, cellData)
	local OfficNode = cc.CSLoader:createNode("RewordListNode.csb")
    local ReultList_Bg = gt.seekNodeByName(OfficNode, "ReultList_Bg")
    if tag%2 == 0 then
        ReultList_Bg:setTexture("res/res/RangeList/ReultList.png")
    else
        ReultList_Bg:setTexture("")
    end
--	-- 期数
	local game_name = gt.seekNodeByName(OfficNode, "TxtNumPeriod")
	game_name:setString(cellData.periods)
--	-- 时间
	local piaoti = gt.seekNodeByName(OfficNode, "TxtTime")
	piaoti:setString(cellData.DateTime)
    --gt.log("createContentItem balance===",cellData.balance)
    local balance = gt.string_split(cellData.balance,",")
	for i = 1, 5  do
    --gt.log("balance_1===",balance[i])
        if balance[i] ~= "" and balance[i] then
            local balance_1 = gt.string_split(balance[i],"-");
            --local num =  string.sub(cellData.balance,i,i);
		    local qiuBg = gt.seekNodeByName(OfficNode, "TxtOrder_" ..balance_1[1])
            qiuBg:setString(balance_1[2])
--            if i < 3 then 
--		    qiuBg:setString(balance_1[3])
--            else
--            qiuBg:setString(0)
--            end

            --local Sprite = gt.seekNodeByName(OfficNode, "Sprite_" .. balance_1[1])
            local SpritePos = gt.seekNodeByName(OfficNode, "Sprite_" .. i)
            SpritePos:setPosition(cc.p(qiuBg:getPositionX(),SpritePos:getPositionY()))
        else
            local SpritePos = gt.seekNodeByName(OfficNode, "Sprite_" .. i)
            SpritePos:setVisible(false)
            local qiuBg = gt.seekNodeByName(OfficNode, "TxtOrder_" .. i)
		    qiuBg:setVisible(false)
        end
        if #balance < 5 then
            local SpritePos = gt.seekNodeByName(OfficNode, "Sprite_" .. i)
            local qiuBg = gt.seekNodeByName(OfficNode, "TxtOrder_" .. i)
            SpritePos:setPositionX(-168.75+337.5*i)
            qiuBg:setPositionX(-168.75+337.5*i)
        end
	end
	local cellSize = OfficNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(OfficNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end

function ResultScene:createContentBJLItem(tag, cellData)
    --{{}=2 {}="670989" {}="1-1-7,2-0-1,3-0,4-0,5-0" {}="02,07,03,01,08,05,09,06,04,10" {}="5,11,44,60,60,12,54,7,20,49," }
	local OfficNode = cc.CSLoader:createNode("RewordListNode_Bjl.csb")
    local ReultList_Bg = gt.seekNodeByName(OfficNode, "ReultList_Bg")
    if tag%2 == 0 then
        ReultList_Bg:setTexture("res/res/RangeList/ReultList.png")
    else
        ReultList_Bg:setTexture("")
    end
--	-- 局
	local game_name = gt.seekNodeByName(OfficNode, "TxtXue")
	game_name:setString(cellData.round_order.."局")
--	-- 期数
	local TxtPeriod = gt.seekNodeByName(OfficNode, "TxtPeriod")
	TxtPeriod:setString(cellData.issue.."期")
--	-- 赢区域
    local balance = gt.string_split(cellData.balance,",")
    for i= 1 ,5 do
        if balance[i] ~= "" and balance[i] then
            local balance_1 = gt.string_split(balance[i],"-");
            --local num =  string.sub(cellData.balance,i,i);
		    local piaoti = gt.seekNodeByName(OfficNode, "TxtWin_" ..balance_1[1])
            if balance_1[2] == "1" then
                piaoti:setVisible(true)
            else
                piaoti:setVisible(false)
            end
        end
    end
    --gt.log("balance===",cellData.balance)
    --中奖号码
    local numtap =  gt.string_split(cellData.lottery_no,",")
    local TxtZhongJiang = gt.seekNodeByName(OfficNode, "TxtZhongJiang")
    for i = 1, 10  do 
        if numtap[i] ~= "10" then
            for w in string.gmatch(numtap[i], "[^%z]") do
                numtap[i] = w
            end
        else
            numtap[i] = "0"
        end
    end
	TxtZhongJiang:setString(numtap[1]..numtap[2]..numtap[3]..numtap[4]..numtap[5]..numtap[6]..numtap[7]..numtap[8]..numtap[9]..numtap[10])
    --牌列表
    local MsgTbl = gt.string_split(cellData.baccarat_init_card,",")
	for i = 1, 10  do
    --gt.log("balance_1===",balance[i])
        local paiSpZ = gt.seekNodeByName(OfficNode, "Xiaopai_"..i)
        local paiColor,painum = math.modf(MsgTbl[i]/16)
        paiSpZ:setTexture("res/res/gamepai/PukePai_1_"..painum*16 .."_"..paiColor ..".png")
        paiSpZ:setScale(0.5)
	end
	local cellSize = OfficNode:getContentSize()
	local cellItem = ccui.Widget:create()
    --gt.log("BJLResultClickEvent===",tag)
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(OfficNode)
	cellItem:addClickEventListener(handler(self, self.BJLResultClickEvent))
	
	return cellItem
end

function ResultScene:BJLResultClickEvent(sender, eventType)
local BalanceDate = gt.BalanceInfo[#gt.BalanceInfo - sender:getTag() + 1] 

    local cmsg = cmd_game_pb.CGetBaccaratBalanceReq()
    cmsg.msg_id = gt.EnterGameRoomId
    cmsg.node_id = gt.EnterGameRoomId
    local msgdata = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_REQ,msgdata)

    local BJLResult = require("app/views/UI/BJLResult"):create(BalanceDate)
    self:addChild(BJLResult)
end

function ResultScene:onNodeEvent(eventName)
	if "enter" == eventName then
    --要启动联网取数据！
      gt.log("onNodeEvent===enter  ")
      gt.showLoadingTips()
      self.ResultList:removeAllItems()
      self:initRewardResult()
    elseif "exit" == eventName then

    end
end
return ResultScene