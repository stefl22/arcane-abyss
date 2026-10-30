local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local RS=game:GetService('ReplicatedStorage')
local Tween=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local p=Players.LocalPlayer
local event=RS:WaitForChild('AbismoEvent')
local gui=Instance.new('ScreenGui'); gui.Name='AbismoHUD'; gui.ResetOnSpawn=false; gui.Parent=p:WaitForChild('PlayerGui')
local function text(parent,size,pos,value)
 local t=Instance.new('TextLabel'); t.Size=size; t.Position=pos; t.BackgroundColor3=Color3.fromRGB(17,19,32); t.BackgroundTransparency=.12; t.TextColor3=Color3.fromRGB(235,237,255); t.TextWrapped=true; t.Font=Enum.Font.GothamBold; t.TextSize=16; t.Text=value; t.Parent=parent
 local corner=Instance.new('UICorner',t); corner.CornerRadius=UDim.new(0,10); return t
end
local title=text(gui,UDim2.new(.42,0,0,32),UDim2.new(.29,0,0,8),'ARCANE ABYSS • AWAKENING')
local stats=text(gui,UDim2.new(.42,0,0,32),UDim2.new(.29,0,0,44),'Awakening your lineage…')
local message=text(gui,UDim2.new(.6,0,0,36),UDim2.new(.2,0,0,84),'')
local health=text(gui,UDim2.new(.28,0,0,26),UDim2.new(.36,0,1,-126),'')
local hint=text(gui,UDim2.new(.94,0,0,34),UDim2.new(.03,0,1,-42),'MOUSE Look  ·  CLICK Punch  ·  SHIFT Dodge  ·  CTRL Sprint  ·  ALT Cursor')
local slotsFrame=Instance.new('Frame',gui); slotsFrame.Size=UDim2.new(.7,0,0,48); slotsFrame.Position=UDim2.new(.15,0,1,-94); slotsFrame.BackgroundTransparency=1
local catalog=Instance.new('Frame',gui); catalog.Size=UDim2.new(.94,0,0,90); catalog.Position=UDim2.new(.03,0,1,-228); catalog.BackgroundTransparency=1; catalog.Visible=false; catalog.Name='Grimorio'
local grid=Instance.new('UIGridLayout',catalog); grid.CellSize=UDim2.new(1/6,-4,.5,-4); grid.CellPadding=UDim2.fromOffset(4,4)
local powers={'Arcane Spear','Frost Nova','Radiant Renewal','Flame Bolt','Arcane Wave','Aegis','Lightning Strike','Blizzard','Soul Drain','Solar Burst','Void Lance','Judgment'}
local selected={1,2,3,4}; local unlocked=4; local nextSlot=1; local ends={}; local buttons={}; local slotButtons={}; local keys={'Q','E','R','T'}
local queuedCast=0
local function requestCast(id)
 local remaining=(ends[id] or 0)-os.clock()
 if remaining>.16 then return end
 queuedCast=queuedCast+1; local token=queuedCast
 local function fire()
  if token~=queuedCast then return end
  local camera=workspace.CurrentCamera; local character=p.Character
  local root=character and character:FindFirstChild('HumanoidRootPart')
  if not camera or not root then return end
  local view=camera.ViewportSize
  local ray=camera:ViewportPointToRay(view.X*.5,view.Y*.5)
  local params=RaycastParams.new(); params.FilterDescendantsInstances={character}; params.RespectCanCollide=true
  local hit=workspace:Raycast(ray.Origin,ray.Direction*250,params)
  local aimPoint=hit and hit.Position or ray.Origin+ray.Direction*250
  local delta=aimPoint-(root.Position+Vector3.new(0,1,0))
  local direction=delta.Magnitude>.1 and delta.Unit or camera.CFrame.LookVector
  if id==1 or id==4 then
   local flat=Vector3.new(direction.X,0,direction.Z)
   if flat.Magnitude>.1 then root.CFrame=CFrame.lookAt(root.Position,root.Position+flat) end
  end
  event:FireServer('cast',{id=id,aim=direction})
 end
 if remaining>0 then task.delay(remaining+.015,fire) else fire() end
end

local function button(parent)
 local b=Instance.new('TextButton',parent); b.BackgroundColor3=Color3.fromRGB(44,39,75); b.TextColor3=Color3.new(1,1,1); b.TextSize=13; b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.TextWrapped=true
 local corner=Instance.new('UICorner',b); corner.CornerRadius=UDim.new(0,8); return b
