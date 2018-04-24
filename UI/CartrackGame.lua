
-- Creator matt 
-- Create Time 2017/10/20
-- 跑车赛道

local gt = cc.exports.gt

local CartrackGame = class("CartrackGame", function()
	--return cc.CSLoader:createNode("CarTrackNode.csb")
    return cc.Node:create()
end)

temp ={


}
function CartrackGame:ctor(lottery_id,RoomMsgTbl,GametopNode)

    self.lottery_id = lottery_id;
    if self.lottery_id == 4 then
    self.csbNode, self.action = gt.createCSAnimation("BoatTrackNode.csb")
      self.action:play("saitao", true)
    else
    self.csbNode, self.action = gt.createCSAnimation("CarTrackNode.csb")
    end
    self:addChild(self.csbNode)
    self.GametopNode = GametopNode   --顶部节点
	self:registerScriptHandler(handler(self, self.onNodeEvent))

    self.PlayActions = false
	self.MoveCloud = 0      --移动
    self.MoveDir = true     --移动方向
    self.PfbIsBig = false
    self.stopflag = false
    self.Twoindex = {1,1,1,1,1,1,1,1,1,1}


    
	self.RoomMsgTbl = RoomMsgTbl
    self.GradeNode = gt.createCSAnimation("GradeNode.csb")
    --self.GradeNode:setAnchorPoint(0.5,0.5)
    self.GradeNode:setVisible(false)
    --self:addChild(self.GradeNode)

    self.gradetuSP = gt.seekNodeByName(self.csbNode, "gradetu")
    --self.gradetuSP:addChild(self.GradeNode)

    self.ScrollView = gt.seekNodeByName(self.GradeNode, "ScrollView_1")
    self.zhupanPanel = gt.seekNodeByName(self.GradeNode, "zhupanPanel")
    self.gadzadPanel = gt.seekNodeByName(self.GradeNode, "gadzadPanel")
    self.xiaoluPanel = gt.seekNodeByName(self.GradeNode, "xiaoluPanel")
    self.dayanluPanel = gt.seekNodeByName(self.GradeNode, "dayanluPanel")
    self.daluPanel = gt.seekNodeByName(self.GradeNode, "daluPanel")
    
    self.KaiJiangBtn = gt.seekNodeByName(self.csbNode, "KaiJiangBtn")
    self.KaiJiangBtn:setVisible(false)
    --声音按钮
    self.SoundCheck = gt.seekNodeByName(self.csbNode, "SoundCheck")
    
    self.SoundCheck:addClickEventListener(function()
         if self.SoundCheck:isSelected() then
            --print("self.SoundCheck:Selected()")
            gt.soundEngine:resumeAllSound()
            gt.soundEngine:setSoundEffectVolume(gt.EffectsVolume) 
        else
            --print("self.SoundCheck:unSelected()")
            gt.soundEngine:pauseAllSound()
            gt.soundEngine:setSoundEffectVolume(0) 
        end 
	end)

    self.PfbIsup = true
    self.Pfb_Panel = gt.seekNodeByName(self.csbNode, "Pfb_Panel")
    --gt.log("Pfb_Panel ==========",self.Pfb_Panel:getPosition())
    --local cbetBoxSize = Pfb_Panel:getContentSize()
    self.Pfb_layer = gt.seekNodeByName(self.Pfb_Panel, "Pfb_layer")

    local Pfb_Bt = ccui.Widget:create()
    Pfb_Bt:setContentSize(self.gradetuSP:getContentSize())
    Pfb_Bt:setTouchEnabled(false)
    Pfb_Bt:addChild(self.GradeNode)
    Pfb_Bt:addClickEventListener(function()
        gt.log("Pfb_Bt === ",self.PfbIsup)
        if self.PfbIsup then
            self.ScrollView:setTouchEnabled(false)
            self.GradeNode:setScale(0.5)
            self.GradeNode:setPosition(cc.p(200,138))
            self.PfbIsBig = false
        else
--            self.ScrollView:setTouchEnabled(true)
--            self.GradeNode:setPosition(cc.p(375,0))
--            self.GradeNode:setScale(1)
--            self.PfbIsBig = true
        end
	end)
    self:addChild(Pfb_Bt)
    -- 评分板放大按钮
