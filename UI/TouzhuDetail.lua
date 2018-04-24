
local gt = cc.exports.gt
local Utils = cc.exports.Utils

local TouzhuDetail = class("TouzhuDetail", function()
	return cc.Layer:create()
end)

function TouzhuDetail:ctor()

	local Decdetail = nil
	Decdetail = cc.CSLoader:createNode("Decdetail.csb")
    self.Decdetail = Decdetail

	Decdetail:setAnchorPoint(0.5, 0.5)
	--Decdetail:setPosition(gt.winCenter)
    self.DecdetailPosX = 375
    self.DecdetailPosY = 667
    Decdetail:setPosition(cc.p(self.DecdetailPosX, self.DecdetailPosY + 700))
	self:addChild(Decdetail)
    
	local DecdetailStopBtn = gt.seekNodeByName(Decdetail, "Button_Stop")        --收起投注显示
    DecdetailStopBtn:addClickEventListener(function()
        self:DecdetailMove()
	end)
    --更多投注明细
	local DecdetailMoreBtn = gt.seekNodeByName(Decdetail, "Button_MoreDetail")        --收起投注显示
    DecdetailMoreBtn:addClickEventListener(function()
        local BettingDetaiScene = require("app/views/Scene/BettingDetaiScene"):create()
        self:addChild(BettingDetaiScene)
	end)

    self.Decdetail = Decdetail
	local CardSetBtn = gt.seekNodeByName(Decdetail, "Button_CardSet")        --卡牌设置
    CardSetBtn:addClickEventListener(function()
        local AddCardSet = require("app/views/Scene/AddCardSet"):create()
		 cc.Director:getInstance():replaceScene(AddCardSet)   
	end)

end

function TouzhuDetail:DecdetailMove()
        
    local pos
    local str = "res/res/"
    if self.DecdetailIsup then
        pos = cc.p(self.DecdetailPosX, self.DecdetailPosY)
        str = str.."upgame.png"
    else
        pos = cc.p(self.DecdetailPosX, self.DecdetailPosY + 700)
        str = str.."down.png"
    end
    local moveTo = cc.MoveTo:create(0.2, pos)
    local call = cc.CallFunc:create(function ()
        self.DecdetailIsup = not self.DecdetailIsup
--        local grade_png = gt.seekNodeByName(self.lobby_bj, "down_Decdetail")
--        grade_png:setTexture(str)
    end)
    local spa = cc.Spawn:create(moveTo, call)
    self.Decdetail:stopAllActions()
    self.Decdetail:runAction(spa)

end


return TouzhuDetail