end
for i=1,4 do
 local b=button(slotsFrame); b.Size=UDim2.new(1/4,-6,1,0); b.Position=UDim2.new((i-1)/4,3,0,0); b.Name='Power'..i; slotButtons[i]=b
 b.Activated:Connect(function() requestCast(selected[i]) end)
end
for id,name in ipairs(powers) do
 local b=button(catalog); b.LayoutOrder=id; buttons[id]=b
 b.Activated:Connect(function()
  if id>unlocked then message.Text='Descend to unlock this spell.'; return end
  for i,v in ipairs(selected) do if v==id then message.Text='Already equipped in '..keys[i]; return end end
  selected[nextSlot]=id; message.Text=name..' equipped in '..keys[nextSlot]; nextSlot=nextSlot%4+1
 end)
end
UIS.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.UserInputType==Enum.UserInputType.MouseButton1 then if not p:GetAttribute('CameraCursorFree') then event:FireServer('basic') end; return end
 if input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.RightShift then
  local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid'); event:FireServer('dodge',h and h.MoveDirection or Vector3.zero); return
 end
 if input.KeyCode==Enum.KeyCode.B then catalog.Visible=not catalog.Visible; p:SetAttribute('SpellbookOpen',catalog.Visible); return end
 local map={[Enum.KeyCode.Q]=1,[Enum.KeyCode.E]=2,[Enum.KeyCode.R]=3,[Enum.KeyCode.T]=4}; local i=map[input.KeyCode]; if i then requestCast(selected[i]) end
end)

local dodgeButton=button(gui); dodgeButton.Name='Dodge'; dodgeButton.Size=UDim2.new(.12,0,0,45); dodgeButton.Position=UDim2.new(.87,0,1,-94); dodgeButton.Text='SHIFT · DODGE'
dodgeButton.Activated:Connect(function() local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid'); event:FireServer('dodge',h and h.MoveDirection or Vector3.zero) end)
local attackButton=button(gui); attackButton.Name='BasicAttack'; attackButton.Size=UDim2.new(.12,0,0,45); attackButton.Position=UDim2.new(.01,0,1,-94); attackButton.Text='CLICK · PUNCH'
attackButton.Activated:Connect(function() event:FireServer('basic') end)
local book=button(gui); book.Size=UDim2.new(.17,0,0,32); book.Position=UDim2.new(.8,0,0,10); book.Text='B · SPELLBOOK'
book.Activated:Connect(function() catalog.Visible=not catalog.Visible; p:SetAttribute('SpellbookOpen',catalog.Visible) end)

local spellColors={Color3.fromRGB(160,145,255),Color3.fromRGB(170,245,255),Color3.fromRGB(110,255,160),Color3.fromRGB(255,115,35),Color3.fromRGB(185,120,255),Color3.fromRGB(100,200,255),Color3.fromRGB(255,245,150),Color3.fromRGB(190,250,255),Color3.fromRGB(220,80,190),Color3.fromRGB(255,195,75),Color3.fromRGB(155,80,255),Color3.fromRGB(255,240,190)}
local function orb(pos,size,color)
 local o=Instance.new('Part'); o.Shape=Enum.PartType.Ball; o.Size=Vector3.new(size,size,size); o.CFrame=CFrame.new(pos); o.Material=Enum.Material.Neon; o.Color=color; o.Anchored=true; o.CanCollide=false; o.CanQuery=false; o.CanTouch=false; o.Parent=workspace
 if size>=1 then local l=Instance.new('PointLight',o); l.Color=color; l.Range=14; l.Brightness=2 end; Debris:AddItem(o,2); return o
end

local function fade(o,duration,size)
 Tween:Create(o,TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1,Size=size or o.Size}):Play()
end
local function segment(a,b,color,width,life)
 local length=(b-a).Magnitude; if length<.01 then return end
 local o=orb((a+b)/2,.3,color); o.Shape=Enum.PartType.Block; o.Size=Vector3.new(width,width,length); o.CFrame=CFrame.lookAt((a+b)/2,b); fade(o,life); return o
end
local function circle(pos,radius,color,life,vertical)
 for i=1,24 do
  local a=(i-1)*math.pi/12; local b=i*math.pi/12
  local p1=vertical and Vector3.new(math.cos(a)*radius,math.sin(a)*radius,0) or Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
  local p2=vertical and Vector3.new(math.cos(b)*radius,math.sin(b)*radius,0) or Vector3.new(math.cos(b)*radius,0,math.sin(b)*radius)
  segment(pos+p1,pos+p2,color,.12,life)
 end