--	local gradeBtn = gt.seekNodeByName(self.Pfb_layer, "gradeBtn")
--    --gradeTu:setVisible(false)
--    gt.addBtnPressedListener(gradeBtn, handler(self, function()
--        self.GradeNode:setVisible(true)
--        self.GradeNode:setScale(1)
--	end))
    
    -- 评分板按钮
	local PfbBut = gt.seekNodeByName(self.Pfb_layer, "PfbBut")
    gt.addBtnPressedListener(PfbBut, handler(self, function()
        Utils.setClickEffect()
        self:PfbMove()
	end))
    if self.RoomMsgTbl[8] == 4 then
        PfbBut:setVisible(true)
    else
        PfbBut:setVisible(false)
    end

    local Cartrack = gt.seekNodeByName(self.csbNode, "Cartrack_panel")
    
    self.CarTimeBg = gt.seekNodeByName(self.csbNode, "Panel_2")
    self.CarTimeStrip = gt.seekNodeByName(self.csbNode, "TimeOutBg_3")
    self.CarTimeTxt = gt.seekNodeByName(self.csbNode, "Text_1")
    self.CarTimeTxt:setString("20s")
    --self.CarTimeStrip:setRotation(120)
        
    self.saidao_1 = gt.seekNodeByName(Cartrack, "saidao_1")      --云背景
    self.saidao_2 = gt.seekNodeByName(Cartrack, "saidao_2")      --浮标背景
    if self.lottery_id == 4 then
        self.saidaoSprite1 = cc.Sprite:create("res/Boat/sudu_boat.png")        --二云
        self.saidaoSprite2 = cc.Sprite:create("res/Boat/yun1.png")        --二浮标
    else
        self.saidaoSprite1 = cc.Sprite:create("res/gamepai/saidao.png")        --二云
        self.saidaoSprite2 = cc.Sprite:create("res/gamepai/saidao.png")        --二浮标
    end
    self.saidaoSprite1:setPosition(375,0)
    self.saidaoSprite1:setAnchorPoint(0.5,0)
    Cartrack:addChild(self.saidaoSprite1)

    self.saidaoSprite2:setPosition(375,355)
    self.saidaoSprite2:setAnchorPoint(0.5,1)
    Cartrack:addChild(self.saidaoSprite2)


    self.zhongdi = gt.seekNodeByName(self.csbNode, "zhongdi")

    self.Createtbl = {{},{},{},{},{},{},{},{},{},{}}
    self.Createtbllist = {{},{},{},{},{},{},{},{},{},{}}
    self:CreateNumtbl(false)

    self.CarNode = {}
    for i = 1, 10 do
        if self.lottery_id == 4 then
            local Boat = gt.seekNodeByName(Cartrack, "Boat"..i)
            local BoatNode,BoatNodeaction = gt.createCSAnimation("BoatNode.csb")
            Boat:addChild(BoatNode,5)
            local Boatwei = gt.seekNodeByName(BoatNode, "carwei")
            Boatwei:setVisible(false)
            self.CarNode[i] = {BoatNode,BoatNodeaction,Boatwei}
            local sports_Boat = gt.seekNodeByName(BoatNode, "sports_boat")
            sports_Boat:setTexture("res/res/Boat/sports_boat"..i..".png")
        else
            local Car = gt.seekNodeByName(Cartrack, "Car"..i)
            local CarNode,CarNodeaction = gt.createCSAnimation("CarNode.csb")
            Car:addChild(CarNode,5)
            local carwei = gt.seekNodeByName(CarNode, "carwei")
            carwei:setVisible(false)
            self.CarNode[i] = {CarNode,CarNodeaction,carwei}
            local sports_car = gt.seekNodeByName(CarNode, "sports_car")
            sports_car:setTexture("res/res/gamepai/sports_car"..i..".png")
        end
    end
    --百家乐输赢（百家乐当前靴的输赢）应答
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_RSP, self, self.BaccaratBalanceRsp)
    --gt.socketClient:registerMsgListener(cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_RSP, self, self.BaccaratBalanceRsp)

end

function CartrackGame:GetLotteryResult()
   --百家乐输赢（百家乐当前靴的输赢）应答
    local cmsg = cmd_game_pb.CGetBaccaratBalanceReq()
    cmsg.msg_id = gt.EnterGameRoomId
    cmsg.node_id = gt.EnterGameRoomId
    local msgdata = cmsg:SerializeToString()
    gt.socketClient:sendMessage( cmd_net_pb.CMD_GAME, cmd_net_pb.CMD_GAME_BACCARAT_BALANCE_REQ,msgdata)
   --
end


function CartrackGame:PfbMove()
        local pos
        local str = "res/res/"
    if self.PfbIsup then
        pos = cc.p(self.Pfb_layer:getPositionX(), self.Pfb_layer:getPositionY() - 350)
        str = str.."grade_up.png"
        self:GetLotteryResult()
    else
        pos = cc.p(self.Pfb_layer:getPositionX(), self.Pfb_layer:getPositionY() + 350)
        str = str.."grade_dw.png"
        self.GradeNode:setVisible(false)
        self.gradetuSP:setVisible(true)
    end
    local moveTo = cc.MoveTo:create(0.5, pos)
	local call = cc.CallFunc:create(function ()
        if self.PfbIsup then
            self.GradeNode:setScale(0.5)
            self.GradeNode:setVisible(true)
            self.GradeNode:setPosition(cc.p(195,136))
            self.gradetuSP:setVisible(false)
            self.ScrollView:setTouchEnabled(false)
        else
            self.GradeNode:setVisible(false)
        end
            self.PfbIsup = not self.PfbIsup
            local grade_png = gt.seekNodeByName(self.Pfb_layer, "grade_dw")
            grade_png:setTexture(str)
            
	end)
	local spa = cc.Sequence:create(moveTo, call)
    self.Pfb_layer:stopAllActions()
    self.Pfb_layer:runAction(spa)
