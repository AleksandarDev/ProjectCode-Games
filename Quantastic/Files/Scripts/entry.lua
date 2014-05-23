fpsCounter = 0
fpsTimer = 0
fpsPeriod = 10
fps = 0

-- Called after the script has started.
function Start()

	-- load some textures
	loadSprite("Circle", "ProjectCode_Graphics_W81\\Assets\\circle.dds")
	loadSprite("DarkerGray", "ProjectCode_Graphics_W81\\Assets\\DarkerGray.dds")
	loadSprite("LighterGray", "ProjectCode_Graphics_W81\\Assets\\LighterGray.dds")
	loadSprite("PlayerCharacter", "ProjectCode_Graphics_W81\\Assets\\playerCharacter.dds")
	loadSprite("WateryBackground", "ProjectCode_Graphics_W81\\Assets\\WateryBackground.dds")
	loadSprite("IcyBackground", "ProjectCode_Graphics_W81\\Assets\\IcyBackground.dds")
	loadSprite("SomethingBlueBackground", "ProjectCode_Graphics_W81\\Assets\\SomethingBlueBackground.dds")
	loadSprite("Portal", "ProjectCode_Graphics_W81\\Assets\\Portal.dds")
	loadSprite("GroundLightBlue", "ProjectCode_Graphics_W81\\Assets\\GroundLightBlue.dds")
	loadSprite("GroundLightRed", "ProjectCode_Graphics_W81\\Assets\\GroundLightRed.dds")
	loadSprite("ThinkingBubble", "ProjectCode_Graphics_W81\\Assets\\ThinkingBubble.dds")
	loadSprite("Text01", "ProjectCode_Graphics_W81\\Assets\\Text01.dds")
	loadSprite("Text02", "ProjectCode_Graphics_W81\\Assets\\Text02.dds")
	loadSprite("Text03", "ProjectCode_Graphics_W81\\Assets\\Text03.dds")

	-- Main menu textures
	loadSprite("MainMenuBackground", "ProjectCode_Graphics_W81\\Assets\\MainMenuBackground.dds")
	loadSprite("StartButton", "ProjectCode_Graphics_W81\\Assets\\StartButton.dds")
	loadSprite("OptionsButton", "ProjectCode_Graphics_W81\\Assets\\OptionsButton.dds")
	loadSprite("CreditsButton", "ProjectCode_Graphics_W81\\Assets\\CreditsButton.dds")
	loadSprite("Credits", "ProjectCode_Graphics_W81\\Assets\\Credits.dds")
	loadSprite("BackButton", "ProjectCode_Graphics_W81\\Assets\\GoBack.dds")
	loadSprite("Level1Button", "ProjectCode_Graphics_W81\\Assets\\Level1Button.dds")
	loadSprite("Level2Button", "ProjectCode_Graphics_W81\\Assets\\Level2Button.dds")
	loadSprite("Level3Button", "ProjectCode_Graphics_W81\\Assets\\Level3Button.dds")
	loadSprite("Level4Button", "ProjectCode_Graphics_W81\\Assets\\Level4Button.dds")
	loadSprite("Logotype", "ProjectCode_Graphics_W81\\Assets\\QuantasticLogo.dds")
	loadSprite("SoundVolume", "ProjectCode_Graphics_W81\\Assets\\SoundVolumeText.dds")
	loadSprite("Pause", "ProjectCode_Graphics_W81\\Assets\\Pause.dds")
	loadSprite("Resume", "ProjectCode_Graphics_W81\\Assets\\ResumeButton.dds")
	loadSprite("Quit", "ProjectCode_Graphics_W81\\Assets\\QuitButton.dds")

	-- load sounds
	--loadSound("HipHoppy", "ProjectCode_Graphics_W81\\Assets\\hiphoppy_adpcm.wav")
	loadSound("Jump", "ProjectCode_Graphics_W81\\Assets\\Jump.wav")
	loadSound("MenuButton", "ProjectCode_Graphics_W81\\Assets\\MenuButton.wav")
	loadSound("TimeTravel", "ProjectCode_Graphics_W81\\Assets\\TimeTravel.wav")

	background(0.0)
	startScript("mainMenu")

	monitorVariable("fps")

end

-- Called before every frame is rendered.
function Update(dt)
	
	fpsCounter = fpsCounter + 1
	fpsTimer = fpsTimer + dt
	if fpsCounter > fpsPeriod then
		fps = 1 / (fpsTimer / fpsPeriod)
		fpsTimer = 0
		fpsCounter = fpsCounter - fpsPeriod
	end

end

-- Called after the script has ended.
function Stop()
	
end