end
local function burst(pos,color,count,power)
 local flash=orb(pos,.6,Color3.fromRGB(230,230,255)); flash.Transparency=.3; fade(flash,.22,Vector3.new(power*.45,power*.45,power*.45))
 for i=1,count do
  local a=i*math.pi*2/count
  local shard=orb(pos,.35,color); shard.Shape=Enum.PartType.Block
  Tween:Create(shard,TweenInfo.new(.55),{Position=pos+Vector3.new(math.cos(a)*power,(i%3)-1,math.sin(a)*power),Transparency=1}):Play()
 end
end

-- Layer poses after Animator evaluation. Supports Motor6D and upgraded R15 joints.
local Run=game:GetService('RunService')
local poseCache=setmetatable({},{__mode='k'})
local poseRuns=setmetatable({},{__mode='k'})
local function actionPose(character,frames)
 if not character then return end
 local cache=poseCache[character]
 if not cache then
  cache={}
  for _,j in ipairs(character:GetDescendants()) do
   if j:IsA('AnimationConstraint') or j:IsA('Motor6D') then
    cache[j.Name:gsub(' ',''):lower()]={joint=j,axes=j.C0.Rotation,current=CFrame.identity}
   end
  end
  poseCache[character]=cache
 end
 local initial={}
 for name,entry in pairs(cache) do initial[name]=entry.current end
 poseRuns[character]={frames=frames,start=os.clock(),initial=initial}
end
Run.PreAnimation:Connect(function()
 for character,cache in pairs(poseCache) do
  for _,entry in pairs(cache) do
   if entry.applied and entry.joint.Parent then entry.joint.Transform=entry.baseFrame; entry.applied=false end
  end
  if not character.Parent then poseCache[character]=nil; poseRuns[character]=nil end
 end
end)

local movementLean=CFrame.identity
local function cacheCharacter(character)
 task.spawn(function()
  character:WaitForChild('HumanoidRootPart'); character:WaitForChild('Humanoid')
  task.wait(.3); if character.Parent then actionPose(character,{}) end
 end)
end
p.CharacterAdded:Connect(cacheCharacter); if p.Character then cacheCharacter(p.Character) end
Run.PreSimulation:Connect(function(dt)
 for character,cache in pairs(poseCache) do
  local run=poseRuns[character]; local previous={}; local frame; local elapsed=0
  if run then
   elapsed=os.clock()-run.start; previous=run.initial
   for _,candidate in ipairs(run.frames) do
    if elapsed<=candidate.time then frame=candidate; break end
    elapsed=elapsed-candidate.time; previous=candidate.pose
   end
   if not frame then poseRuns[character]=nil end
  end
  local movement=CFrame.identity
  local alpha=frame and Tween:GetValue(math.clamp(elapsed/frame.time,0,1),Enum.EasingStyle.Quad,Enum.EasingDirection.Out) or 1
  for name,entry in pairs(cache) do
   if entry.joint.Parent then
    local offset=frame and (previous[name] or CFrame.identity):Lerp(frame.pose[name] or CFrame.identity,alpha) or CFrame.identity
    entry.current=offset
    if name=='waist' or name=='rootjoint' then offset=movement*offset end
    entry.baseFrame=entry.joint.Transform; entry.applied=true
    entry.joint.Transform=entry.axes:Inverse()*offset*entry.axes*entry.baseFrame
   end
  end
 end
end)
local function angle(x,y,z) return CFrame.Angles(math.rad(x),math.rad(y),math.rad(z)) end
local function punchAnimation(character,combo)
 local left=combo==2; local side=left and 'left' or 'right'; local other=left and 'right' or 'left'; local sign=left and -1 or 1
 local wind={[side..'shoulder']=angle(35,sign*-15,sign*22),[side..'elbow']=angle(-70,0,0),[other..'shoulder']=angle(50,0,-sign*15),waist=angle(0,-sign*18,0)}
 local hit={[side..'shoulder']=angle(combo==3 and 112 or 88,sign*8,sign*-5),[side..'elbow']=angle(-5,0,0),[other..'shoulder']=angle(55,0,-sign*18),waist=angle(-8,sign*22,0)}
 wind.rootjoint=angle(0,-sign*12,0); hit.rootjoint=angle(-5,sign*16,0)
 wind.righthip=angle(-8,0,0); wind.lefthip=angle(8,0,0)
 hit.root=CFrame.new(0,-.12,-.12)*angle(-4,sign*6,0)
 hit.righthip=angle(combo==3 and -18 or -8,0,0); hit.lefthip=angle(10,0,0)
 actionPose(character,{{time=.07,pose=wind},{time=.08,pose=hit},{time=.07,pose=hit},{time=.16,pose={}}})
