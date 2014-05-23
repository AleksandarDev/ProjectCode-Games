fpsCounter = 0
fpsTimer = 0
fpsPeriod = 10
fps = 0

-- Called after the script has started.
function Start()
	-- load sounds
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