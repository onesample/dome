
-- Creator matt 
-- Create Time 2017/10/20
-- 发牌器

local gt = cc.exports.gt

local FapaiqiGame = class("FapaiqiGame", function()
	return cc.CSLoader:createNode("FapaiNode.csb")
end)

function FapaiqiGame:ctor( RoomMsgTbl )

	self:registerScriptHandler(handler(self, self.onNodeEvent))
	self.msgTextCache = {}
    self.PlayActions = false
	self.RoomMsgTbl = RoomMsgTbl
    self.fapainum = 9
    self.showPaiOver = true

    --self:fapai()
    self.shengpai = gt.seekNodeByName(self, "shengpai")
    self.TxtXueJu = gt.seekNodeByName(self, "TxtXueJu")
    for i=1,10 do 
        local paiSp = cc.Sprite:create("res/gamepai/pai_0.png")
		paiSp:setPosition(cc.p(270,-18))
        paiSp:setRotation(-80)
        paiSp:setOpacity(30)
        paiSp:setScale(0.6)
		paiSp:setTag(i)
		self:addChild(paiSp)
        paiSp:setVisible(false)

        local paiSpZ = cc.Sprite:create("res/gamepai/pai_0.png")
        paiSpZ:setVisible(false)
        paiSpZ:setTag(10+i)
        self:addChild(paiSpZ)
    end
end

function FapaiqiGame:onNodeEvent(eventName)
	if "enter" == eventName then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function FapaiqiGame:update(delta)
	if not self.PlayActions then
		return
	end
    --跑球
end

function FapaiqiGame:fapai()
        local paiSp = self:getChildByTag(10 - self.fapainum)
        paiSp:setTexture("res/gamepai/pai_0.png")
        gt.soundEngine:playEffect("ShowCard",false)
        paiSp:setVisible(true)
        local t1,t2 = math.modf(self.fapainum/5)
        local pos1 = cc.p(-300 + (0.8 - t2)*500,(t1-1)*125 + 60)
        if paiSp:getPositionX() == pos1.x then
            return
        end
        local moveTo1 = cc.MoveTo:create(0.4, pos1)

        local RotateTo1 = cc.RotateTo:create(0.4, 0)
        local ScaleTo1 = cc.ScaleTo:create(0.4,1)
        local FadeTo1 = cc.FadeTo:create(0.4,255)
        local spa1 = cc.Spawn:create(moveTo1,RotateTo1,ScaleTo1,FadeTo1)

        local pos = cc.p(200,-78)
        local moveTo = cc.MoveTo:create(0.2, pos)
        local RotateTo = cc.RotateTo:create(0.2, -90)
        local ScaleTo = cc.ScaleTo:create(0.2,0.8)
        local FadeTo = cc.FadeTo:create(0.2,180)

	    local spa = cc.Spawn:create(moveTo,RotateTo,ScaleTo,FadeTo)

        local call = cc.CallFunc:create(function ()
            self.fapainum = self.fapainum -1
            if self.fapainum > -1 then
                self:fapai()
            end
	    end)
        local Seq = cc.Sequence:create(spa,spa1,call)
	    paiSp:stopAllActions()
	    paiSp:runAction(Seq)
    --end
end

--收发牌
function FapaiqiGame:shuofapai()
        --收牌
        for i=1,10 do 
            local paiSp = self:getChildByTag(i)
            local paiSpZ = self:getChildByTag(10+i)
            local pos = cc.p(-320,-80)
            local SmoveTo = cc.MoveTo:create(0.8, pos)
            local SScaleTo = cc.ScaleTo:create(0.8,0.4)
            local SFadeTo = cc.FadeTo:create(0.8,0)
	        local Scall = cc.CallFunc:create(function ()
                paiSp:setVisible(false)
                paiSp:setPosition(cc.p(270,-18))
                paiSp:setRotation(-80)
                paiSp:setOpacity(30)
                paiSp:setScale(0.6)
                paiSpZ:setVisible(false)
                paiSpZ:setPosition(cc.p(270,-18))
                --paiSpZ:setRotation(-80)
                --paiSpZ:setOpacity(30)
               -- paiSpZ:setScale(0.6)
                self.fapainum = 9
                if i == 10 then
                    --self:fapai()
                end
	        end)
	        local Sspa = cc.Spawn:create(SmoveTo,SScaleTo,SFadeTo)
            local SSeq = cc.Sequence:create(Sspa,cc.DelayTime:create(2),Scall)
	        --paiSp:stopAllActions()
	        paiSp:runAction(SSeq)
	        --paiSpZ:stopAllActions()
	        paiSpZ:runAction(SSeq)
        end
end

function FapaiqiGame:showPai(MsgTbl,CardNum)
    local MsgTbl = MsgTbl or "1,2,3,4,5,6,7,8,9,10"
    gt.soundEngine:playEffect("xianhua",false)
    local paiindex = 1;
    self.shengpai:setString(CardNum)
    MsgTbl = gt.string_split(MsgTbl,",")
    self.showPaiOver = false
    --dump(MsgTbl, "showPai")
    if #MsgTbl < 3 then   -- 在关盘时，只显示背牌
        
    else
        for i=1,10 do   
            local paiColor,painum = math.modf(MsgTbl[i]/16)
            --gt.log("pai===",painum*16,paiColor)
            local paiSp = self:getChildByTag(i)
            local paiSpZ = self:getChildByTag(10+i)
            paiSpZ:setTexture("res/res/gamepai/PukePai_1_"..painum*16 .."_"..paiColor ..".png")
            paiSpZ:setPosition(paiSp:getPosition())
            paiSpZ:setScaleX(0)
            paiSpZ:setScaleY(1)
            paiSpZ:setRotation(0)
            --paiSpZ:setRotation(360)
            paiSpZ:setOpacity(255)
            local call = cc.CallFunc:create(function ()
                paiSp:setVisible(false)
                paiSpZ:setVisible(true)
                paiSpZ:runAction(cc.Sequence:create(cc.ScaleTo:create(1,1,1),cc.CallFunc:create(function ()
                    if i == 10 then
                    self.showPaiOver = true
                    end
                end)))
            end)
            paiSp:runAction(cc.Sequence:create(cc.ScaleTo:create(1,0,1),call))
        end    
    end
