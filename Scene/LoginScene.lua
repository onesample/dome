local gt = cc.exports.gt

require("app/DefineConfig")
require("app/Utils")
require("app.protocols.cmd_account_pb")
require("app.protocols.cmd_net_pb")
require("app.protocols.cmd_sys_pb")

local Utils = cc.exports.Utils

local LoginScene = class("LoginScene", function()
	return cc.Scene:create()
end)

gt.loginSceneState = true

function LoginScene:ctor(isback,isRegister)
    local _isback = true
    if isback ~= nil then
        _isback = false
    end
	-- 重新设置搜索路径
	local writePath = cc.FileUtils:getInstance():getWritablePath()
	local resSearchPaths = {
		writePath,
		writePath .. "src/",
		writePath .. "res/",
		"src/",
		"res/"
	}
	cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)

	self:initData()

	gt.soundManager = require("app/views/commom/SoundManager")
	--------------------------
	-- 这里的标记,修改这里的,以后不用修改UtilityTools.lua中的标记了
	gt.isUpdateNewLast = true
	-- 是否是苹果审核状态
	gt.isInReview = false
	-- 调试模式
	gt.debugMode = true
	-- 是否在大厅界面检测资源版本
	gt.isCheckResVersion = true

	-- 是否要显示商城
	gt.isShoppingShow = false
	-- 记录打牌局数
	gt.isNumberMark = 0

	gt.name_s = "d8dbfeeaf12"
	gt.name_e = "25f1fd508b1"
	gt.chu_wan = 5
	gt.zhong_wan = 6
	gt.gao_wan = 7
	gt.gu_wan = 8

    self.CTYIsup = true
 
	gt.shareWeb = "http://www.ixianlai.com/"

	if gt.isDebugPackage then
		gt.isInReview = gt.debugInfo.AppStore
		gt.debugMode = gt.debugInfo.Debug
		gt.debugMode =true --20161125
	end

	-- 初始化定位
	-- Utils.initLocation()

	self.needLoginWXState = 0 -- 本地微信登录状态
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("Login.csb")
	--csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode

    --初始化YVSDK
--    path = cc.FileUtils:getInstance():getWritablePath()
--    if gt.isIOSPlatform() or gt.isAndroidPlatform() then
--    yvcc.YVTool:getInstance():initSDK("1000808",path, false)
--    end
	-- 初始化Socket网络通信
	gt.socketClient = require("app/SocketClient"):getInstance()
     --gt.socketClient =require("app/SocketClient")
	 
	 --print(gt.socketClient.rcvMsgListeners)
	if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end

    local function btnEvent( sender, eventType )
        if eventType == ccui.TouchEventType.began then

        elseif eventType == ccui.TouchEventType.canceled then
            
        elseif eventType == ccui.TouchEventType.ended then
            
            self:onButtonClickedEvent(sender:getTag(), sender)
        end
    end

    require("app/utils/PriFrame"):create()

	-- local healthAlert = gt.seekNodeByName(csbNode, "Text_1")
	-- healthAlert:setVisible(false)

--	self.healthyNode = gt.seekNodeByName(csbNode, "healthy_node")
--	self.healthyNode:setVisible(false)
	--更新检测
	-- self:updateAppVersion()

    local loginbj = gt.seekNodeByName(csbNode, "jcgame_bj") 
	-- 帐号登录
	self.account_but = gt.seekNodeByName(loginbj, "account_but")
	self.account_but_0 = gt.seekNodeByName(loginbj, "account_but_0")
    self.account_but:setTag(80)
    self.account_but:addTouchEventListener(btnEvent)

	
    -- 手机登录
	self.mobile_but = gt.seekNodeByName(loginbj, "mobile")
	self.mobile_but_0 = gt.seekNodeByName(loginbj, "mobile_0")
    self.mobile_but:setTag(82)
    self.mobile_but:addTouchEventListener(btnEvent)
    self.mobile_but:setVisible(false)
    --self.account_but_0:setVisible(false)
    self.mobile_but_0:setVisible(false)
    -- 快速登录
	local quick_but = gt.seekNodeByName(loginbj, "quick")
    --quick_but:setTag(83)
    --quick_but:addTouchEventListener(btnEvent)
     gt.addBtnPressedListener(quick_but, function()
        --快速登录
        gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
        self.loadingtime = 0
        gt.isshowlading = true
        gt.IsQuickLogon = true
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_QUICK_LOGON_REQ,{})
    end)

    self.mobilereg = gt.seekNodeByName(csbNode, "mobilereg_panel")
	self.mobilereg:setVisible(false)
    self.Accountreg = gt.seekNodeByName(csbNode, "AccountReg_panel")
	self.Accountreg:setVisible(false)
    self.findpaw = gt.seekNodeByName(csbNode, "findpaw_panel")
	self.findpaw:setVisible(false)
    self.account = gt.seekNodeByName(csbNode, "account_panel")
	self.account:setVisible(true)
    
    --帐号登录
    local accountlogin_but = gt.seekNodeByName(self.account, "login_but")
    local account_Number = cc.UserDefault:getInstance():getStringForKey( "Mb_account_Number")
    local account_Pwd = cc.UserDefault:getInstance():getStringForKey( "Mb_account_Pwd")
    
    local MBEditbox_account = gt.seekNodeByName(self.account, "Editbox_1")
    local account_account = ccui.EditBox:create(cc.size(330,48), "") 
    account_account:setPosition(cc.p(274,41.5))
    account_account:setAnchorPoint(0.5, 0.5)
    account_account:setFontSize(40)
    account_account:setFontColor(cc.c3b(255,255,255))
    account_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    account_account:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    account_account:setPlaceHolder("手机号")
    local account_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    account_account:registerScriptEditBoxHandler(account_Handler) 
    MBEditbox_account:addChild(account_account)

    local MBEditbox_psd = gt.seekNodeByName(self.account, "Editbox_2")
    local account_psd = ccui.EditBox:create(cc.size(330,48), "") 
    account_psd:setPosition(cc.p(249,41.5))
    account_psd:setAnchorPoint(0.5, 0.5)
    account_psd:setFontSize(40)
    account_psd:setFontColor(cc.c3b(255,255,255))
    account_psd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
    account_psd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    account_psd:setPlaceHolder("请输入8位数密码")
    local accountpsd_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    account_psd:registerScriptEditBoxHandler(accountpsd_Handler) 
    MBEditbox_psd:addChild(account_psd)

    self.AccountSure = gt.seekNodeByName(MBEditbox_account, "enter_box")
    self.AccountSure:setVisible(false)
    self.AccountFace = gt.seekNodeByName(MBEditbox_account, "cursor_5")
    self.AccountBox = account_account
    if account_Number ~= "" then
        account_account:setText(account_Number)
    end

    gt.addBtnPressedListener(accountlogin_but, function()
        gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
        self.loadingtime = 0
        gt.isshowlading = true
        local cmsg = cmd_account_pb.CPhoneLogonReq()
        cmsg.phone_number =gt.GlobalRoaming..self.AccountBox:getText()
        --cmsg.pwd = self:PasswordEncrypt(account2:getStringValue())
        cmsg.pwd = gt.PasswordEncrypt(account_psd:getText())
        local msgData = cmsg:SerializeToString()
        gt.IsQuickLogon = false
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_LOGON_REQ,msgData)

        cc.UserDefault:getInstance():setStringForKey( "Mb_account_Number" ,self.AccountBox:getText())

    end)
