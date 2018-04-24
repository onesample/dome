
local gt = cc.exports.gt
local Utils = cc.exports.Utils
require("app.protocols.cmd_lobby_pb")

local DecdetailmoreScene = class("DecdetailmoreScene", function()
	return cc.Layer:create()
end)
DecdetaiList  = {
    {DateTime = "150270 3893",method = "三公三公三公",money = 60 ,shuying = 20},
    {DateTime = "150270 3893",method = "三公三公三公",money = 70 ,shuying = 20},
    {DateTime = "150270 3893",method = "三公三公三公",money = 80 ,shuying = 20},
    {DateTime = "150270 3893",method = "三公三公三公",money = 70 ,shuying = 20},
    {DateTime = "150270 3893",method = "三公三公三公",money = 90 ,shuying = 20},
    }
function DecdetailmoreScene:ctor()

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("Decdetail_more.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.began then

        elseif eventType == ccui.TouchEventType.canceled then
            
        elseif eventType == ccui.TouchEventType.ended then
            
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")
    self.csbNode = csbNode
    -- 跑马灯
	local marqueeNode = gt.seekNodeByName(lobby_bj, "Node_marquee")
	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)
	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
		--local RechargeChose = require("app/views/Scene/ReChargeChose"):create()
		--cc.Director:getInstance():replaceScene(RechargeChose)  
        --self:removeFromParent()
        Utils.setClickEffect()
        self:setVisible(false)
	end)
    self.Decdetail = gt.seekNodeByName(csbNode, "Decdetail_View")

    self.CTYIsup = true
    self.CTYbMove = true
    self.Country_Panel = gt.seekNodeByName(csbNode, "Country_Panel")
    self.Out_Layer = gt.seekNodeByName(self.Country_Panel, "Out_Layer")
    local CTYBut = gt.seekNodeByName(self.Country_Panel, "BtnOut")
    gt.addBtnPressedListener(CTYBut, handler(self, function()
        if self.CTYbMove then
            Utils.setClickEffect()
            self:CTYMove()
        end
	end))
    --local iii = self:dateChange("2013-03-01",1)
    self.LastTime = {}
    local nTime = os.time() - 86400
    self.curTime= os.date('%Y',nTime).."-"..os.date('%m',nTime).."-"..os.date('%d',nTime)
    self.TextTime_Out = gt.seekNodeByName(self.Country_Panel, "TextTime_Out")
    self.TextTime_Out:setString(self.curTime)
    for i = 1 ,7 do
        local TextTime = gt.seekNodeByName(self.Country_Panel, "TextTime_"..i)
        self.LastTime[i] = self:dateChange(self.curTime,i-1)
        TextTime:setString(self.LastTime[i])
        local BtnTime = gt.seekNodeByName(self.Country_Panel, "BtnTime_"..i)
        BtnTime:setTag(90+i)
        BtnTime:addTouchEventListener(btnEvent)
    end
    -- 获取用户投注详情
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_RESP, self, self.onGetUserBetDetailResp)

end

function DecdetailmoreScene:CTYMove()
    local pos
    local str = "res/res/OpenCountry/"
    self.CTYbMove = false
    if self.CTYIsup then
        pos = cc.p(self.Out_Layer:getPositionX(), self.Out_Layer:getPositionY() - 374)
        str = str.."button_zhankai.png"
    else
        pos = cc.p(self.Out_Layer:getPositionX(), self.Out_Layer:getPositionY() + 374)
        str = str.."button_zhankai_2.png"
    end
    local moveTo = cc.MoveTo:create(0.5, pos)
	local call = cc.CallFunc:create(function ()
        self.CTYbMove = true
        if self.CTYIsup then
            
        else
            
        end
        self.CTYIsup = not self.CTYIsup
        local grade_png = gt.seekNodeByName(self.Country_Panel, "SprZhankai")
        grade_png:setTexture(str)
            
	end)
	local spa = cc.Sequence:create(moveTo, call)
    self.Out_Layer:stopAllActions()
    self.Out_Layer:runAction(spa)
end

function DecdetailmoreScene:dateChange(time,dayChange)
    if string.len(time)==10 and string.match(time,"%d%d%d%d%-%d%d%-%d%d") then
        local year=string.sub(time,0,4);--年份
        local month=string.sub(time,6,7);--月
        local day=string.sub(time,9,10);--日
        local time=os.time({year=year, month=month, day=day})-dayChange*86400 --一天86400秒
        return (os.date('%Y',time).."-"..os.date('%m',time).."-"..os.date('%d',time))
    else
        return
    end
end
function DecdetailmoreScene:onButtonClickedEvent(tag, ref)   
    print("onButtonClickedEvent----",tag)
    self:CTYMove()
    if 91 == tag then
        self.TextTime_Out:setString(self.LastTime[tag-90])
        self:getBetDetailByRoom(self.LastTime[tag-90])
    elseif 92 == tag then
        self.TextTime_Out:setString(self.LastTime[tag-90])
        self:getBetDetailByRoom(self.LastTime[tag-90])
    elseif 93 == tag then
        self.TextTime_Out:setString(self.LastTime[tag-90])
        self:getBetDetailByRoom(self.LastTime[tag-90])
    elseif 94 == tag then
        self.TextTime_Out:setString(self.LastTime[tag-90])
        self:getBetDetailByRoom(self.LastTime[tag-90])
    elseif 95 == tag then
        self.TextTime_Out:setString(self.LastTime[tag-90])
        self:getBetDetailByRoom(self.LastTime[tag-90])
    elseif 96 == tag then
        self.TextTime_Out:setString(self.LastTime[tag-90])
        self:getBetDetailByRoom(self.LastTime[tag-90])
    elseif 97 == tag then
        self.TextTime_Out:setString(self.LastTime[tag-90])
        self:getBetDetailByRoom(self.LastTime[tag-90])
    end
