
transitionCurrentTime = 0
transitionTimeTotal = nil
transitionOffsetTotal = nil
transitionSpeed = nil
transitionFinished = false
enablePhysics = false
scenePosY = nil

restitutionC = 0.3
frictionC = 0.4
mass = 1.0
numberOfRigidBodies = 9
rigidBody = {}    -- new array
rigidBodyPosY = {}
for i=1, numberOfRigidBodies do
	rigidBody[i] = nil
end


-- Called after the script has started.
function Start(transitionTime, transitionOffset, transitionSpeedArg)
	
	info("started")
	transitionCurrentTime = 0
	transitionFinished = false
	transitionTimeTotal = tonumber(transitionTime)
	transitionOffsetTotal = tonumber(transitionOffset)
	transitionSpeed = tonumber(transitionSpeedArg)
	scenePosY = 0
	
	updateAmbientLight(1.0, 1.0, 1.0)
	setPhysicsFlowOfTime(0.8)
	
	rigidBodyPosY[1] = 0.0
	rigidBody[1] = rigidbody.addRectangle("DEMO", false, restitutionC, frictionC, mass, 3.0, 1.5, -2.5, rigidBodyPosY[1], 0.0)
	
	extraRectangleXSize = 120
	xSize = 6.0
	xOffset = -4.0
	rigidBodyPosY[2] = 2.0
	xOffset = xOffset + xSize*(extraRectangleXSize/774.0)*0.5
	rigidBody[2] = rigidbody.addRectangle("rectangle", true, restitutionC, frictionC, mass, xSize*(extraRectangleXSize/774.0), 1.0, xOffset, rigidBodyPosY[2], 0.0)
	xOffset = xOffset + xSize*(extraRectangleXSize/774.0)*0.5
	
	rigidBodyPosY[3] = 2.0
	xOffset = xOffset + xSize*(208.0/774.0)*0.5
	rigidBody[3] = rigidbody.addRectangle("Thank", true, restitutionC, frictionC, mass, xSize*(208.0/774.0), 1.0, xOffset, rigidBodyPosY[3], 0.0)
	xOffset = xOffset + xSize*(208.0/774.0)*0.5
	
	rigidBodyPosY[4] = 2.0
	xOffset = xOffset + xSize*(137.0/774.0)*0.5
	rigidBody[4] = rigidbody.addRectangle("you", true, restitutionC, frictionC, mass, xSize*(137.0/774.0), 1.0, xOffset, rigidBodyPosY[4], 0.0)
	xOffset = xOffset + xSize*(137.0/774.0)*0.5
	
	rigidBodyPosY[5] = 2.0
	xOffset = xOffset + xSize*(109.0/774.0)*0.5
	rigidBody[5] = rigidbody.addRectangle("for", true, restitutionC, frictionC, mass, xSize*(109.0/774.0), 1.0, xOffset, rigidBodyPosY[5], 0.0)
	xOffset = xOffset + xSize*(109.0/774.0)*0.5
	
	rigidBodyPosY[6] = 2.0
	xOffset = xOffset + xSize*(163.0/774.0)*0.5
	rigidBody[6] = rigidbody.addRectangle("your", true, restitutionC, frictionC, mass, xSize*(163.0/774.0), 1.0, xOffset, rigidBodyPosY[6], 0.0)
	xOffset = xOffset + xSize*(163.0/774.0)*0.5
	
	rigidBodyPosY[7] = 2.0
	xOffset = xOffset + xSize*(157.0/774.0)*0.5
	rigidBody[7] = rigidbody.addRectangle("time", true, restitutionC, frictionC, mass, xSize*(157.0/774.0), 1.0, xOffset, rigidBodyPosY[7], 0.0)
	xOffset = xOffset + xSize*(157.0/774.0)*0.5
	
	rigidBodyPosY[8] = 2.0
	xOffset = xOffset + xSize*(extraRectangleXSize/774.0)*0.5
	rigidBody[8] = rigidbody.addRectangle("rectangle", true, restitutionC, frictionC, mass, xSize*(extraRectangleXSize/774.0), 1.0, xOffset, rigidBodyPosY[8], 0.0)
	xOffset = xOffset + xSize*(extraRectangleXSize/774.0)*0.5
	
	-- QR
	rigidBodyPosY[9] = -1.5
	rigidBody[9] = rigidbody.addRectangle("QR", false, restitutionC, frictionC, mass, 0.72*2.0, 2.0, 3.0, rigidBodyPosY[9], 0.0)
	
end

-- Called before every frame is rendered.
function Update(dt)
	
	if (not transitionFinished) then
		transitionCurrentTime = transitionCurrentTime + dt
		scenePosY = scenePosY + transitionSpeed*math.abs(math.abs(transitionOffsetTotal) - math.abs(scenePosY))*dt
		
		for i=1, numberOfRigidBodies do
			posX, posY, rot = rigidbody.getPositionOrientation(rigidBody[i])
			rigidbody.updatePositionOrientation(rigidBody[i], posX, scenePosY + rigidBodyPosY[i] - transitionOffsetTotal, rot)
		end
		
		if (transitionCurrentTime >= transitionTimeTotal) then transitionFinished = true end
		
	elseif (enablePhysics) then
		currentTime, flowOfTime = physics.getTimeValues()
	
		-- Apply gravity
		for i=1, numberOfRigidBodies do rigidbody.addForce(rigidBody[i], 0.0, -9.0) end
	end
end

-- Called after the script has ended.
function Stop()
	
	for i=1, numberOfRigidBodies do
		removeRigidBody(rigidBody[i])
	end
	info("stopped")
	
end

-- Called when user touches the screen.
function OnInput(type, coordX, coordY)
	
	if ((type == inputTypeUp) and (not enablePhysics) and (transitionFinished)) then
		enablePhysics = true
		info("physics enabled")
	end	
end