--    accountlogin_but:setTag(100)
--    accountlogin_but:addTouchEventListener(btnEvent)
    
	local SignThree_1 = gt.seekNodeByName(self.account, "SignThree_1")
    SignThree_1:setVisible(false)
    -- 第三方微信登录
	self.weChat_but = gt.seekNodeByName(self.account, "SignWeChat_Btn")
    self.weChat_but:setTag(81)
    self.weChat_but:addTouchEventListener(btnEvent)
    self.weChat_but:setVisible(false)
    -- 第三方QQ登录
	self.QQ_but = gt.seekNodeByName(self.account, "SignQQ_Btn")
    self.QQ_but:setTag(801)
    self.QQ_but:addTouchEventListener(btnEvent)
    self.QQ_but:setVisible(false)

    --手机注册
    local mobilereg_but = gt.seekNodeByName(self.mobilereg, "login_but")
    mobilereg_but:setTag(100)
    mobilereg_but:addTouchEventListener(btnEvent)
    
    --取消手机注册
    local mobilcancel_but = gt.seekNodeByName(self.mobilereg, "cancel_but")
     gt.addBtnPressedListener(mobilcancel_but, function()
        self.mobilereg:setVisible(false)
        self.Country_Panel:setPositionY(440)
        self.account:setVisible(true)
        self.findpaw:setVisible(false)
    end)
    
    --取消修改密码 
    local findpawcancel_but = gt.seekNodeByName(self.findpaw, "cancel_but")
     gt.addBtnPressedListener(findpawcancel_but, function()
        self.mobilereg:setVisible(false)
        self.Country_Panel:setPositionY(440)
        self.account:setVisible(true)
        self.findpaw:setVisible(false)
    end)
    --修改密码获取验证码
     --修改密码手机号
    local FBEditbox = gt.seekNodeByName(self.findpaw, "Editbox_1")
    local FBaccount = ccui.EditBox:create(cc.size(330,48), "") 
    FBaccount:setPosition(cc.p(274,41.5))
    FBaccount:setAnchorPoint(0.5, 0.5)
    FBaccount:setFontSize(40)
    FBaccount:setFontColor(cc.c3b(255,255,255))
    FBaccount:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    FBaccount:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    FBaccount:setPlaceHolder("手机号")
    local FBaccount_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    FBaccount:registerScriptEditBoxHandler(FBaccount_Handler) 
    FBEditbox:addChild(FBaccount)
    self.FBEditSure = gt.seekNodeByName(FBEditbox, "enter_box")
    self.FBEditSure:setVisible(false)
    self.FBEditFace = gt.seekNodeByName(FBEditbox, "cursor_5")

     --校验码
    local FBEditbox2 = gt.seekNodeByName(self.findpaw, "Editbox_2")
    local FBaccount2 = ccui.EditBox:create(cc.size(250,48), "") 
    FBaccount2:setPosition(cc.p(210,41.5))
    FBaccount2:setAnchorPoint(0.5, 0.5)
    FBaccount2:setFontSize(40)
    FBaccount2:setFontColor(cc.c3b(255,255,255))
    FBaccount2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    FBaccount2:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    FBaccount2:setPlaceHolder("验证码")
    local FBaccount2_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    FBaccount2:registerScriptEditBoxHandler(FBaccount2_Handler) 
    FBEditbox2:addChild(FBaccount2)

     --密码
    local FBEditbox4 = gt.seekNodeByName(self.findpaw, "Editbox_4")
    local FBaccount_Psd  =  ccui.EditBox:create(cc.size(330,45), "") 
    FBaccount_Psd:setPosition(cc.p(249,44.5))
    FBaccount_Psd:setAnchorPoint(0.5, 0.5)
    FBaccount_Psd:setFontSize(40)
    FBaccount_Psd:setFontColor(cc.c3b(255,255,255))
    FBaccount_Psd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
    FBaccount_Psd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    FBaccount_Psd:setPlaceHolder("请输入8位数密码")
    local FBaccountPsd_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    FBaccount_Psd:registerScriptEditBoxHandler(FBaccountPsd_Handler) 
    FBEditbox4:addChild(FBaccount_Psd)
    self.FBaccount_Psd = FBaccount_Psd
     --重复密码
    local FBEditbox5 = gt.seekNodeByName(self.findpaw, "Editbox_5")
    local FBaccount_Psd2  =  ccui.EditBox:create(cc.size(330,48), "") 
    FBaccount_Psd2:setPosition(cc.p(249,41.5))
    FBaccount_Psd2:setAnchorPoint(0.5, 0.5)
    FBaccount_Psd2:setFontSize(40)
    FBaccount_Psd2:setFontColor(cc.c3b(255,255,255))
    FBaccount_Psd2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD )
    FBaccount_Psd2:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    FBaccount_Psd2:setPlaceHolder("重复密码")
    local FBaccountPsd2_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    FBaccount_Psd2:registerScriptEditBoxHandler(FBaccountPsd2_Handler) 
    FBEditbox5:addChild(FBaccount_Psd2)
    self.FBaccount_Psd2 = FBaccount_Psd2

    self.FBSendAuth_find = gt.seekNodeByName(FBEditbox2, "enter_box")
    self.TxtTime_find = gt.seekNodeByName(FBEditbox2, "Txt_Time")
    self.TxtTime_find:setVisible(false)
    self.nTime_find = 120

    gt.addBtnPressedListener(self.FBSendAuth_find, function()

        local MJ_account = FBaccount:getText()
        --gt.log("MJ_account = ",MJ_account,#MJ_account)
--        if #MJ_account ~= 11 then
--            require("app/views/UI/NoticeTips"):create("提示","请输入正确手机号！", nil, nil, true)
--            return
--        end

        --发送手机校证码
        local cmsg = cmd_account_pb.CForgetPwdReq()
        --cmsg.phone_type = 1
        --cmsg.verify_type = 2
        cmsg.phone_number = gt.GlobalRoaming..MJ_account
        local msgData = cmsg:SerializeToString()

        gt.socketClient:sendMessage(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_FORGET_PWD_REQ,msgData)

    end)
    --修改密码 
    local findpawlogin_but = gt.seekNodeByName(self.findpaw, "login_but")
        gt.addBtnPressedListener(findpawlogin_but, function()
            local MJ_account = FBaccount:getText()
            --gt.log("MJ_account = ",MJ_account,#MJ_account)
--            if #MJ_account ~= 11 then
--                require("app/views/UI/NoticeTips"):create("提示","请输入正确手机号！", nil, nil, true)
--                return
--            end
            local Psd_account = FBaccount_Psd:getText()
            local Psd_account2 = FBaccount_Psd2:getText()
            if #Psd_account ~= 8 then
                require("app/views/UI/NoticeTips"):create("提示","请输入8位数密码！", nil, nil, true)
                return
            end
            if Psd_account ~= Psd_account2 then
                require("app/views/UI/NoticeTips"):create("提示","两次密码输入不一致！", nil, nil, true)
                return
            end

            cc.UserDefault:getInstance():setStringForKey( "Mb_Phone_Number" ,FBaccount:getText())
            cc.UserDefault:getInstance():setStringForKey( "Mb_Phone_Pwd" ,FBaccount_Psd:getText())
            --修改密码
            local cmsg = cmd_account_pb.CChangePwdReq()
            cmsg.phone_number = gt.GlobalRoaming..FBaccount:getText()
            --cmsg.pwd =self:PasswordEncrypt(account4:getStringValue()) 
            cmsg.pwd = gt.PasswordEncrypt(FBaccount_Psd:getText())
            cmsg.verify_code = tonumber(FBaccount2:getText())
            local msgData = cmsg:SerializeToString()
            gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_CHG_PWD_REQ,msgData)
        end)

    --注册
    local accountreg_but = gt.seekNodeByName(self.account, "accountreg")
--    accountreg_but:setTag(100)
--    accountreg_but:addTouchEventListener(btnEvent)
    gt.addBtnPressedListener(accountreg_but, function()
            self.mobilereg:setVisible(true)
            self.Country_Panel:setPositionY(510)
            self.account:setVisible(false)
            self.findpaw:setVisible(false)
        end)
    --帐号忘记
    local Accforgetpsw = gt.seekNodeByName(self.account, "forgetpsw")
    --Accforgetpsw:setTag(102)
    --Accforgetpsw:addTouchEventListener(btnEvent)
    gt.addBtnPressedListener(Accforgetpsw, function()
        self.mobilereg:setVisible(false)
        self.Country_Panel:setPositionY(440)
        self.account:setVisible(false)
        self.findpaw:setVisible(true)

--        local MBEditbox1 = gt.seekNodeByName(self.account, "Editbox_1")
--        local account1 = gt.seekNodeByName(MBEditbox1, "account_box")

--        local cmsg = cmd_account_pb.CForgetPwdReq()
--        cmsg.phone_number = account1:getStringValue()
--        local msgData = cmsg:SerializeToString()
--        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_FORGET_PWD_REQ,msgData)

    end)

    --手机注册手机号
    local MBEditbox_reg1 = gt.seekNodeByName(self.mobilereg, "Editbox_1")
    local account_reg = ccui.EditBox:create(cc.size(330,48), "") 
    account_reg:setPosition(cc.p(274,41.5))
    account_reg:setAnchorPoint(0.5, 0.5)
    account_reg:setFontSize(40)
    account_reg:setFontColor(cc.c3b(255,255,255))
    account_reg:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    account_reg:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    account_reg:setPlaceHolder("手机号")
    local accountreg_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    account_reg:registerScriptEditBoxHandler(accountreg_Handler) 
    MBEditbox_reg1:addChild(account_reg)
    self.account_reg = account_reg
    self.MBregSure = gt.seekNodeByName(MBEditbox_reg1, "enter_box")
    self.MBregSure:setVisible(false)
    self.MBregFace = gt.seekNodeByName(MBEditbox_reg1, "cursor_5")
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
    local accountreg2_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    account_reg2:registerScriptEditBoxHandler(accountreg2_Handler) 
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
    local accountreg3_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    account_reg3:registerScriptEditBoxHandler(accountreg3_Handler) 
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
    local accountreg5_Handler = function(event)  
        if event == "began" then  
            if self.CTYIsup == false then
                self:CTYMove()
            end
        end  
    end  
    account_reg5:registerScriptEditBoxHandler(accountreg5_Handler) 
    MBEditbox_reg5:addChild(account_reg5)
    self.account_reg5 = account_reg5

    self.SendAuth_reg = gt.seekNodeByName(MBEditbox_reg2, "enter_box")
    self.TxtTime_reg = gt.seekNodeByName(MBEditbox_reg2, "Txt_Time")
    self.TxtTime_reg:setVisible(false)
    self.nTime_reg = 120
    gt.addBtnPressedListener(self.SendAuth_reg, function()

        local MJ_account = account_reg:getText()
        gt.log("MJ_account = ",MJ_account,#MJ_account)
--        if #MJ_account ~= 11 then
--            require("app/views/UI/NoticeTips"):create("提示","请输入正确手机号！", nil, nil, true)
--            return
--        end
        --发送手机校证码
        local cmsg = cmd_account_pb.CPhoneVerifyReq()
        cmsg.phone_type = 1
        --cmsg.verify_type = 1
        cmsg.phone_number = gt.GlobalRoaming..MJ_account
        local msgData = cmsg:SerializeToString()

        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_REQ,msgData)

    end)

    --地区选择
    
    self.CTYbMove = true
    self.Country_Panel = gt.seekNodeByName(csbNode, "Country_Panel")
    self.Country_Panel:setPositionY(self.Country_Panel:getPositionY()-70)
    self.Out_Layer = gt.seekNodeByName(self.Country_Panel, "Out_Layer")
    local CTYBut = gt.seekNodeByName(self.Country_Panel, "BtnOut")
    gt.addBtnPressedListener(CTYBut, handler(self, function()
        if self.CTYbMove then
            Utils.setClickEffect()
            self:CTYMove()
        end
	end))
    local BtnChina = gt.seekNodeByName(self.Country_Panel, "BtnChina")
    local BtnHK = gt.seekNodeByName(self.Country_Panel, "BtnHK")
    local BtnAM = gt.seekNodeByName(self.Country_Panel, "BtnAM")
    local BtnJPZ = gt.seekNodeByName(self.Country_Panel, "BtnJPZ")
    BtnChina:setTag(90)
    BtnHK:setTag(91)
    BtnAM:setTag(92)
    BtnJPZ:setTag(93)
    BtnChina:addTouchEventListener(btnEvent)
    BtnHK:addTouchEventListener(btnEvent)
    BtnAM:addTouchEventListener(btnEvent)
    BtnJPZ:addTouchEventListener(btnEvent)
    if isRegister then
        self.account:setVisible(false)
        self.mobilereg:setVisible(true)
        self.Country_Panel:setPositionY(510)
    end
        --联网测试
