
local gt = cc.exports.gt
local Utils = cc.exports.Utils
require("app.protocols.cmd_lobby_pb")

local RechargeChose = class("RechargeChose", function()
	return cc.Layer:create()
end)

function RechargeChose:ctor()

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("ReCharge_Chose.csb")

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
--        local MainScene = require("app/views/Scene/MainScene"):create()
--        cc.Director:getInstance():replaceScene(MainScene)
        self:removeFromParent()
        --self:setVisible(false)
	end)
    --微信充值
	local WechatBtn = gt.seekNodeByName(csbNode, "Button_Weixin")
    WechatBtn:setVisible(false)
    --QQ充值
	local QQPayBtn = gt.seekNodeByName(csbNode, "Button_QQ")
    QQPayBtn:setVisible(false)
    --代充值
	local AgentPayBtn = gt.seekNodeByName(csbNode, "Button_Ali")
    --银行卡充值
	local BankPayBtn = gt.seekNodeByName(csbNode, "Button_Line")
    --修改资金密码
	local ChangePayBtn = gt.seekNodeByName(csbNode, "Button_ChangePass")
    
    --微信充值
    WechatBtn:addClickEventListener(function()
       require("app/views/UI/NoticeTips"):create("提示","功能末开启！", nil, nil, true)
	end)
    --QQ充值
    QQPayBtn:addClickEventListener(function()
       require("app/views/UI/NoticeTips"):create("提示","功能末开启！", nil, nil, true)
	end)    
    
    --修改资金密码
    ChangePayBtn:addClickEventListener(function()
        local ChangePayWord = require("app/views/Scene/ChangePayWord"):create()
        self:addChild(ChangePayWord)
	end)
    self.OfflineThirdPayTypeS = gt.OfflineThirdPayTypeS
    self.bank_infoS = gt.bank_infoS
    --获取支付方式列表请求
    --gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PAYWAY_REQ,"{}") 
    
    AgentPayBtn:addClickEventListener(function()
        self.RechargeScene = require("app/views/Scene/RechargeScene"):create(self.OfflineThirdPayTypeS)
        self:addChild(self.RechargeScene)
	end)
    BankPayBtn:addClickEventListener(function()
        self.ReChargeLinePay = require("app/views/Scene/ReChargeLinePay"):create(self.bank_infoS)
        self:addChild(self.ReChargeLinePay)
	end)
end


function RechargeChose:onGetPaywayResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.CGetPaywayResp()
    stResp:ParseFromString(buf)
    gt.log("onGetPaywayResp code:"..stResp.code)
end


return RechargeChose

