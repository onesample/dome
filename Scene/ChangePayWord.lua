
local gt = cc.exports.gt
local Utils = cc.exports.Utils

require("app.protocols.cmd_lobby_pb")
require("app.protocols.cmd_account_pb")

local ChangePayWord = class("ChangePayWord", function()
	return gt.createMaskLayer(80)
end)

function ChangePayWord:ctor()

    self._OfficNode = {}
    self._RuleNode = {}
    print("ChangePayWord === ")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local csbNode = cc.CSLoader:createNode("Recharge_Change.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
    csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	--self:setPosition(cc.p(-gt.winSize.width * 0.5, -gt.winSize.height + 57 ))
	self:addChild(csbNode)
	self.rootNode = csbNode

    --
    local PssWord_Old = gt.seekNodeByName(self.rootNode, "PssWord_Old")
    local PassWord_New = gt.seekNodeByName(self.rootNode, "PassWord_New")
    local PassWord_Repeat = gt.seekNodeByName(self.rootNode, "PassWord_Repeat")

    local ChangeSure_but = gt.seekNodeByName(self.rootNode, "ChangeSure_but")
    gt.addBtnPressedListener(ChangeSure_but, handler(self, function()
        Utils.setClickEffect()
        local cmsg = cmd_account_pb.CModifyExchangePwdReq()
        cmsg.old_pwd = gt.PasswordEncrypt(PssWord_Old:getStringValue())
        cmsg.new_pwd = gt.PasswordEncrypt(PassWord_New:getStringValue()) 
        local msgData = cmsg:SerializeToString()
        gt.socketClient:sendMessage( cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_MODIFY_EXCHANGE_PWD_REQ,msgData)                
	end))
    
    --关闭按钮
    local Clsoe_but = gt.seekNodeByName(self.rootNode, "Button_Close")
    gt.addBtnPressedListener(Clsoe_but, handler(self, function()
        Utils.setClickEffect()
        self:removeFromParent()
	end))


        --增加收款人银行卡应答
    gt.socketClient:registerMsgListener(cmd_net_pb.CMD_ACCOUNT, cmd_net_pb.CMD_ACCOUNT_MODIFY_EXCHANGE_PWD_RESP, self, self.onModlfyExchangePwdResp)

end

function ChangePayWord:onModlfyExchangePwdResp(msgTbl)
    gt.DataBase:headDecode( msgTbl )
    local buf = gt.DataBase:getBodyBuff(msgTbl)
    local stResp = cmd_account_pb.SModifyExchangePwdResp()
    stResp:ParseFromString(buf)
    gt.log("onAddPayeeResp code:"..stResp.code)
    if stResp.code == 0 then
        require("app/views/UI/NoticeTips"):create("提示","修改成功！", nil, nil, true)
    elseif stResp.code == 1 then
        require("app/views/UI/NoticeTips"):create("提示","系统错误！", nil, nil, true)
    elseif stResp.code == 2 then
        require("app/views/UI/NoticeTips"):create("提示","密码格式非法！", nil, nil, true)
    elseif stResp.code == 3 then
        require("app/views/UI/NoticeTips"):create("提示","原密码验证失败！", nil, nil, true)
    elseif stResp.code == 4 then
        require("app/views/UI/NoticeTips"):create("提示","收款人未添加！", nil, nil, true)
    end

end


return ChangePayWord