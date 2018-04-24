
local gt = cc.exports.gt
local Utils = cc.exports.Utils
local BJLResult = class("BJLResult", function()
	return gt.createMaskLayer(160)
end)

function BJLResult:ctor(cellData)
    --print("PlayerListScene === ")
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

    local csbNode = cc.CSLoader:createNode("RewordNode_Bjl.csb")
    self.csbNode = csbNode
    self:addChild(csbNode)
    local Clsoe_but = gt.seekNodeByName(csbNode, "Button_Close")
    gt.addBtnPressedListener(Clsoe_but, handler(self, function()
        self:removeFromParent()
	end))

--	-- 局
	local game_name = gt.seekNodeByName(csbNode, "TxtXue")
	game_name:setString(gt.boots_num.."靴"..cellData.round_order.."局")
--	-- 期数
	local TxtPeriod = gt.seekNodeByName(csbNode, "TxtPeriod")
	TxtPeriod:setString(cellData.issue.."期")
--	-- 赢区域
    gt.log("balance===",cellData.balance)
    local balance = gt.string_split(cellData.balance,",")
    local winImage = gt.seekNodeByName(csbNode, "winImage")
    for i= 1 ,5 do
        if balance[i] ~= "" and balance[i] then
            local balance_1 = gt.string_split(balance[i],"-");
            --local num =  string.sub(cellData.balance,i,i);
            if i < 4 then
                if balance_1[2] == "1" then
                    winImage:setTexture("res/res/RangeList/win_"..i ..".png")
                end
            else
            	local piaoti = gt.seekNodeByName(csbNode, "TxtWin_" ..balance_1[1])
                if balance_1[2] == "1" then
                    piaoti:setVisible(true)
                else
                    piaoti:setVisible(false)
                end
            end
        end
    end

    --牌列表
    --gt.log("baccarat_player_card===",cellData.baccarat_init_card,cellData.lottery_no)
    local MsgTbl = gt.string_split(cellData.baccarat_init_card,",")
    local paiListSpZ = {}
	for i = 1, 10  do
        paiListSpZ[i] = gt.seekNodeByName(csbNode, "Xiaopai_"..i)
        
        local paiColor,painum = math.modf(MsgTbl[i]/16)
        paiListSpZ[i]:setTexture("res/res/gamepai/PukePai_1_"..painum*16 .."_"..paiColor ..".png")
        paiListSpZ[i]:setScale(0.5)
	end

    --gt.log("baccarat_player_card===",cellData.baccarat_player_card)
    local player_card = gt.string_split(cellData.baccarat_player_card,",")
    local CardIndex = {}
	for i = 1, 3  do
        local paiSpZ = gt.seekNodeByName(csbNode, "Overpai_"..i)
        if player_card[i] ~= nil then
            local showpai = gt.string_split(player_card[i],"-")
            local paiColor,painum = math.modf(showpai[1]/16)
            table.insert(CardIndex,showpai[2])
            paiSpZ:setTexture("res/res/gamepai/PukePai_1_"..painum*16 .."_"..paiColor ..".png")
            paiSpZ:setScale(0.5)
            local  PukePai_bj = cc.Sprite:create("res/res/gamepai/PukePai_bj1.png")
            paiListSpZ[tonumber(showpai[2])]:addChild(PukePai_bj)
            PukePai_bj:setPosition(cc.p(38,54))
            PukePai_bj:setScale(2)
            --paiListSpZ[tonumber(showpai[2])]:setOpacity(30)
        else
            paiSpZ:setVisible(false)
        end
	end

    --gt.log("baccarat_player_card===",cellData.baccarat_banker_card)
    local banker_card = gt.string_split(cellData.baccarat_banker_card,",")
	for i = 4, 6  do
        local paiSpZ = gt.seekNodeByName(csbNode, "Overpai_"..i)
        if banker_card[i-3] ~= nil then
            local showpai = gt.string_split(banker_card[i-3],"-")
            local paiColor,painum = math.modf(showpai[1]/16)
            table.insert(CardIndex,showpai[2])
            paiSpZ:setTexture("res/res/gamepai/PukePai_1_"..painum*16 .."_"..paiColor ..".png")
            paiSpZ:setScale(0.5)
            local  PukePai_bj = cc.Sprite:create("res/res/gamepai/PukePai_bj2.png")
            paiListSpZ[tonumber(showpai[2])]:addChild(PukePai_bj)
            PukePai_bj:setPosition(cc.p(38,54))
            PukePai_bj:setScale(2)
            --paiListSpZ[tonumber(showpai[2])]:setOpacity(150)
        else
            paiSpZ:setVisible(false)
        end
	end

    --中奖号码
    self:showzhonjian(cellData.lottery_no)

--    for i = 1 ,10 do
--        if CardIndex[i] then
--            local CardNum = tonumber(CardIndex[i])
--            paiSpZ[CardNum]:setOpacity(80)
--        end
--    end
end

function BJLResult:showzhonjian(tbl)
    --local numtap = tbl
    local numtap =  gt.string_split(tbl,",")
	for i = 1, 10  do
        --local num =  string.sub(RoomMsgTbl[2],i,i);
        local num =  numtap[i]
		local shade = gt.seekNodeByName(self.csbNode, "shade_" .. i)
        if num ~= "10" then
            if self.ChoseGameid ~= 6 then
                for w in string.gmatch(num, "[^%z]") do
                    num = w
                end
            end
        else
            num = "0"
        end
		shade:setString(num)
	end
end


--官方结果层显示
function BJLResult:initResultLater()
	for i, cellData in ipairs(self.RangelistTuhao) do
		local GameItem = self:createResultItem(i, cellData)
		self.RangeList:pushBackCustomItem(GameItem)
	end
end
function BJLResult:createResultItem(tag, cellData)

end


return BJLResult