
local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local Run=game:GetService('RunService')
local GuiService=game:GetService('GuiService')
local p=Players.LocalPlayer
local remote=game:GetService('ReplicatedStorage'):WaitForChild('AbismoEvent')
local impulse=Instance.new('BindableEvent'); impulse.Name='AbismoCameraImpulse'; impulse.Parent=script.Parent
local yaw,pitch=0,-.17
local smoothYaw,smoothPitch=yaw,pitch
local zoom,zoomNow=11,11
local shoulder,shoulderNow=0,0
local focus,character,humanoid,root
local fadeParts={}
local descendantConnection
local cursorFree,menuOpen,focused=false,false,true
local reduced=true
local kick,shake,land=0,0,0
local stick=Vector2.zero
local touch,lastTouch
local sprinting=false
local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.RespectCanCollide=true
local function sprint(value)
 if sprinting==value then return end
 sprinting=value; remote:FireServer('sprint',value)
end
local function setCharacter(c)
 character=c; humanoid=c:WaitForChild('Humanoid'); root=c:WaitForChild('HumanoidRootPart')
 params.FilterDescendantsInstances={c}; focus=nil; sprinting=false
 if descendantConnection then descendantConnection:Disconnect() end
 fadeParts={}
 local function cachePart(v) if v:IsA('BasePart') or v:IsA('Decal') then table.insert(fadeParts,v) end end
 for _,v in c:GetDescendants() do cachePart(v) end
 descendantConnection=c.DescendantAdded:Connect(cachePart)
 yaw=math.atan2(-root.CFrame.LookVector.X,-root.CFrame.LookVector.Z); smoothYaw=yaw
 kick=0; shake=0
 humanoid.StateChanged:Connect(function(_,state)
  if state==Enum.HumanoidStateType.Landed then land=.13; kick=math.max(kick,1.2) end
 end)
end
p.CharacterAdded:Connect(setCharacter)
if p.Character then task.spawn(setCharacter,p.Character) end
impulse.Event:Connect(function(kind)
 if kind=='dodge' then kick=math.max(kick,5)
 elseif kind=='punch' then shake=math.max(shake,.06)
 elseif kind=='spear' then kick=math.max(kick,3); shake=math.max(shake,.09)
 elseif kind=='nova' then kick=math.max(kick,2); shake=math.max(shake,.12)
 elseif kind=='heal' then kick=math.max(kick,1) end
end)
GuiService.MenuOpened:Connect(function() menuOpen=true; sprint(false) end)
GuiService.MenuClosed:Connect(function() menuOpen=false end)
UIS.WindowFocusReleased:Connect(function() focused=false; sprint(false) end)
UIS.WindowFocused:Connect(function() focused=true end)
UIS.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.LeftAlt then cursorFree=not cursorFree end
 if input.KeyCode==Enum.KeyCode.V then shoulder=-shoulder end
 if input.KeyCode==Enum.KeyCode.M then reduced=not reduced end
 if input.KeyCode==Enum.KeyCode.LeftControl or input.KeyCode==Enum.KeyCode.RightControl then sprint(true) end
 if input.UserInputType==Enum.UserInputType.Touch and input.Position.X>workspace.CurrentCamera.ViewportSize.X*.5 then touch=input; lastTouch=input.Position end
end)
UIS.InputEnded:Connect(function(input)
 if input.KeyCode==Enum.KeyCode.LeftControl or input.KeyCode==Enum.KeyCode.RightControl then sprint(false) end
 if input==touch then touch=nil; lastTouch=nil end
end)
UIS.InputChanged:Connect(function(input,processed)
 if input.UserInputType==Enum.UserInputType.MouseMovement and not cursorFree and not menuOpen and not p:GetAttribute('SpellbookOpen') and focused and not UIS:GetFocusedTextBox() then
  yaw=yaw-input.Delta.X*.003; pitch=math.clamp(pitch-input.Delta.Y*.003,-1.05,.5)
 elseif input.UserInputType==Enum.UserInputType.MouseWheel and not processed then zoom=math.clamp(zoom-input.Position.Z*1.25,6,17)
 elseif input.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(input.Position.X,input.Position.Y)
 elseif input==touch and lastTouch then
  local delta=input.Position-lastTouch; lastTouch=input.Position
  yaw=yaw-delta.X*.004; pitch=math.clamp(pitch-delta.Y*.004,-1.05,.5)
 end
end)
local hud=Instance.new('ScreenGui'); hud.Name='CameraControls'; hud.ResetOnSpawn=false; hud.Parent=p:WaitForChild('PlayerGui')
local function button(name,y)
 local b=Instance.new('TextButton'); b.Name=name; b.Size=UDim2.new(.17,0,0,28); b.Position=UDim2.new(.8,0,0,y); b.BackgroundColor3=Color3.fromRGB(18,25,39); b.BackgroundTransparency=.15; b.TextColor3=Color3.fromRGB(185,212,239); b.Font=Enum.Font.Gotham; b.TextSize=12; b.Parent=hud; Instance.new('UICorner',b).CornerRadius=UDim.new(0,8); return b
