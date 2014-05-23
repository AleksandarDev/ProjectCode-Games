
--------------------------------------------------------------------------------------
--- BrainAI class definition
--------------------------------------------------------------------------------------

brainAI = class(nil)

function brainAI:init(ownerRigidBodyIndex, x, y)
	self.bodyIndex = ownerRigidBodyIndex
	self.timer = 0.0
	self.nextUpdate = 2.0 + math.random()*2.0
	self.isDisplayingThinkBubble = false
	self.thinkBubbleTimer = 0.0
	self.thinkBubbleSpriteIndex = nil
	self.targetX = x
	self.wantsToJump = false
	self.canSeeThePortal = false
end

function brainAI:checkIfThereIsSpaceToMove(wantsToMove, x, y, sizeX, sizeY)
	index, distanceHorizontal = lineIntersection(x, y + sizeY/2.0, wantsToMove, 0.0, self.bodyIndex)
	if ((distanceHorizontal < 0.0) or (distanceHorizontal > (math.abs(wantsToMove) + sizeX/2.0))) then	-- is there space to the right
		index, distanceVertical = lineIntersection(x + wantsToMove, y + sizeY/2.0, 0.0, -1.0, self.bodyIndex)
		if ((distanceVertical > 0.0) and (distanceVertical < (sizeY*2.0 + 0.2))) then -- get point on the ground
			targetPosYOnGround = y + sizeY/2.0 - distanceVertical
			index, distanceForHeightCheck = lineIntersection(x + wantsToMove, targetPosYOnGround, 0.0, 1.0, index)
			if ((distanceForHeightCheck < 0.0) or (distanceForHeightCheck > sizeY)) then -- is there space for my height
				self.targetX = x + wantsToMove
			end
		end
	end
end

function brainAI:update(dt, x, y, velX, velY, sizeX, sizeY, maxMove, mass)

	-- Can I see the portal?
	index, distanceToObstacle = lineIntersection(x, y + sizeY/4.0, portalPosX - x, portalPosY - y, self.bodyIndex)
	distanceToPortal = math.sqrt((portalPosX - x)*(portalPosX - x) + (portalPosY - y)*(portalPosY - y))
	if (distanceToPortal < distanceToObstacle) then	
		self.canSeeThePortal = true
		wantsToMove = (portalPosX - x) / math.abs(portalPosX - x) * 0.8
		local prevTarget = self.targetX
		self:checkIfThereIsSpaceToMove(wantsToMove, x, y, sizeX, sizeY)
		if (prevTarget == self.targetX) then -- try again if no success, but with smaller steps
			self:checkIfThereIsSpaceToMove(wantsToMove*0.8, x, y, sizeX, sizeY) end 
	else
		self.canSeeThePortal = false
	end
	
	-- Should I do something new?
	self.timer = self.timer + dt
	if ((self.timer >= self.nextUpdate) and (not self.canSeeThePortal)) then
		self.timer = 0.0
		self.nextUpdate = 2.0 + math.random()*2.0

		-- Decide what to do
		local action = math.random()
		if ((action < 0.2) and (not self.isDisplayingThinkBubble)) then -- Display bubble
			info("AI: adding think bubble.")
			self.isDisplayingThinkBubble = true
			self.thinkBubbleSpriteIndex = addSprite("ThinkingBubble", x, y, 0.1, 1.0, 1.0, 0.0, shadowTypeNone)
		elseif ((action > 0.2) and (action < 0.9)) then -- Change position
			wantsToMove = math.random()*1.0 + 0.5
			if (math.random() < 0.5) then wantsToMove = wantsToMove*(-1.0) end
			self:checkIfThereIsSpaceToMove(wantsToMove, x, y, sizeX, sizeY)
		end
	end

	-- Make sure I am at targetX
	local move = self.targetX - x
	local moveDirection = move/math.abs(move)
	if (math.abs(move) < 0.05) then
		move = 0.0
	elseif (math.abs(move) > maxMove) then
		move = moveDirection * maxMove
	end
	local neededForce = 0.0
	if (move == 0.0) then
		neededForce = 0.3 * (-velX)*mass / dt -- velocity killer
	elseif ((math.abs(velX) < math.abs(move)) or (velX*move < 0.0)) then
		neededForce = move * mass * 4.0
	end
	addForceOnRigidBody(self.bodyIndex, neededForce, 0.0)

	-- Do I need to jump?
	local jumpScan = math.abs(move)
	if (jumpScan > 0.9) then jumpScan = 0.9 end
	index, distance = lineIntersection(x, y - sizeY/4.0, moveDirection, 0.0, self.bodyIndex)
	if ((distance > 0.0) and (distance < math.abs(jumpScan))) then
		self.wantsToJump = true
	end

	-- Update think bubble if needed
	if (self.isDisplayingThinkBubble) then
		self.thinkBubbleTimer = self.thinkBubbleTimer + dt
		if (self.thinkBubbleTimer > 4.0) then
			self.thinkBubbleTimer = 0.0
			self.isDisplayingThinkBubble = false
			info("AI: removing think bubble.")
			removeSprite(self.thinkBubbleSpriteIndex)
		else
			updateSprite(self.thinkBubbleSpriteIndex, x + 0.5, y + 0.8, 1.0, 1.0, 0.0)
		end 
	end
