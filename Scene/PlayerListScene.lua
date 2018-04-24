
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local PlayerListScene = class("PlayerListScene", function()
	return gt.createMaskLayer(160)
end)

--RangelistTuhao = {"用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234"}
function PlayerListScene:ctor(user_list)
    self.user_list = user_list
    self.RangelistTuhao = {}
    --print("PlayerListScene === ")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local csbNode = cc.CSLoader:createNode("PlayerListNum.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
    csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	--self:setPosition(cc.p(-gt.winSize.width * 0.5, -gt.winSize.height + 57 ))
	self:addChild(csbNode)
	self.rootNode = csbNode
    --关闭按钮
    local Clsoe_but = gt.seekNodeByName(self.rootNode, "Button_Close")
    gt.addBtnPressedListener(Clsoe_but, handler(self, function()
        self:removeFromParent()
	end))
    for i = 1 ,#self.user_list do
        self.RangelistTuhao[i] = self.user_list[i].nick_name
        --print("user_list ====== ",self.user_list[i].nick_name,self.user_list[i].uid)
    end
    local TxtPeople_num = gt.seekNodeByName(self.rootNode, "TxtPeople_num")
    TxtPeople_num:setString(#self.user_list)
    self.RangeList = gt.seekNodeByName(csbNode, "ListView_Player")
    self:initResultLater()
   
end
--官方结果层显示
function PlayerListScene:initResultLater()
	for i, cellData in ipairs(self.RangelistTuhao) do
		local GameItem = self:createResultItem(i, cellData)
		self.RangeList:pushBackCustomItem(GameItem)
	end
end
function PlayerListScene:createResultItem(tag, cellData)
	local OfficNode = cc.CSLoader:createNode("PlayerNumList.csb")
    --	-- 大标题
	local game_Num = gt.seekNodeByName(OfficNode, "Text_Num")
	game_Num:setString(tag)
	local game_name = gt.seekNodeByName(OfficNode, "Text_Name")
	game_name:setString(self.RangelistTuhao[tag])
    if tag%2 == 0 then
        OfficNode:setPosition(OfficNode:getPositionX()+307,OfficNode:getPositionY()+(tag/2)*40)
    else
        OfficNode:setPosition(OfficNode:getPositionX() ,OfficNode:getPositionY() + math.floor(tag/2) * 40 )
    end

	local cellSize = OfficNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(OfficNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end


return PlayerListScene