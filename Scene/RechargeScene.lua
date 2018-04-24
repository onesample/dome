
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local RechargeScene = class("RechargeScene", function()
	return cc.Layer:create()
end)

function RechargeScene:ctor(OfflineThirdPayTypeS)

    local OfflineThirdPayTypeS = OfflineThirdPayTypeS or {}
	local csbNode = nil
	csbNode = cc.CSLoader:createNode("ReCharge_Scene.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    
    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")
    -- 跑马灯
	local marqueeNode = gt.seekNodeByName(lobby_bj, "Node_marquee")
	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)
	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        Utils.setClickEffect()
		--local RechargeChose = require("app/views/Scene/ReChargeChose"):create()
		--cc.Director:getInstance():replaceScene(RechargeChose)  
        self:removeFromParent()
        --self:setVisible(false)
	end)

     --微信充值
	local WechatBtn = gt.seekNodeByName(csbNode, "WePay_Btn")
    local ChoseBtn1 = gt.seekNodeByName(WechatBtn, "ChoseBtn")
    local ChoseOn1 = gt.seekNodeByName(WechatBtn, "ChoseOn")
    local Copy_but1 = gt.seekNodeByName(WechatBtn, "Button_copy")
    Copy_but1:addClickEventListener(function()
        local TxtWeChat = gt.seekNodeByName(WechatBtn, "TxtWeChat")
        gt.copyToClipboard(TxtWeChat:getString())
        require("app/views/UI/NoticeTips"):create("提示","复制成功！\n请添加官方代充微信号", nil, nil, true)     
    end)
    
    --支付宝充值
	local AliPayBtn = gt.seekNodeByName(csbNode, "AliPay_Btn")
    local ChoseBtn2 = gt.seekNodeByName(AliPayBtn, "ChoseBtn")
    local ChoseOn2 = gt.seekNodeByName(AliPayBtn, "ChoseOn")
    local Copy_but2 = gt.seekNodeByName(AliPayBtn, "Button_copy")
    Copy_but2:addClickEventListener(function()
        local TxtWeChat = gt.seekNodeByName(AliPayBtn, "TxtWeChat")
        gt.copyToClipboard(TxtWeChat:getString())
        require("app/views/UI/NoticeTips"):create("提示","复制成功！\n请添加官方代充支付宝账号", nil, nil, true)  
    end)
    ChoseOn2:setVisible(false)

    local Button_help = gt.seekNodeByName(csbNode, "Button_help")
    Button_help:setVisible(false)

    local pay_way = 1
    local pay_type = 1
    local ChosesWeChatBtn = gt.seekNodeByName(WechatBtn, "ChosesWeChatBtn")
    ChosesWeChatBtn:addClickEventListener(function()
        ChoseOn1:setVisible(true)
		ChoseOn2:setVisible(false)
		--ChoseOn3:setVisible(false)
        pay_way = 1
        pay_type = 1
	end)
    local ChosesAliPayBtn = gt.seekNodeByName(AliPayBtn, "ChosesAliPayBtn")
    ChosesAliPayBtn:addClickEventListener(function()
        ChoseOn1:setVisible(false)
		ChoseOn2:setVisible(true)
		--ChoseOn3:setVisible(false)
        pay_way = 1
        pay_type = 2
	end)

    --微信充值
    local TxtWeChat1 = gt.seekNodeByName(WechatBtn, "TxtWeChat")
    local TxtWeChat2 = gt.seekNodeByName(AliPayBtn, "TxtWeChat")
    for i=1,#OfflineThirdPayTypeS do
        if OfflineThirdPayTypeS[i].pay_type == 1  then  --微信
            TxtWeChat1:setString(OfflineThirdPayTypeS[i].pay_account)
        end
        if OfflineThirdPayTypeS[i].pay_type == 2  then  --支付宝
            TxtWeChat2:setString(OfflineThirdPayTypeS[i].pay_account)
        end
    end

    --充值识别码
    local Recharge = gt.seekNodeByName(csbNode, "Editbox_1")
    local RechargeCode = gt.seekNodeByName(Recharge, "account_box")
    RechargeCode:setString(gt.playerData.recharge_code)
    --充值金额
    local MBEditbox = gt.seekNodeByName(csbNode, "Editbox_1_0")
    local money = ccui.EditBox:create(cc.size(600,100), "") 
    money:setPosition(cc.p(110,50))
    money:setAnchorPoint(0, 0.5)
    money:setFontSize(70)
    money:setFontColor(cc.c3b(255,255,255))
    money:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    money:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    money:setPlaceHolder("充值金额")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    MBEditbox:addChild(money)

    --提交按钮
	local SubmitBtn = gt.seekNodeByName(csbNode, "login_but")
	gt.addBtnPressedListener(SubmitBtn, function()
       local MoneyValue =  money:getText()
       gt.log("MJ_account",MoneyValue)
        MoneyValue = tonumber(MoneyValue)
        if MoneyValue == nil then
            require("app/views/UI/NoticeTips"):create("提示","请输入充值金额！", nil, nil, true)       
        elseif MoneyValue<100 then
            require("app/views/UI/NoticeTips"):create("提示","最低充值100元！", nil, nil, true)         
        else
            --提交订单号请求
            local cmsg = cmd_lobby_pb.CGetOfflineOrderReq()
            cmsg.pay_way = pay_way
            cmsg.pay_type = pay_type -- tonumber(AccountValue)
            cmsg.money = MoneyValue
            local msgData = cmsg:SerializeToString()
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_OFFLINE_ORDER_REQ,msgData)        
        end
	end)

    --获取支付方式列表应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_OFFLINE_ORDER_RESP, self, self.onGetOfflineOrderResp)

end


function RechargeScene:onGetOfflineOrderResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetOfflineOrderResp()
    stResp:ParseFromString(buf)
    gt.log("onGetOfflineOrderResp code:"..stResp.code)
    local this = self
    if stResp.code == 0 then
        function OKcallfan()
           --gt.log("setVisible code--1111----")
           self:removeFromParent()
        --self:setVisible(false)
        end
       require("app/views/UI/NoticeTips"):create("提示","提交成功，订单号："..stResp.order_id, OKcallfan, nil, true)
    elseif stResp.code ~= 0 then
       require("app/views/UI/NoticeTips"):create("提示","提交失败，请重试！", nil, nil, true)
    end
end

return RechargeScene