--		gt.LoginServer.ip = "192.168.0.17"
--		gt.LoginServer.port = "28088"

        if _isback then
            gt.socketClient:connect(gt.LoginServer.ip, gt.LoginServer.port, true)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(1) ,cc.CallFunc:create(function ()
                --Token登录
                local Mb_Token = cc.UserDefault:getInstance():getStringForKey( "Mb_Access_Token" )
                if #Mb_Token < 5 then
                    return
                end
                local cmsg = cmd_account_pb.CTokenLogonReq()
                cmsg.token = Mb_Token
                local msgData = cmsg:SerializeToString()
                gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_TOKEN_LOGON_REQ,msgData)        
            end)))
        else
            gt.socketClient:setIsStartGame(false)
            gt.socketClient:close()
        end

    --手机验证回调
	gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_RESP, self, self.onPhoneVerifyResp)
	--手机注册回调
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_REGISTER_RESP, self, self.onPhoneRegisterResp)
	--手机登录回调
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_LOGON_RESP, self, self.onPhonelogonResp)
	--TOKEN登录应答
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_TOKEN_LOGON_RESP, self, self.onTokenLogonResp)
	--快速登录应答
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_QUICK_LOGON_RESP, self, self.onQuickLogonResp)
	--第三方登录应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_THIRD_PARTY_LOGON_RESP, self, self.onThirdPartyLogonResp)
	--忘记密码应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_FORGET_PWD_RESP, self, self.onForgetPwdResp)
    --修改密码应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_CHG_PWD_RESP, self, self.onChgPwdResp)
    --获取国家区号(下行)
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_COUNTRY_CODE_RESP, self, self.onGetCountryCodeResp)
    --self.selectCount:setHACenter() 
end

function LoginScene:onGetCountryCodeResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SGetCountryCodeResp()
    stResp:ParseFromString(buf)
    gt.log("onGetCountryCodeResp code国家:"..stResp.code.."+"..stResp.cur_country_code)
    dump(stResp.all_country_code)
    if stResp.code == 0 then
        
    end
end
function LoginScene:editboxHandle(strEventName,sender)
    if strEventName == "began" then
        --sender:selectedAll() --光标进入，选中全部内容
        if self.CTYIsup == false then
            self:CTYMove()
        end
    elseif strEventName == "return" then
    
    elseif strEventName == "changed" then 

    elseif strEventName == "ended" then
        if self.account_reg3:getText() ~= self.account_reg4:getText() then
            require("app/views/UI/NoticeTips"):create("提示","两次密码输入不一致!", nil, nil, true)
            self.account_reg4:setText("")
            return
       end
    end
end
function LoginScene:PsdboxHandle(strEventName,sender)
    if strEventName == "began" then
        --sender:selectedAll() --光标进入，选中全部内容
    elseif strEventName == "return" then
    
    elseif strEventName == "changed" then 

    elseif strEventName == "ended" then
        if self.FBaccount_Psd:getText() ~= self.FBaccount_Psd2:getText() then
            require("app/views/UI/NoticeTips"):create("提示","两次密码输入不一致!", nil, nil, true)
            self.FBaccount_Psd2:setText("")
            return
       end
    end
end
function LoginScene:onChgPwdResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SChangePwdResp()
    stResp:ParseFromString(buf)
    gt.log("onChgPwdResp code:"..stResp.code)
    if stResp.code == 0 then
        local Phone_Number = cc.UserDefault:getInstance():getStringForKey( "Mb_Phone_Number")
        local Phone_Pwd = cc.UserDefault:getInstance():getStringForKey( "Mb_Phone_Pwd")

        local cmsg = cmd_account_pb.CPhoneLogonReq()
        cmsg.phone_number =  gt.GlobalRoaming..Phone_Number
        --cmsg.pwd = self:PasswordEncrypt(Phone_Pwd)
        cmsg.pwd = gt.PasswordEncrypt(Phone_Pwd)
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_LOGON_REQ,msgData)
        return
    elseif stResp.code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，系统错误！", nil, nil, true)
    elseif stResp.code == 2 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，验证码不存在！", nil, nil, true)
    elseif stResp.code == 3 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，验证码已过期！", nil, nil, true)
    elseif stResp.code == 4 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，安全码不存在！", nil, nil, true)
    elseif stResp.code == 5 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码格式非法！", nil, nil, true)
    elseif stResp.code == 6 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码未注册！", nil, nil, true)
    elseif stResp.code == 7 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，密码长度非法（不为8位）！", nil, nil, true)
    elseif stResp.code == 8 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，验证码不匹配！", nil, nil, true)
    end
    cc.UserDefault:getInstance():setStringForKey("IPaddr" ,"")
end

function LoginScene:onForgetPwdResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SForgetPwdResp()
    stResp:ParseFromString(buf)
    gt.log("onForgetPwdResp code:"..stResp.code..";expire_time:"..stResp.expire_time)
    if stResp.code==0 then
        self.FBSendAuth_find:setVisible(false)
        self.TxtTime_find:setVisible(true)
        self.nTime_find = 120
        self.TxtTime_find:setString(self.nTime_find.."s")
    elseif stResp.code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，系统错误！", nil, nil, true)
    elseif stResp.code == 2 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码没有注册！", nil, nil, true)
    elseif stResp.code == 3 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码已注册过了！", nil, nil, true)
    elseif stResp.code == 4 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，手机号码格式非法（小于11位或大于15位）！", nil, nil, true)
    elseif stResp.code == 5 then
        require("app/views/UI/NoticeTips"):create("提示","发送失败，验证码未过期！", nil, nil, true)
    end

end

function LoginScene:onQuickLogonResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SQuickLogonResp()
    stResp:ParseFromString(buf)
    gt.log("onQuickLogonResp code:"..stResp.code..";token"..stResp.token)
    if stResp.code == 0 then
    -- 登录成功
--    	local mainScene = require("app/views/Scene/MainScene"):create(isNewPlayer)
--        cc.Director:getInstance():replaceScene(mainScene)  
--        gt.socketClient:setIsStartGame(true)
        local cmsg = cmd_account_pb.CTokenLogonReq()
        cmsg.token = stResp.token
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_TOKEN_LOGON_REQ,msgData)
    else
        --token 登录失败 清空token
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    end
end

function LoginScene:onThirdPartyLogonResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SThirdPartyLogonResp()
    stResp:ParseFromString(buf)
    gt.log("onThirdPartyLogonResp code:"..stResp.code..";token"..stResp.token)
    if stResp.code == 0 then
    -- 登录成功
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,stResp.token)
--    	local mainScene = require("app/views/Scene/MainScene"):create(isNewPlayer)
--        cc.Director:getInstance():replaceScene(mainScene)  
--        gt.socketClient:setIsStartGame(true)
        local cmsg = cmd_account_pb.CTokenLogonReq()
        cmsg.token = stResp.token
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_TOKEN_LOGON_REQ,msgData)
    elseif stResp.code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，系统错误！", nil, nil, true)
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    elseif stResp.code == 2 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，需要安全码！", nil, nil, true)
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    elseif stResp.code == 3 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，安全码不存在！", nil, nil, true)
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    elseif stResp.code == 4 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，昵称不存在！", nil, nil, true)
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    elseif stResp.code == 5 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，昵称过长！", nil, nil, true)
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    elseif stResp.code == 6 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，昵称重复！", nil, nil, true)
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    else
        --token 登录失败 清空token
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,"")
    end
