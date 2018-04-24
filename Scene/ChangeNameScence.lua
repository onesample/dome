
local gt = cc.exports.gt

local ChangeNameScence = class("ChangeNameScence", function()
	return gt.createMaskLayer(160)
end)

function ChangeNameScence:ctor(titleText, tipsText, okFunc, cancelFunc, singleBtn)
	self:setName("ChangeNameScence")

	local csbNode = cc.CSLoader:createNode("ChangeName.csb")
    csbNode:setAnchorPoint(0.5, 0.5)
	csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	self:addChild(csbNode)

	self.rootNode = csbNode
    
    
    local ChangeNameBg = gt.seekNodeByName(csbNode, "edit_box1")
    local ChangeNameTxt = ccui.EditBox:create(cc.size(330,48), "") 
    ChangeNameTxt:setPosition(cc.p(254,41.5))
    ChangeNameTxt:setAnchorPoint(0.5, 0.5)
    ChangeNameTxt:setFontSize(40)
    ChangeNameTxt:setFontColor(cc.c3b(255,255,255))
    ChangeNameTxt:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    ChangeNameTxt:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    ChangeNameTxt:setPlaceHolder("请输入新昵称")
    --self.selectCount:registerScriptEditBoxHandler(function(eventname,sender) self:editboxHandle(eventname,sender) end) 
    ChangeNameBg:addChild(ChangeNameTxt)
    
    -- 提交按钮
	local submit_btn = gt.seekNodeByName(csbNode, "submit_btn")
	gt.addBtnPressedListener(submit_btn, function()
        local NewName =  ChangeNameTxt:getText()
        if NewName == "" then
            require("app/views/UI/NoticeTips"):create("提示",	"请输入正确昵称！", nil, nil, true)
            return
        else
            local cmsg = cmd_lobby_pb.CChangceUserNicknameReq()
            cmsg.new_nickename = NewName
            gt.playerData.nickname = NewName
            local msgData = cmsg:SerializeToString()
            gt.socketClient:sendMessage( cmd_net_pb.CMD_LOBBY, cmd_net_pb.CMD_LOBBY_CHANGCE_USER_NICKNAME_REQ,msgData)
        end
	end)
end


return ChangeNameScence
