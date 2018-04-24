
local gt = cc.exports.gt
local Utils = cc.exports.Utils
require("app.protocols.cmd_lobby_pb")

local AddCardSet = class("AddCardSet", function()
	return cc.Layer:create()
end)

function AddCardSet:ctor(BackToMain)
    
	-- 注册节点事件
	--self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("CardMange_Scene.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    
    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")
    -- 跑马灯
	local marqueeNode = gt.seekNodeByName(lobby_bj, "Node_marquee")
	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)

    self.NoCard = gt.seekNodeByName(csbNode, "NoCard_Panel")        --无卡片添加银行卡
	self.NoCard:setVisible(true)
    self.ConfirPhone = gt.seekNodeByName(csbNode, "ConfirPhone_Panel")          --输入手机号验证
	self.ConfirPhone:setVisible(false)
    self.BankCard = gt.seekNodeByName(csbNode, "BankCard_Panel")                --输入银行卡验证
	self.BankCard:setVisible(false)
    self.OperSuccess = gt.seekNodeByName(csbNode, "OperSuccess_Panel")          --绑定成功
	self.OperSuccess:setVisible(false)

    self.MyBankCard = true
    if gt.playerData.Bankname == "name" then
        self.MyBankCard = false
    end

    

--    local bgBtn = cc.Scale9Sprite:create("res/BettingEveryDay/Bank_bg.png")  
--    local bgBtnHighLight = cc.Scale9Sprite:create("res/BettingEveryDay/Bank_bg.png")  
--    local titleBtnLabel = cc.Label:createWithSystemFont("SimulateDataSimulateData", "Marker Felt", 30)  
--    titleBtnLabel:setColor(cc.c3b(159,168,175))  

--    local controlButton = cc.ControlButton:create(titleBtnLabel, bgBtn)  
--    controlButton:setBackgroundSpriteForState(bgBtnHighLight,cc.CONTROL_STATE_HIGH_LIGHTED)  
--    controlButton:setTitleColorForState(cc.c3b(255, 255, 255), cc.CONTROL_STATE_HIGH_LIGHTED )  
--    controlButton:setPosition(375,600)  
--    --绑定事件  
--    controlButton:registerControlEventHandler(TouchDownAction, cc.CONTROL_EVENTTYPE_TOUCH_DOWN)  
--    csbNode:addChild(controlButton)  
--    local function TouchDownAction()  