end
local function dodgeAnimation(character,direction)
 local root=character and character:FindFirstChild('HumanoidRootPart'); if not root then return end
 local localDir=root.CFrame:VectorToObjectSpace(direction.Unit)
 local lean=CFrame.new(0,-.65,0)*angle(localDir.Z*38,0,-localDir.X*32)
 local pose={root=lean,rootjoint=lean,waist=angle(-18,0,0),rightshoulder=angle(-30,0,22),leftshoulder=angle(-30,0,-22),rightelbow=angle(-65,0,0),leftelbow=angle(-65,0,0),righthip=angle(-55,0,5),lefthip=angle(25,0,-5),rightknee=angle(80,0,0),leftknee=angle(45,0,0)}
 actionPose(character,{{time=.065,pose=pose},{time=.19,pose=pose},{time=.16,pose={}}})
end
local function spearAnimation(character)
 local wind={rightshoulder=angle(145,-15,25),rightelbow=angle(-65,0,0),leftshoulder=angle(50,20,-25),waist=angle(0,-25,0),rootjoint=angle(0,-20,0)}
 local release={rightshoulder=angle(90,0,-12),rightelbow=angle(-5,0,0),leftshoulder=angle(15,0,-35),waist=angle(-12,25,0),rootjoint=angle(-8,20,0)}
 actionPose(character,{{time=.4,pose=wind},{time=.09,pose=release},{time=.25,pose={}}})
end
local function assetBurst(name,position,color,scale)
 local library=game.ReplicatedStorage:FindFirstChild('ArcaneVFXV7')
 local template=library and library:FindFirstChild(name); if not template then return end
 local anchor=Instance.new('Part'); anchor.Name='ArcaneEffect'; anchor.Size=Vector3.one; anchor.Transparency=1; anchor.Anchored=true; anchor.CanCollide=false; anchor.CanTouch=false; anchor.CanQuery=false; anchor.CFrame=CFrame.new(position); anchor.Parent=workspace
 Debris:AddItem(anchor,2)
 local attachment=Instance.new('Attachment'); attachment.Parent=anchor
 for _,source in template:GetChildren() do
  if source:IsA('ParticleEmitter') then
   local e=source:Clone(); e.Color=ColorSequence.new(color,Color3.new(1,1,1)); e.LightEmission=.8; e.LightInfluence=0; e.Brightness=1.5
   local sizes={} for _,k in e.Size.Keypoints do table.insert(sizes,NumberSequenceKeypoint.new(k.Time,math.clamp(k.Value*scale,.05,12*scale),0)) end
   e.Size=NumberSequence.new(sizes); e.Parent=attachment; e:Emit(e:GetAttribute('BurstCount') or 5)
  end
 end
 local l=Instance.new('PointLight'); l.Color=color; l.Range=16; l.Brightness=2; l.Parent=anchor
 Tween:Create(l,TweenInfo.new(.5),{Brightness=0}):Play()
end