end
function DecdetailmoreScene:getBetDetailByRoom(date_time)
    local cmsg = cmd_lobby_pb.CGetUserBetDetailReq()
    --cmsg.uid = gt.playerData.uid
    cmsg.detail_id = -1
    cmsg.detail_num = 50
    --cmsg.date_time = os.date("%Y-%m-%d")
    cmsg.date_time = date_time
    local msgData = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_BET_DETAIL_REQ,msgData)        
end
function DecdetailmoreScene:onGetUserBetDetailResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetUserBetDetailResp()
    stResp:ParseFromString(buf)
    if stResp.code == 0 then
         local yinkui_Num = gt.seekNodeByName(self.csbNode, "yinkui_Num")
         yinkui_Num:setString(string.format("%.01f", stResp.bet_win_lose/10000))
         gt.log("DecdetailmoreScene投注盈亏值:"..stResp.bet_win_lose)
         local lossvalue = stResp.bet_win_lose
         if stResp.bet_win_lose == nil then 
            lossvalue = 0
         end
        self:ShowData(lossvalue,stResp.bet_detail_list)
    end
end

function DecdetailmoreScene:ShowData(loss_value,msgdata)
    local yinkui_Num = gt.seekNodeByName(self.csbNode, "yinkui_Num")
    self.Decdetail:removeAllItems()
    local BjlareaName = {"闲(","庄(","和(","闲对(","庄对("}
    if nil ~= msgdata and type(msgdata) == "table" then
        for i=1, #msgdata do
            local lottary={} 
            lottary.DateTime = msgdata[i].create_time
            lottary.money = msgdata[i].refund
            local bet_chips = msgdata[i].area_id.."门(".. msgdata[i].bet_chips/10000 .. ")"
            if msgdata[i].play_method == 1 then
            play_method = "牌九"
            elseif msgdata[i].play_method == 2 then 
            play_method = "牛牛"
            elseif msgdata[i].play_method == 3 then 
            play_method = "三公"
            elseif msgdata[i].play_method == 4 then 
            play_method = "百家乐"
            bet_chips = BjlareaName[msgdata[i].area_id].. msgdata[i].bet_chips/10000 .. ")"
            elseif msgdata[i].play_method == 5 then 
            play_method = "单张"
            elseif msgdata[i].play_method == 6 then 
            play_method = "番摊"
            end
            --gt.log("投注明细========",msgdata[i].create_time,msgdata[i].detail_id)
            --gt.log("投注明细===",msgdata[i].create_time,msgdata[i].detail_id)
            lottary.issue = msgdata[i].issue
            lottary.lottery_id = msgdata[i].lottery_id
            lottary.money = bet_chips
            lottary.DateTime = os.date("%H:%M:%S",msgdata[i].create_time) --msgdata[i].create_time
            lottary.method = play_method
            lottary.table_name = msgdata[i].table_name
            if msgdata[i].exchange_type == 0 then
            lottary.shuying = "未结算"
            else
            lottary.shuying = string.format(string.format("%.01f", msgdata[i].balance_chips/10000)) --   msgdata[i].settle_chips/10000
            end
            --gt.log("投注明细===========",msgdata[i].table_id,msgdata[i].play_method,msgdata[i].settle_chips,msgdata[i].area_id,msgdata[i].bet_chips) 
		    local GameItem = self:createDetailItem(i, lottary)
		    self.Decdetail:pushBackCustomItem(GameItem)
	    end
    end
end

gametypelist = {"SaicheIco_1.png","ShiShiCaiIco_1.png","NongChangBg_1.png","KuaiTingBg_1.png"}
function DecdetailmoreScene:createDetailItem(tag, cellData)
	local RangeNode = cc.CSLoader:createNode("DecdetailMore_list.csb")

    local DetailListBg = gt.seekNodeByName(RangeNode,"detail_listBg")
    if tag%2 == 0 then
        DetailListBg:setTexture("res/res/LobbyHall/detail_listBg.png")
    else
        DetailListBg:setTexture("")
    end

    local gametuo = gt.seekNodeByName(RangeNode, "gametuo")
    local str = "res/res/GameList/"..gametypelist[cellData.lottery_id]
	if cc.FileUtils:getInstance():isFileExist(str) then
        gametuo:setTexture(str)
    end

    local GameType = gt.seekNodeByName(RangeNode, "GameType")
    GameType:setString(cellData.method)
    local TxtTime = gt.seekNodeByName(RangeNode,"TxtTime")
    TxtTime:setString(cellData.DateTime)
    local issue = gt.seekNodeByName(RangeNode,"issue")
    issue:setString(cellData.issue)
    local TxtName = gt.seekNodeByName(RangeNode,"TxtName")
    TxtName:setString(cellData.table_name)
    local TxtMoney = gt.seekNodeByName(RangeNode,"TxtMoney")
    TxtMoney:setString(cellData.money)
    local TxtShuying = gt.seekNodeByName(RangeNode,"TxtShuying")
    TxtShuying:setString(cellData.shuying)

    local cellSize = RangeNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RangeNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end
return DecdetailmoreScene

