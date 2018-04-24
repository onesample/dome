
local gt = cc.exports.gt

local FeedBackScene = class("FeedBackScene", function()
	return gt.createMaskLayer(160)
end)

require("app.protocols.cmd_lobby_pb")

function FeedBackScene:ctor(titleText, tipsText, okFunc, cancelFunc, singleBtn)
	self:setName("FeedBackScene")

	local csbNode = cc.CSLoader:createNode("FeedBack.csb")
    csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	self:addChild(csbNode)

	self.rootNode = csbNode
    
    -- 返回按钮
	local backBtn = gt.seekNodeByName(csbNode, "Btn_cancel")
	gt.addBtnPressedListener(backBtn, function()
        self:removeFromParent()
        Utils.setClickEffect()
	end)

    local TextField = gt.seekNodeByName(csbNode, "TextField_1")
    
    -- 提交按钮
	local submit_btn = gt.seekNodeByName(csbNode, "submit_btn")
	gt.addBtnPressedListener(submit_btn, function()
        --用户意见反馈请求
        local TextSTr = TextField:getString()
        if #TextSTr > 0 then
            local cmsg = cmd_lobby_pb.CUserFeedBackReq()
            cmsg.msg_content = TextField:getString()
            local msgData = cmsg:SerializeToString()
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_WRITE_FEEDBACK_REQ,msgData)        
        else
            require("app/views/UI/NoticeTips"):create("提示",	"没有填定内容！", nil, nil, true)
            --self:removeFromParent()
        end

	end)

    -- 获取用户投注详情
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_WRITE_FEEDBACK_RESP, self, self.onWriteFeedbackResp)

end

function FeedBackScene:onWriteFeedbackResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_lobby_pb.SUserFeedBackResp()
    stResp:ParseFromString(buf)
    if stResp.code == 0 then
       require("app/views/UI/NoticeTips"):create("提示","提交成功！", nil, nil, true)
       self:removeFromParent()
    else
       require("app/views/UI/NoticeTips"):create("提示","提交失败！", nil, nil, true)
       self:removeFromParent()
    end
end

return FeedBackScene