local function spear(data,color)
 local model=Instance.new('Model'); model.Name='LanzaArcanaVisual'
 local function piece(name,size,cf,material,tint,cls)
  local o=Instance.new(cls or 'Part'); o.Name=name; o.Size=size; o.CFrame=cf; o.Anchored=true; o.CanCollide=false; o.CanQuery=false; o.CanTouch=false; o.Material=material; o.Color=tint; o.Parent=model; return o
 end
 local shaft=piece('Asta',Vector3.new(.22,.22,7),CFrame.new(),Enum.Material.Metal,Color3.fromRGB(180,210,245))
 piece('Núcleo',Vector3.new(.1,.1,7.2),CFrame.new(.15,0,0),Enum.Material.Neon,color)
 piece('Guarda',Vector3.new(1.7,.22,.35),CFrame.new(0,0,-3),Enum.Material.Neon,color)
 for i=0,3 do
  piece('Crystal blade',Vector3.new(.18,.8,3),CFrame.Angles(0,0,i*math.pi/2)*CFrame.new(0,.4,-4.5),Enum.Material.Glass,Color3.fromRGB(170,190,255),'WedgePart')
 end
 for z=-2,2,1 do piece('Runa',Vector3.new(.34,.34,.13),CFrame.new(0,0,z)*CFrame.Angles(0,0,math.pi/4),Enum.Material.Neon,color) end
 local light=Instance.new('PointLight',shaft); light.Color=color; light.Range=15; light.Brightness=2
 local a=Instance.new('Attachment',shaft); a.Position=Vector3.new(.35,0,3)
 local b=Instance.new('Attachment',shaft); b.Position=Vector3.new(-.35,0,3)
 local trail=Instance.new('Trail',shaft); trail.Attachment0=a; trail.Attachment1=b; trail.Lifetime=.24; trail.Color=ColorSequence.new(color); trail.LightEmission=1; trail.FaceCamera=true
 model.PrimaryPart=shaft
 local character=data.caster.Character; local root=character and character:FindFirstChild('HumanoidRootPart')
 local origin=root and (root.CFrame* CFrame.new(1.6,2,-1)).Position or data.origin
 local direction=data.target-origin; if direction.Magnitude<.1 then direction=Vector3.new(0,0,-1) else direction=direction.Unit end
 local start=CFrame.lookAt(origin,origin+direction)
 model:PivotTo(start); model.Parent=workspace; Debris:AddItem(model,1.5)
 for _,piece in ipairs(model:GetChildren()) do
  if piece:IsA('BasePart') then local opacity=piece.Material==Enum.Material.Glass and .15 or 0; piece.Transparency=1; Tween:Create(piece,TweenInfo.new(.16),{Transparency=opacity}):Play() end
 end
 local driver=Instance.new('CFrameValue'); driver.Value=start
 local con=driver:GetPropertyChangedSignal('Value'):Connect(function() if model.Parent then model:PivotTo(driver.Value) end end)
 circle(origin,1.4,color,.35,true)
 assetBurst('Charge',origin,color,.55)
 task.delay(.2,function()
  if not model.Parent then con:Disconnect(); driver:Destroy(); return end
  local goal=CFrame.lookAt(data.target,data.target+direction)*CFrame.new(0,0,6)
  Tween:Create(driver,TweenInfo.new(.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Value=goal}):Play()
  task.delay(.25,function()
   assetBurst('SpearImpact',data.target,color,1.1); circle(data.target,3,color,.3,true)
   for _,o in ipairs(model:GetChildren()) do if o:IsA('BasePart') then fade(o,.14) end end
   con:Disconnect(); driver:Destroy()
  end)
 end)
end


local function particles(position,color,count,upward)
 local anchor=orb(position,.1,color); anchor.Transparency=1
 local e=Instance.new('ParticleEmitter'); e.Texture='rbxasset://textures/particles/sparkles_main.dds'; e.Color=ColorSequence.new(color,Color3.new(1,1,1)); e.LightEmission=1; e.Rate=0; e.Lifetime=NumberRange.new(.35,.85); e.Speed=NumberRange.new(upward and 3 or 7,upward and 7 or 14); e.SpreadAngle=Vector2.new(upward and 25 or 180,180); e.Drag=4; e.Acceleration=Vector3.new(0,upward and 6 or -3,0); e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.13),NumberSequenceKeypoint.new(.2,.24),NumberSequenceKeypoint.new(1,0)}); e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.1),NumberSequenceKeypoint.new(.6,.3),NumberSequenceKeypoint.new(1,1)}); e.Parent=anchor; e:Emit(count)
end
local function expandingRing(position,color,radius,duration)
 local count=32
 for i=1,count do
  local a=(i-.5)*math.pi*2/count
  local direction=Vector3.new(math.cos(a),0,math.sin(a))
  local o=orb(position+direction,.2,color); o.Shape=Enum.PartType.Block
  o.Size=Vector3.new(.07,.07,2*math.sin(math.pi/count))
  o.CFrame=CFrame.lookAt(position+direction,position+direction+Vector3.new(-math.sin(a),0,math.cos(a)))
  Tween:Create(o,TweenInfo.new(duration,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=position+direction*radius,Size=Vector3.new(.1,.1,2*radius*math.sin(math.pi/count)),Transparency=1}):Play()
 end
