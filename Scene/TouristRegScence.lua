
local gt = cc.exports.gt

local TouristRegScence = class("TouristRegScence", function()
	return gt.createMaskLayer(160)
end)

function TouristRegScence:ctor()

	local csbNode = cc.CSLoader:createNode("TouristReg.csb")
    csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	self:addChild(csbNode)

	self.rootNode = csbNode
    
    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.began then

        elseif eventType == ccui.TouchEventType.canceled then
            
        elseif eventType == ccui.TouchEventType.ended then
            
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end
    self.mobilereg = gt.seekNodeByName(csbNode, "mobilereg_panel")
    --手机注册
    local mobilereg_but = gt.seekNodeByName(self.mobilereg, "login_but")
    mobilereg_but:setTag(100)
    mobilereg_but:addTouchEventListener(btnEvent)
    
    --取消手机注册
    local mobilcancel_but = gt.seekNodeByName(self.mobilereg, "cancel_but")
     gt.addBtnPressedListener(mobilcancel_but, function()
        self:removeFromParent()
    end)
       --手机注册手机号
    local MBEditbox_reg1 = gt.seekNodeByName(self.mobilereg, "Editbox_1")
    local account_reg = ccui.EditBox:create(cc.size(330,48), "") 
    account_reg:setPosition(cc.p(254,41.5))
    account_reg:setAnchorPoint(0.5, 0.5)
    account_reg:setFontSize(40)
    account_reg:setFontColor(cc.c3b(255,255,255))
    account_reg:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    account_reg:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    account_reg:setPlaceHolder("手机号")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    MBEditbox_reg1:addChild(account_reg)
    self.account_reg = account_reg

    --校验码
    local MBEditbox_reg2 = gt.seekNodeByName(self.mobilereg, "Editbox_2")
    local account_reg2 = ccui.EditBox:create(cc.size(250,48), "") 
    account_reg2:setPosition(cc.p(210,41.5))
    account_reg2:setAnchorPoint(0.5, 0.5)
    account_reg2:setFontSize(40)
    account_reg2:setFontColor(cc.c3b(255,255,255))
    account_reg2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    account_reg2:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    account_reg2:setPlaceHolder("验证码")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    MBEditbox_reg2:addChild(account_reg2)
    self.account_reg2 = account_reg2
    
    local MBEditbox_reg3 = gt.seekNodeByName(self.mobilereg, "Editbox_3")
    local account_reg3 = ccui.EditBox:create(cc.size(330,48), "") 
    account_reg3:setPosition(cc.p(249,41.5))
    account_reg3:setAnchorPoint(0.5, 0.5)
    account_reg3:setFontSize(40)
    account_reg3:setFontColor(cc.c3b(255,255,255))
    account_reg3:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
    account_reg3:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    account_reg3:setPlaceHolder("请输入8位数密码")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    MBEditbox_reg3:addChild(account_reg3)
    self.account_reg3 = account_reg3


    local MBEditbox_reg4 = gt.seekNodeByName(self.mobilereg, "Editbox_4")
    local account_reg4 = ccui.EditBox:create(cc.size(330,48), "") 
    account_reg4:setPosition(cc.p(249,41.5))
    account_reg4:setAnchorPoint(0.5, 0.5)
    account_reg4:setFontSize(40)
    account_reg4:setFontColor(cc.c3b(255,255,255))
    account_reg4:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
    account_reg4:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    account_reg4:setPlaceHolder("重复密码")
    account_reg4:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    MBEditbox_reg4:addChild(account_reg4)
    self.account_reg4 = account_reg4


    local MBEditbox_reg5 = gt.seekNodeByName(self.mobilereg, "Editbox_5")
    local account_reg5 = ccui.EditBox:create(cc.size(330,48), "") 
    account_reg5:setPosition(cc.p(254,41.5))
    account_reg5:setAnchorPoint(0.5, 0.5)
    account_reg5:setFontSize(40)
    account_reg5:setFontColor(cc.c3b(255,255,255))
    account_reg5:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    account_reg5:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    account_reg5:setPlaceHolder("安全码")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    MBEditbox_reg5:addChild(account_reg5)
    self.account_reg5 = account_reg5

    self.SendAuth_reg = gt.seekNodeByName(MBEditbox_reg2, "enter_box")
    self.TxtTime_reg = gt.seekNodeByName(MBEditbox_reg2, "Txt_Time")
    self.TxtTime_reg:setVisible(false)
    self.nTime_reg = 60
    gt.addBtnPressedListener(self.SendAuth_reg, function()

        local MJ_account = account_reg:getText()
        gt.log("MJ_account = ",MJ_account,#MJ_account)
        if #MJ_account ~= 11 then
            require("app/views/UI/NoticeTips"):create("提示","请输入正确手机号！", nil, nil, true)
            return
        end
        --发送手机校证码
        local cmsg = cmd_account_pb.CPhoneVerifyReq()
        cmsg.phone_type = 1
        --cmsg.verify_type = 1
        cmsg.phone_number = gt.GlobalRoaming..MJ_account
        local msgData = cmsg:SerializeToString()

        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_REQ,msgData)

    end)
    --手机验证回调
	gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_RESP, self, self.onPhoneVerifyResp)
	--手机注册回调
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_REGISTER_RESP, self, self.onPhoneRegisterResp)
end
function TouristRegScence:onPhoneRegisterResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SPhoneRegisterResp()
    stResp:ParseFromString(buf)
    gt.log("onPhoneRegisterResp code:"..stResp.code..";token:"..stResp.token)
    if stResp.code == 0 then
    -- 注册成功，token登录
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,stResp.token)
        local cmsg = cmd_account_pb.CTokenLogonReq()
        cmsg.token = stResp.token
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_TOKEN_LOGON_REQ,msgData)
    elseif stResp.code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，系统错误！", nil, nil, true)
    elseif stResp.code == 2 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，验证码不存在！", nil, nil, true)
    elseif stResp.code == 3 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，验证码已过期！", nil, nil, true)
    elseif stResp.code == 4 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，安全码不存在！", nil, nil, true)
    elseif stResp.code == 5 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，手机号码已存在(已注册)！", nil, nil, true)
    elseif stResp.code == 6 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，昵称为空！", nil, nil, true)
    elseif stResp.code == 7 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，密码长度非法（不为8位）！", nil, nil, true)
    elseif stResp.code == 8 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，手机号码格式非法（小于11位）！", nil, nil, true)
    elseif stResp.code == 9 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，验证码不匹配！", nil, nil, true)
    else
        require("app/views/UI/NoticeTips"):create("提示","注册失败，请重新输入！", nil, nil, true)
    end
