
-- Creator ArthurSong
-- Create Time 2016/2/23

local gt = cc.exports.gt

local GametopNode = class("GametopNodes", function()
	return cc.CSLoader:createNode("GameTopNode.csb")
end)

function GametopNode:ctor(father, RoomMsgTbl ,ChoseGameid)
    self.father = father
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.msgTextCache = {}

    self.PlayActions = false

	self.RoomMsgTbl = RoomMsgTbl
    self.ChoseGameid = ChoseGameid

    --local Label_Text = gt.seekNodeByName(self, "Label_Text")
    --Label_Text:setString(RoomMsgTbl[1].."-"..RoomMsgTbl[3].."期-"..RoomMsgTbl[4])

    self:showzhonjian(RoomMsgTbl)

	-- 返回按钮
	local backBtn = gt.seekNodeByName(self, "Btn_back")
    gt.addBtnPressedListener(backBtn, handler(self, function()
        Utils.setClickEffect()
        function OKcallfan(args)
    		self:removeFromParent()
            gt.soundEngine:stopEffect(gt.playEngineStr)
                --离开桌子
            gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_LEAVE_REQ,{})
            local playScene = require("app/views/Scene/GameRoom"):create()
            cc.Director:getInstance():replaceScene(playScene)
        end
            require("app/views/UI/NoticeTips"):create("提示",	"您的资金将在本局结算后返还\n确定退出？", OKcallfan, nil, false)
            --cc.Director:getInstance():popScene()
	end))

    -- 开奖结果
	local result_but = gt.seekNodeByName(self, "result_but")
    gt.addBtnPressedListener(result_but, handler(self, function()
        Utils.setClickEffect()
			--self:removeFromParent()
              --开奖结果
--            local resultScene = require("app/views/Scene/ResultScene"):create(self.ChoseGameid)
--            self:addChild(resultScene)
                --排行榜
            local RangeScene = require("app/views/Scene/RangeScene"):create()
            self.father:addChild(RangeScene)
            RangeScene:setLocalZOrder(100009)
            --庄家收益
--            local ProfitScene = require("app/views/Scene/ProfitScene"):create()
--            self:addChild(ProfitScene,99)
	end))

end

function GametopNode:onNodeEvent(eventName)
	if "enter" == eventName then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function GametopNode:update(delta)
	if not self.PlayActions then
		return
	end

    --跑球
end

function GametopNode:showzhonjian(zhonjianTal,tbl)
--	if type(zhonjianTal) ~= "table"  then
--		return
--	end
    local numtap = tbl
    if zhonjianTal ~= "" then
        numtap =  gt.string_split(zhonjianTal[2],",")
        local Label_Text = gt.seekNodeByName(self, "Label_Text")
        Label_Text:setString(zhonjianTal[1].."-"..zhonjianTal[3].."期-"..zhonjianTal[4])
    end
	for i = 1, 10  do
        --local num =  string.sub(RoomMsgTbl[2],i,i);
        local num =  numtap[i]
        --local sNum = ""
        if self.ChoseGameid ~= 6 then
		    local shade = gt.seekNodeByName(self, "shade_" .. i)
		    local shadow = gt.seekNodeByName(self, "shadow_" .. i)
            shadow:setVisible(false)
            shade:setPosition(124+516/(#numtap -1)*(i-1),shade:getPositionY())
            if #numtap <= 5 then
                shade:setPosition(178+394/(#numtap -1)*(i-1),shade:getPositionY())
            end
            if num == nil then
                shade:setVisible(false)
            else
                if num ~= "10" then
                    if self.ChoseGameid ~= 6 then
                        for w in string.gmatch(num, "[^%z]") do
                            num = w
                        end
                    end
                else
                    num = "0"
                end
            end
		    shade:setString(num)
        else
            local shade = gt.seekNodeByName(self, "shade_" .. i)
		    local shadow = gt.seekNodeByName(self, "shadow_" .. i)
            shade:setVisible(false)
            shadow:setVisible(false)
            shadow:setPosition(124+516/(#numtap -1)*(i-1),shadow:getPositionY())
            if num == nil then
                shadow:setVisible(false)
            else
                if num ~= "10" then
                    if self.ChoseGameid ~= 6 then
                        for w in string.gmatch(num, "[^%z]") do
                            num = w
                        end
                    end
                end
            end
		    local lottery_num = gt.seekNodeByName(shadow, "lottery_num")
            lottery_num:setString(num)
        end
	end
end

function GametopNode:showMsg(msgText, repeattimes)

end

return GametopNode