end

function CartrackGame:onNodeEvent(eventName)
	if "enter" == eventName then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
		listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
	elseif "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

gradetu = {"gradxian.png","gradzhuan.png","gradhe.png"}
Dgradetu = {"gradblue.png","gradred.png","gradgreen.png","bluedi.png","reddi.png"}
function CartrackGame:showluda(balance)
        local temp_j = 0
        local temp_j1 = 0
        local Iszhuang = 0
        local temp_i = 0
        local Dt1 = 0 
        local Dt2 = 0 
        local Dt3 = 0
        local MaxDt = 0;
        local TempMaxDt = 0;
        local MaxLen = 5
        local luidNum = {0,0,0,0,0}
        local xiaoluilist = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        self.dayanlunum = 0
        self.xiaolunum = 0
        self.gadzadnum = 0

        self.zhupanPanel:removeAllChildren()
        self.gadzadPanel:removeAllChildren()
        self.xiaoluPanel:removeAllChildren()
        self.dayanluPanel:removeAllChildren()
        self.daluPanel:removeAllChildren()

    for i=1,#balance do
        --gt.log("===round_order:"..balance[i].round_order..";issue = "..balance[i].issue..";balance="..balance[i].balance)         
        local balancestr = gt.string_split(balance[i].balance,",")
        for j = 1, #balancestr  do
        --gt.log("balance_1===",balancestr[j])
            if balancestr[j] ~= "" and balancestr[j] then
                local balance_1 = gt.string_split(balancestr[j],"-");
                --local num =  string.sub(cellData.balance,i,i);
                local t1,t2 = math.modf((i-1)/6)
                --gt.log("showludaPos=",18 + 35*(t1),18 + (t2*6)*35,balance_1[2],j)
                if balance_1[2] == "1" then
                    luidNum[j] = luidNum[j] + 1
                    local DpaiSp = cc.Sprite:create("res/gradetu/"..Dgradetu[j])

                    if i > 1 and temp_i ~= i then
                        --gt.log("showludaPos=",i,j,temp_i,temp_j,Dt2,Dt1,MaxDt)
                        temp_i = i
                        if temp_j == j or j == 3 or ( temp_j1 == 3 and temp_j == 0) then  
                            Dt2 = Dt2 + 1
                            if Dt2 > MaxLen then 
                                Dt2 = MaxLen
                                Dt1 = Dt1 + 1                          
                                TempMaxDt = TempMaxDt + 1
                                if MaxDt < TempMaxDt then
                                    MaxDt = TempMaxDt
                                end
                            end
                        else
                            if Dt2 > MaxLen then
                                MaxLen = MaxLen -1
                            else
                                MaxLen = 5
                            end
                            if Dt2 == MaxLen and MaxDt > 0 then 
                                MaxDt = MaxDt - 1
                                if MaxDt < 0 then
                                    MaxDt = 0
                                end
                                Dt1 = Dt1 - MaxDt
                            else
                                Dt1 = Dt1 + 1
                            end
                            TempMaxDt = 0
                            Dt2 = 0
                            Dt3 = Dt3 + 1
                        end
--                        if temp_j == j or j == 3 or ( temp_j1 == 3 and temp_j == 0) then
--                            Dt2 = Dt2 + 1
--                            if Dt2 > 5 then 
--                                Dt2 = 5
--                                Dt1 = Dt1 + 1
--                                MaxDt = MaxDt + 1
--                            end
--                            -- 比较规则  直落
--                        else
--                            Dt1 = Dt1 + 1 - MaxDt
--                            Dt2 = 0
--                            MaxDt = 0
--                            Dt3 = Dt3 + 1
--                            -- 比较规则  换列
--                        end
                    end
                    if j < 4 then
                        local paiSp = cc.Sprite:create("res/gradetu/"..gradetu[j])
                        paiSp:setPosition(cc.p(25 + 62*(t1),336 - (t2*6)*62)) 
                        paiSp:setScale(1.5)
                        self.zhupanPanel:addChild(paiSp)
                        --gt.log("Dt1;Dt2 =",Dt1,Dt2)
                        if j ~= 3 then 
                            xiaoluilist[Dt3+1] = xiaoluilist[Dt3+1] +1
                            --小路规则显示
                            --self.showxiaolui(self.xiaoluilist,j==temp_j)
                        end
                        if temp_j ~= j and j ~= 3 then
                            temp_j = j
                            if j == 1 then
                                Iszhuang = 0
                            else
                                Iszhuang = 1
                            end
                        end
                        temp_j1 = j
                    end
                    DpaiSp:setPosition(cc.p(16 + 37*(Dt1),220 - (Dt2)*39))
                    DpaiSp:setScale(1.3)
                    self.daluPanel:addChild(DpaiSp)
                end
            end
        end       
    end
    --dump(xiaoluilist, "xiaoluilist")
    self:showxiaolui(xiaoluilist,Iszhuang,Dt1)
    for i=1,5 do
        local shownum = luidNum[i]
        if i==1 then 
            shownum = luidNum[2]
        elseif i==2 then
            shownum = luidNum[1]
        end
        if i==4 then 
            shownum = luidNum[5]
        elseif i==5 then
            shownum = luidNum[4]
        end
        local luidNum = gt.seekNodeByName(self.GradeNode, "Txt_luidNum"..i)
        luidNum:setString(shownum)
    end