--    end  

    --点击添加银行卡
    local AddCard_btn = gt.seekNodeByName(self.NoCard, "Add_but")
    gt.addBtnPressedListener(AddCard_btn, function()
        Utils.setClickEffect()
        if self.MyBankCard then
            self.NoCard:setVisible(false)
            self.BankCard:setVisible(true)
        else
            self.NoCard:setVisible(false)
            self.ConfirPhone:setVisible(true)
        end
    end)

    local Phonebox = gt.seekNodeByName(self.ConfirPhone, "Editbox_Phone")
    local PhoneText = ccui.EditBox:create(cc.size(330,48), "") 
    PhoneText:setPosition(cc.p(233,48))
    PhoneText:setAnchorPoint(0, 0.5)
    PhoneText:setFontSize(40)
    PhoneText:setFontColor(cc.c3b(255,255,255))
    PhoneText:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    PhoneText:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    PhoneText:setPlaceHolder("手机号")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    Phonebox:addChild(PhoneText)
    self.PhoneText = PhoneText

    --校验码正确下一步
    local Verify_btn = gt.seekNodeByName(self.ConfirPhone, "Button_verify")
    gt.addBtnPressedListener(Verify_btn, function()
        --发送手机校证码
        local cmsg = cmd_account_pb.CPhoneVerifyReq()
        cmsg.phone_type = 2
        --cmsg.verify_type = 3
        cmsg.phone_number = PhoneText:getText()
        gt.log("phone_number"..PhoneText:getText())
        local msgData = cmsg:SerializeToString()

        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_REQ,msgData)
    
    end)

        --加收款人
        local Peoplebox = gt.seekNodeByName(self.ConfirPhone, "Editbox_People")
        local PeoplText = ccui.EditBox:create(cc.size(330,48), "") 
        PeoplText:setPosition(cc.p(233,48))
        PeoplText:setAnchorPoint(0, 0.5)
        PeoplText:setFontSize(40)
        PeoplText:setFontColor(cc.c3b(255,255,255))
        PeoplText:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
        PeoplText:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        PeoplText:setPlaceHolder("姓名")
        --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
        Peoplebox:addChild(PeoplText)

        local Checkbox = gt.seekNodeByName(self.ConfirPhone, "Editbox_Check")
        local CheckText = ccui.EditBox:create(cc.size(330,48), "") 
        CheckText:setPosition(cc.p(233,48))
        CheckText:setAnchorPoint(0, 0.5)
        CheckText:setFontSize(40)
        CheckText:setFontColor(cc.c3b(255,255,255))
        CheckText:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
        CheckText:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        CheckText:setPlaceHolder("校验码")
        --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
        Checkbox:addChild(CheckText)
        if gt.playerData.playerType == 1 then 
            Checkbox:setVisible(false)
        end
        local OutWordbox = gt.seekNodeByName(self.ConfirPhone, "Editbox_OutWord")
        local OutWordText = ccui.EditBox:create(cc.size(330,48), "") 
        OutWordText:setPosition(cc.p(233,48))
        OutWordText:setAnchorPoint(0, 0.5)
        OutWordText:setFontSize(40)
        OutWordText:setFontColor(cc.c3b(255,255,255))
        OutWordText:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
        OutWordText:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        OutWordText:setPlaceHolder("提现密码")
        --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
        OutWordbox:addChild(OutWordText)
        self.OutWordText = OutWordText
        --重复密码
        local RepOutWordbox = gt.seekNodeByName(self.ConfirPhone, "Editbox_RepOutWord")
        local RepOutWordText = ccui.EditBox:create(cc.size(330,48), "") 
        RepOutWordText:setPosition(cc.p(233,48))
        RepOutWordText:setAnchorPoint(0, 0.5)
        RepOutWordText:setFontSize(40)
        RepOutWordText:setFontColor(cc.c3b(255,255,255))
        RepOutWordText:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
        RepOutWordText:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        RepOutWordText:setPlaceHolder("重复密码")
        RepOutWordText:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
        RepOutWordbox:addChild(RepOutWordText)
        self.RepOutWordText = RepOutWordText

    --校验码正确下一步
    local bindingNext_btn = gt.seekNodeByName(self.ConfirPhone, "Next_but")
    gt.addBtnPressedListener(bindingNext_btn, function()
        
--        if #PeoplText:getStringValue() < 5 or #PhoneText:getStringValue() < 5 or #OutWordText:getStringValue()<8 then
--            require("app/views/UI/NoticeTips"):create("提示","资料不全!", nil, nil, true)
--            return
--        end
        if self.OutWordText:getText() ~= self.RepOutWordText:getText() or self.RepOutWordText:getText() == "" then
            require("app/views/UI/NoticeTips"):create("提示","请输入正确密码!", nil, nil, true)
            return
       end
        if PeoplText:getText() == "" then
            require("app/views/UI/NoticeTips"):create("提示","请输入正确姓名!", nil, nil, true)
            return
       end
        if PhoneText:getText() == "" then
            require("app/views/UI/NoticeTips"):create("提示","请输入正确手机号!", nil, nil, true)
            return
       end
        local cmsg = cmd_lobby_pb.CAddPayeeRecordReq()
        cmsg.payee_name = PeoplText:getText()
        cmsg.phone_number = PhoneText:getText()
        cmsg.pwd =gt.PasswordEncrypt(OutWordText:getText()) 
        if gt.playerData.playerType ~= 1 then 
            cmsg.verify_code = tonumber(CheckText:getText())
        end
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_ADD_PAYEE_RECORD_REQ,msgData)        

    end)
    local BankCardBox = gt.seekNodeByName(self.BankCard, "Editbox_BankCard")
    local BankCardText = ccui.EditBox:create(cc.size(430,48), "") 
    BankCardText:setPosition(cc.p(200,48))
    BankCardText:setAnchorPoint(0, 0.5)
    BankCardText:setFontSize(40)
    BankCardText:setFontColor(cc.c3b(255,255,255))
    BankCardText:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    BankCardText:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    BankCardText:setPlaceHolder("银行卡号")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    BankCardBox:addChild(BankCardText)
    self.BankCardText = BankCardText
    --输入银行卡 sunbmit_but
    local sunbmit_but = gt.seekNodeByName(self.BankCard, "sunbmit_but")
    gt.addBtnPressedListener(sunbmit_but, function()
        local cmsg = cmd_lobby_pb.CAddPayeeBankcardReq()
        cmsg.bank_no = BankCardText:getText()
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_ADD_PAYEE_BANKCORD_REQ,msgData)
    end)

    --继续添加银行卡
    local continue_but = gt.seekNodeByName(self.OperSuccess, "continue_but")
    gt.addBtnPressedListener(continue_but, function()
        
        self.BankCard:setVisible(true)
        self.OperSuccess:setVisible(false)
    end)

    --获取收款人请求
    --gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PAYEE_RECORD_REQ,"{}")

    --修改密码应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_ADD_PAYEE_RECORD_RESP, self, self.onPayeeRecordResp)
    --获取收款人应答
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PAYEE_RECORD_RESP, self, self.onGetPayeeResp)
    --增加收款人银行卡应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_ADD_PAYEE_BANKCORD_RESP, self, self.onAddPayeeResp)

	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        Utils.setClickEffect()
        if self.ConfirPhone:isVisible() == true then
            self.ConfirPhone:setVisible(false)
            self.NoCard:setVisible(true)
        elseif self.BankCard:isVisible() == true  then
            self.BankCard:setVisible(false)
            self.ConfirPhone:setVisible(false)
            self.NoCard:setVisible(true)
        elseif self.OperSuccess:isVisible() == true  then
            self.OperSuccess:setVisible(false)
            self.NoCard:setVisible(true)
            if BackToMain == 1 then
                local MainScene = require("app/views/Scene/MainScene"):create()
                cc.Director:getInstance():replaceScene(MainScene)
            else
                self:setVisible(false)
            end
        else
            if BackToMain == 1 then
                local MainScene = require("app/views/Scene/MainScene"):create()
                cc.Director:getInstance():replaceScene(MainScene)
            else
                self:setVisible(false)
            end
        end
	end)

