--提现
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local SystemMsg = class("SystemMsg", function()
	return cc.Scene:create()
end)

function SystemMsg:ctor()

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("Msg_Scene.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    
    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")
    -- 跑马灯
	local marqueeNode = gt.seekNodeByName(lobby_bj, "Node_marquee")
	local marqueeMsg = require("app/views/UI/MarqueeMsg"):create()
	marqueeNode:addChild(marqueeMsg)
--    gt.marqueeMsgTemp = "数学家在不在玩！"
--	self.marqueeMsg = marqueeMsg
--	if gt.marqueeMsgTemp then
--		self.marqueeMsg:showMsg(gt.marqueeMsgTemp)
--	end
	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        local MainScene = require("app/views/Scene/MainScene"):create()
        cc.Director:getInstance():replaceScene(MainScene)
	end)
end


return SystemMsg