end

xiaogradetu = {"yellored.png","yelloblue.png","red.png","blue.png","redxian.png","bluexian.png"}
function CartrackGame:showxiaolui(xiaolulist,Iszhuan,index)
    --
    local liuindex = 2
    if xiaolulist[2]<1 then
        --return
    end 
    local xiaogr = 0
    local xiaolu = 0
    local xiaopz = 0
    local tempxiaogr = 0
    local tempxiaolu = 0
    local tempxiaopz = 0
    local Xt1 = 0 
    local Xt2 = 0
    local Xt3 = 0 
    local Xt4 = 0
    local Xt5 = 0 
    local Xt6 = 0
    local MaxXt = 0
    local MaxXt2 = 0
    local MaxLen = 5
    local MaxXt3 = 0
    local MaxXt4 = 0
    local MaxLen3 = 5
    local MaxXt5 = 0
    local MaxXt6 = 0
    local MaxLen5 = 5
    for i=1,20 do 
        if xiaolulist[liuindex]>0 then 
        --gt.log("xiaolulist===",xiaolulist[liuindex])
            for j=1,xiaolulist[liuindex] do
--                if j==1 and liuindex ==2 then
--                    break
--                end 
                if j==1 then
                    if liuindex>2 then
                        if xiaolulist[liuindex-1] == xiaolulist[liuindex-2] then
                            xiaogr = 1
                        else
                            xiaogr = 2
                        end
                    end
                    if liuindex>3 then
                        if xiaolulist[liuindex-1] == xiaolulist[liuindex-3] then
                            xiaolu = 3
                        else
                            xiaolu = 4
                        end
                    end

                    if liuindex>4 then
                        if xiaolulist[liuindex-1] == xiaolulist[liuindex-4] then
                            xiaopz = 5
                        else
                            xiaopz = 6
                        end
                    end
                else
                    if j <= xiaolulist[liuindex-1] or j - xiaolulist[liuindex-1]>1 then
                        xiaogr = 1
                    else
                        xiaogr = 2
                    end

                    if liuindex>2 then
                        if j <= xiaolulist[liuindex-2] or j - xiaolulist[liuindex-2]>1 then
                            xiaolu = 3
                        else
                            xiaolu = 4
                        end
                    end

                    if liuindex>3 then
                        if j <= xiaolulist[liuindex-3] or j - xiaolulist[liuindex-3]>1 then
                            xiaopz = 5
                        else
                            xiaopz = 6
                        end
                    end
                end