end

function LoginScene:PasswordEncrypt(passwordstr)
    require  "mime"   
    --数组  
    local retTable  = {};  
    retTable["password"] = passwordstr
    retTable["time"] = os.time()
    local cjson = require "json"  

    local jsonStr = cjson.encode(retTable);  
    gt.log("jsonStr = ",jsonStr)

    --Rsa 加解密
    local encryptData = gt.CCalcRsa:M_Encrypt(jsonStr)
    --gt.log("encryptData = ",encryptData)
--    local DecryptData = gt.CCalcRsa:M_Decrypt(encryptData)
--    --gt.log("DecryptData = ",DecryptData)
    return mime.b64(encryptData)
end

--function LoginScene:onTokenLogonResp(msgTbl)
--    gt.DataBase:headDecode( msgTbl )
--    local buf = gt.DataBase:getBodyBuff(msgTbl)
--    local stResp = cmd_account_pb.STokenLogonResp()
--    stResp:ParseFromString(buf)
--    -- 去掉转圈
--	gt.removeLoadingTips()
--    gt.isshowlading = false
--    gt.log("onTokenLogonResp code:"..stResp.code..";uid:"..stResp.uid..";nick_name"..stResp.nick_name,stResp.coin)
--    if stResp.code == 0 then
--    -- 登录成功
--    	-- 玩家信息
--        gt.playerData.uid = stResp.uid
--        gt.playerData.nickname = stResp.nick_name
--        gt.playerData.recharge_code = stResp.recharge_code
--        gt.playerData.coin = stResp.coin
--        gt.playerData.playerType = stResp.register_type
--        gt.playerData.is_first = stResp.is_first
--        gt.playerData.profitValue = 0

--    	local mainScene = require("app/views/Scene/MainScene"):create(isNewPlayer)
--        cc.Director:getInstance():replaceScene(mainScene)  
--        gt.socketClient:setIsStartGame(true)

--    else
--        --token 登录失败 清空token
--        cc.UserDefault:getInstance():setStringForKey("Mb_Access_Token","")
--    end
--end

function LoginScene:onPhonelogonResp(msgTbl)
    -- 去掉转圈
	gt.removeLoadingTips()
    gt.isshowlading = false
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SPhoneLogonResp()
    stResp:ParseFromString(buf)
    gt.log("onPhonelogonResp code:"..stResp.code..";token:"..stResp.token)
    if stResp.code == 0 then
    -- 登录成功，token登录
        cc.UserDefault:getInstance():setStringForKey( "Mb_Access_Token" ,stResp.token)
        local cmsg = cmd_account_pb.CTokenLogonReq()
        cmsg.token = stResp.token
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_TOKEN_LOGON_REQ,msgData)
        return
    elseif stResp.code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，系统错误！", nil, nil, true)
    elseif stResp.code == 2 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，密码长度非法（不为8位）！", nil, nil, true)
    elseif stResp.code == 3 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，手机号码格式非法（小于11位或大于15位）！", nil, nil, true)
    elseif stResp.code == 4 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，手机号码未注册！", nil, nil, true)
    elseif stResp.code == 5 then
        require("app/views/UI/NoticeTips"):create("提示","登录失败，密码错误！", nil, nil, true)
    else
        require("app/views/UI/NoticeTips"):create("提示","请输入正确的手机号或密码！", nil, nil, true)
    end
    cc.UserDefault:getInstance():setStringForKey("IPaddr" ,"")
end

function LoginScene:onPhoneRegisterResp(msgTbl)
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
    elseif stResp.code == 10 then
        require("app/views/UI/NoticeTips"):create("提示","注册失败，昵称过长！", nil, nil, true)
    else
        require("app/views/UI/NoticeTips"):create("提示","注册失败，请重新输入！", nil, nil, true)
    end
end

function LoginScene:onPhoneVerifyResp(msgTbl)

    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SPhoneVerifyResp()
    stResp:ParseFromString(buf)
    local tiem = os.date("%Y%m%d%H%M%S",stResp.expire_time/1000);
    if stResp.code==0 then
        gt.log("onPhoneVerifyResp code:"..stResp.code..";expire_time:"..tiem)
        self.SendAuth_reg:setVisible(false)
        self.TxtTime_reg:setVisible(true)
        self.nTime_reg = 120
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

--登入成功接收的消息
function LoginScene:onButtonClickedEvent(tag, ref)   
    print("onButtonClickedEvent----",tag)
    local str 
    print("+++++++++++++++++++++")
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
        

    elseif 101 == tag then
         -- 进入大厅主场景
		 -- 判断是否是新玩家
		 local isNewPlayer = msgTbl.m_new == 0 and true or false
		 local mainScene = require("app/views/Scene/MainScene"):create(isNewPlayer)
		 cc.Director:getInstance():replaceScene(mainScene)

    elseif 102 == tag then
         -- 进入大厅主场景
		 -- 判断是否是新玩家
		 local isNewPlayer = msgTbl.m_new == 0 and true or false
		 local mainScene = require("app/views/Scene/MainScene"):create(isNewPlayer)
		 cc.Director:getInstance():replaceScene(mainScene)
    elseif 80 == tag then
        self.mobilereg:setVisible(false)
        self.Country_Panel:setPositionY(440)
        self.account:setVisible(true)
        self.findpaw:setVisible(false)
        self.Accountreg:setVisible(false)
        --self.account_but:setVisible(false)
        
        --self.mobile_but:setVisible(true)

        --self.account_but_0:setVisible(true)
        
        --self.mobile_but_0:setVisible(false)

    elseif 82 == tag then
        self.mobilereg:setVisible(false)
        self.Country_Panel:setPositionY(440)
        self.account:setVisible(false)
        self.findpaw:setVisible(false)
        self.Accountreg:setVisible(true)
        --self.account_but:setVisible(true)
        
        --self.mobile_but:setVisible(false)

        --self.account_but_0:setVisible(false)
        
        --elf.mobile_but_0:setVisible(true)
    elseif 81 == tag or 801 == tag then
            --第三方登录 test
        local cmsg = cmd_account_pb.CThirdPartyLogonReq()
        cmsg.third_id =  "1000001"..tag
        cmsg.third_type =  1
        cmsg.promo_code =  200003
        cmsg.face_id =  "matt"
        cmsg.nick_name =  "matt"
        cmsg.sex =  0
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_THIRD_PARTY_LOGON_REQ,msgData)
        
    elseif 90 == tag then
        str = "res/res/OpenCountry/icon_China.png"
        gt.GlobalRoaming = 86
        self:CTYMove()
    elseif 91 == tag then
        str = "res/res/OpenCountry/icon_hongkong.png"
        gt.GlobalRoaming = 852
        self:CTYMove()
    elseif 92 == tag then
        str = "res/res/OpenCountry/icon_aomen.png"
        gt.GlobalRoaming = 853
        self:CTYMove()
    elseif 93 == tag then
        str = "res/res/OpenCountry/icon_jianpu.png"
        gt.GlobalRoaming = 00855
        self:CTYMove()
    end
    if str then
        self.AccountFace:setTexture(str)
        self.FBEditFace:setTexture(str)
        self.MBregFace:setTexture(str)
    end
end

function LoginScene:initData()
	--清理一些数据
	for k, v in pairs(package.loaded) do
		if string.find(k, "app/localizations/") == 1 then
			package.loaded[k] = nil
		end 
	end 
	require("app/localizations/LocationUtil")

	package.loaded["app/DefineConfig"] = nil	
	require("app/DefineConfig")

	--清理纹理
	cc.SpriteFrameCache:getInstance():removeSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
end

function LoginScene:getCdnIp()
	-- 进入cdn状态,默认高防
	local playCount = tonumber(self:getPlayCount())
	if playCount ~= nil then
		local filename = nil
		local num = 0
		if playCount < 11 then
			num = self:getAscii(self.unionid)
		elseif playCount < 21 then
			num = gt.chu_wan
		elseif playCount < 51 then
			num = gt.zhong_wan
		elseif playCount < 101 then
			num = gt.gao_wan
		else
			num = gt.gu_wan
		end
		--gt.log("getCdnIp num = " .. num)
		if num > 0 and num < 9 then
			filename = self:getFileByNum(num)
			if filename then
				gt.log("getCdnIp filename = " .. filename)
				self:getYoYoFile(filename)
				return true
			end
		end
	else
		gt.log("getCdnIp playCount = nil")
	end
	self:getIPByState("yundun")
	self:sendRealLogin(self.accessToken, self.refreshToken, self.openid,
					self.sex, self.nickname, self.headimgurl, self.unionid)
end

function LoginScene:getPlayCount()
	local playCount = cc.UserDefault:getInstance():getStringForKey("yoyo_name")
	if playCount ~= "" then
		local s = string.find(playCount, gt.name_s)
		local e = string.find(playCount, gt.name_e)
		if s and e then
			return string.sub(playCount, s + string.len(gt.name_s), e - 1)
		end
	end
	return 0
