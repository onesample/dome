
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local BettingDetaiScene = class("BettingDetaiScene", function()
	return gt.createMaskLayer(160)
end)

RangelistTuhao = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { RangeName = "用户名1234", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名5678", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名0755", RangeWin = 102334, RangeLose = 12234 },
        }

function BettingDetaiScene:ctor()
    self.TxtName = {}
    self.TxtWin = {}
    self.TxtLose = {}
    print("BettingDetaiScene === ")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    
	local csbNode = cc.CSLoader:createNode("BettingDetail.csb")
--	csbNode:setAnchorPoint(0.5, 0.5)
--    csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
--	self:setPosition(cc.p(-gt.winSize.width * 0.5, -gt.winSize.height + 57 ))
	self:addChild(csbNode)
	self.rootNode = csbNode
    --关闭按钮
    local Clsoe_but = gt.seekNodeByName(self.rootNode, "Button_Close")
    gt.addBtnPressedListener(Clsoe_but, handler(self, function()
        Utils.setClickEffect()
        self:removeFromParent()
	end))

    
    self.RangeList = gt.seekNodeByName(csbNode, "ListView_Profit")


end
--官方结果层显示
function BettingDetaiScene:initResultLater()
	for i, cellData in ipairs(RangelistTuhao) do
		local GameItem = self:createResultItem(i, cellData)
		self.RangeList:pushBackCustomItem(GameItem)
	end
end
function BettingDetaiScene:createResultItem(tag, cellData)
	local RangeNode = cc.CSLoader:createNode("RangeListNode.csb")

    local cellSize = RangeNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RangeNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end

return BettingDetaiScene