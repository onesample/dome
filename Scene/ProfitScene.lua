local gt = cc.exports.gt
local Utils = cc.exports.Utils
local ProfitScene = class("ProfitScene", function()
	return gt.createMaskLayer(160)
end)

ProfitlistTap = 
        {
     --userName 用户名, profit 收益 
    {userName = "用户名1", profit = 500 },
    {userName = "用户名2", profit = 1000 },
    {userName = "用户名3", profit = 1500 },
    {userName = "用户名4", profit = 2000 },
    {userName = "用户名5", profit = 2500 },
    {userName = "用户名6", profit = 3000 },
    {userName = "用户名7", profit = 3500 },
    {userName = "用户名8", profit = 4000 },
        }
function ProfitScene:ctor(earnings,ranking)

    for i=1,#ranking do 
        gt.log("UdatCellItem===",ranking[i].order,ranking[i].nick_name,ranking[i].earnings)
    end    
	local csbNode = cc.CSLoader:createNode("ProfitBanker.csb")
	csbNode:setAnchorPoint(0.5, 0.5)

    csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	--self:setPosition(cc.p(-gt.winSize.width * 0.5, -gt.winSize.height + 57 ))
    self:setPosition(cc.p(0, 0))
	self:addChild(csbNode)
	self.rootNode = csbNode
    --关闭按钮
    local Clsoe_but = gt.seekNodeByName(self.rootNode, "Button_Close")
    gt.addBtnPressedListener(Clsoe_but, handler(self, function()
        Utils.setClickEffect()
        self:removeFromParent()
	end))
    local ProfitDi = gt.seekNodeByName(csbNode, "ProfitDi")
    local MineProfit = gt.seekNodeByName(csbNode, "Text_4_0")
    MineProfit:setString(string.format("%.01f", earnings/10000))
    
    self.ResultList = gt.seekNodeByName(csbNode, "ListView_Profit")
    
    self:initProfitLater(ranking)
end

function ProfitScene:initProfitLater(ranking)
    for i, cellData in ipairs(ranking) do
		local GameItem = self:createResultItem(i, cellData)
		self.ResultList:pushBackCustomItem(GameItem)
	end
end

function ProfitScene:createResultItem(tag, cellData)
	local ListNode = cc.CSLoader:createNode("ProFitListNode.csb")
    local ProfitBg = gt.seekNodeByName(ListNode, "ProfitDi_1")
    
    local ProfitNum = gt.seekNodeByName(ListNode, "Text_Num")
    local ProfitName = gt.seekNodeByName(ListNode, "Text_Name")
    local ProfitResult = gt.seekNodeByName(ListNode, "Text_Profit")
    local ProfitIco = gt.seekNodeByName(ListNode, "Image_Ico")
    ProfitNum:setString(cellData.order+1)
    ProfitName:setString(cellData.nick_name)
    ProfitResult:setString(string.format("%.01f", cellData.earnings/10000))
    if tag == 1 then
        ProfitIco:setTexture("res/res/RangeList/TheFirst.png")
        ProfitNum:setVisible(false)
    elseif tag == 2 then
        ProfitIco:setTexture("res/res/RangeList/TheScond.png")
        ProfitNum:setVisible(false)
    elseif tag == 3 then
        ProfitIco:setTexture("res/res/RangeList/TheThird.png")
        ProfitNum:setVisible(false)
    else
        ProfitIco:setVisible(false)
        ProfitNum:setVisible(true)
    end
    if tag%2 == 0 then
        ProfitBg:setTexture("")
    else
        ProfitNum:setColor(cc.c3b(214,191,121))
        ProfitName:setColor(cc.c3b(214,191,121))
        ProfitResult:setColor(cc.c3b(214,191,121))
    end

	local cellSize = ListNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setContentSize(cellSize)
	cellItem:addChild(ListNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end

function ProfitScene:UdatCellItem(earnings,ranking)

    for i=1,#ranking do 
        --gt.log("UdatCellItem===========",ranking[i].order,ranking[i].nick_name,ranking[i].earnings)
    end
end
return ProfitScene
--endregion