end

function LoginScene:savePlayCount(count)
	local name = gt.name_s .. count .. gt.name_e
	cc.UserDefault:getInstance():setStringForKey("yoyo_name", name)
end

function LoginScene:getAscii(uuid)
	if not uuid then
		return 1
	end
	local ascii = string.byte(string.sub(uuid, #uuid - 1))
	return (ascii % 4) + 1
end

function LoginScene:getFileByNum(num)
	local filename = "s_1_3_1_4_" .. num .. "_2_4_3"
	local md5 = cc.UtilityExtension:generateMD5(filename, string.len(filename))
	return "http://zhuanzhuanmj.oss-cn-hangzhou.aliyuncs.com/" .. md5 .. ".txt"
end

function LoginScene:getYoYoFile(filename)
	if self.xhr == nil then
        self.xhr = cc.XMLHttpRequest:new()
        self.xhr:retain()
        self.xhr.timeout = 10 -- 设置超时时间
    end
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local refreshTokenURL = filename
    self.xhr:open("GET", refreshTokenURL)
    self.xhr:registerScriptHandler(handler(self, self.onYoYoResp))
    self.xhr:send()
end

function LoginScene:onYoYoResp()
	-- 默认高防
    if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
        self.dataRecv = self.xhr.response -- 获取到数据
        local data = tostring(self.xhr.response)
        if data then
        	gt.log("onYoYoResp data = " .. data)
			local ipTab = string.split(data, ".")
			if #ipTab == 4 then -- 正确的ip地址
				gt.LoginServer.ip = data
				gt.log("onYoYoResp ip = " .. data)
				self.xhr:unregisterScriptHandler()
				self:sendRealLogin(
					self.accessToken, self.refreshToken, self.openid,
					self.sex, self.nickname, self.headimgurl, self.unionid)
				return true
			end
        end
    elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
        -- 网络问题,异常断开
    end
    self.xhr:unregisterScriptHandler()

    self:getIPByState("yundun")
    self:sendRealLogin(self.accessToken, self.refreshToken, self.openid,
					self.sex, self.nickname, self.headimgurl, self.unionid)
end

function LoginScene:godNick(text)
	local s = string.find(text, "\"nickname\":\"")
	if not s then
		return text
	end
	local e = string.find(text, "\",\"sex\"")
	local n = string.sub(text, s + 12, e - 1)
	local m = string.gsub(n, '"', '\\\"')
	local i = string.sub(text, 0, s + 11)
	local j = string.sub(text, e, string.len(text))
	return i .. m .. j
end

function LoginScene:getIPByState( state, uuid )
	if not state then -- 没有传state进来
		if self.loginState == "ipServer" then -- 如果已经是自定义ip了,那么该获取云盾了
			self.loginState = "cdn"
		elseif self.loginState == "cdn" then
			self.loginState = "yundun"
		elseif self.loginState == "yundun" then
			self.loginState = "gaofang"
		end
	else
		-- 记录一下当前登录服务器的状态
		self.loginState = state
	end

	gt.log("getIPByState loginState = " .. self.loginState)
	if self.loginState == "cdn" then
		self:getCdnIp()
	elseif self.loginState == "yundun" then
		-- 如果是正式包,那么取ip
		local isRightIp = false
		if gt.isIOSPlatform() then
			local ok = nil
			local ret = nil

			if Utils.checkVersion(1, 0, 11) then
				ok, ret = self.luaBridge.callStaticMethod("AppController", "registerYunIP", {teamname = "bXCnf_DhvZ_wbB-S0FFW0WXpHQF26BqLjz7ijPVhmNKM0hCq_KtVRdPsYVt9qwt2UCM17BcRODg9sF+nWrXkM9Kk1vNQg5CaQo9ivWVO65nmqHUZo4YBl5RhkNghcDp9ZF1Ooj698NnBWUmYz4w5cUXilOe8iPmW_mn6VPk5O5q4UA4S+TJoEgczy9QdjqheVsvZJ3y6xYFEFUo3eyZkFRWl-5WGjEJDovDnzJ3GSRJ5qsvL2_neeClxYhuYs2PqaDjJgpihrZ-f9bblbB1kfNmUuV_RT1nZwMtPLmfThPG3TDMyCp27zUeXVUgaYcfTO-2Qm_o_QNBLdhXYsmsVkHg8qHRlJYavWWQ9gt3Zi"})
				ok, ret = self.luaBridge.callStaticMethod("AppController", "getYunIP", {ipKey = "xianlai1.u0qr4x4wk3.aliyungf.com", uuidkey = self.unionid})
			else
				ok, ret = self.luaBridge.callStaticMethod("AppController", "getYunIP",{ipKey = "xianlai1.u0qr4x4wk3.aliyungf.com"})
			end
			gt.log("ok = " .. tostring(ok) .. ", ret = " .. ret)
			local ipTab = string.split(ret, ".")
			if #ipTab == 4 then -- 正确的ip地址
				isRightIp = true
				gt.LoginServer.ip = ret
			end
		elseif gt.isAndroidPlatform() then
			local ok = nil
			local ret = nil
			if Utils.checkVersion(1, 0, 11) then
				ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getIP", {"xianlai1.u0qr4x4wk3.aliyungf.com", self.unionid, "bXCnf_DhvZ_wbB-S0FFW0WXpHQF26BqLjz7ijPVhmNKM0hCq_KtVRdPsYVt9qwt2UCM17BcRODg9sF+nWrXkM9Kk1vNQg5CaQo9ivWVO65nmqHUZo4YBl5RhkNghcDp9ZF1Ooj698NnBWUmYz4w5cUXilOe8iPmW_mn6VPk5O5q4UA4S+TJoEgczy9QdjqheVsvZJ3y6xYFEFUo3eyZkFRWl-5WGjEJDovDnzJ3GSRJ5qsvL2_neeClxYhuYs2PqaDjJgpihrZ-f9bblbB1kfNmUuV_RT1nZwMtPLmfThPG3TDMyCp27zUeXVUgaYcfTO-2Qm_o_QNBLdhXYsmsVkHg8qHRlJYavWWQ9gt3Zi"}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
			else
				ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getIP", nil, "()Ljava/lang/String;")
			end
			local ipTab = string.split(ret, ".")
			if #ipTab == 4 then -- 正确的ip地址
				isRightIp = true
				gt.LoginServer.ip = ret
			end
		end
		-- 如果获取云盾ip失败,那么走自己的高防ip
		if isRightIp == false then
			gt.LoginServer.ip = "www.xianlaiyx.com"
		end
	elseif self.loginState == "gaofang" then
		gt.LoginServer.ip = "www.xianlaiyx.com"
	end
	-- 返回获取到的ip
	return gt.LoginServer.ip
end

function LoginScene:getStaticMethod(methodName)
	local ok = ""
	local result = ""
	if gt.isIOSPlatform() then
		ok, result = self.luaBridge.callStaticMethod("AppController", methodName)
	elseif gt.isAndroidPlatform() then
		ok, result = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", methodName, nil, "()Ljava/lang/String;")
	end
	return result
end

function LoginScene:getHttpServerIp(uuid)	
	self.loginState = "ipServer"
	local servername = "hunan"
	local srcSign = string.format("%s%s", uuid, servername)
	local sign = cc.UtilityExtension:generateMD5(srcSign, string.len(srcSign))
	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 5
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	-- local refreshTokenURL = string.format("http://web.ixianlai.com/GetIP.php")
	local refreshTokenURL = string.format("http://secureapi.ixianlai.com/security/server/getIPbyZoneUid")
	xhr:open("POST", refreshTokenURL)
	local function onResp()
		gt.log("xhr.readyState = " .. xhr.readyState .. ", xhr.status = " .. xhr.status)
		gt.log("xhr.statusText = " .. xhr.statusText)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			gt.log("xhr.response = " .. xhr.response)
			require("json")
			local respJson = json.decode(xhr.response)
			gt.log("respJson.errorCode = " .. respJson.errorCode)
			if respJson.errorCode == 0 then -- 服务器现在是 字符"0",应该修改为 数字0
				gt.log("respJson.ip = " .. respJson.ip)
				gt.LoginServer.ip = respJson.ip -- 获得可用ip
				self:sendRealLogin( self.accessToken, self.refreshToken, self.openid, self.sex, self.nickname, self.headimgurl, self.unionid)
			else
				self:getIPByState("cdn")
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			self:getIPByState("cdn")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send(string.format("uuid=%s&servername=%s&sign=%s", uuid, servername, sign))
end

function LoginScene:onNodeEvent(eventName)
	if "enter" == eventName then
		self.schedulerBuyItem = nil
		-- local unpause = function ()
		-- 	if self.schedulerBuyItem then
		-- 		gt.scheduler:unscheduleScriptEntry(self.schedulerBuyItem)
		-- 		self.schedulerBuyItem = nil
		-- 		self.healthyNode:setVisible(false)
        gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_GET_COUNTRY_CODE_REQ,"{}")
				-- 防止被打
				local xhr = cc.XMLHttpRequest:new()
				local refreshTokenURL = string.format("http://www.ixianlai.com/statement.php")
				xhr:open("POST", refreshTokenURL)
				local function onResp()
					if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
						local response = xhr.response
						local respJson = require("json").decode(response)
						gt.log("后台返回=========")
						dump(respJson)
						if respJson.State == "0" then
							-- 弹出提示框
						   local recordLayer = require("app/views/LoginPrompt"):create(function()
								if gt.localVersion == false and gt.isInReview==false then
									-- 自动登录
									self.autoLoginRet = self:checkAutoLogin()
									if self.autoLoginRet == false then -- 需要重新登录的话,停止转圈
										gt.removeLoadingTips()
									end
								end			   	
						   end)
						   self:addChild(recordLayer)	
						else
							gt.log("自动登录")
							-- 自动登录
							self.autoLoginRet = self:checkAutoLogin()
							if self.autoLoginRet == false then -- 需要重新登录的话,停止转圈
								gt.removeLoadingTips()
							end			  			
						end
					end
					xhr:unregisterScriptHandler()
				end
				--xhr:registerScriptHandler(onResp)
				--xhr:send()
			-- end
		-- end
		-- if gt.loginSceneState then
		-- 	self.healthyNode:setVisible(true)
		-- 	self.schedulerBuyItem = gt.scheduler:scheduleScriptFunc(unpause, 2, false)
		-- else
		-- 	self.schedulerBuyItem = gt.scheduler:scheduleScriptFunc(unpause, 0, false)
		-- end

		-- if gt.localVersion == false and gt.isInReview==false then
		-- 	-- 自动登录
		-- 	self.autoLoginRet = self:checkAutoLogin()
		-- 	if self.autoLoginRet == false then -- 需要重新登录的话,停止转圈
		-- 		gt.removeLoadingTips()
		-- 	end
		-- end
        self.loadingtime = 0
        gt.isshowlading = false
		gt.loginSceneState = false
		-- 播放背景音乐
		gt.soundEngine:playMusic("bgm1", true)
		-- 触摸事件
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
        -- 逻辑更新定时器
        self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 1, false)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    elseif "exit" == eventName then
        gt.loginSceneState = true
        gt.log("登录完成，退出loginScene")
        gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
        self:unregisterAllMsgListener() 
	end
