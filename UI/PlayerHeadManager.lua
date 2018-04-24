
local gt = cc.exports.gt

local PlayerHeadManager = class("PlayerHeadManager", function()
	return cc.Node:create()
end)

function PlayerHeadManager:ctor()
	-- 注册节点事件
	self:registerScriptHandler(handler(self, self.onNodeEvent))

	self.headImageObservers = {}

	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
end

function PlayerHeadManager:onNodeEvent(eventName)
	if "exit" == eventName then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
	end
end

function PlayerHeadManager:update(delta)
--20161118
	-- local transObservers = {}
	-- local curTime = os.time()
	-- for i, observerData in ipairs(self.headImageObservers) do		
		-- if cc.FileUtils:getInstance():isFileExist(observerData.imgFileName) and (curTime-observerData.startTime)>2 then
			-- observerData.headSpr:setTexture(observerData.imgFileName)
			-- observerData.headURL = string.gsub(observerData.headURL, "/0", "/96")
			-- if observerData.isFlushImage then
				-- cc.UserDefault:getInstance():setStringForKey(observerData.imgFileName, observerData.headURL)
			-- end
		-- else
			-- table.insert(transObservers, observerData)
		-- end
	-- end
	-- self.headImageObservers = transObservers
end

function PlayerHeadManager:attach(headSpr, playerUID, headURL, mark)
	-- print("=========",headSpr,playerUID,headURL)
	if not headSpr or not headURL or string.len(headURL) == 0 then
		return
	end

	local imgFileName = string.format("head_img_%d.png", playerUID)

	local observerData = {}
	-- observerData.target = target
	observerData.headSpr = headSpr
	observerData.imgFileName = imgFileName
	-- observerData.headURL = headURL
	observerData.headURL = string.gsub(headURL, "/0", "/96")
	observerData.isFlushImage = false
	table.insert(self.headImageObservers, observerData)
	if cc.FileUtils:getInstance():isFileExist(observerData.imgFileName) then
		observerData.headSpr:setTexture(observerData.imgFileName)
	end

		-- 当前头像不存在或者头像更新,重新下载
		observerData.startTime = os.time()
		--20161118
		--cc.UtilityExtension:httpDownloadImage(observerData.headURL, playerUID)
		observerData.isFlushImage = true
	-- end
end

function PlayerHeadManager:detach(headSpr)
	for i, observerData in ipairs(self.headImageObservers) do
		if observerData.headSpr == headSpr then
			table.remove(self.headImageObservers, i)
			break
		end
	end
end

return PlayerHeadManager