end
function AddCardSet:editboxHandle(strEventName,sender)
    if strEventName == "began" then
        --sender:selectedAll() --光标进入，选中全部内容
    elseif strEventName == "return" then
    
    elseif strEventName == "changed" then 

    elseif strEventName == "ended" then
       if self.OutWordText:getText() ~= self.RepOutWordText:getText() then
            require("app/views/UI/NoticeTips"):create("提示","两次密码输入不一致!", nil, nil, true)
            self.RepOutWordText:setText("") 
            return
       end
    end
end
function AddCardSet:onAddPayeeResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SAddPayeeBankcardResp()
    stResp:ParseFromString(buf)
    gt.log("onAddPayeeResp code:"..stResp.code)
    if stResp.code == 0 then
        self.BankCard:setVisible(false)
        self.BankCardText:setText("")
        self.OperSuccess:setVisible(true)
        gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PAYEE_RECORD_REQ,"{}")
    elseif stResp.code == 1 then
       require("app/views/UI/NoticeTips"):create("提示","系统错误", nil, nil, true)
    elseif stResp.code == 2 then
       require("app/views/UI/NoticeTips"):create("提示","银行卡号格式错误", nil, nil, true)
    elseif stResp.code == 3 then
       require("app/views/UI/NoticeTips"):create("提示","卡号已存在", nil, nil, true)
    elseif stResp.code == 4 then
       require("app/views/UI/NoticeTips"):create("提示","收款人不存在", nil, nil, true)
    end
end

function AddCardSet:onPayeeRecordResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SAddPayeeRecordResp()
    stResp:ParseFromString(buf)
    gt.log("onPayeeRecordResp code:"..stResp.code)
    if stResp.code == 0 then
        self.BankCard:setVisible(true)
        self.ConfirPhone:setVisible(false)
        self.NoCard:setVisible(false)
        self.OperSuccess:setVisible(false)
    elseif stResp.code == 1 then
       require("app/views/UI/NoticeTips"):create("提示","系统错误", nil, nil, true)
    elseif stResp.code == 2 then
       require("app/views/UI/NoticeTips"):create("提示","密码格式非法", nil, nil, true)
    elseif stResp.code == 3 then
       require("app/views/UI/NoticeTips"):create("提示","收款人格式非法", nil, nil, true)
    elseif stResp.code == 4 then
       require("app/views/UI/NoticeTips"):create("提示","注册类型非法", nil, nil, true)
    elseif stResp.code == 5 then
       require("app/views/UI/NoticeTips"):create("提示","手机号码非法", nil, nil, true)
    elseif stResp.code == 6 then
       require("app/views/UI/NoticeTips"):create("提示","验证码长度非法", nil, nil, true)
    elseif stResp.code == 7 then
       require("app/views/UI/NoticeTips"):create("提示","验证码不存在", nil, nil, true)
    elseif stResp.code == 8 then
       require("app/views/UI/NoticeTips"):create("提示","验证码已过期", nil, nil, true)
    elseif stResp.code == 9 then
       require("app/views/UI/NoticeTips"):create("提示","验证码不匹配", nil, nil, true)
    elseif stResp.code == 10 then
       require("app/views/UI/NoticeTips"):create("提示","收款人已存在", nil, nil, true)
    else
       require("app/views/UI/NoticeTips"):create("提示","code = "..stResp.code, nil, nil, true)
    end
end

--function AddCardSet:onNodeEvent(eventName)
--	if "enter" == eventName then

--	elseif "exit" == eventName then
--        gt.log("退出AddCardSet")
--        self:unregisterAllMsgListener()
--    end	     
--end

function AddCardSet:unregisterAllMsgListener()
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_PAYEE_RECORD_RESP)
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_ADD_PAYEE_RECORD_RESP)
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_RESP)
end

function AddCardSet:setCardVisible(bVisible)
	if bVisible then
        if #gt.playerData.Banklist>0 then
            local NocardBg = gt.seekNodeByName(self.NoCard, "NocardBg")
            NocardBg:setTexture("res/BettingEveryDay/Bank_bg.png")
            local BankText = gt.seekNodeByName(self.NoCard, "BankText")
            BankText:setString(gt.playerData.Banklist[1].bank_no)
        end
    end
end

return AddCardSet