--                self.dayanlunum = self.dayanlunum + 1
--                if self.dayanlunum < 1 then 
--                    break
--                end

                if tempxiaogr ~= xiaogr then
                    Xt2 = 0
                    Xt1 = Xt1 + 1 - MaxXt
                    MaxXt = 0
                else
                   Xt2 = Xt2 + 1
                   if Xt1 <= MaxXt2 then
                        --Xt1 = Xt1 + 1
                        MaxLen = MaxLen - 1
                   else
                        MaxLen = 5
                   end
                   if Xt2 > MaxLen then 
                        MaxXt = MaxXt + 1
                        Xt1 = Xt1 + 1
                        MaxXt2 = Xt1
                        Xt2 = Xt2 - 1
                    end
                end
                --gt.log("Xt1===",Xt1,Xt2)
                if xiaolu > 0 then
                    if tempxiaolu ~= xiaolu then
                        Xt4 = 0
                        Xt3 = Xt3 + 1 - MaxXt3
                        MaxXt3 = 0
                    else
                       Xt4 = Xt4 + 1

                       if Xt3 <= MaxXt4 then
                            --MaxLen3 = MaxLen3 - 1
                       else
                            MaxLen3 = 5
                       end
                       if Xt4 > MaxLen3 then 
                            MaxXt3 = MaxXt3 + 1
                            Xt3 = Xt3 + 1
                            MaxXt4 = Xt3
                            Xt4 = Xt4 - 1
                            MaxLen3 = MaxLen3 - 1
                        end
                    end
                end
                --gt.log("Xt3===",Xt3,Xt4)
                if xiaopz > 0 then
                    if tempxiaopz ~= xiaopz then
                        Xt6 = 0
                        Xt5 = Xt5 + 1 - MaxXt5
                        MaxXt5 = 0
                    else
                       Xt6 = Xt6 + 1

                       if Xt5 <= MaxXt6 then
                            --MaxLen5 = MaxLen5 - 1
                       else
                            MaxLen5 = 5
                       end
                       if Xt6 > MaxLen5 then 
                            MaxXt5 = MaxXt5 + 1
                            Xt5 = Xt5 + 1
                            MaxXt6 = Xt5
                            Xt6 = Xt6 - 1
                            MaxLen5 = MaxLen5 - 1
                        end
                    end
                end
                tempxiaogr = xiaogr
                tempxiaolu = xiaolu
                tempxiaopz = xiaopz

                if xiaogr > 0 then
                    --local t1,t2 = math.modf((self.dayanlunum-1)/6)
                    local paiSp = cc.Sprite:create("res/gradetu/"..xiaogradetu[xiaogr])
                    paiSp:setPosition(cc.p(10 + 20*(Xt1-1),110 - Xt2*20))
                    --paiSp:setScale(0.6)
                    self.dayanluPanel:addChild(paiSp)
                    --xiaogr = 0
                end

                if xiaolu > 0 then
                    local paiSp = cc.Sprite:create("res/gradetu/"..xiaogradetu[xiaolu])
                    paiSp:setScale(0.8)
                    paiSp:setPosition(cc.p(10 + 20*(Xt3-1),110 - Xt4*20))
                    self.xiaoluPanel:addChild(paiSp)
                    --xiaolu = 0
                end

                if xiaopz > 0 then
                    local paiSp = cc.Sprite:create("res/gradetu/"..xiaogradetu[xiaopz])
                    --paiSp:setScale(0.6)
                    paiSp:setPosition(cc.p(10 + 20*(Xt5-1),110 - Xt6*20))
                    self.gadzadPanel:addChild(paiSp)
                    --xiaopz = 0
                end
            end
            liuindex = liuindex + 1
        end
        
    end
        liuindex = liuindex - 1
        local Txiaogr = 0
        local Txiaolu = 0
        local Txiaopz = 0

        local number = 1
        if Iszhuan then 
            number = xiaolulist[liuindex] + 1
        else
            number = 1
            liuindex = liuindex + 1
        end

        if number==1 then
            if liuindex>2 then
                if xiaolulist[liuindex-1] == xiaolulist[liuindex-2] then
                    xiaogr = 1
                else
                    xiaogr = 2
                end
            end
            if liuindex>3 then
                if xiaolulist[liuindex-1] == xiaolulist[liuindex-3] then
                    xiaolu = 3
                else
                    xiaolu = 4
                end
            end

            if liuindex>4 then
                if xiaolulist[liuindex-1] == xiaolulist[liuindex-4] then
                    xiaopz = 5
                else
                    xiaopz = 6
                end
            end
        else
            if liuindex>1 then
                if number <= xiaolulist[liuindex-1] or number - xiaolulist[liuindex-1]>1 then
                    xiaogr = 1
                else
                    xiaogr = 2
                end
            end

            if liuindex>2 then
                if number <= xiaolulist[liuindex-2] or number - xiaolulist[liuindex-2]>1 then
                    xiaolu = 3
                else
                    xiaolu = 4
                end
            end

            if liuindex>3 then
                if number <= xiaolulist[liuindex-3] or number - xiaolulist[liuindex-3]>1 then
                    xiaopz = 5
                else
                    xiaopz = 6
                end
            end
        end

        if xiaogr == 1 then
            Txiaogr = 2
        end
        if xiaogr == 2 then
            Txiaogr = 1
        end
        if xiaolu == 4 then
            Txiaolu = 3
        end
        if xiaolu == 3 then
            Txiaolu = 4
        end
        if xiaopz == 6 then
            Txiaopz = 5
        end
        if xiaopz == 5 then
            Txiaopz = 6
        end
       local showpro = {xiaogr,xiaolu,xiaopz,Txiaogr,Txiaolu,Txiaopz}
       if Iszhuan==1 then 
            showpro = {xiaogr,xiaolu,xiaopz,Txiaogr,Txiaolu,Txiaopz}
       else
            showpro = {Txiaogr,Txiaolu,Txiaopz,xiaogr,xiaolu,xiaopz}
       end

       for i=1,6 do 
        --gt.log("xiaolulist===",showpro[i],Iszhuan)
        local zhuang = gt.seekNodeByName(self.GradeNode, "zhuang_"..i)
        if showpro[i] == 0 then
            zhuang:setVisible(false)
        else
            zhuang:setTexture("res/gradetu/"..xiaogradetu[showpro[i]])
        end
       end 
end

function CartrackGame:update(delta)
	if not self.PlayActions then
        if self.lottery_id ~= 4 then
            self.action:pause()
        end
		return
	end
    --跑车

--    for i = 1, 10 do
--        if math.random(1,2) < 1.5 then
--            self.CarNode[i][3]:setVisible(false)
--        else
--            self.CarNode[i][3]:setVisible(true)
--        end
--    end