end
--登入成功接收的消息
function TouristRegScence:onButtonClickedEvent(tag, ref)   
    print("onButtonClickedEvent----",tag)
    if 100 == tag then
        --local account2 = gt.seekNodeByName(MBEditbox2, "account_box")
        --数组  
        if self.account_reg3:getText() ~= self.account_reg4:getText() then 
            --密码不相同，返回  tip
            require("app/views/UI/NoticeTips"):create("提示","两次密码输入不一致!", nil, nil, true)
            self.account_reg4:setText("")
            return
        end

        require  "mime"   
        --发送手机注册
        local cmsg = cmd_account_pb.CPhoneRegisterReq()
        cmsg.phone_number = gt.GlobalRoaming..self.account_reg:getText()
        cmsg.nick_name = self.account_reg:getText()
        --cmsg.pwd = self:PasswordEncrypt(account3:getStringValue())
        cmsg.pwd = gt.PasswordEncrypt(self.account_reg3:getText())
        cmsg.verify_code = tonumber(self.account_reg2:getText())
        cmsg.promo_code = tonumber(self.account_reg5:getText())
        local msgData = cmsg:SerializeToString()

        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_REGISTER_REQ,msgData)     
        
    end

end
function TouristRegScence:onPhoneVerifyResp(msgTbl)

    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SPhoneVerifyResp()
    stResp:ParseFromString(buf)
    local tiem = os.date("%Y%m%d%H%M%S",stResp.expire_time/1000);
    if stResp.code==0 then
        gt.log("onPhoneVerifyResp code:"..stResp.code..";expire_time:"..tiem)
        self.SendAuth_reg:setVisible(false)
        self.TxtTime_reg:setVisible(true)
        self.nTime_reg = 60
        self.TxtTime_reg:setString(self.nTime_reg.."s")
    elseif stResp.code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，系统错误！", nil, nil, true)
    elseif stResp.code == 2 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码没有注册！", nil, nil, true)
    elseif stResp.code == 3 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码已注册过了！", nil, nil, true)
    elseif stResp.code == 4 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码格式非法！", nil, nil, true)
    elseif stResp.code == 5 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，验证码未过期！", nil, nil, true)
    end
end

return TouristRegScence
