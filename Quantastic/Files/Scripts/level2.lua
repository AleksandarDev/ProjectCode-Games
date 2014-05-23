
actorIndices = {}    -- new array

ledgeRigidBody = nil
numberOfRigidBodies = 13
rigidBody = {}    -- new array
for i=1, numberOfRigidBodies do
	rigidBody[i] = nil
end

-- Called after the script has started.
function Start()

	isLevelCompleted = false
	isLevelFailed = false
	levelOverTimer = 0.0
	levelOverWaitTime = 1.0
	info("Level2 started")

	-- Set up the scene
	background(0.0)
	setGrayscaleColor(1.0, 1.0, 1.0, 0.0)
	backgroundSprite1 = addSprite("WateryBackground", 0.0, 0.0, -2.0, 25.0, 25.0, 0.0, shadowTypeRectangle) -- add 2 tileable background sprites
	backgroundSprite2 = addSprite("WateryBackground", 25.0, 0.0, -2.0, 25.0, 25.0, 0.0, shadowTypeRectangle)
	portalX = 17.5
	portalY = -8.7
	portalSprite = addSprite("Portal", portalX, portalY, -0.1, 1.2, 1.4, 0.0, shadowTypeNone) -- portal

	restitutionC = 0.3
	frictionC = 0.7
	-- spriteName, isMovable, restitutionC, frictionC, mass, sizeX, sizeY, posX, posY, orientation
	rigidBody[1] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 15.0, 48.0, -6.0, -25.5, 0.0)
	rigidBody[2] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 7.0, 48.0, 8.8, -25.0, 0.0)
	rigidBody[3] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 20.0, 50.0, -15.0, 0.0, 0.0)
	rigidBody[4] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 1.0, 4.0, -5.0, 2.0, 0.0)
	rigidBody[5] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 4.0, 1.0, -1.0, -1.5, 0.0)
	rigidBody[6] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 4.0, 10.0, 3.5, -14.0, 0.0) -- pitfall ground
	rigidBody[7] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 7.0, 5.0, 17.0, -3.5, 0.0)
	rigidBody[8] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 20.0, 35.0, 17.0, -27.0, 0.0)
	rigidBody[9] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 15.0, 25.0, 26.0, -8.0, 0.0)
	rigidBody[10] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 5.0, 19.0, 0.0, 0.0)
	rigidBody[11] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 4.0, 0.4, 18.0, -9.4, 0.0)
	rigidBody[12] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 4.0, 0.8, 16.7, -6.0, 0.0)
	rigidBody[13] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 0.9, 2.0, 12.5, -9.0, 0.0)

	ledgeRigidBody = addRectangleRigidBody("DarkerGray", true, restitutionC, frictionC, 2.0, 0.5, 4.0, 9.5, 1.0, 0.0)

	updateAmbientLight(0.6, 0.6, 0.6)
	updateLightSource(0, 1.0, 1.0, 1.0, directionalLight, -0.2, 0.2, 0.2)
	setPhysicsFlowOfTime(1.0)

	-- Call in the player character
	currentActor = 0
	startScript("playerCharacters", "level2", -4.0, -1.0, portalX, portalY, 0)

	-- pitfall goes last (alpha blending)
	pitfallX = 3.4
	pitfallY = -8.5
	pitfallSprite1 = addSprite("GroundLightRed", pitfallX, pitfallY, -0.1, 4.0, 1.3, 0.0, shadowTypeNone) -- pitfall
	pitfallSprite2 = addSprite("GroundLightRed", pitfallX, pitfallY - 0.25, 0.01, 3.8, 0.5, 0.0, shadowTypeNone)

	-- Set text
	textSprite = addSprite("Text02", 8.1, -1.5, 0.01, 6.0, 1.5, 0.0, shadowTypeNone)
end

-- Called before every frame is rendered.
function Update(dt)

	currentTime, flowOfTime = getPhysicsTimeValues()
	if ((not isLevelCompleted) and (not isLevelFailed)) then
		-- Apply gravity
		if (flowOfTime > 0.0) then
			addForceOnRigidBody(ledgeRigidBody, 0.0, -9.0*2.0)
			for i=1, currentActor do addForceOnRigidBody(actorIndices[i], 0.0, -9.0) end
		end

		for i=1, currentActor do
			x, y, orientation = getRigidBodyPositionAndOrientation(actorIndices[i])
			-- Is level complete?
			if ((math.abs(x - portalX) < 0.5) and (math.abs(y - portalY) < 0.5)) then
				isLevelCompleted = true
				info("Level2 completed.")
				stopScript("playerCharacters")
				break
			end
			-- Did someone fall into pitfall
			if ((math.abs(x - pitfallX) < 4.0) and (math.abs(y - pitfallY + 0.5) < 0.5)) then
				isLevelFailed = true
				info("Level2 failed.")
				stopScript("playerCharacters")
				break
			end
		end
	else
		levelOverTimer = levelOverTimer + dt
		setGrayscaleColor(0.0, 0.0, 0.0, levelOverTimer/levelOverWaitTime)
		if (levelOverTimer >= levelOverWaitTime) then
			if (isLevelFailed) then -- go to next level
				stopScript("level2")
				startScript("level2")
			elseif (isLevelCompleted) then
				stopScript("level2")
				lastLevel, volume = loadSettings()
				if (lastLevel < 3) then saveSettings(3, volume) info("Level3 saved as last level.") end
				startScript("level3")
			end
		end
	end
end

-- Called after the script has ended.
function Stop()
	for i=1, numberOfRigidBodies do
		removeRigidBody(rigidBody[i])
	end
	removeRigidBody(ledgeRigidBody)

	removeSprite(portalSprite)
	removeSprite(pitfallSprite1)
	removeSprite(pitfallSprite2)
	removeSprite(textSprite)
	removeSprite(backgroundSprite1)
	removeSprite(backgroundSprite2)
end

-- Called when other scrpit is trying to send data via sendToScript(..)
function ReceiveMessage(callerScript, charIndex)
	if (tonumber(charIndex) > 0) then
		currentActor = currentActor + 1
		actorIndices[currentActor] = charIndex
	else
		isLevelFailed = true
		info("Level2 failed.")
		stopScript("playerCharacters")
	end
end