
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local RangeScene = class("RangeScene", function()
	return gt.createMaskLayer(160)
end)

RangelistTuhao = 
        {

        }
RangelistLaomo = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { RangeName = "用户名11111", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名2222", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名3333", RangeWin = 102334, RangeLose = 12234 },
        }
RangelistMvp = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { RangeName = "用户名4444", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名5555", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名666", RangeWin = 102334, RangeLose = 12234 },
        }

RangelistDay = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { RangeName = "用户名0000", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名0001", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名0002", RangeWin = 102334, RangeLose = 12234 },
        }
RangelistWeek = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { RangeName = "用户名1111", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名1112", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名1113", RangeWin = 102334, RangeLose = 12234 },
        }
RangelistMonth = 
        {
     --periods 期号, zhonjian 中奖号码, piaoti 大标题, piaoti1 小标题, shichang 周期时长，秒为单位 
    { RangeName = "用户名2224", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名2225", RangeWin = 102334, RangeLose = 12234 },
    { RangeName = "用户名2226", RangeWin = 102334, RangeLose = 12234 },
        }
function RangeScene:ctor()
    self.TxtName = {}
    self.TxtWin = {}
    self.TxtLose = {}
    print("RangeScene === ")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))
    self.ClickArea = 1  --点击区域
	local csbNode = cc.CSLoader:createNode("Range_Layer.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
    csbNode:setPosition(cc.p(gt.winSize.width * 0.5, gt.winSize.height*0.5 ))
	--self:setPosition(cc.p(-gt.winSize.width * 0.5, -gt.winSize.height + 57 ))
	self:addChild(csbNode)
	self.rootNode = csbNode
    --关闭按钮
    local Clsoe_but = gt.seekNodeByName(self.rootNode, "Button_Close")
    gt.addBtnPressedListener(Clsoe_but, handler(self, function()
        Utils.setClickEffect()
        self:removeFromParent()
	end))
    --排行榜按钮
    local tuhaoBtn = gt.seekNodeByName(self.rootNode, "Button_1")
    tuhaoBtn:setColor(cc.c3b(214,191,121))
    local laomoBtn = gt.seekNodeByName(self.rootNode, "Button_2")
    local mvpBtn = gt.seekNodeByName(self.rootNode, "Button_3")
    local tuhaoLightBtn = gt.seekNodeByName(self.rootNode, "RangeLight_tuhao")
    local laomoLightBtn = gt.seekNodeByName(self.rootNode, "RangeLight_laomo")
    local mvpLightBtn = gt.seekNodeByName(self.rootNode, "RangeLight_mvp")
    laomoLightBtn:setVisible(false)
    mvpLightBtn:setVisible(false)

    --周期按钮
    local LastDayBtn = gt.seekNodeByName(self.rootNode, "Button_LastDay")
    LastDayBtn:setColor(cc.c3b(214,191,121))
    local WeekBtn = gt.seekNodeByName(self.rootNode, "Button_Week")
    local MonthBtn = gt.seekNodeByName(self.rootNode, "Button_Month")
    self.LastDayBtn = LastDayBtn
    self.WeekBtn = WeekBtn
    self.MonthBtn = MonthBtn
    local FirstLine = gt.seekNodeByName(self.rootNode, "YellowLine_48")
    local SecondLine = gt.seekNodeByName(self.rootNode, "YellowLine_49")
    local ThirdLine = gt.seekNodeByName(self.rootNode, "YellowLine_50")
    self.FirstLine = FirstLine
    self.SecondLine = SecondLine
    self.ThirdLine = ThirdLine
    SecondLine:setVisible(false)
    ThirdLine:setVisible(false)
    

    self.RangeList = gt.seekNodeByName(csbNode, "ListView_Range")
    self:initResultLater(gt.RangelistTuhaoDay)
    self:ChangeRangeTxt(gt.RangelistTuhaoDay,1)
    --点击排行榜
    gt.addBtnPressedListener(tuhaoBtn, handler(self, function()
        Utils.setClickEffect()
        self.RangeList:removeAllItems()
        self:initResultLater(gt.RangelistTuhaoDay)
        self:ChangeRangeTxt(gt.RangelistTuhaoDay,1)
        tuhaoBtn:setColor(cc.c3b(214,191,121))
        laomoBtn:setColor(cc.c3b(243,243,243))
        mvpBtn:setColor(cc.c3b(243,243,243))
        tuhaoLightBtn:setVisible(true)
        laomoLightBtn:setVisible(false)
        mvpLightBtn:setVisible(false)
        self:ShowLastDay()
        self.ClickArea = 1 
	end))
    gt.addBtnPressedListener(laomoBtn, handler(self, function()
        Utils.setClickEffect()
        self.RangeList:removeAllItems()
        self:initResultLater(gt.RangelistLaomoDay)
        self:ChangeRangeTxt(gt.RangelistLaomoDay,2)
        tuhaoBtn:setColor(cc.c3b(243,243,243))
        laomoBtn:setColor(cc.c3b(214,191,121))
        mvpBtn:setColor(cc.c3b(243,243,243))
        tuhaoLightBtn:setVisible(false)
        laomoLightBtn:setVisible(true)
        mvpLightBtn:setVisible(false)
        self:ShowLastDay()
        self.ClickArea = 2
	end))
    gt.addBtnPressedListener(mvpBtn, handler(self, function()
        Utils.setClickEffect()
        self.RangeList:removeAllItems()
        self:initResultLater(gt.RangelistMvpDay)
        self:ChangeRangeTxt(gt.RangelistMvpDay,3)
        tuhaoBtn:setColor(cc.c3b(243,243,243))
        laomoBtn:setColor(cc.c3b(243,243,243))
        mvpBtn:setColor(cc.c3b(214,191,121))
        tuhaoLightBtn:setVisible(false)
        laomoLightBtn:setVisible(false)
        mvpLightBtn:setVisible(true)
        self:ShowLastDay()
        self.ClickArea = 3
	end))

    --点击时间
    gt.addBtnPressedListener(LastDayBtn, handler(self, function()
        Utils.setClickEffect()
        self:ClickDay(self.ClickArea)
        self:ShowLastDay()
	end))
    gt.addBtnPressedListener(WeekBtn, handler(self, function()
        Utils.setClickEffect()
        self:ClickWeek(self.ClickArea)
        LastDayBtn:setColor(cc.c3b(243,243,243))
        WeekBtn:setColor(cc.c3b(214,191,121))
        MonthBtn:setColor(cc.c3b(243,243,243))
        FirstLine:setVisible(false)
        SecondLine:setVisible(true)
        ThirdLine:setVisible(false)
	end))
    gt.addBtnPressedListener(MonthBtn, handler(self, function()
        Utils.setClickEffect()
        self:ClickMonth(self.ClickArea)
        LastDayBtn:setColor(cc.c3b(243,243,243))
        WeekBtn:setColor(cc.c3b(243,243,243))
        MonthBtn:setColor(cc.c3b(214,191,121))
        FirstLine:setVisible(false)
        SecondLine:setVisible(false)
        ThirdLine:setVisible(true)
	end))
end

--官方结果层显示
function RangeScene:ShowLastDay()
    self.LastDayBtn:setColor(cc.c3b(214,191,121))
    self.WeekBtn:setColor(cc.c3b(243,243,243))
    self.MonthBtn:setColor(cc.c3b(243,243,243))
    self.FirstLine:setVisible(true)
    self.SecondLine:setVisible(false)
    self.ThirdLine:setVisible(false)
end

--官方结果层显示
function RangeScene:initResultLater(RangelistNum)
    if RangelistNum then
	    for i, cellData in ipairs(RangelistNum) do
		    local GameItem = self:createResultItem(i, cellData)
		    self.RangeList:pushBackCustomItem(GameItem)
	    end
    end
end
function RangeScene:createResultItem(tag, cellData)
	local RangeNode = cc.CSLoader:createNode("RangeListNode.csb")
    local SprTitle = gt.seekNodeByName(RangeNode,"FirstCoin")
    local Text_Rander = gt.seekNodeByName(RangeNode,"Text_Rander")
    Text_Rander:setVisible(false)
    self.TxtName[tag] = gt.seekNodeByName(RangeNode,"Text_Name")
    self.TxtWin[tag] = gt.seekNodeByName(RangeNode,"Text_Win")
    self.TxtLose[tag] = gt.seekNodeByName(RangeNode,"Text_Lose")
    self.TxtLose[tag]:setVisible(false)
    if tag == 1 then
        SprTitle:setTexture("res/res/RangeList/TheFirst.png")
    elseif tag == 2 then
        SprTitle:setTexture("res/res/RangeList/TheScond.png")
    elseif tag == 3 then
        SprTitle:setTexture("res/res/RangeList/TheThird.png")
    else
        SprTitle:setVisible(false)
        Text_Rander:setVisible(true)
        Text_Rander:setString(tag)
    end

    local cellSize = RangeNode:getContentSize()
	local cellItem = ccui.Widget:create()
	cellItem:setTag(tag)
	cellItem:setTouchEnabled(true)
	cellItem:setContentSize(cellSize)
	cellItem:addChild(RangeNode)
	-- cellItem:addClickEventListener(handler(self, self.historyItemClickEvent))
	
	return cellItem
end
--官方结果层显示
function RangeScene:ChangeRangeTxt(TxtRange,cType)
    if TxtRange then
        for i = 1 ,#TxtRange do 
	        self.TxtName[i]:setString(TxtRange[i].nick_name)
            local recharge_money = 0
            if cType == 1 then
                recharge_money = TxtRange[i].recharge_money/10000
            elseif cType == 2 then
                recharge_money = TxtRange[i].bet_money/10000
            else
                recharge_money = TxtRange[i].profit_money/10000
            end
            self.TxtWin[i]:setString( string.format("%.1f",recharge_money ))
            --self.TxtLose[i]:setString(TxtRange[i].RangeLose)
        end
    end
end

function RangeScene:ClickDay(Area)
    self.RangeList:removeAllItems()
    if Area == 1 then
        self:initResultLater(gt.RangelistTuhaoDay)
        self:ChangeRangeTxt(gt.RangelistTuhaoDay,1)
    elseif Area == 2 then
        self:initResultLater(gt.RangelistLaomoDay)
        self:ChangeRangeTxt(gt.RangelistLaomoDay,2)
    else
        self:initResultLater(gt.RangelistMvpDay)
        self:ChangeRangeTxt(gt.RangelistMvpDay,3)
    end
end
function RangeScene:ClickWeek(Area)
    self.RangeList:removeAllItems()
    if Area == 1 then
        self:initResultLater(gt.RangelistTuhaoDayWeek)
        self:ChangeRangeTxt(gt.RangelistTuhaoDayWeek,1)
    elseif Area == 2 then
        self:initResultLater(gt.RangelistLaomoWeek)
        self:ChangeRangeTxt(gt.RangelistLaomoWeek,2)
    else
        self:initResultLater(gt.RangelistMvpWeek)
        self:ChangeRangeTxt(gt.RangelistMvpWeek,3)
    end
end
function RangeScene:ClickMonth(Area)
    self.RangeList:removeAllItems()
    if Area == 1 then
        self:initResultLater(gt.RangelistTuhaoDayMonth)
        self:ChangeRangeTxt(gt.RangelistTuhaoDayMonth,1)
    elseif Area == 2 then
        self:initResultLater(gt.RangelistLaomoMonth)
        self:ChangeRangeTxt(gt.RangelistLaomoMonth,2)
    else
        self:initResultLater(gt.RangelistMvpMonth)
        self:ChangeRangeTxt(gt.RangelistMvpMonth,3)
    end
end

return RangeScene