end

function brainAI:dispose()
	if (self.isDisplayingThinkBubble) then
		removeSprite(self.thinkBubbleSpriteIndex)
		info("AI: removing think bubble.")
	end
end

--------------------------------------------------------------------------------------
--- Actor class definition
--------------------------------------------------------------------------------------

actor = class(nil)

function actor:init(posX, posY)
	self.mass = 1.0	
	self.x = posX
	self.y = posY
	self.sizeX = 0.7
	self.sizeY = 0.9
	self.index = addRectangleRigidBody("PlayerCharacter", true, 0.0, 0.0, self.mass, self.sizeX, self.sizeY, posX, posY, 0.0)
	enableRotationRigidBody(self.index, false)
	self.orientation = 0.0
	self.lastJumpTimer = 0.0
	self.move = 0.0
	self.maxMove = 3.5
	self.AITookOver = false
	self.brain = brainAI(self.index, self.x, self.y)

end

function actor:update(dt)

	self.x, self.y, self.orientation = getRigidBodyPositionAndOrientation(self.index)
	velX, velY, rotation = getRigidBodyVelocity(self.index)
	movementType = getRigidBodyMovementType(self.index)

	if (not self.AITookOver) then
		-- Moving left and right
		neededForce = 0.0
		if (self.move == 0.0) then
			neededForce = 0.3 * (-velX)*self.mass / dt -- velocity killer
		elseif ((math.abs(velX) < math.abs(self.move)) or (velX*self.move < 0.0)) then
			neededForce = self.move * self.mass * 4.0
		end
		addForceOnRigidBody(self.index, neededForce, 0.0)
		self.brain.targetX = self.x

		elseif(movementType == rigidBodyIsAnimating) then -- do not update AI while there is animation to play first
			self.brain.targetX = self.x
			if (self.brain.isDisplayingThinkBubble) then
				removeSprite(self.brain.thinkBubbleSpriteIndex)
			end
		elseif (movementType == rigidBodyIsSimulating) then
			self.brain:update(dt, self.x, self.y, velX, velY, self.sizeX, self.sizeY, self.maxMove, self.mass)
	end	
	
	index, distance = lineIntersection(self.brain.targetX, self.y, 0.0, -1.0, self.index)


	-- Jumping
	self.lastJumpTimer = self.lastJumpTimer + dt
	if (self.brain.wantsToJump and self.lastJumpTimer > 0.3) then
		local jumped = rigidBodyJumpIfPossible(self.index, 0.0, 5.5)
		if (jumped) then setSoundState("Jump", soundStatePlayOnce, 0.25) end
		self.brain.wantsToJump = false
		self.lastJumpTimer = 0.0
	end
end