end
local function impulse(kind)
 local signal=script.Parent:FindFirstChild('AbismoCameraImpulse')
 if signal then signal:Fire(kind) end
end
local function novaEffect(data,character,color)
 local root=character and character:FindFirstChild('HumanoidRootPart')
 local center=data.origin-Vector3.new(0,3.3,0)
 local raised={rightshoulder=angle(145,0,20),leftshoulder=angle(145,0,-20),rightelbow=angle(-50,0,0),leftelbow=angle(-50,0,0),waist=angle(8,0,0)}
 local slam={rightshoulder=angle(30,0,25),leftshoulder=angle(30,0,-25),root=CFrame.new(0,-.5,0),waist=angle(-28,0,0),righthip=angle(-25,0,0),lefthip=angle(-25,0,0),rightknee=angle(40,0,0),leftknee=angle(40,0,0)}
 actionPose(character,{{time=.16,pose=raised},{time=.12,pose=slam},{time=.12,pose=slam},{time=.3,pose={}}})
 circle(center,3,color,.35,false)
 task.delay(.2,function()
  expandingRing(center+Vector3.new(0,.15,0),color,22,.65)
  expandingRing(center+Vector3.new(0,.3,0),Color3.fromRGB(230,250,255),16,.5)
  assetBurst('Frost',center+Vector3.new(0,2,0),color,1.3)
  for i=1,16 do
   local a=i*math.pi/8; local radius=i%2==0 and 9 or 15
   local pos=center+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
   local ice=Instance.new('WedgePart'); ice.Name='FrostShard'; ice.Anchored=true; ice.CanCollide=false; ice.CanQuery=false; ice.CanTouch=false; ice.Material=Enum.Material.Glass; ice.Color=Color3.fromRGB(155,226,255); ice.Transparency=.2; ice.Size=Vector3.new(1.1,.1,2); ice.CFrame=CFrame.new(pos)*CFrame.Angles(0,-a,0); ice.Parent=workspace; Debris:AddItem(ice,1.4)
   Tween:Create(ice,TweenInfo.new(.18),{Size=Vector3.new(1.1,4+i%3,2),Position=pos+Vector3.new(0,2,0)}):Play()
   task.delay(.65,function() fade(ice,.45,Vector3.new(.2,.1,.3)) end)
  end
  if data.caster==p then impulse('nova') end
 end)
end
local function renewalEffect(data,character)
 local gold=Color3.fromRGB(255,215,125); local root=character and character:FindFirstChild('HumanoidRootPart')
 actionPose(character,{{time=.22,pose={rightshoulder=angle(55,0,45),leftshoulder=angle(55,0,-45),rightelbow=angle(-65,0,0),leftelbow=angle(-65,0,0),waist=angle(6,0,0)}},{time=.45,pose={rightshoulder=angle(75,0,65),leftshoulder=angle(75,0,-65)}},{time=.3,pose={}}})
 task.spawn(function()
  for i=1,5 do
   if not root or not root.Parent then break end
   local pos=root.Position-Vector3.new(0,2.8,0)
   expandingRing(pos,gold,4+i*.3,.65)
   if i==1 or i==4 then assetBurst('Heal',pos+Vector3.new(0,2,0),gold,.7) end
   for j=1,3 do
    local a=i*.7+j*math.pi*2/3
    local spark=orb(pos+Vector3.new(math.cos(a)*2.5,1,math.sin(a)*2.5),.3,gold)
    Tween:Create(spark,TweenInfo.new(.6),{Position=spark.Position+Vector3.new(0,4,0),Transparency=1}):Play()
   end
   task.wait(.14)
  end
 end)
 if data.caster==p then impulse('heal') end
end

