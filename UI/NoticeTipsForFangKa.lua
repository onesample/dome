
local gt = cc.exports.gt

local NoticeTipsForFangKa = class("NoticeTipsForFangKa", function()
	return cc.LayerColor:create(cc.c4b(85, 85, 85, 85), gt.winSize.width, gt.winSize.height)
end)

-- fangkaInfoFlag 如果此参数为true则说明是购买房卡提示，需要进行特殊处理
function NoticeTipsForFangKa:ctor(titleText, tipsText, okFunc, cancelFunc, singleBtn)
	self:setName("NoticeTipsForFangKa")
    
    if gt.isIOSPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaoc")
	elseif gt.isAndroidPlatform() then
		self.luaBridge = require("cocos/cocos2d/luaj")
	end
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	local csbNode = cc.CSLoader:createNode("NoticeTipsForFangKa.csb")
	local btn1 = gt.seekNodeByName(csbNode,"Button_buy")
	local btn2 = gt.seekNodeByName(csbNode,"Button_agent")
	local btn3 = gt.seekNodeByName(csbNode,"Button_qq")

 	
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
	self.rootNode = csbNode
	self.showStrLabel1 = gt.seekNodeByName(csbNode, "Label_Show1")
	self.showStrLabel2 = gt.seekNodeByName(csbNode, "Label_Show2")
    self.showStrLabel3 = gt.seekNodeByName(csbNode, "Label_Show3")
    
	if titleText then
		local titleLabel = gt.seekNodeByName(csbNode, "Label_title")
		titleLabel:setString(titleText)
	end
	if tipsText then
		self.strTab = string.split(tipsText, ",")
		if self.strTab[1] then
			self.showStrLabel1:setString(self.strTab[1])
		end
		if self.strTab[2] then
			-- self.showStrLabel2:setString(self.strTab[2])
			local content = {"xianlai0217", "xianlai0199", "xianlai0177", "paohuzi110"}
			self.showStrLabel2:setString(content[gt.playerData.uid % 4 + 1] .. "【微信】")
		end
		if self.strTab[3] then
			-- self.showStrLabel3:setString(self.strTab[3])
			self.showStrLabel3:setString("xianlai6【微信公众号】")
		end
	end
    
	-- btn1:setVisible(true)
	-- btn2:setVisible(true)
	-- btn3:setVisible(true)
	btn1:setTag(10000)
	btn2:setTag(10001)
	btn3:setTag(10002)
	local function okCallback(sender)
 	
 	if sender:getTag()==10000 then
 		self.copy_Str=self.showStrLabel1:getString()
     elseif sender:getTag()==10001 then
        self.copy_Str=self.showStrLabel2:getString()
     elseif sender:getTag()==10002 then
        self.copy_Str=self.showStrLabel3:getString()
    end
    if gt.isIOSPlatform() then
	local okJump = self.luaBridge.callStaticMethod("AppController", "copyStr",{copystr = self.copy_Str})
	elseif gt.isAndroidPlatform() then
	local okJump = self.luaBridge.callStaticMethod("org/cocos2dx/lua/AppActivity", "copyStr",
	{self.copy_Str}, "(Ljava/lang/String;)V")  
    end	

end
    gt.addBtnPressedListener(btn1, function(sender)
		okCallback(sender)
	end)
	gt.addBtnPressedListener(btn2, function(sender)
		okCallback(sender)
	end)
	gt.addBtnPressedListener(btn3, function(sender)
		okCallback(sender)
	end)
	


	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	gt.addBtnPressedListener(okBtn, function()
		self:removeFromParent()
		if okFunc then
			okFunc()
		end
	end)

	local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	gt.addBtnPressedListener(cancelBtn, function()
		self:removeFromParent()
		if cancelFunc then
			cancelFunc()
		end
	end)

	if singleBtn then
		okBtn:setPositionX(0)
		cancelBtn:setVisible(false)
	end

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
	end
end

function NoticeTipsForFangKa:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	elseif "exit" == eventName then
		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:removeEventListenersForTarget(self)
	end
end

function NoticeTipsForFangKa:onTouchBegan(touch, event)
	return true
end

function NoticeTipsForFangKa:onTouchEnded(touch, event)
	local bg = gt.seekNodeByName(self.rootNode, "Img_bg")
	if bg then
		local point = bg:convertToNodeSpace(touch:getLocation())
		local rect = cc.rect(0, 0, bg:getContentSize().width, bg:getContentSize().height)
		if not cc.rectContainsPoint(rect, cc.p(point.x, point.y)) then
			self:removeFromParent()
		end
	end
end

return NoticeTipsForFangKa