function actor:onInput(type, worldX, worldY)

	local lastCursorRelPosX = x - self.x
	local lastCursorRelPosY = y - self.y

	if (type == inputTypeUp) then
		lastCursorRelPosX = 0.0
		lastCursorRelPosY = 0.0
		self.brain.wantsToJump = false
	end
	
	self.move = lastCursorRelPosX
	if (lastCursorRelPosX > self.maxMove) then
		self.move = self.maxMove
	end
	if (lastCursorRelPosX < -self.maxMove) then
		self.move = -self.maxMove
	end
	if (math.abs(lastCursorRelPosX) < 0.5) then
		self.move = 0.0
	end

	--local cursorLength = math.sqrt(lastCursorRelPosX*lastCursorRelPosX + lastCursorRelPosY*lastCursorRelPosY)
	--local angle = math.acos(lastCursorRelPosY / cursorLength)
	if (lastCursorRelPosY > 1.2) then
		self.brain.wantsToJump = true
	end

end

function actor:startBrain()
	self.AITookOver = true
end

function actor:dispose()
	removeRigidBody(self.index)

	self.brain:dispose()
end


--------------------------------------------------------------------------------------
-- Script functions
--------------------------------------------------------------------------------------

callerScriptName = nil
portalPosX = nil
portalPosY = nil
timeTravelHold = 0.0
timeTravelHoldMax = 1.0
tryingToTimeTravel = false
timeTraveling = false
canTimeTravel = nil
actorProjectionSpriteIndex = -1
actorProjectionPosX = nil
actorProjectionPosY = nil
maxNumberOfClones = 2
currentActor = 1
actors = {}    -- new array
for i=1, maxNumberOfClones do
	actors[i] = nil
end

-- Called after the script has started.
function Start(callerScriptNameArg, posX, posY, portalPosXArg, portalPosYArg, canTimeTravelArg)
	
	timeSinceLastUp = 0.0
	timeSinceLastDown = 0.0
	isInMenu = false
	portalPosX = portalPosXArg
	portalPosY = portalPosYArg
	canTimeTravel = tonumber(canTimeTravelArg)
	callerScriptName = callerScriptNameArg
	currentActor = 1
	actorProjectionSpriteIndex = -1
	--math.randomseed(os.time()) -- NERADI!! :s
	actors[currentActor] = actor(posX, posY)
	sendToScript(callerScriptName, actors[currentActor].index)
	clonesVisibility = 0.0
	clonesVisibilityAccumulator = 0.0
	clonesVisibilityAccumulatorMax = 0.5

end

-- Called before every frame is rendered.
function Update(dt)

	if (isInMenu) then
		--for i=1, currentActor do addForceOnRigidBody(actors[i].index, 0.0, 9.0) end -- cancel gravity from level
		return 
	end

	-- accumulate time
	if (tryingToTimeTravel) then
		timeTravelHold = timeTravelHold + dt
	else
		timeTravelHold = 0.0
	end

	-- calculate how much clones see each other
	if (currentActor > 1) then
		local directionX = actors[currentActor - 1].x - actors[currentActor].x
		local directionY = actors[currentActor - 1].y - actors[currentActor].y
		index, distance = lineIntersection(actors[currentActor].x, actors[currentActor].y, directionX, directionY, actors[currentActor].index)
		if (index == actors[currentActor - 1].index) then
			clonesVisibility = 1.0 / distance * dt
			if (clonesVisibility > 1.0) then clonesVisibility = 1.0 end
		else
			clonesVisibility = -0.5 * dt
		end
		
	end
	clonesVisibilityAccumulator = clonesVisibilityAccumulator + clonesVisibility
	if (clonesVisibilityAccumulator < 0.0) then
		clonesVisibilityAccumulator = 0.0
	elseif (clonesVisibilityAccumulator >= clonesVisibilityAccumulatorMax) then
		clonesVisibilityAccumulator = clonesVisibilityAccumulatorMax
	end

	-- offset camera based on clones visibility
	offsetX = 2.0*(math.random() - 0.5) * clonesVisibilityAccumulator/clonesVisibilityAccumulatorMax * 0.3
	offsetY = 2.0*(math.random() - 0.5) * clonesVisibilityAccumulator/clonesVisibilityAccumulatorMax * 0.3

	-- time travel related visual effect and camera control
	if (timeTraveling) then
		setGrayscaleColor(1.0, 1.0, 1.0, 1.0)
	else
		if (clonesVisibilityAccumulator == 0.0) then setGrayscaleColor(1.0, 1.0, 1.0, timeTravelHold/timeTravelHoldMax)
		else setGrayscaleColor(1.0, 0.5, 0.5, clonesVisibilityAccumulator/clonesVisibilityAccumulatorMax) end
		setPhysicsFlowOfTime(1.0 - timeTravelHold/timeTravelHoldMax)
		updateCamera(actors[currentActor].x + offsetX, actors[currentActor].y + 1.0 + offsetY, 7.0)
	end

	-- initiate time travel
	if ((timeTravelHold >= timeTravelHoldMax) and (not timeTraveling)) then
		tryingToTimeTravel = false
		setPhysicsFlowOfTime(-4.0)
		info("timeFlow: -1.0")
		timeTraveling = true
		setSoundState("TimeTravel", soundStatePlayLoop, 0.6)
		actorProjectionPosX = actors[currentActor].x
		actorProjectionPosY = actors[currentActor].y
		actorProjectionSpriteIndex = addSprite("PlayerCharacter", actorProjectionPosX, actorProjectionPosY, 0.0, actors[currentActor].sizeX, actors[currentActor].sizeY, 0.0, shadowTypeNone)
	end

	for i=1, currentActor do
		actors[i]:update(dt)
	end

	-- DoubleTap
	timeSinceLastDown = timeSinceLastDown + dt
	timeSinceLastUp = timeSinceLastUp + dt

	-- Signal if over
	if (clonesVisibilityAccumulator == clonesVisibilityAccumulatorMax) then
		sendToScript(callerScriptName, -1)
	end
