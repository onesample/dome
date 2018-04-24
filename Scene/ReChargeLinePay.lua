
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local ReChargeLinePay = class("ReChargeLinePay", function()
	return cc.Layer:create()
end)

function ReChargeLinePay:ctor(bankinfo)
    --self.father = father

    local bankinfo = bankinfo or {}
	local csbNode = nil
	csbNode = cc.CSLoader:createNode("ReCharge_Line.csb")

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

    --银行信息
    local bankno = gt.seekNodeByName(csbNode, "bankno")
    local payee_name = gt.seekNodeByName(csbNode, "payee_name")
    local bank_branch_name = gt.seekNodeByName(csbNode, "bank_branch_name")
    local GetName 
    for i=1,#bankinfo do
        bankno:setString(bankinfo[1].bank_no)
        payee_name:setString(bankinfo[i].bank_of_deposit  .."    "..  bankinfo[i].payee_name)
        GetName = bankinfo[i].payee_name
        bank_branch_name:setString(bankinfo[i].bank_branch_name)
    end

    local Button_help = gt.seekNodeByName(csbNode, "Button_help")
    Button_help:setVisible(false)
    
    local Copy_but1 = gt.seekNodeByName(csbNode, "Button_copy")
    Copy_but1:addClickEventListener(function()
        gt.copyToClipboard(bankno:getString())
        require("app/views/UI/NoticeTips"):create("提示","复制卡号成功！", nil, nil, true)     
    end)

    local Button_copyName = gt.seekNodeByName(csbNode, "Button_copyName")
    Button_copyName:addClickEventListener(function()
        gt.copyToClipboard(GetName)
        require("app/views/UI/NoticeTips"):create("提示","复制姓名成功！", nil, nil, true)     
    end)
     --充值识别码
    local Recharge = gt.seekNodeByName(csbNode, "Editbox_1")
    local RechargeCode = gt.seekNodeByName(Recharge, "account_box")
    RechargeCode:setString(gt.playerData.recharge_code)
    --充值金额
    local MBEditbox = gt.seekNodeByName(csbNode, "Editbox_1_0")
    local money = ccui.EditBox:create(cc.size(350,100), "") 
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
            cmsg.pay_way = 2
            cmsg.pay_type = 1 -- tonumber(AccountValue)
            cmsg.money = MoneyValue
            local msgData = cmsg:SerializeToString()
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_OFFLINE_ORDER_REQ,msgData)        
        end
	end)

    --获取支付方式列表应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_OFFLINE_ORDER_RESP, self, self.onGetOfflineOrderResp)

end

function ReChargeLinePay:onGetOfflineOrderResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetOfflineOrderResp()
    stResp:ParseFromString(buf)
    gt.log("onGetOfflineOrderResp code:"..stResp.code)
    local this = self
    if stResp.code == 0 then
        function OKcallfan(args)
            gt.log("setVisible LinePay code------")
           self:removeFromParent()
        --self:setVisible(false)
        end
       require("app/views/UI/NoticeTips"):create("提示","提交成功，订单号："..stResp.order_id, OKcallfan, nil, false)
    elseif stResp.code ~= 0 then
       require("app/views/UI/NoticeTips"):create("提示","提交失败，请重试！", nil, nil, true)
    end
end

return ReChargeLinePay

