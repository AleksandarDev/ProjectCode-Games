button = class(nil)

function button:init(spriteName, x, y, z, w, h, rot)
	self.x = x
	self.y = y
	self.z = z
	self.w = w
	self.h = h
	self.rot = rot or 0

	self.ptr = addSprite(
		spriteName,
		self.x, self.y, self.z,
		self.w, self.h, rot,
		shadowTypeNone)

	self.isPrssed = false
	self.isClick = false
	self._isPrevClicked = false
	self._startRecorded = false
end

function button:updateVisual(x, y, w, h, isTemp)
	x = x or self.x
	y = y or self.y
	w = w or self.w
	h = h or self.h

	if not (self.ptr == nil) then
		if isTemp then
			updateSprite(self.ptr, x, y, w, h, self.rot)	
		else
			self.x = x
			self.y = y
			self.w = w
			self.h = h
			updateSprite(self.ptr, self.x, self.y, self.w, self.h, self.rot)
		end
	end
end

function button:update()
	-- Handle click state (only one frame)
	if self._isPrevClicked then 
		self.isClick = false 
		self._isPrevClicked = false
	end
	if self.isClick then 
		self._isPrevClicked = true
	end

	-- Update visual
	if self.isPressed then
		self:size(self.w - 0.1, self.h - 0.1, true)
	else 
		self:updateVisual() 
	end
end

function button:pos(x, y, isTemp)
	if not (x and y) then return self.x, self.y 
	else self:updateVisual(x, y, nil, nil, isTemp) end
end

function button:size(w, h, isTemp)
	if not (w and h) then return self.w, self.h
	else self:updateVisual(nil, nil, w, h, isTemp) end
end

function button:isUnder(x, y)
	local wd2 = self.w / 2
	local hd2 = self.h / 2

	if  x < self.x + wd2 and
		x > self.x - wd2 and 
		y < self.y + hd2 and 
		y > self.y - hd2 then
		return true
	end

	return false
end

function button:onTouch(type, worldX, worldY)
	if type == 0 and self:isUnder(worldX, worldY) then
		self._startRecorded = true
	end

	if type == 0 or type == 2 then
		if self:isUnder(worldX, worldY) and self._startRecorded then
			self.isPressed = true
		else
			self.isPressed = false
		end
	else
		if self.isPressed then
			self.isClick = true
		end

		self._startRecorded = false
		self.isPressed = false
	end
end

function button:dispose()
	removeSprite(self.ptr)
	self.ptr = nil
end

currentLevelName = nil
menuBackground = nil
pause = nil

backButton = nil
startButton = nil

-- Called after the script has started.
function Start(x, y, currentLevelNameArg)

	currentLevelName = currentLevelNameArg
	y = y + 2

	info("Pause Menu")

	debug("Building UI...")
	-- Background along with buttons is set a little towards the camera, for depth stencil buffer
	menuBackground = addSprite("MainMenuBackground", x, y, 0.09, 20, 3.5, 0, shadowTypeNone)
	pause = addSprite("Pause", x, y + 1, 0.1, 1, 1, 0, shadowTypeNone)

	-- Source size: 300/140 : 1.5/0.7
	startButton = button("Resume", x, y, 0.1, 1.5, 0.7)
	optionsButton = button("Quit", x, y + -0.8, 0.1, 1.5, 0.7)

	debug("Setting scene...")

end


-- Called before every frame is rendered.
function Update(dt)

	startButton:update()
	optionsButton:update()

	if startButton.isClick then 
		debug("Resume clicked") 
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		sendToScript("playerCharacters")
		stopScript("pauseMenu")
	end

	if optionsButton.isClick then
		debug("Quit clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		stopScript(currentLevelName)
		stopScript("playerCharacters")
		stopScript("pauseMenu")
		startScript("mainMenu")
	end
end

-- Called after the script has ended.
function Stop()
	startButton:dispose()
	optionsButton:dispose()

	removeSprite(menuBackground)
	removeSprite(pause)
end

-- Called when user touches the screen.
function OnInput(type, coordX, coordY)
	
	x, y = transformFromScreenSpaceToWorld(coordX, coordY)

	startButton:onTouch(type, x, y)
	optionsButton:onTouch(type, x, y)

end
