--提现
local gt = cc.exports.gt
local Utils = cc.exports.Utils
require("app.protocols.cmd_lobby_pb")

local WithdrawalScene = class("WithdrawalScene", function()
	return cc.Scene:create()
end)

function WithdrawalScene:ctor()

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("Withdraw_Scene.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    self.cur_count = 0      --提现次数
    self:registerScriptHandler(handler(self, self.onNodeEvent))
    
    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")
    self.lobby_bj = lobby_bj
    -- 跑马灯
	local marqueeNode = gt.seekNodeByName(lobby_bj, "Node_marquee")
	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)

    local Withdraw_Phone = gt.seekNodeByName(lobby_bj, "Withdraw_Phone")
    Withdraw_Phone:setVisible(false)
    local Withdraw_Confir = gt.seekNodeByName(lobby_bj, "Withdraw_Confir")
    Withdraw_Confir:setVisible(false)
    
    local Withdraw_Money = gt.seekNodeByName(lobby_bj, "Withdraw_Money")
    self.chuangchu = ccui.EditBox:create(cc.size(400,48), "") 
    self.chuangchu:setPosition(cc.p(107,62))
    self.chuangchu:setAnchorPoint(0, 0.5)
    self.chuangchu:setFontSize(40)
    self.chuangchu:setFontColor(cc.c3b(129,123,98))
    self.chuangchu:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    self.chuangchu:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.chuangchu:setPlaceHolder("可转出到卡" .. string.format("%.01f", gt.playerData.coin/10000))
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    Withdraw_Money:addChild(self.chuangchu)
    

    	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        Utils.setClickEffect()
        local MainScene = require("app/views/Scene/MainScene"):create()
        cc.Director:getInstance():replaceScene(MainScene)
	end)

    local chuangchu_but = gt.seekNodeByName(csbNode, "chuangchu_but")
	gt.addBtnPressedListener(chuangchu_but, function()
        --self.chuangchu:setTextColor(cc.c3b(255,255,255))
        Utils.setClickEffect()
        local nOutCoin = math.modf(string.format("%.01f", gt.playerData.coin/10000))
        nOutCoin = tostring(nOutCoin)
        self.chuangchu:setText(nOutCoin)
	end)
    
    local wangji_But = gt.seekNodeByName(csbNode, "wangji_But")
	gt.addBtnPressedListener(wangji_But, function()
        Utils.setClickEffect()
        
	end)
--    local wangji_But = gt.seekNodeByName(lobby_bj, "wangji_But")
--	gt.addBtnPressedListener(wangji_But, function()

--	end)

--    local yanzheng_but = gt.seekNodeByName(lobby_bj, "yanzheng_but")
--	gt.addBtnPressedListener(yanzheng_but, function()
--        local MJ_account = account:getStringValue()
--        --gt.log("MJ_account = ",MJ_account,#MJ_account)
--        if #MJ_account ~= 11 then
--           -- return
--        end

--        --发送手机校证码
--        local cmsg = cmd_account_pb.CPhoneVerifyReq()
--        cmsg.phone_type = 1
--        cmsg.verify_type = 1
--        cmsg.phone_number = MJ_account
--        local msgData = cmsg:SerializeToString()

--        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_REQ,msgData)
--	end)

    if gt.playerData.Banklist~=nil and #gt.playerData.Banklist > 0 then
        local accountName = gt.seekNodeByName(lobby_bj, "accountName")
        accountName:setString(gt.playerData.Bankname)
        local BankNo = gt.seekNodeByName(lobby_bj, "BankNo")
        BankNo:setString(gt.playerData.Banklist[1].bank_no)
    else
