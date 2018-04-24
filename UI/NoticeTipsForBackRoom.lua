
local gt = cc.exports.gt

local NoticeTipsForBackRoom = class("NoticeTipsForBackRoom", function()
	return gt.createMaskLayer()
end)

-- fangkaInfoFlag 如果此参数为true则说明是购买房卡提示，需要进行特殊处理
function NoticeTipsForBackRoom:ctor(titleText, tipsText, okFunc, cancelFunc)
	self:setName("NoticeTipsForBackRoom")

	local csbNode = cc.CSLoader:createNode("NoticeTipsForBackRoom.csb")
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)

	-- if titleText then
	-- 	local titleLabel = gt.seekNodeByName(csbNode, "Label_title")
	-- 	titleLabel:setString(titleText)
	-- end
	-- if tipsText then
	-- 	local strTab = string.split(tipsText, ",")
	-- 	if strTab[1] then
	-- 		local showStrLabel = gt.seekNodeByName(csbNode, "Label_Show1")
	-- 		showStrLabel:setString(strTab[1])
	-- 	end
	-- 	if strTab[2] then
	-- 		local showStrLabel = gt.seekNodeByName(csbNode, "Label_Show2")
	-- 		showStrLabel:setString(strTab[2])
	-- 	end
	-- 	if strTab[3] then
	-- 		local showStrLabel = gt.seekNodeByName(csbNode, "Label_Show3")
	-- 		showStrLabel:setString(strTab[3])
	-- 	end
	-- end

	-- 左边按钮,应该解散房间并弹出输入房间号的界面
	local okBtn = gt.seekNodeByName(csbNode, "Btn_ok")
	gt.addBtnPressedListener(okBtn, function()
		self:removeFromParent()
		if okFunc then
			okFunc()
		end
	end)

	-- 右边按钮,应该返回自己所在的房间
	local cancelBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	gt.addBtnPressedListener(cancelBtn, function()
		self:removeFromParent()
		if cancelFunc then
			cancelFunc()
		end
	end)

	-- 右上角"x"号,关闭按钮
	local okBtn = gt.seekNodeByName(csbNode, "Btn_close")
	gt.addBtnPressedListener(okBtn, function()
		self:removeFromParent()
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

return NoticeTipsForBackRoom