--    for i = 1, 10 do
--        if math.random(1,2) < 1.5 then
--            self.CarNode[i][3]:setVisible(false)
--        else
--            local posX = self.CarNode[i][1]:getPositionX()
--            self.CarNode[i][3]:setVisible(true)
--            if posX < -500 then
--                self.zhongdi:setVisible(true)
--                self.zhongdi:setPositionX(115)
--            end
--            if posX < -650 then
--                self.CarNode[i][2]:pause()
--                self.CarNode[i][3]:setVisible(false)
--            else
--                self.CarNode[i][1]:setPositionX(posX - math.random(0,10))
--                --local moveto = cc.MoveTo:create(0.4,  cc.p(posX - math.random(0,50),0))
--                --self.CarNode[i][1]:runAction(cc.RepeatForever:create(moveto))
--            end
--        end
--    end

    self.MoveCloud = self.MoveCloud + 15
    
    if self.MoveDir == true then
--        self.saidaoSprite1:setPosition(375+self.MoveCloud,0)
--        self.saidao_1:setPosition( -375 +self.MoveCloud, 0)
--        self.saidaoSprite2:setPosition(375+self.MoveCloud,335)
--        self.saidao_2:setPosition( -375 +self.MoveCloud, 335)
        self.saidaoSprite1:setPositionX(375+self.MoveCloud)
        self.saidao_1:setPositionX( -375 +self.MoveCloud)
        self.saidaoSprite2:setPositionX(375+self.MoveCloud)
        self.saidao_2:setPositionX( -375 +self.MoveCloud)
        if self.saidaoSprite1:getPositionX() > 1125 then
            self.MoveDir = false
            self.MoveCloud = 0
        end 
    else
--        self.saidaoSprite1:setPosition(-375+self.MoveCloud,0)
--        self.saidao_1:setPosition( 375 +self.MoveCloud, 0)
--        self.saidaoSprite2:setPosition(375+self.MoveCloud,335)
--        self.saidao_2:setPosition( -375 +self.MoveCloud, 335)
        self.saidaoSprite1:setPositionX(-375+self.MoveCloud)
        self.saidao_1:setPositionX( 375 +self.MoveCloud)
        self.saidaoSprite2:setPositionX(375+self.MoveCloud)
        self.saidao_2:setPositionX( -375 +self.MoveCloud)
        if self.saidao_1:getPositionX() > 1125 then
            self.MoveDir = true
            self.MoveCloud = 0
        end 
    end
end

function CartrackGame:SetLotteryNo(isflag)
    self.stopflag = isflag
end

function CartrackGame:CarTimeUpdate(Total,delta)
    self.CarTimeTxt:setString(delta.."s")
    self.CarTimeBg:setVisible(true)
    local Rotate = Total - delta
    local animation = cc.RotateTo:create(0.2, (120/Total)*Rotate)
    self.CarTimeStrip:runAction(cc.RepeatForever:create(animation))
    
    if delta <= 6 and delta > 1 then
        gt.playEngineStr = gt.soundEngine:playEffect("DaojiShi",false)
    end
    if delta <= 0 then
        self.CarTimeBg:setVisible(false)
        --gt.soundEngine:stopEffect(gt.playEngineStr)
    else
        self.CarTimeBg:setVisible(true)
    end
end


function CartrackGame:PlayCarBao()
    --self.CarMoveEffect =  gt.soundEngine:playEffect("CarMove",true)
    if self.lottery_id == 4 then
        gt.playEngineStr = gt.soundEngine:playEffect("BoattrackMove",false)
    else
        gt.playEngineStr = gt.soundEngine:playEffect("CarMove",true)
    end
    --跑车
    --gt.log("PlayCarBao ==========")
    self.PlayActions = true
    --self.stopflag = false
    self.zhongdi:setVisible(false)
    --local csbNode, action = gt.createCSAnimation("CarTrackNode.csb")
	self.action:play("saitao", true)
    for i = 1, 10 do
        self.CarNode[i][2]:play("carbao", true)