--       local scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, function ()
--       function OKcallfan(args)
--    		self:removeFromParent()
--            local AddCardSet = require("app/views/Scene/AddCardSet"):create()
--		    cc.Director:getInstance():replaceScene(AddCardSet) 
--            --gt.scheduler:unscheduleScriptEntry(scheduleHandler)  
--        end
--        require("app/views/UI/NoticeTips"):create("提示","你还没加银行卡，是否去添加相关信息？", OKcallfan, nil, false)
--        end),2,true)
        --return
    end
    
    local Withdraw_Password = gt.seekNodeByName(lobby_bj, "Withdraw_Password")
    local password = ccui.EditBox:create(cc.size(330,48), "") 
    password:setPosition(cc.p(107,44))
    password:setAnchorPoint(0, 0.5)
    password:setFontSize(40)
    password:setFontColor(cc.c3b(129,123,98))
    password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
    password:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    password:setPlaceHolder("提现密码")
    --password:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    Withdraw_Password:addChild(password)
    
    local wangji_But = gt.seekNodeByName(Withdraw_Password, "wangji_But")
    --修改资金密码
    wangji_But:addClickEventListener(function()
        local ChangePayWord = require("app/views/Scene/ChangePayWord"):create()
        self:addChild(ChangePayWord)
	end)



    local WithdrawSure_but = gt.seekNodeByName(csbNode, "WithdrawSure_but")
	gt.addBtnPressedListener(WithdrawSure_but, function()
        Utils.setClickEffect()
        local money = tonumber(self.chuangchu:getText())
        if money == nil then
            require("app/views/UI/NoticeTips"):create("提示","请输入提现金额！", nil, nil, true)            
            return
        elseif money < 100 then
            require("app/views/UI/NoticeTips"):create("提示","单次提现金额不得少于100！", nil, nil, true)            
            return
        elseif money > 1000000 then
            require("app/views/UI/NoticeTips"):create("提示","单次提现金额不得超过1000000！", nil, nil, true)            
            return
        elseif money > gt.playerData.coin/10000 then
            require("app/views/UI/NoticeTips"):create("提示","提现超出了你的额度！", nil, nil, true)            
            return
        end
        local cmsg = cmd_lobby_pb.CGetExchangeOrderReq()
        cmsg.payee_id = gt.playerData.Banklist[1].bank_id
        cmsg.pwd = gt.PasswordEncrypt(password:getText())
        --gt.log("WithdrawSure==",cmsg.pwd)
        cmsg.money = money * 100
        local msgData = cmsg:SerializeToString()
        --获取兑换订单号请求
        gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_EXCHANGE_ORDER_REQ,msgData)
        
	end)
       --获取兑换订单号应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_EXCHANGE_ORDER_RESP, self, self.onGetExchangeOrderResp)
    --获取用户今日提款次数（下行）
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_WITHDRAWAL_COUNT_RESP, self, self.onGetUserOrderNumResp)
    self.AddCardSet = require("app/views/Scene/AddCardSet"):create(1)
	self:addChild(self.AddCardSet)
    self.AddCardSet:setVisible(false)
end

function WithdrawalScene:onNodeEvent(eventName)
	if "enter" == eventName then
        if gt.playerData.Banklist~=nil and #gt.playerData.Banklist < 1 then
            function OKcallfan(args)

    		    self:removeFromParent()
                self.AddCardSet:setVisible(true)

                --gt.scheduler:unscheduleScriptEntry(scheduleHandler)  
            end
            function cancelFunc(args)
    		    self:removeFromParent()
                local MainScene = require("app/views/Scene/MainScene"):create()
                cc.Director:getInstance():replaceScene(MainScene)
            end
            require("app/views/UI/NoticeTips"):create("提示","你还没加银行卡，是否去添加相关信息？", OKcallfan, cancelFunc, false)
        else
            --获取用户今日提款次数（上行）空
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_USER_WITHDRAWAL_COUNT_REQ,"{}")
        end
    elseif "exit" == eventName then

    end
end

function WithdrawalScene:onGetExchangeOrderResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetExchangeOrderResp()
    stResp:ParseFromString(buf)
    gt.log("onGetExchangeOrderResp code:"..stResp.code)
    if stResp.code == 0 then
        self.cur_count =  self.cur_count + 1
        function OKcallfan()
            local MainScene = require("app/views/Scene/MainScene"):create()
            cc.Director:getInstance():replaceScene(MainScene)
        end
       require("app/views/UI/NoticeTips"):create("提示","取现已提交！", OKcallfan, nil, true)
       gt.scheduler:scheduleScriptFunc(handler(self, function ()
        self.chuangchu:setTextColor(cc.c3b(129,123,98))
        self.chuangchu:setText("可转出到卡" + string.format("%.01f", gt.playerData.coin/10000))
       end),2,true)
    elseif stResp.code == 2 then
       require("app/views/UI/NoticeTips"):create("提示","提现密码错误！", nil, nil, true)
    else
        require("app/views/UI/NoticeTips"):create("提示","提现错误！", nil, nil, true)
    end
    
end


function WithdrawalScene:onGetUserOrderNumResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetUserWithdrawalCountResp()
    stResp:ParseFromString(buf)
    gt.log("onGetUserOrderNumResp code:"..stResp.code)
    self.cur_count = stResp.cur_count
    if stResp.code == 0 then
        if stResp.limit_count - self.cur_count > 0 then
            local OrderNum = stResp.limit_count - self.cur_count
            local Text_Prompt3 = gt.seekNodeByName(self.lobby_bj, "Text_Prompt3")
            Text_Prompt3:setString("今日剩余免费提现次数："..OrderNum.."次")
            --require("app/views/UI/NoticeTips"):create("提示","今日剩余免费提现次数："..OrderNum.."次", nil, nil, true)
        else
            local Text_Prompt3 = gt.seekNodeByName(self.lobby_bj, "Text_Prompt3")
            Text_Prompt3:setString("今日免费提现次数已用完，\n继续提现将会收取3%服务费！")
            --require("app/views/UI/NoticeTips"):create("提示","今日免费提现次数已用完，继续提现将会收取3%服务费！", OKcallfan, nil, true)
        end
    else
        require("app/views/UI/NoticeTips"):create("提示","系统错误，请重试！", nil, nil, true)
    end
    
end

return WithdrawalScene

