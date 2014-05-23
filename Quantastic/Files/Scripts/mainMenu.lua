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

slider = class(nil)

function slider:init(x, y, w, thumbW, thumbH, lineH)
	self.x = x
	self.y = y
	self.w = w

	self.thumbPos = 0
	self.thumbW = thumbW
	self.thumbH = thumbH

	self.lineH = lineH

	self.linePtr = addSprite("DarkerGray", x, y, 0, self.w, self.lineH, 0, shadowTypeNone)
	self.thumbPtr = addSprite("PlayerCharacter", x, y, 0, self.thumbW, self.thumbH, 0, shadowTypeNone)

	self.isPrssed = false
	self.isClick = false
	self._isPrevClicked = false
	self._wasPressed = false
	self._startRecorded = false
end

function slider:update() 
	-- Handle click state (only one frame)
	if self._isPrevClicked then 
		self.isClick = false 
		self._isPrevClicked = false
	end
	if self.isClick then 
		self._isPrevClicked = true
	end

	if not (self.thumbPtr == nil) then
		updateSprite(self.thumbPtr, self.x - self.w / 2 + self.w * self.thumbPos, self.y, self.thumbW, self.thumbH, 0)
	end
end

function slider:isThumbUnder(x, y)
	local wd2 = self.thumbW / 2
	local hd2 = self.thumbH / 2

	local thumbX = self.x - self.w / 2 + self.thumbPos * self.w
	if  x < thumbX + wd2 and
		x > thumbX - wd2 and 
		y < self.y + hd2 and 
		y > self.y - hd2 then
		return true
	end

	return false
end

function slider:onTouch(type, worldX, worldY)
	if type == 0 and self:isThumbUnder(worldX, worldY) then
		self._startRecorded = true
	end

	if type == 0 or type == 2 then
		if self:isThumbUnder(worldX, worldY) and self._startRecorded then
			self.isPressed = true
		else
			self.isPressed = false
		end
	else
		if self.isPressed then
			self.isClick = true
		end

		self._startRecorded = false
		self._wasPressed = false
		self.isPressed = false
	end

	if self.isPressed or self._wasPressed then
		self._wasPressed = true
		self.thumbPos = (worldX + self.w / 2) / self.w
		self.thumbPos = math.max(0, math.min(1, self.thumbPos))
	end
end

function slider:dispose()
	removeSprite(self.thumbPtr)
	removeSprite(self.linePtr)
	self.thumbPtr = nil
	self.linePtr = nil
end

menuBackground = nil

logotype = nil
logotypeW = 4
logotypeH = 1
logotypeY = 1.5

credits = nil

backButton = nil
startButton = nil
optionsButton = nil
creditsButton = nil
level1Button = nil
level2Button = nil
level3Button = nil
level4Button = nil
soundVolumeLabel = nil

volumeSlider = nil
lastVolumePosition = 0

cameraX = 0
cameraY = 0
cameraZ = 6
cameraViewAtX = 0
cameraViewAtY = 0

sprite = -1
rigidBody1 = -1
timer = 6
posX = 0.0
posY = 0.0

inGame = false

-- Called after the script has started.
function Start(isInGame)

	info("Main Menu")

	inGame = isInGame
	if inGame then debug("In game menu") end

	setGrayscaleColor(1, 1, 1, 0)
	background(1, 1, 1)
	monitorVariable("cameraX")
	monitorVariable("cameraY")
	monitorVariable("level")

	debug("Building UI...")
	-- Background
	menuBackground = addSprite("MainMenuBackground", 2, 0, 0, 10, 10, 0, shadowTypeNone)

	-- Home
	logotype = addSprite("Logotype", 0, logotypeY, 0.01, logotypeW, logotypeH, 0, shadowTypeNone)
	-- Source size: 300/140 : 1.5/0.7
	startButton = button("StartButton", 0, 0, 0, 1.5, 0.7)
	optionsButton = button("OptionsButton", 0, -0.8, 0, 1.5, 0.7)
	creditsButton = button("CreditsButton", 0, -1.6, 0, 1.5, 0.7)

	-- Levels
	level1Button = button("Level1Button", 10, 0, 0, 1.5, 0.7)
	level2Button = button("Level2Button", 10, -0.8, 0, 1.5, 0.7)
	level3Button = button("Level3Button", 10, -1.6, 0, 1.5, 0.7)
	level4Button = button("Level4Button", 10, -2.4, 0, 1.5, 0.7)

	-- Options
	volumeSlider = slider(0, -10, 2, 0.3, 0.3, 0.04)
	soundVolumeLabel = addSprite("SoundVolume", -2.5, -10, 0.1, 2.8, 0.7, 0.0, shadowTypeNone)

	-- Credits
	credits = addSprite("Credits", -12, -1, 0, 6, 3, 0, shadowTypeNone)

	-- Initiaze back button
	ShowBackButton()
	HideBackButton()

	debug("Setting scene...")
	updateAmbientLight(0.2, 0.2, 0.2)
	updateCamera(cameraX, cameraY, cameraZ);
	cameraViewAtX = 0
	cameraViewAtY = 0

	--setSoundState("HipHoppy", soundStatePlay)
	level, soundVolume = loadSettings()
	volumeSlider.thumbPos = soundVolume
	lastVolumePosition = soundVolume;

	if level < 2 then level2Button:dispose() end
	if level < 3 then level3Button:dispose() end
	if level < 4 then level4Button:dispose() end