local function magic(data)
 local color=spellColors[data.id] or Color3.fromRGB(120,205,255)
 local c=data.caster and data.caster.Character
 local localRoot=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
 if localRoot and (localRoot.Position-data.origin).Magnitude>120 then return end
 if data.kind=='dodge' then
  if data.caster==p then impulse('dodge') end
  dodgeAnimation(c,data.target-data.origin)
  task.spawn(function()
   for _=1,4 do
    if not c or not c.Parent then break end
    for _,limb in ipairs(c:GetChildren()) do
     if limb:IsA('BasePart') and limb.Name~='HumanoidRootPart' then
      local ghost=Instance.new('Part'); ghost.Name='EstelaEsquiva'; ghost.Size=limb.Size; ghost.CFrame=limb.CFrame; ghost.Anchored=true; ghost.CanCollide=false; ghost.CanQuery=false; ghost.CanTouch=false; ghost.Color=color; ghost.Material=Enum.Material.Neon; ghost.Transparency=.8; ghost.Parent=workspace; fade(ghost,.25); Debris:AddItem(ghost,.3)
     end
    end
    task.wait(.055)
   end
  end)
  return
 end
 if data.kind=='punch' then
  punchAnimation(c,data.combo or 1)
  if data.caster==p then task.delay(.14,function() impulse('punch') end) end
  local hand=c and (c:FindFirstChild(data.combo==2 and 'LeftHand' or 'RightHand') or c:FindFirstChild(data.combo==2 and 'Left Arm' or 'Right Arm'))
  if hand then
   local a=Instance.new('Attachment',hand); a.Position=Vector3.new(0,-.4,0)
   local b=Instance.new('Attachment',hand); b.Position=Vector3.new(0,.4,0)
   local trail=Instance.new('Trail',hand); trail.Attachment0=a; trail.Attachment1=b; trail.Lifetime=.09; trail.Transparency=NumberSequence.new(.5,1); trail.Color=ColorSequence.new(Color3.fromRGB(240,240,240)); trail.FaceCamera=true
   Debris:AddItem(trail,.25); Debris:AddItem(a,.3); Debris:AddItem(b,.3)
  end
  if data.caster==p then attackButton.Text='HIT '..tostring(data.combo or 1)..' / 3'; task.delay(.7,function() if attackButton.Parent then attackButton.Text='CLICK · PUNCH' end end) end
  return
 end
 if data.id>=1 and data.id<=4 then
  if data.id==1 then spearAnimation(c)
  elseif data.id==4 then actionPose(c,{{time=.22,pose={rightshoulder=angle(65,0,20),rightelbow=angle(-80,0,0),waist=angle(0,-12,0)}},{time=.08,pose={rightshoulder=angle(95,0,-10),rightelbow=angle(-5,0,0),waist=angle(0,12,0)}},{time=.22,pose={}}})
  elseif data.id==2 then
   actionPose(c,{{time=.18,pose={rightshoulder=angle(145,0,20),leftshoulder=angle(145,0,-20)}},{time=.13,pose={waist=angle(-20,0,0),rightshoulder=angle(20,0,25),leftshoulder=angle(20,0,-25)}},{time=.3,pose={}}})
  else
   actionPose(c,{{time=.3,pose={rightshoulder=angle(65,0,45),leftshoulder=angle(65,0,-45),rightelbow=angle(-40,0,0),leftelbow=angle(-40,0,0)}},{time=.5,pose={rightshoulder=angle(70,0,65),leftshoulder=angle(70,0,-65)}},{time=.3,pose={}}})
  end
  require(game.ReplicatedStorage:WaitForChild('ArcaneSpellArtV8')).Play(data)
  return
 end
 if c then actionPose(c,{{time=.12,pose={rightshoulder=angle(95,0,-15),rightelbow=angle(-20,0,0)}},{time=.12,pose={rightshoulder=angle(95,0,-15)}},{time=.2,pose={}}}) end
 local support=data.kind=='heal' or data.kind=='shield'
 local area=data.kind=='area' or data.kind=='frostarea'
 if data.kind~='basic' then
  circle(data.origin-Vector3.new(0,3.4,0),4,color,.7,false)
  circle(data.origin-Vector3.new(0,3.4,0),3,color,.6,false)
 end
 if support then
  local shell=orb(data.origin,2,color); shell.Transparency=.75; fade(shell,.8,Vector3.new(9,9,9))
  for i=1,14 do
   local a=i*math.pi/7; local spark=orb(data.origin+Vector3.new(math.cos(a)*3,-3,math.sin(a)*3),.35,color)
   Tween:Create(spark,TweenInfo.new(.9),{Position=spark.Position+Vector3.new(0,8,0),Transparency=1}):Play()
  end
 elseif area then
  circle(data.origin-Vector3.new(0,3,0),12,color,.65,false)
  burst(data.origin,color,16,12)
  if data.kind=='frostarea' then
   for i=1,12 do
    local a=i*math.pi/6; local pos=data.origin+Vector3.new(math.cos(a)*9,-3,math.sin(a)*9)
    local ice=orb(pos,.2,color); ice.Shape=Enum.PartType.Block; ice.CFrame=CFrame.new(pos)*CFrame.Angles(.2,a,.3); ice.Transparency=.25
    Tween:Create(ice,TweenInfo.new(.2),{Size=Vector3.new(.7,5,.7),Position=pos+Vector3.new(0,2,0)}):Play()
    task.delay(.4,function() fade(ice,.4) end)
   end
  end
 else
  local basic=data.kind=='basic'; local projectile=orb(data.origin,basic and .8 or 1.8,color)
  local a=Instance.new('Attachment',projectile); a.Position=Vector3.new(0,.6,0)
  local b=Instance.new('Attachment',projectile); b.Position=Vector3.new(0,-.6,0)
  local trail=Instance.new('Trail',projectile); trail.Attachment0=a; trail.Attachment1=b; trail.Lifetime=.25; trail.Color=ColorSequence.new(color); trail.FaceCamera=true; trail.LightEmission=1
  if not basic then
   circle(data.origin,2,color,.3,true)
   segment(data.origin,data.target,color,.16,.25)
  end
  Tween:Create(projectile,TweenInfo.new(.22,Enum.EasingStyle.Linear),{Position=data.target}):Play()
  task.delay(.22,function() projectile.Transparency=1; burst(data.target,color,basic and 5 or 12,basic and 3 or 7) end)
 end
