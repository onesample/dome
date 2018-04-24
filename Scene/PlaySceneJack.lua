
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local PlaySceneJack = class("PlaySceneJack", function()
	return cc.Scene:create()
end)

function PlaySceneJack:ctor()

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("LittleGame_Jack.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    
    local lobby_bj = gt.seekNodeByName(csbNode, "GameJackBg_1")

	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        Utils.setClickEffect()
        local LittleGameScene = require("app/views/Scene/LittleGameScene"):create()
		 cc.Director:getInstance():replaceScene(LittleGameScene)     
	end)
end


return PlaySceneJack