end

function FapaiqiGame:showBackPai(CardNum,BootsId,BootsRoundNum)
    self.shengpai:setString(CardNum)
    self.TxtXueJu:setString("靴局："..BootsId.."靴"..BootsRoundNum.."局")
    for i=1,10 do   
        local paiSp = self:getChildByTag(i)
        paiSp:setVisible(true)
        paiSp:setRotation(0)
        paiSp:setOpacity(255)
        paiSp:setScale(1)
        local t1,t2 = math.modf((10 - i)/5)
        local pos1 = cc.p(-300 + (0.8 - t2)*500,(t1-1)*125 + 60)
        paiSp:setPosition(pos1)
    end
end

function FapaiqiGame:showMsg(msgText, repeattimes)
	if not msgText or string.len(msgText) == 0 then
		return
	end

	table.insert(self.msgTextCache, msgText)

	if self.m_repeattimes then
		self.msgTextCache = {}
		table.insert(self.msgTextCache, msgText)
	end

	self.m_repeattimes = repeattimes
	if self.m_parentNode then
		self.m_parentNode:setVisible( true )
	end
end

function FapaiqiGame:xiaofapai(ShowPaiList,callback)
    if #ShowPaiList<1 then
        callback()
        return
    end
    local diangshu = 0;
    self.xiaopailist = {0,0,0,0,0,0};
    for i=1,#ShowPaiList do
        local showpai = ShowPaiList[i]
        if showpai then
            local showpai = gt.string_split(showpai,",")
            if i > 2 then
                break
            end
            for j=1,#showpai do 
                gt.log("xiaofapai = ",showpai[j])
                local showpai = gt.string_split(showpai[j],"-")
                self.xiaopailist[j*2 - 2 + i] = showpai[2]

--                local paiSp = self:getChildByTag(showpai[2])
--                local paiSpZ = self:getChildByTag(showpai[2]+10)
--                paiSp:setVisible(false)
--                paiSpZ:setLocalZOrder(paiSpZ:getLocalZOrder()+j)
--                local pos = cc.p(-400+j*90+(i-1)*380,-800)
--                local SmoveTo = cc.MoveTo:create(1.5, pos)
--                local SScaleTo = cc.ScaleTo:create(1.5,0.9)
--                local Sspa = cc.Spawn:create(SmoveTo,SScaleTo)
--                paiSpZ:runAction(Sspa)

                --diangshu = showpai[1] % 16 + diangshu
            end
        end
    end
    --dump(self.xiaopailist, "xiaopailist")
    self:xiaofapaiList(self.xiaopailist[1],1,callback)
    diangshu = diangshu % 10 

end

function FapaiqiGame:xiaofapaiList(paispnum,idx,callback)
    local index = idx
    if index < 7 then 
        --gt.log("xiaofapaiList  index == ",index)
        if paispnum == 0 or paispnum == nil then 
            index = index + 1
            self:xiaofapaiList(self.xiaopailist[index],index,callback)
            return
        end
    else
        callback()
        return
    end 
    local j,i = math.modf(index/2)
    gt.log("xiaofapaiList== ",j,i,paispnum)
    local paiSp = self:getChildByTag(paispnum)
    local paiSpZ = self:getChildByTag(paispnum+10)
    paiSp:setVisible(true)
    paiSp:setScale(1)
    paiSp:setPosition(paiSpZ:getPosition())
    paiSp:setTexture(paiSpZ:getTexture())
    paiSp:setOpacity(80)
    paiSpZ:setLocalZOrder(paiSpZ:getLocalZOrder()+index)
    local pos = cc.p( -300 + j*90+(1-i*2)*285,-800)
--    local SmoveTo = cc.MoveTo:create(1.5, pos)
    local SScaleTo = cc.ScaleTo:create(1.5,1.1)
    local RotateTo
    if index == 5 or index == 6 then 
        RotateTo = cc.RotateTo:create(1.5, -90)
        pos = cc.p( -300 + j*100+(1-i*2)*285,-820)
    end
    --local pos = cc.p( 50 + j*90+(i*2-1)*520,-800)
    local SmoveTo = cc.MoveTo:create(1.5, pos)
    local DelayTime = cc.DelayTime:create(1)
    local call10 = cc.CallFunc:create(function ()
        index = index + 1
        if index < 7 then
            self:xiaofapaiList(self.xiaopailist[index],index,callback)
        else
            callback()
        end
    end)
    local Sspa
    if index == 5 or index == 6 then 
        Sspa = cc.Spawn:create(SmoveTo,SScaleTo,RotateTo)
    else
        Sspa = cc.Spawn:create(SmoveTo,SScaleTo)
    end
    local Wspa = cc.Sequence:create(Sspa,DelayTime,call10)
    paiSpZ:runAction(Wspa)

end

function FapaiqiGame:UpdateXue(CardNum,BootsId,BootsRoundNum)
    self.shengpai:setString(CardNum)
    self.TxtXueJu:setString("靴局："..BootsId.."靴"..BootsRoundNum.."局")
end

return FapaiqiGame