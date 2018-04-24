
local gt = cc.exports.gt

local NoticeTips = class("NoticeTips", function()
	return gt.createMaskLayer(160)
end)

function NoticeTips:ctor(titleText, tipsText, okFunc, cancelFunc, singleBtn,sprFile)
	self:setName("NoticeTips")

	local csbNode = cc.CSLoader:createNode("NoticeTips.csb")
    csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	self:addChild(csbNode)

	self.rootNode = csbNode
   
	if titleText then
		local titleLabel = gt.seekNodeByName(csbNode, "Label_title")
		titleLabel:setString(titleText)
	end

	if tipsText then
		local tipsLabel = gt.seekNodeByName(csbNode, "Label_tips")
		tipsLabel:setString(tipsText)
	end
	
	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	gt.addBtnPressedListener(okBtn, function()
        Utils.setClickEffect()
        self:removeFromParent()	
		if okFunc then
			okFunc()
		end
	end)

	local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	gt.addBtnPressedListener(cancelBtn, function()
        Utils.setClickEffect()
		self:removeFromParent()
		if cancelFunc then
			cancelFunc()
		end
	end)
    
    local oktext=gt.seekNodeByName(okBtn,"Image_1")
    if sprFile then
        oktext:setTexture(sprFile)
    end
	local canceltext=gt.seekNodeByName(cancelBtn,"Image_2") 
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("images/public_ui.plist")  --zjc 20161118

-- æŒ‰é’®äº¤æ¢é¢œè‰²
    if titleText=="提示" then
        local okBtn=gt.seekNodeByName(csbNode, "Btn_ok")
        local cancelBtn=gt.seekNodeByName(csbNode, "Btn_cancel")    --zjc 20161118
        -- oktext:loadTexture("text_sure.png",1)
        -- canceltext:loadTexture("text_cancel.png",1)
    end
   
	if singleBtn then
		--okBtn:setPositionX(0)
		cancelBtn:setVisible(false)
	end

	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then

        gt.log("提示窗口")
        local NoticeTips = runningScene:getChildByName("NoticeTips")
        if NoticeTips == nil then
		    runningScene:addChild(self, gt.CommonZOrder.NOTICE_TIPS)
        end

	end
	
end

return NoticeTips