--            local pox1 = - math.random(0,80)
--	        local moveTo1 = cc.MoveTo:create(1, cc.p( pox1, 0))
--            local pox2 = - math.random(0,80) + pox1
--	        local moveTo2 = cc.MoveTo:create(1, cc.p( pox2, 0))
--            local pox3 = - math.random(0,80) + pox2
--	        local moveTo3 = cc.MoveTo:create(1, cc.p( pox3, 0))
--            local pox4 = - math.random(0,80) + pox3
--	        local moveTo4 = cc.MoveTo:create(1, cc.p( pox4, 0))
--            local pox5 = - math.random(-80,80) + pox4
--	        local moveTo5 = cc.MoveTo:create(1, cc.p( pox5, 0))
--            local pox6 = - math.random(-80,80) + pox5
--	        local moveTo6 = cc.MoveTo:create(1, cc.p( pox6, 0))
--            local pox7 = - math.random(-80,80) + pox6
--	        local moveTo7 = cc.MoveTo:create(1, cc.p( pox7, 0))
--            local pox8 = - math.random(-80,80) + pox7
--	        local moveTo8 = cc.MoveTo:create(1, cc.p( pox8, 0))
--            local pox9 = - math.random(-80,80) + pox8 
--	        local moveTo9 = cc.MoveTo:create(1, cc.p( pox9, 0))

            local call0 = cc.CallFunc:create(function ()
                  self.CarNode[i][3]:setVisible(true)            
	        end)

	        local moveTo1 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][1].num, 0))
	        local moveTo2 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][2].num, 0))
	        local moveTo3 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][3].num, 0))
	        local moveTo4 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][4].num, 0))
	        local moveTo5 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][5].num, 0))
	        local moveTo6 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][6].num, 0))
	        local moveTo7 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][7].num, 0))
	        local moveTo8 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][8].num, 0))
	        local moveTo9 = cc.MoveTo:create(1.5, cc.p( self.Createtbl[i][9].num, 0))

	        local call1 = cc.CallFunc:create(function ()
                self.GametopNode:showzhonjian("",self.Createtbllist[1])
                self.CarNode[i][3]:setVisible(self.Createtbl[i][2].ishuo)    
	        end)
	        local call2 = cc.CallFunc:create(function ()
                self.GametopNode:showzhonjian("",self.Createtbllist[2])
                self.CarNode[i][3]:setVisible(self.Createtbl[i][3].ishuo)    
	        end)
	        local call3 = cc.CallFunc:create(function ()
               self.GametopNode:showzhonjian("",self.Createtbllist[3])
               self.CarNode[i][3]:setVisible(self.Createtbl[i][4].ishuo)    
	        end)
	        local call4 = cc.CallFunc:create(function ()
                self.GametopNode:showzhonjian("",self.Createtbllist[4])
                self.CarNode[i][3]:setVisible(self.Createtbl[i][5].ishuo)    
	        end)
	        local call5 = cc.CallFunc:create(function ()
                self.GametopNode:showzhonjian("",self.Createtbllist[5])
                self.CarNode[i][3]:setVisible(self.Createtbl[i][6].ishuo)    
	        end)
	        local call6 = cc.CallFunc:create(function ()
                self.GametopNode:showzhonjian("",self.Createtbllist[6])
                self.CarNode[i][3]:setVisible(self.Createtbl[i][7].ishuo)    
	        end)
	        local call7 = cc.CallFunc:create(function ()
                self.GametopNode:showzhonjian("",self.Createtbllist[7])
                self.CarNode[i][3]:setVisible(self.Createtbl[i][8].ishuo)    
	        end)
	        local call8 = cc.CallFunc:create(function ()
                self.GametopNode:showzhonjian("",self.Createtbllist[8])
                self.CarNode[i][3]:setVisible(self.Createtbl[i][9].ishuo)    
	        end)


            local Spawn1 = cc.Spawn:create(call0,moveTo1)
            local Spawn2 = cc.Spawn:create(call1,moveTo2)
            local Spawn3 = cc.Spawn:create(call2,moveTo3)
            local Spawn4 = cc.Spawn:create(call3,moveTo4)
            local Spawn5 = cc.Spawn:create(call4,moveTo5)
            local Spawn6 = cc.Spawn:create(call5,moveTo6)
            local Spawn7 = cc.Spawn:create(call6,moveTo7)
            local Spawn8 = cc.Spawn:create(call7,moveTo8)
            local Spawn9 = cc.Spawn:create(call8,moveTo9)

            local call11 = cc.CallFunc:create(function ()
                    if i == 1 then
                        self.GametopNode:showzhonjian("",self.Createtbllist[9])   
                        self:CreateNumtbl(true)
                    end
                    self:PlayCarBao_One(i)
                    self.Twoindex[i] = 1
                    self.CarNode[i][3]:setVisible(self.Createtbl[i][self.Twoindex[i]].ishuo)  
	        end)
            local spa = cc.Sequence:create(Spawn1,Spawn2,Spawn3,Spawn4,Spawn5,Spawn6,Spawn7,Spawn8,Spawn9,call11)
	        --self.CarNode[i][1]:stopAllActions()
	        self.CarNode[i][1]:runAction(spa)
    end
end

function CartrackGame:PlayCarBao_One(indx)
    local pox = - math.random(-80,80) - 400 
    --local moveTo11 = cc.MoveTo:create(1, cc.p( pox, 0))
    local moveTo11 = cc.MoveTo:create(1.5, cc.p(self.Createtbl[indx][self.Twoindex[indx]].num, 0))
    local call11 = cc.CallFunc:create(function ()
            self.Twoindex[indx] = self.Twoindex[indx] + 1
            if self.Twoindex[indx] > 10  then 
                self:CreateNumtbl(true)
                self.Twoindex[indx] = 1
            end
        self.GametopNode:showzhonjian("",self.Createtbllist[self.Twoindex[indx]])  
        self.CarNode[indx][3]:setVisible(self.Createtbl[indx][self.Twoindex[indx]].ishuo)  
        --end
        if self.stopflag == false then
            self:PlayCarBao_One(indx)
            else
            self:PlayCarBao_Two(indx)
        end
    end)

    local spa = cc.Sequence:create(moveTo11,call11)
    self.CarNode[indx][1]:runAction(spa)

end

