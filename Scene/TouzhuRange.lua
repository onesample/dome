
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local TouzhuRange = class("TouzhuPiaming", function()
	return gt.createMaskLayer(160)
end)

--RangelistTuhao = {"用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234","用户名1234"}
function TouzhuRange:ctor(bet_list)
    self.bet_list = bet_list
    self.RangelistTuhao = {}
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local csbNode = cc.CSLoader:createNode("TouzhuPiaming.csb")
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
    local TotalBet = 0 
    for i = 1 ,#self.bet_list do
        self.RangelistTuhao[i] = self.bet_list[i]
        TotalBet = TotalBet + self.bet_list[i].bet_money

        if gt.playerData.uid == self.bet_list[i].uid then
            local My_Bet = gt.seekNodeByName(self.rootNode, "TextMy_bet")
	        My_Bet:setString(self.bet_list[i].bet_money/10000)
        end
    end
    local TxtPeople_num = gt.seekNodeByName(self.rootNode, "TxtTotal_bet")
    TxtPeople_num:setString(TotalBet/10000)


    self.RangeList = gt.seekNodeByName(csbNode, "ListView_Player")
    self:initResultLater()
   
end
--官方结果层显示
function TouzhuRange:initResultLater()
	for i, cellData in ipairs(self.RangelistTuhao) do
		local GameItem = self:createResultItem(i, cellData)
		self.RangeList:pushBackCustomItem(GameItem)
	end
end
function TouzhuRange:createResultItem(tag, cellData)
	local OfficNode = cc.CSLoader:createNode("TouzhuNumList.csb")
    --	-- 大标题
	local game_Num = gt.seekNodeByName(OfficNode, "Text_Num")
	game_Num:setString(tag)
	local game_name = gt.seekNodeByName(OfficNode, "Text_Name")
	game_name:setString(self.RangelistTuhao[tag].nick_name)

	local game_Money = gt.seekNodeByName(OfficNode, "Text_Money")
	game_Money:setString(self.RangelistTuhao[tag].bet_money/10000)
    local TxtColor = cc.c3b(255,255,255)
    if tag == 1 then
        TxtColor = cc.c3b(252,255,39)
    elseif tag == 2 then
        TxtColor = cc.c3b(255,255,255)
    elseif tag == 3 then
        TxtColor = cc.c3b(214,191,121)
    else
        TxtColor = cc.c3b(222,214,189)
    end
    game_Num:setColor(TxtColor)
    game_name:setColor(TxtColor)
    game_Money:setColor(TxtColor)
	local cellSize = OfficNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(OfficNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end


return TouzhuRange