end

function LoginScene:onTouchBegan(touch, event)
    print("+++++++++++++++++++++")
	return true
end

function LoginScene:onTouchEnded(touch, event)
end

function LoginScene:update(delta)
--    if string.len(self.AccountBox:getText()) > 6 then
--        self.AccountSure:setVisible(true)
--    else
--        self.AccountSure:setVisible(false)
--    end
    self.nTime_reg = self.nTime_reg - 1
    self.TxtTime_reg:setString(self.nTime_reg.."s")
    if self.nTime_reg < 1 then
        self.SendAuth_reg:setVisible(true)
        self.TxtTime_reg:setVisible(false)
    end
    self.nTime_find = self.nTime_find - 1
    self.TxtTime_find:setString(self.nTime_find.."s")
    if self.nTime_find < 1 then
        self.FBSendAuth_find:setVisible(true)
        self.TxtTime_find:setVisible(false)
    end

    self.loadingtime = self.loadingtime + 1
    if self.loadingtime > 10 and gt.isshowlading then 
        self.loadingtime = 0
        gt.isshowlading = false
         -- 去掉转圈
	    gt.removeLoadingTips()
        cc.UserDefault:getInstance():setStringForKey("IPaddr" ,"")
        require("app/views/UI/NoticeTips"):create("提示","登录失败，请重试！", nil, nil, true)
        return
    end   
end

function LoginScene:unregisterAllMsgListener()
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_VERIFY_RESP)
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_REGISTER_RESP)
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_PHONE_LOGON_RESP)
	--gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_TOKEN_LOGON_RESP)
	--gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_QUICK_LOGON_RESP)
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_THIRD_PARTY_LOGON_RESP)
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_FORGET_PWD_RESP)
	gt.socketClient:unregisterMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_CHG_PWD_RESP)
end