end
local function damageNumber(data)
 local anchor=orb(data.position,.1,Color3.new(1,1,1)); anchor.Transparency=1
 local g=Instance.new('BillboardGui',anchor); g.Size=UDim2.fromOffset(100,45); g.AlwaysOnTop=true; g.StudsOffset=Vector3.new(0,3,0)
 local t=Instance.new('TextLabel',g); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=tostring(data.damage); t.Font=Enum.Font.GothamBlack; t.TextSize=25; t.TextColor3=Color3.fromRGB(255,225,140); t.TextStrokeTransparency=.3
 Tween:Create(g,TweenInfo.new(.7),{StudsOffset=Vector3.new(0,6,0)}):Play()
 Tween:Create(t,TweenInfo.new(.7),{TextTransparency=1,TextStrokeTransparency=1}):Play()
end
local synced=false
event.OnClientEvent:Connect(function(data)
 if data.vfx then magic(data); return end
 if data.damage then damageNumber(data); return end
 if data.cooldown then ends[data.cooldown]=os.clock()+data.duration; return end
 synced=true
 unlocked=data.unlocked; title.Text='ARCANE ABYSS • '..string.upper(data.race)
 stats.Text='Floor '..data.floor..'/5  •  Defeated: '..data.kills..'/3  •  Aether: '..data.coins
 if data.floor==0 then stats.Text='SANCTUARY · Safe zone · Practice your powers' end
 if data.floor==5 then stats.Text='Floor 5/5 • '..(data.won and 'GUARDIAN DEFEATED' or 'Defeat the guardian')..' • Aether: '..data.coins end
 if data.message~='' then
  message.Text=data.message; message.Visible=true; local previous=data.message
  task.delay(4,function() if message.Text==previous then message.Visible=false end end)
 end
end)
task.spawn(function()
 while gui.Parent do
  local dodgeRemaining=math.max(0,(ends.dodge or 0)-os.clock()); dodgeButton.Text=dodgeRemaining>0 and string.format('DODGE %.1fs',dodgeRemaining) or 'SHIFT · DODGE'
  local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid'); health.Text=h and ('HEALTH '..math.ceil(h.Health)..' / '..h.MaxHealth) or 'Returning to checkpoint…'
  for i,b in ipairs(slotButtons) do local id=selected[i]; local remaining=math.max(0,(ends[id] or 0)-os.clock()); b.Text=keys[i]..' • '..powers[id]..(remaining>0 and string.format(' (%.1fs)',remaining) or '') end
  for id,b in ipairs(buttons) do b.Text=id<=unlocked and powers[id] or ('LOCKED · Floor '..math.ceil(id/3)); b.BackgroundColor3=id<=unlocked and Color3.fromRGB(62,48,98) or Color3.fromRGB(28,29,38) end
  task.wait(.1)
 end
end)
event:FireServer('sync')
task.spawn(function() for _=1,8 do task.wait(1); if synced then return end; event:FireServer('sync') end; message.Text='Server unavailable. Check the Studio Output window.' end)

