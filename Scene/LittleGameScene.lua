
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local LittleGameScene = class("LittleGameScene", function()
	return cc.Scene:create()
end)
gameChose = 
        {
    {bj = "LittleGame1.png" },
    {bj = "LittleGame2.png" },
        }

function LittleGameScene:ctor()

	local csbNode = nil
	csbNode = cc.CSLoader:createNode("LittleGame_Scene.csb")

	csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(gt.winCenter)
	self:addChild(csbNode)
    
    local lobby_bj = gt.seekNodeByName(csbNode, "lobby_bj")

	-- 返回按钮
	local backBtn = gt.seekNodeByName(lobby_bj, "Btn_back")
	gt.addBtnPressedListener(backBtn, function()
        local MainScene = require("app/views/Scene/MainScene"):create()
        cc.Director:getInstance():replaceScene(MainScene)
	end)

    self.LittleGameList = gt.seekNodeByName(csbNode, "ListView_Game")
    self:initGameRoomlist()
end

--游戏房间选择
function LittleGameScene:initGameRoomlist()
	for i, cellData in ipairs(gameChose) do
		local GameItem = self:createGameItem(i, cellData)
		self.LittleGameList:pushBackCustomItem(GameItem)
	end
end


function LittleGameScene:createGameItem(tag, cellData)
	local cellNode = cc.CSLoader:createNode("LittleGame_List.csb")
	-- game 图
	local gametuo = gt.seekNodeByName(cellNode, "LittleGame1_1")
    local str = "res/res/LittleGame/"..cellData.bj
	if cc.FileUtils:getInstance():isFileExist(str) then
        gametuo:setTexture(str)
    end
    
	local cellSize = cellNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(cellNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	cellItem:addClickEventListener(handler(self, self.enterGame))
	return cellItem
end

function LittleGameScene:enterGame(sender, eventType)
    local gameid = sender:getTag()
    gt.log("enterGame== ",gameid,gameid%2)
    local playScene
    if gameid == 1 then
        playScene = require("app/views/Scene/PlaySceneFruit"):create()
    elseif gameid == 2 then
        playScene = require("app/views/Scene/PlaySceneJack"):create()
    end
    cc.Director:getInstance():pushScene(playScene)
end
return LittleGameScene