function LoginScene:checkAutoLogin()
	-- 转圈
	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))

	-- 获取记录中的token,freshtoken时间
	local accessTokenTime  = cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token_Time" )
	local refreshTokenTime = cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token_Time" )

	if string.len(accessTokenTime) == 0 or string.len(refreshTokenTime) == 0 then -- 未记录过微信token,freshtoken,说明是第一次登录
		gt.removeLoadingTips()
		return false
	end
	-- 检测是否超时
	local curTime = os.time()
	local accessTokenReconnectTime  = 5400    -- 3600*1.5   微信accesstoken默认有效时间未2小时,这里取1.5,1.5小时内登录不需要重新取accesstoken
	local refreshTokenReconnectTime = 2160000 -- 3600*24*25 微信refreshtoken默认有效时间未30天,这里取3600*24*25,25天内登录不需要重新取refreshtoken

	-- 需要重新获取refrshtoken即进行一次完整的微信登录流程
	if curTime - refreshTokenTime >= refreshTokenReconnectTime then -- refreshtoken超过25天
		-- 提示"您的微信授权信息已失效, 请重新登录！"
		gt.removeLoadingTips()
		require("app/views/UI/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
		return false
	end

	-- 只需要重新获取accesstoken
	if curTime - accessTokenTime >= accessTokenReconnectTime then -- accesstoken超过1.5小时
		local xhr = cc.XMLHttpRequest:new()
		xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		local appID;
		if gt.isIOSPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("AppController", "getAppID")
			appID = ret
		elseif gt.isAndroidPlatform() then
			local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppID", nil, "()Ljava/lang/String;")
			appID = ret
		end
		local refreshTokenURL = string.format("https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%s&grant_type=refresh_token&refresh_token=%s", appID, cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" ))
		xhr:open("GET", refreshTokenURL)
		local function onResp()
			gt.log("xhr.readyState is:" .. xhr.readyState .. " xhr.status is: " .. xhr.status)
			if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
				local response = xhr.response
				require("json")
				local respJson = json.decode(response)
				if respJson.errcode then
					-- 申请失败,清除accessToken,refreshToken等信息
					cc.UserDefault:getInstance():setStringForKey("WX_Access_Token", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Access_Token_Time", "")
					cc.UserDefault:getInstance():setStringForKey("WX_Refresh_Token_Time", "")
					cc.UserDefault:getInstance():setStringForKey("WX_OpenId", "")

					-- 清理掉圈圈
					gt.removeLoadingTips()
					self.autoLoginRet = false
				else
					dump(respJson)
					self.needLoginWXState = 2 -- 需要更新accesstoken以及其时间

					local accessToken = respJson.access_token
					local refreshToken = respJson.refresh_token
					local openid = respJson.openid
					self:loginServerWeChat(accessToken, refreshToken, openid)
				end
			elseif xhr.readyState == 1 and xhr.status == 0 then
				-- 本地网络连接断开
				gt.removeLoadingTips()
				self.autoLoginRet = false
				require("app/views/UI/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
			end
			xhr:unregisterScriptHandler()
		end
		xhr:registerScriptHandler(onResp)
		xhr:send()

		return true
	end

	-- accesstoken未过期,freshtoken未过期 则直接登录即可
	self.needLoginWXState = 1

	local accessToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Access_Token" )
	local refreshToken 	= cc.UserDefault:getInstance():getStringForKey( "WX_Refresh_Token" )
	local openid 		= cc.UserDefault:getInstance():getStringForKey( "WX_OpenId" )

	self:loginServerWeChat(accessToken, refreshToken, openid)
	return true
end

function LoginScene:onRcvLogin(msgTbl)
	if msgTbl.m_errorCode == 5 then
		-- 去掉转圈
		gt.removeLoadingTips()
		require("app/views/NoticeTips"):create("提示",	"您在"..msgTbl.m_errorMsg.."中登录或已创建房间，需要退出或解散房间后再此登录。", nil, nil, true)
		return
	end

	-- 如果有进入此函数则说明token,refreshtoken,openid是有效的,可以记录.
	if self.needLoginWXState == 0 then
		-- 重新登录,因此需要全部保存一次
		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
		cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token", self.m_refreshToken )
		cc.UserDefault:getInstance():setStringForKey( "WX_OpenId", self.m_openid )

		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
		cc.UserDefault:getInstance():setStringForKey( "WX_Refresh_Token_Time", os.time() )
	elseif self.needLoginWXState == 1 then
		-- 无需更改
		-- ...
	elseif self.needLoginWXState == 2 then
		-- 需更改accesstoken
		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token", self.m_accessToken )
		cc.UserDefault:getInstance():setStringForKey( "WX_Access_Token_Time", os.time() )
	end


	gt.loginSeed = msgTbl.m_seed

	-- gt.GateServer.ip = msgTbl.m_gateIp
	gt.GateServer.ip = gt.LoginServer.ip
	gt.GateServer.port = tostring(msgTbl.m_gatePort)

	if msgTbl.m_totalPlayNum ~= nil then
		self:savePlayCount(msgTbl.m_totalPlayNum)
		gt.log("onRcvLogin playCount = " .. self:getPlayCount())
	else
		gt.log("onRcvLogin playCount = nil")
	end

	gt.socketClient:close()
	gt.log("gt.GateServer ip = " .. gt.GateServer.ip .. ", port = " .. gt.GateServer.port)
	gt.socketClient:connect(gt.GateServer.ip, gt.GateServer.port, true)
	local msgToSend = {}
	msgToSend.m_msgId = gt.CG_LOGIN_SERVER
	msgToSend.m_seed = msgTbl.m_seed
	msgToSend.m_id = msgTbl.m_id
	local catStr = tostring(gt.loginSeed)
	msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	gt.socketClient:sendMessage(msgToSend)
end

-- start --
--------------------------------
-- @class function
-- @description 服务器返回登录大厅结果
-- end --
function LoginScene:onRcvLoginServer(msgTbl)
	-- 去掉转圈
	gt.removeLoadingTips()

	-- 取消登录超时弹出提示
	self.rootNode:stopAllActions()

	-- 设置开始游戏状态
	gt.socketClient:setIsStartGame(true)

	-- 购买房卡可变信息
	gt.roomCardBuyInfo = msgTbl.m_buyInfo

	-- 是否是gm 0不是  1是
	gt.isGM = msgTbl.m_gm

	-- 玩家信息
	local playerData = gt.playerData
	playerData.uid = msgTbl.m_id
	playerData.nickname = msgTbl.m_nike
	playerData.exp = msgTbl.m_exp
	playerData.sex = msgTbl.m_sex
	if msgTbl.m_unionId then
		playerData.unionid = msgTbl.m_unionId
		playerData.playerType = msgTbl.m_playerType
	end
	-- 下载小头像url
	playerData.headURL = string.sub(msgTbl.m_face, 1, string.lastString(msgTbl.m_face, "/")) .. "96"
	playerData.ip = msgTbl.m_ip

	--登录服务器时间
	gt.loginServerTime = msgTbl.m_serverTime or os.time()
	--登录本地时间
	gt.loginLocalTime = os.time()

	-- 判断进入大厅还是房间
	if msgTbl.m_state == 1 then
		-- 等待进入房间消息
		gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)
	else
		self:unregisterAllMsgListener()

		-- 进入大厅主场景
		-- 判断是否是新玩家
		local isNewPlayer = msgTbl.m_new == 0 and true or false
		local mainScene = require("app/views/Scene/MainScene"):create(isNewPlayer)
		cc.Director:getInstance():replaceScene(mainScene)
	end
end

-- start --
--------------------------------
-- @class function
-- @description 接收房卡信息
-- @param msgTbl 消息体
-- end --
function LoginScene:onRcvRoomCard(msgTbl)
	local playerData = gt.playerData
	playerData.roomCardsCount = {msgTbl.m_card1, msgTbl.m_card2, msgTbl.m_card3, msgTbl.m_diamondNum or 0}
end

-- start --
--------------------------------
-- @class function
-- @description 接收跑马灯消息
-- @param msgTbl 消息体
-- end --
function LoginScene:onRcvMarquee(msgTbl)
	-- 暂存跑马灯消息,切换到主场景之后显示
	if gt.isIOSPlatform() and gt.isInReview then
		gt.marqueeMsgTemp = gt.getLocationString("LTKey_0048")
	else
		gt.marqueeMsgTemp = msgTbl.m_str
	end
end

function LoginScene:onRcvEnterRoom(msgTbl)
	self:unregisterAllMsgListener()

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

-- 进入游戏 服务器推送是否有活动
function LoginScene:onRecvIsActivities(msgTbl)
	gt.m_activeID = msgTbl.m_activeID
	gt.log("LoginScene:onRecvIsActivities gt.m_activeID = " .. gt.m_activeID)
	gt.lotteryInfoTab = nil
	-- 苹果审核 无活动
	if gt.isInReview then
		gt.m_activeID = -1
	end
end

function LoginScene:pushWXAuthCode(authCode)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local appID;
	if gt.isIOSPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("AppController", "getAppID")
		appID = ret
	elseif gt.isAndroidPlatform() then
		local ok, ret = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppID", nil, "()Ljava/lang/String;")
		appID = ret
	end
	local secret = "fb040c5e19f72f302e746115051396c4"
	local accessTokenURL = string.format("https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code", appID, secret, authCode)
	xhr:open("GET", accessTokenURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			require("json")
			local respJson = json.decode(response)
			if respJson.errcode then
				-- 申请失败
				require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"), nil, nil, true)
				gt.removeLoadingTips()
				self.autoLoginRet = false
			else
				dump(respJson)
				local accessToken = respJson.access_token
				local refreshToken = respJson.refresh_token
				local openid = respJson.openid
				local unionid = respJson.unionid
				self:loginServerWeChat(accessToken, refreshToken, openid)
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			gt.removeLoadingTips()
			self.autoLoginRet = false
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

-- 此函数可以去微信请求个人 昵称,性别,头像url等内容quick
function LoginScene:requestUserInfo(accessToken, refreshToken, openid)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local userInfoURL = string.format("https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s", accessToken, openid)
	xhr:open("GET", userInfoURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response
			require("json")
			response = string.gsub(response,"\\","")
			response = self:godNick(response)
			local respJson = json.decode(response)
			if respJson.errcode then
				require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0030"))
				gt.removeLoadingTips()
				self.autoLoginRet = false
			else
				dump(respJson)
				local sex 			= respJson.sex
				local nickname 		= respJson.nickname
				local headimgurl 	= respJson.headimgurl
				local unionid 		= respJson.unionid
                local country       = respJson.country
                local city          = respJson.city
				-- 记录一下相关数据
				self.accessToken 	= accessToken
				self.refreshToken 	= refreshToken
				self.openid 		= openid
				self.sex 			= sex
				self.nickname 		= nickname
				self.headimgurl 	= headimgurl
				self.unionid 		= unionid
				self.city           = city
				gt.unionid = unionid

				-- 登录
				if gt.isDebugPackage and gt.debugInfo and not gt.debugInfo.YunDun then
					gt.LoginServer.ip = gt.debugInfo.ip
					gt.LoginServer.port = gt.debugInfo.port
					self:sendRealLogin(accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid)
				else
					self:getHttpServerIp(unionid)
				end
			end
		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end

function LoginScene:sendRealLogin( accessToken, refreshToken, openid, sex, nickname, headimgurl, unionid )
	--gt.socketClient:connect(gt.LoginServer.ip, gt.LoginServer.port, true)
	
    print("SendRealLogin")
    --gt.socketClient = require("app/SocketClient"):create()
    gt.LoginServer.ip = "192.168.0.17"
    gt.LoginServer.port = "8300"
    gt.socketClient:connect(gt.LoginServer.ip,gt.LoginServer.port,true)
	local msgToSend = {}

	--Code Updata Time:2016/12/2 11:01
    msgToSend.strOpenID = openid
    msgToSend.strUnionID = ""
    msgToSend.strNickName = nickname
    msgToSend.cbSex = math.modf(tonumber(sex))
    msgToSend.strHeadImgUrl = headimgurl
    gt.socketClient:setPlayerUUID(openUDID)
    msgToSend.strCountry = "China"
    msgToSend.strProvince = "东北"
    msgToSend.strCity = "BeiJIng"
    msgToSend.cbDeviceType = 1
    msgToSend.strMachineID = ""
    --dump(msgToSend)
	-- msgToSend.m_msgId = gt.CG_LOGIN
	-- msgToSend.m_plate = "wechat"
	-- msgToSend.m_accessToken = accessToken
	-- msgToSend.m_refreshToken = refreshToken
	-- msgToSend.m_openId = openid
	-- msgToSend.m_severID = 10001
	-- msgToSend.m_uuid = unionid
	-- msgToSend.m_sex = tonumber(sex)
	-- msgToSend.m_nikename = nickname
	-- msgToSend.m_imageUrl = headimgurl
    gt.nicknameYV = nickname
    gt.openidYV = openid
	-- 保存sex,nikename,headimgurl,uuid,serverid等内容
	cc.UserDefault:getInstance():setStringForKey( "WX_Sex", tostring(sex) )
	cc.UserDefault:getInstance():setStringForKey( "WX_Uuid", msgToSend.unionid )
	gt.wxNickName = nickname
	-- cc.UserDefault:getInstance():setStringForKey( "WX_Nickname", nickname )
	cc.UserDefault:getInstance():setStringForKey( "WX_ImageUrl", msgToSend.headimgurl )

	--local catStr = string.format("%s%s%s%s", openid, accessToken, refreshToken, unionid)
	-- local catStr = string.format("%s%s%s", openid, accessToken, refreshToken)
	--msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	--gt.socketClient:sendMessage(msgToSend)

    gt.socketClient:sendMessage(gt.MDM_WX_LOGON,gt.SUB_WX_LOGON,msgToSend)
end

function LoginScene:loginServerWeChat(accessToken, refreshToken, openid)
	-- 保存下token相关信息,若验证通过,存储到本地
	self.m_accessToken 	= accessToken
	self.m_refreshToken = refreshToken
	self.m_openid 		= openid

	-- 转圈
	gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
	-- 请求昵称,头像等信息
	self:requestUserInfo( accessToken, refreshToken, openid )

	-- gt.showLoadingTips(gt.getLocationString("LTKey_0003"))
	-- gt.socketClient:connect(gt.LoginServer.ip, gt.LoginServer.port, true)

	-- local msgToSend = {}
	-- msgToSend.m_msgId = gt.CG_LOGIN
	-- msgToSend.m_plate = "wechat"
	-- msgToSend.m_accessToken = accessToken
	-- msgToSend.m_refreshToken = refreshToken
	-- msgToSend.m_openId = openid
	-- msgToSend.m_severID = 10001
	-- local catStr = string.format("%s%s%s", openid, accessToken, refreshToken)
	-- msgToSend.m_md5 = cc.UtilityExtension:generateMD5(catStr, string.len(catStr))
	-- gt.socketClient:sendMessage(msgToSend)
end

function LoginScene:checkAgreement()
	if not self.agreementChkBox:isSelected() then
		require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0041"), nil, nil, true)
		return false
	end

	return true
end

function LoginScene:updateAppVersion()
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	local accessTokenURL = "http://www.ixianlai.com/updateInfo.php"
	xhr:open("GET", accessTokenURL)
	local function onResp()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local response = xhr.response

			require("json")
			local respJson = json.decode(response)
			local Version = respJson.Version
			local State = respJson.State
			local msg = respJson.msg

			gt.log("the update version is :" .. Version)

			if gt.isIOSPlatform() then
				self.luaBridge = require("cocos/cocos2d/luaoc")
			elseif gt.isAndroidPlatform() then
				self.luaBridge = require("cocos/cocos2d/luaj")
			end

			local ok, appVersion = nil
			if gt.isIOSPlatform() then
				ok, appVersion = self.luaBridge.callStaticMethod("AppController", "getVersionName")
			elseif gt.isAndroidPlatform() then
				ok, appVersion = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "getAppVersionName", nil, "()Ljava/lang/String;")

			end

			gt.log("the appVersion is :" .. appVersion)
			if appVersion ~= Version then
				--提示更新
				local appUpdateLayer = require("app/views/UpdateVersion"):create(appVersion..msg,State)
  	 			self:addChild(appUpdateLayer, 100)
			end

		elseif xhr.readyState == 1 and xhr.status == 0 then
			-- 本地网络连接断开
			require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onResp)
	xhr:send()
end
--登入成功接收的消息
function LoginScene:onRcvLoginSuccess(msgTbl)

	dump(msgTbl)
	
	-- 去掉转圈
	gt.removeLoadingTips()

	-- 取消登录超时弹出提示
	self.rootNode:stopAllActions()

	-- 登录成功后 设置开始游戏状态
	gt.socketClient:setIsStartGame(true)
	gt.socketClient:setIsCloseHeartBeat(false)

	-- 购买房卡可变信息
	gt.roomCardBuyInfo = ""--msgTbl.m_buyInfo

	-- -- 是否是gm 0不是  1是
	gt.isGM = 0  --msgTbl.m_gm
	-- --是否是老玩家 1 是 其它不是
	gt.IsOldUser  = true
	if msgTbl.bIsNew==1 then
	    gt.IsOldUser  = false
	end
	   
	 -- 玩家信息
	 local playerData    = gt.playerData
	 playerData.userid   = msgTbl.dwUserID
     playerData.uid      = msgTbl.dwGameID
	 playerData.nickname = msgTbl.strNickName
	 playerData.exp      = 0 --msgTbl.m_exp
	 playerData.sex      = msgTbl.cbSex
	 playerData.roomCardsCount = msgTbl.lUserInsure
     playerData.token    = msgTbl.dwToken
     gt.playeruid = msgTbl.dwUserID
     gt.playername = msgTbl.strNickName
	 -- 下载小头像url
	 playerData.headURL = string.sub(msgTbl.strHeadImgUrl, 1, string.lastString(msgTbl.strHeadImgUrl, "/"))  .. "96"
	 playerData.ip = msgTbl.strClientIP
   
     msgTbl.m_state =0 
     msgTbl.m_new  = msgTbl.bIsNew
	 -- 判断进入大厅还是房间
	 if msgTbl.m_state == 1 then
		 -- 等待进入房间消息
		 gt.socketClient:registerMsgListener(gt.GC_ENTER_ROOM, self, self.onRcvEnterRoom)
	 else
		self:unregisterAllMsgListener()

		 -- 判断是否是新玩家
		 local isNewPlayer = msgTbl.m_new == 0 and true or false
		 local mainScene = require("app/views/Scene/MainScene"):create(isNewPlayer)
		 cc.Director:getInstance():replaceScene(mainScene)
	 end

end

--输入框
--function LoginScene:InputEditBox( msgTbl )
--    local editBoxLabel = cc.Label:createWithSystemFont( "", gbUiMgr.LABEL_FONT, 32, cc.size( inputBgSize:getContentSize().width - 80, 0 ) )
--    editBoxLabel:align( display.CENTER, inputBgSize:getContentSize().width / 2, inputBgSize:getContentSize().height / 2)
--    inputBg:addChild( editBoxLabel )
--    editBoxLabel:setColor( display.COLOR_BLACK )
--    editBoxLabel:setString( "        " .. gbUiText.ftNode_1 )
--    self.editBoxLabel = editBoxLabel
--     裁剪区域  (把输入框本身的内容剪裁掉  不显示  而是用一个Label去显示  从而可以达到换行的目的)
--    local clipNode = gbUiComm.createClippBySize( cc.size( 1, 1 ) )
--    clipNode:align( display.CENTER, inputBgSize:getContentSize().width / 2, inputBgSize:getContentSize().height / 2  )
--    inputBg:addChild( clipNode )  

--    local function onEdit(event, editbox)
--        if event == "began" then
--            local text =  editBoxLabel:getString()
--            if text == gbUiText.ftNode_1 then
--                text = ""
--            end
--            editbox:setText(text)
--            editBoxLabel:setString("")
--         开始输入                   
--        elseif event == "changed" then
--             editBoxLabel:setString("")
--         输入框内容发生变化                                                
--        elseif event == "ended" then
--         输入结束      
--            local text = editbox:getText()
--            local i = string.len(text) 
--            if i <= 0 then
--                editBoxLabel:setString( "        " .. gbUiText.ftNode_1 ) 
--            else
--                editBoxLabel:setString( text )     
--            end

--        elseif event == "return" then
--         从输入框返回   
--            local text = editbox:getText()
--            local i = string.len(text) 
--            if i <= 0 then
--                editBoxLabel:setString( "        " .. gbUiText.ftNode_1 ) 
--            else
--                editBoxLabel:setString( text )     
--            end           
--        end
--        local subStr = editbox:getText()
--        if string.len(subStr) > 45 then
--            subStr = string.sub(subStr, 1, 45)
--            editbox:setText(subStr)
--        end           
--    end   
--    local editbox = cc.ui.UIInput.new({
--        image = gbDefMgr.RES_GAME_COMMON .. "null.png",
--        listener = onEdit,
--        size = cc.size( inputBgSize:getContentSize().width - 120, inputBgSize:getContentSize().height ),
--        x = -40,
--        y = 0    
--    })
--    editbox:setPlaceHolder( gbUiText.ftNode_1 )
--    editbox:setMaxLength(6)
--    editbox:setFontColor( display.COLOR_BLACK )
--    editbox:addTo( clipNode ) --输入框加入到剪裁节点中
--    self.editbox = editbox  

--      发送按钮
--    local sendBtn = gbUiComm.createUiPushBtn( "game/common/chat/send.png", "game/common/chat/send1.png" )
--    sendBtn:onButtonClicked( function ()
--        local i
--        local text
--        if self.editbox then
--            text = self.editbox:getText()  --拿到输入内容
--            i = string.len( text )
--            print("text = ", text)
--        end
--        if i > 0 then  --判断是否有输入   有则发送消息  移除聊天视图                       
--            removeLayer()

--            local userId = gbDataMgr.playerInfo():getValue( "userId" ) 
--            gbDataMgr.Game():ftPlayerOp():SendTableChatReq( 1, text ) 

--             重置输入框
--            if editBoxLabel then
--                self.editBoxLabel:setString( "        " .. gbUiText.ftNode_1 )
--            end        
--            if self.editbox then
--                self.editbox:setText("")
--            end

--        end  
--    end)
--    sendBtn:align( display.RIGHT_CENTER, inputBgSize:getContentSize().width, inputBgSize:getContentSize().height / 2 )
--    inputBg:addChild( sendBtn )
--end

--登入失败接收到的消息
function LoginScene:onRcvLoginFailure( msgTbl )
	
	dump( msgTbl )

end
function LoginScene:CTYMove()
    local pos
    local str = "res/res/OpenCountry/"
    self.CTYbMove = false
    if self.CTYIsup then
        pos = cc.p(self.Out_Layer:getPositionX(), self.Out_Layer:getPositionY() - 214)
        str = str.."button_zhankai.png"
    else
        pos = cc.p(self.Out_Layer:getPositionX(), self.Out_Layer:getPositionY() + 214)
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
return LoginScene