end

-- Called after the script has ended.
function Stop()
	for i=1, currentActor do
		actors[i]:dispose()
	end
end

-- Called when user touches the screen.
function OnInput(type, coordX, coordY)
	x, y = transformFromScreenSpaceToWorld(coordX, coordY)
	
	if ((type == inputTypeDown) and (currentActor < maxNumberOfClones) and (math.abs(x - actors[currentActor].x) < 0.5) and (math.abs(y - actors[currentActor].y) < 0.5) and (canTimeTravel == 1)) then
		tryingToTimeTravel = true
	elseif (type == inputTypeUp and timeTraveling) then
		tryingToTimeTravel = false
		setPhysicsFlowOfTime(1.0)
		info("timeFlow: 1.0")
		timeTraveling = false
		removeSprite(actorProjectionSpriteIndex)
		actors[currentActor]:startBrain()
		setSoundState("TimeTravel", soundStateStop)
		currentActor = currentActor + 1
		actors[currentActor] = actor(actorProjectionPosX, actorProjectionPosY)
		sendToScript(callerScriptName, actors[currentActor].index)
	elseif (type == inputTypeUp) then
		tryingToTimeTravel = false
	end

	if ((math.abs(x - actors[currentActor].x) > 0.5) or (math.abs(y - actors[currentActor].y) > 0.5)) then
		tryingToTimeTravel = false
	end
	
	-- this only affects currently controled actor
	actors[currentActor]:onInput(type, x, y)
	
	-- DoubleTap?
	if ((type == inputTypeDown) and (timeSinceLastDown > 0) and (timeSinceLastDown < 0.2)) then
		startScript("pauseMenu", actors[currentActor].x, actors[currentActor].y, callerScriptName)
		setPhysicsFlowOfTime(0.0)
		isInMenu = true
	end
	if ((type == inputTypeDown) and (math.abs(x - actors[currentActor].x) < 0.5) and (math.abs(y - actors[currentActor].y) < 0.5)) then
		timeSinceLastDown = 0.0
	end
	if ((type == inputTypeUp) and (math.abs(x - actors[currentActor].x) < 0.5) and (math.abs(y - actors[currentActor].y) < 0.5)) then
		timeSinceLastUp = 0.0
	end
end

-- Called when other scrpit is trying to send data via sendToScript(..)
function ReceiveMessage()
	setPhysicsFlowOfTime(1.0)
	isInMenu = false
end