function CartrackGame:PlayCarBao_Two(indx)
        local numtap =  gt.string_split(self.RoomMsgTbl[2],",")
        local indx_i = indx;
	    local call9 = cc.CallFunc:create(function ()
            self.CarNode[indx_i][3]:setVisible(true)
            self.zhongdi:setVisible(true)
            self.zhongdi:setPositionX(115)
            --self.GametopNode:showzhonjian("",self.Createtbllist[9])
            self.GametopNode:showzhonjian("",numtap)
	    end)
        --local pox9 = - math.random(0,60) + pox8 
        local paotime = 0.3;
        for i = 1, 10 do
            if tonumber(numtap[i]) == indx_i then 
                paotime = i*0.3
                break
            end
        end
	    local moveTo10 = cc.MoveTo:create(paotime, cc.p(-652, 0))
	    local call10 = cc.CallFunc:create(function ()
            --self.CarNode[indx_i][3]:setVisible(false)
            --self.CarNode[indx_i][2]:pause()
            self.stopflag = false
            if indx_i == 10 then
                --self.GametopNode:showzhonjian("",numtap)
                --gt.soundEngine:stopEffect(gt.playEngineStr)
                self:CreateNumtbl(false)
                self:CarBaowei()
                self.Twoindex = {1,1,1,1,1,1,1,1,1,1}
            end
	    end)

        local spa = cc.Sequence:create(call9,moveTo10,cc.DelayTime:create(3-paotime),call10)
        self.CarNode[indx_i][1]:runAction(spa)
end

--随机生成十维数组
function CartrackGame:CreateNumtbl(isTwo)
    for i = 1, 10 do
        for j = 1, 10 do
            local tbltemp  = - math.random(0,100);
            self.Createtbl[i][j] = {}
            --table.insert(self.Createtbl[i][j], cbSortValue)
            self.Createtbl[i][j].inx = i
            if isTwo then 
                tbltemp  = - math.random(-120,120); 
                self.Createtbl[i][j].num = -300 + tbltemp
            else
                if j > 1 then
                    if j>4 then
                        tbltemp  = - math.random(-100,100); 
                    end
                    local tempnum =  self.Createtbl[i][j - 1].num + tbltemp
                    if tempnum > -20 then 
                        tempnum  = -20 
                    elseif tempnum < -600 then
                        tempnum  = -600 
                    end
                    self.Createtbl[i][j].num = tempnum
                    
                else
                    self.Createtbl[i][j].num = tbltemp
                end
            end
            if tbltemp < 0 then
                self.Createtbl[i][j].ishuo = true
            else
                self.Createtbl[i][j].ishuo = false
            end
        end
    end
    --dump(self.Createtbl, "十维数组")
    --self.Createtbllist = self.Createtbl
    for i = 1, 10 do
        for j = 1, 10 do
            self.Createtbllist[i][j] = self.Createtbl[j][i]
        end
    end

    local temptbl = {}
    for i = 1, 10 do
        for k = 1, 10 do
            for j = 2, 10 do
                if self.Createtbllist[i][j].num < self.Createtbllist[i][j-1].num then
                    temptbl = self.Createtbllist[i][j]
                    self.Createtbllist[i][j] = self.Createtbllist[i][j-1]
                    self.Createtbllist[i][j-1] = temptbl
                end
            end
        end
    end

   for i = 1, 10 do
        for j = 1, 10 do
            self.Createtbllist[i][j] = self.Createtbllist[i][j].inx
        end
    end
    --dump(self.Createtbllist, "十维数组list")

end

function CartrackGame:CarBaowei()
    self.PlayActions = false
    --stopAction("animation0")
    for i = 1, 10 do
        --self.CarNode[i][2]:pause()
        self.CarNode[i][1]:setPositionX(-652)
        self.CarNode[i][2]:pause()
        self.CarNode[i][3]:setVisible(false)
    end
    self.zhongdi:setVisible(true)
    self.zhongdi:setPositionX(115)
    gt.soundEngine:stopEffect(gt.playEngineStr)
end

function CartrackGame:StopCarBao()
    --跑车
    --gt.log("StopCarBao ==========")
    --local csbNode, action = gt.createCSAnimation("CarTrackNode.csb")
	--self.action:pause()
    self.PlayActions = false
    --stopAction("animation0")
    for i = 1, 10 do
        --self.CarNode[i][2]:pause()
        self.CarNode[i][1]:setPositionX(0)
        self.CarNode[i][2]:pause()
        self.CarNode[i][3]:setVisible(false)
    end
    --self.stopflag = false
    self.zhongdi:setVisible(true)
    self.zhongdi:setPositionX(642)
    gt.soundEngine:stopEffect(gt.playEngineStr)
end

function CartrackGame:showMsg(msgText, repeattimes)

end

function CartrackGame:PfbVisible(bVisible)
    --self.GradeNode:setVisible(bVisible)
    self.GradeNode:setScale(0.5)
    self.ScrollView:setTouchEnabled(false)
    self.GradeNode:setPosition(cc.p(195,136))
    self.PfbIsBig = false
end

--function CartrackGame:onTouchBegan(touch, event)
--    --self.beganPos = self:convertToNodeSpace(touch:getLocation())
--    self:PfbVisible(false)
--    return true
--end
return CartrackGame