end

function ShowBackButton() 
	local x = 0
	local y = 0
	local rot = 0

	if cameraViewAtX > 0 then 
		x = 7.5 
	end
	if cameraViewAtX < 0 then 
		x = -8.5
		rot = 3.14
	end

	if cameraViewAtY < 0 then 
		y = -8.5
		x = -3.5
		rot = -3.14/2
	end

	debug(rot)
	backButton = button("BackButton", x, y, 0, 1, 1, rot)
end

function HideBackButton()
	backButton:dispose()
end

-- Called before every frame is rendered.
function Update(dt)

	startButton:update()
	optionsButton:update()
	creditsButton:update()
	level1Button:update()
	level2Button:update()
	level3Button:update()
	level4Button:update()
	volumeSlider:update()
	backButton:update()

	-- Save if volume changed
	if not (lastVolumePosition == volumeSlider.thumbPos) then
		lastVolumePosition = volumeSlider.thumbPos
		saveSettings(level, lastVolumePosition)
	end

	if startButton.isClick then 
		debug("StartButton clicked") 
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)

		if inGame then
			stopScript("mainMenu")
		else
			cameraViewAtX = 10
			ShowBackButton()
		end
	end

	if optionsButton.isClick then
		debug("OptionsButton clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		cameraViewAtY = -10
		ShowBackButton()
	end

	if creditsButton.isClick then
		debug("CreditsButton clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		cameraViewAtX = -12
		ShowBackButton()
	end

	if backButton.isClick then
		debug("Back clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		cameraViewAtX = 0
		cameraViewAtY = 0
		HideBackButton()
	end

	cameraX = cameraX + (cameraViewAtX - cameraX) * dt * 4
	cameraY = cameraY + (cameraViewAtY - cameraY) * dt * 4
	updateCamera(cameraX, cameraY, cameraZ)
	updateSprite(logotype, cameraX, cameraY + logotypeY, logotypeW, logotypeH, 0.0)

	if level1Button.isClick then
		debug("Level1Button clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		startScript("level1")
		stopScript("mainMenu")
	end

	if level2Button.isClick then
		debug("Level2Button clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		startScript("level2")
		stopScript("mainMenu")
	end

	if level3Button.isClick then
		debug("Level3Button clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		startScript("level3")
		stopScript("mainMenu")
	end

	if level4Button.isClick then
		debug("Level4Button clicked")
		setSoundState("MenuButton", soundStatePlayOnce, 0.3)
		startScript("level4")
		stopScript("mainMenu")
	end
end

-- Called after the script has ended.
function Stop()
	startButton:dispose()
	optionsButton:dispose()
	creditsButton:dispose()
	level1Button:dispose()
	level2Button:dispose()
	level3Button:dispose()
	level4Button:dispose()
	volumeSlider:dispose()

	HideBackButton()

	removeSprite(logotype)
	removeSprite(soundVolumeLabel)
	removeSprite(credits)
	removeSprite(menuBackground)
end

-- Called when user touches the screen.
function OnInput(type, coordX, coordY)
	
	x, y = transformFromScreenSpaceToWorld(coordX, coordY)

	startButton:onTouch(type, x, y)
	optionsButton:onTouch(type, x, y)
	creditsButton:onTouch(type, x, y)
	level1Button:onTouch(type, x, y)
	level2Button:onTouch(type, x, y)
	level3Button:onTouch(type, x, y)
	level4Button:onTouch(type, x, y)
	volumeSlider:onTouch(type, x, y)
	backButton:onTouch(type, x, y)

end