end
local motion=button('Motion',47); motion.Activated:Connect(function() reduced=not reduced end)
local switch=button('Shoulder',80); switch.Text='Stable centered camera'; switch.Active=false
local runButton=button('Sprint',113); runButton.Text='CTRL · Sprint'; runButton.Activated:Connect(function() sprint(not sprinting) end)
local dot=Instance.new('Frame'); dot.Name='AimDot'; dot.AnchorPoint=Vector2.new(.5,.5); dot.Size=UDim2.fromOffset(4,4); dot.Position=UDim2.fromScale(.5,.5); dot.BackgroundColor3=Color3.fromRGB(220,240,255); dot.BorderSizePixel=0; dot.Parent=hud; Instance.new('UICorner',dot).CornerRadius=UDim.new(1,0)
local elapsed=0
Run:BindToRenderStep('AbismoActionCamera',Enum.RenderPriority.Camera.Value+1,function(dt)
 dt=math.min(dt,.1)
 local camera=workspace.CurrentCamera
 if not root or not root.Parent or not humanoid or not camera then return end
 local unlocked=cursorFree or menuOpen or not focused or p:GetAttribute('SpellbookOpen')==true or UIS:GetFocusedTextBox()~=nil
 if p:GetAttribute('CameraCursorFree')~=unlocked then p:SetAttribute('CameraCursorFree',unlocked) end
 if UIS.MouseEnabled then UIS.MouseBehavior=unlocked and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter; UIS.MouseIconEnabled=unlocked end
 dot.Visible=not unlocked
 camera.CameraType=Enum.CameraType.Scriptable
 if not unlocked then yaw=yaw-stick.X*2.5*dt; pitch=math.clamp(pitch+stick.Y*2*dt,-1.05,.5) end
 local alpha=1-math.exp(-18*dt)
 smoothYaw=smoothYaw+(yaw-smoothYaw)*alpha; smoothPitch=smoothPitch+(pitch-smoothPitch)*alpha
 shoulderNow=shoulderNow+(shoulder-shoulderNow)*(1-math.exp(-10*dt))
 zoomNow=zoomNow+(zoom-zoomNow)*(1-math.exp(-12*dt))
 local desiredFocus=root.Position+Vector3.new(0,1.8,0)
 if not focus or (desiredFocus-focus).Magnitude>30 then focus=desiredFocus else focus=focus:Lerp(desiredFocus,1-math.exp(-18*dt)) end
 if humanoid.Health>0 then humanoid.AutoRotate=true end
 local rotation=CFrame.fromOrientation(smoothPitch,smoothYaw,0)
 local desired=focus+rotation:VectorToWorldSpace(Vector3.new(shoulderNow,.1,zoomNow))
 local anchor=root.Position+Vector3.new(0,1.8,0)
 local delta=desired-anchor
 local hit=delta.Magnitude>.01 and workspace:Spherecast(anchor,.45,delta,params)
 local position=hit and anchor+delta.Unit*math.max(.5,hit.Distance-.15) or desired
 local fadeAmount=math.clamp((3.5-(position-anchor).Magnitude)/2,0,1)
 for _,part in fadeParts do if part.Parent then part.LocalTransparencyModifier=fadeAmount end end
 local aim=focus+rotation.LookVector*7
 local speed=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude
 local targetFov=reduced and 72 or 72+math.clamp(speed/28,0,1)*5+kick
 camera.FieldOfView=camera.FieldOfView+(targetFov-camera.FieldOfView)*(1-math.exp(-8*dt))
 local t=os.clock(); local strength=reduced and 0 or shake
 local offset=Vector3.new(math.noise(t*28,0)*strength,math.noise(0,t*28)*strength-land*(reduced and 0 or 1),0)
 local roll=0
 camera.CFrame=CFrame.lookAt(position,aim)*CFrame.new(offset)*CFrame.Angles(0,0,roll)
 camera.Focus=CFrame.new(focus)
 kick=kick*math.exp(-7*dt); shake=shake*math.exp(-10*dt); land=land*math.exp(-10*dt)
 elapsed=elapsed+dt
 if elapsed>.2 then elapsed=0; motion.Text=reduced and 'M · Reduced motion: ON' or 'M · Reduced motion: OFF'; runButton.Text=sprinting and 'CTRL · Sprinting' or 'CTRL · Sprint' end
end)

