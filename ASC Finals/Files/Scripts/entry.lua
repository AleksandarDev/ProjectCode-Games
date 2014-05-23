
transitionTimeTotal = 2.0
transitionOffsetTotal = 14
transitionSpeed = 4.0

-- Called after the script has started.
function Start()
  
  graphics.background(1.0)
  camera.update(0, 0, 5.3)
  
  script.start("s_01", transitionTimeTotal, transitionOffsetTotal, transitionSpeed)
end

-- Called before every frame is rendered.
function Update(dt)
  

end

-- Called after the script has ended.
function Stop()

end
