local Run=game:GetService('RunService')
local Debris=game:GetService('Debris')
local Art={}
local violet=Color3.fromRGB(150,95,255)
local frost=Color3.fromRGB(125,213,255)
local gold=Color3.fromRGB(255,201,99)
local white=Color3.fromRGB(235,231,255)
local function part(parent,name,size,cf,color,material)
 local p=Instance.new('Part'); p.Name=name; p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.CastShadow=false; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.Neon; p.Parent=parent; return p
end
local function line(parent,a,b,width,color)
 local delta=b-a
 return part(parent,'Energy filament',Vector3.new(width,width,math.max(.01,delta.Magnitude)),CFrame.lookAt((a+b)/2,b),color)
end
local function ring(parent,count,color,width)
 local pieces={}
 for i=1,count do pieces[i]=part(parent,'Continuous ring',Vector3.one,CFrame.identity,color) end
 return function(cf,radius,opacity,rotation)
  for i,p in pieces do
   local a=(i-1)*math.pi*2/count+(rotation or 0); local b=i*math.pi*2/count+(rotation or 0)
   local v1=cf:PointToWorldSpace(Vector3.new(math.cos(a)*radius,math.sin(a)*radius,0))
   local v2=cf:PointToWorldSpace(Vector3.new(math.cos(b)*radius,math.sin(b)*radius,0))
   p.Size=Vector3.new(width,width,math.max(.01,(v2-v1).Magnitude+.02)); p.CFrame=CFrame.lookAt((v1+v2)/2,v2); p.Transparency=opacity
  end
 end
end
local function sigil(parent,color)
 local outer=ring(parent,48,color,.045); local inner=ring(parent,40,color,.025)
 local glyphs={}
 for i=1,12 do for j=1,3 do table.insert(glyphs,part(parent,'Arcane inscription',Vector3.new(.035,.25,.035),CFrame.identity,color)) end end
 return function(cf,r,opacity,angle)
  outer(cf,r,opacity,angle); inner(cf,r*.78,opacity+.1,angle)
  for index,p in glyphs do
   local i=math.ceil(index/3); local j=(index-1)%3
   local a=i*math.pi/6+angle
   local glyph=CFrame.new(j==0 and 0 or (j==1 and r*.035 or -r*.025),r*.89+(j==0 and 0 or (j==1 and r*.035 or -r*.035)),0)
   p.CFrame=cf*CFrame.Angles(0,0,a)*glyph*CFrame.Angles(0,0,j==0 and 0 or -.65)
   p.Size=Vector3.new(.03,r*(j==0 and .15 or .08),.03); p.Transparency=opacity
  end
 end
end
local function particle(parent,pos,color,kind,count)
 local a=part(parent,'Particle origin',Vector3.one,CFrame.new(pos),color); a.Transparency=1
 local e=Instance.new('ParticleEmitter'); e.Texture=kind=='mist' and 'rbxasset://textures/particles/smoke_main.dds' or 'rbxassetid://6763809313'
 e.Color=ColorSequence.new(color); e.LightEmission=kind=='mist' and .1 or .85; e.LightInfluence=0; e.Rate=0
 e.Lifetime=NumberRange.new(.25,.65); e.Speed=kind=='mist' and NumberRange.new(3,8) or NumberRange.new(12,28)
 e.Drag=5; e.SpreadAngle=Vector2.new(180,180); e.Acceleration=Vector3.new(0,kind=='mist' and 2 or -6,0)
 e.Size=kind=='mist' and NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,4)}) or NumberSequence.new({NumberSequenceKeypoint.new(0,.16),NumberSequenceKeypoint.new(1,0)})
 e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,kind=='mist' and .8 or .05),NumberSequenceKeypoint.new(1,1)}); e.Parent=a; e:Emit(count)
end
local function sound(parent,pos,pitch)
 local a=part(parent,'Spell audio',Vector3.one,CFrame.new(pos),white); a.Transparency=1
 local s=Instance.new('Sound'); s.SoundId='rbxassetid://9125648149'; s.Volume=.35; s.PlaybackSpeed=pitch; s.RollOffMaxDistance=90; s.RollOffMinDistance=8; s.Parent=a; s:Play()
end
local function animate(model,duration,render,speed)
 local t=0; local connection
 render(0)
 connection=Run.RenderStepped:Connect(function(dt)
  if not model.Parent then connection:Disconnect(); return end
  t=t+dt*(speed or 1)
  if t>duration then connection:Disconnect(); model:Destroy(); return end
  render(t)
 end)
 Debris:AddItem(model,duration/(speed or 1)+3)
end
local function ground(pos,character)
 local params=RaycastParams.new(); params.FilterDescendantsInstances={character}; params.RespectCanCollide=true
 local hit=workspace:Raycast(pos,Vector3.new(0,-12,0),params)
 return hit and hit.Position+Vector3.new(0,.15,0) or pos-Vector3.new(0,3,0)
end
local function pulseLight(parent,position,color,strength,duration)
 local anchor=part(parent,'Spell illumination',Vector3.one,CFrame.new(position),color); anchor.Transparency=1
 local light=Instance.new('PointLight'); light.Color=color; light.Range=22; light.Brightness=strength; light.Shadows=false; light.Parent=anchor
 game:GetService('TweenService'):Create(light,TweenInfo.new(duration),{Brightness=0}):Play()
 return anchor
end

local function flameEmitter(parent,size,rate)
 local template=game.ReplicatedStorage:WaitForChild('SpellMaterialsV9'):WaitForChild('FlameFlipbook')
 local e=template:Clone()
 e.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,236,170)),ColorSequenceKeypoint.new(.25,Color3.fromRGB(255,153,44)),ColorSequenceKeypoint.new(1,Color3.fromRGB(150,36,12))})
 e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,size*.45),NumberSequenceKeypoint.new(.2,size),NumberSequenceKeypoint.new(1,size*.15)})
 e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.6,.25),NumberSequenceKeypoint.new(1,1)})
 e.Lifetime=NumberRange.new(.3,.55); e.Speed=NumberRange.new(.5,2); e.SpreadAngle=Vector2.new(35,35)
 e.Acceleration=Vector3.new(0,5,0); e.Drag=2; e.LightInfluence=0; e.LightEmission=.65; e.Brightness=1.2
 e.Orientation=Enum.ParticleOrientation.FacingCamera; e.Rotation=NumberRange.new(-180,180); e.RotSpeed=NumberRange.new(-35,35)
 e.LockedToPart=false; e.Rate=rate; e.Enabled=rate>0; e.Parent=parent
 return e
end
local function smokeEmitter(parent)
 local e=Instance.new('ParticleEmitter'); e.Texture='rbxasset://textures/particles/smoke_main.dds'
 e.Color=ColorSequence.new(Color3.fromRGB(65,57,55),Color3.fromRGB(110,101,95)); e.LightEmission=0; e.LightInfluence=.6
 e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.7),NumberSequenceKeypoint.new(1,4)})
 e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.8),NumberSequenceKeypoint.new(.3,.85),NumberSequenceKeypoint.new(1,1)})
 e.Lifetime=NumberRange.new(.5,1); e.Speed=NumberRange.new(1,3); e.Acceleration=Vector3.new(0,7,0); e.SpreadAngle=Vector2.new(70,70); e.Rate=12; e.Parent=parent
 return e
end

function Art.Play(data,speed)
 local model=Instance.new('Model'); model.Name='ArcaneSpellV8'; model.Parent=workspace
 local character=data.caster and data.caster.Character
 local root=character and character:FindFirstChild('HumanoidRootPart')
 local origin=data.origin
 if data.id==1 then
  local start=root and (root.CFrame*CFrame.new(2.3,2,-1)).Position or origin
  local target=data.target
  local dir=(target-start).Magnitude>.1 and (target-start).Unit or Vector3.new(0,0,-1)
  local aim=CFrame.lookAt(start,start+dir)
  local seal=sigil(model,violet)
  local impactRing=ring(model,48,violet,.08)
  local shaft=part(model,'Lance core',Vector3.new(.13,.13,7),aim,violet)
  local template=game.ReplicatedStorage:FindFirstChild('ArcaneLanceMeshV8')
  local mesh=template and template:Clone()
  if mesh then mesh.Parent=model end
  local a=Instance.new('Attachment'); a.Position=Vector3.new(0,.18,3); a.Parent=shaft
  local b=Instance.new('Attachment'); b.Position=Vector3.new(0,-.18,3); b.Parent=shaft
  local trail=Instance.new('Trail'); trail.Attachment0=a; trail.Attachment1=b; trail.Color=ColorSequence.new(white,violet); trail.LightEmission=1; trail.Lifetime=.25; trail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}); trail.Parent=shaft
  local light=Instance.new('PointLight'); light.Color=violet; light.Range=18; light.Brightness=1.5; light.Parent=shaft
  local strands={}
  for i=1,3 do strands[i]=part(model,'Orbiting charge',Vector3.new(.05,.05,.35),aim,white) end
  local fired,hit=false,false
  animate(model,1.35,function(t)
   local charge=math.clamp(t/.4,0,1)
   seal(aim*CFrame.new(0,0,-2),1.6+charge*.8,math.clamp((t-.4)*7,0,1),t*1.5)
   local flight=math.clamp((t-.4)/.25,0,1)
   local pos=start:Lerp(target,flight*flight)
   local cf=CFrame.lookAt(pos,pos+dir)*CFrame.Angles(math.rad(55)*(1-flight),0,0)
   shaft.CFrame=cf; shaft.Transparency=t>.65 and 1 or 1-charge
   if mesh then
    mesh:PivotTo(cf*CFrame.Angles(-math.pi/2,0,0))
    for _,p in mesh:GetDescendants() do if p:IsA('BasePart') then p.Transparency=t>.65 and 1 or 1-charge end end
   end
   for i,p in strands do local a=t*12+i*math.pi*2/3; p.CFrame=cf*CFrame.new(math.cos(a)*.55,math.sin(a)*.55,1.4); p.Transparency=t>.65 and 1 or .25 end
   if t>=.4 and not fired then fired=true; sound(model,start,1.1) end
   if t>=.65 and not hit then hit=true; pulseLight(model,target,violet,2.5,.3); particle(model,target,violet,'sparks',32); particle(model,target,violet,'mist',5) end
   local age=math.max(0,t-.65)
   impactRing(CFrame.lookAt(target,target+dir),.3+8*(1-math.exp(-age*8)),t<.65 and 1 or math.clamp(age/.55,0,1),0)
   light.Brightness=t>.65 and 0 or 1.5
  end,speed)
 elseif data.id==2 then
  local center=ground(origin,character); local plane=CFrame.new(center)*CFrame.Angles(math.pi/2,0,0)
  local seal=sigil(model,frost); local wave=ring(model,64,frost,.11); local secondary=ring(model,48,white,.035)
  local shards={}
  for i=1,16 do
   local a=i*math.pi/8
   local crystal=game.ReplicatedStorage:FindFirstChild('ArcaneIceMeshV8')
   local p=crystal and crystal:Clone() or Instance.new('WedgePart'); p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.Material=Enum.Material.Glass; p.Color=frost; p.Parent=model
   shards[i]={p=p,a=a,r=7+(i%3)*2.3,h=3+(i%4)*.8}
  end
  local burst=false
  animate(model,1.25,function(t)
   seal(plane,3+math.min(t/.2,1)*.8,math.clamp((t-.18)*5,0,1),-t)
   local progress=math.clamp((t-.2)/.55,0,1)
   local radius=22*(1-(1-progress)^2)
   wave(plane,radius,t<.2 and 1 or progress,0)
   secondary(plane,radius*.88,t<.2 and 1 or math.min(1,progress+.2),0)
   if t>=.2 and not burst then burst=true; pulseLight(model,center+Vector3.new(0,2,0),frost,2,.5); sound(model,center,.72); particle(model,center+Vector3.new(0,1,0),frost,'mist',16) end
   for _,s in shards do
    local emerge=math.clamp((radius-s.r)*2,0,1)
    local fade=math.clamp((t-.72)/.45,0,1)
    s.p.Size=Vector3.new(.65,math.max(.05,s.h*emerge*(1-fade)),1.3)
    s.p.CFrame=CFrame.new(center+Vector3.new(math.cos(s.a)*s.r,s.p.Size.Y/2,math.sin(s.a)*s.r))*CFrame.Angles(0,-s.a,.2)
    s.p.Transparency=emerge==0 and 1 or .25+fade*.75
   end
  end,speed)
 elseif data.id==3 then
  local seal=sigil(model,gold); local rings={}
  for i=1,3 do rings[i]=ring(model,40,i==2 and white or gold,.035) end
  local motes={}
  for i=1,18 do local p=part(model,'Healing mote',Vector3.new(.09,.09,.32),CFrame.new(origin),gold); motes[i]=p end
  local healLight=pulseLight(model,origin,gold,1.4,1.5)
  sound(model,origin,.65)
  animate(model,1.6,function(t)
   local center=root and root.Parent and ground(root.Position,character) or ground(origin,character)
   local fade=math.clamp((t-1)/.6,0,1)
   healLight.Position=center+Vector3.new(0,2,0)
   seal(CFrame.new(center)*CFrame.Angles(math.pi/2,0,0),3.4,.2+fade*.8,t*.35)
   for i,draw in rings do
    local u=(t*.7+(i-1)/3)%1
    draw(CFrame.new(center+Vector3.new(0,u*5,0))*CFrame.Angles(math.pi/2,0,0),2.6-u*.8,math.min(1,.3+u*.5+fade),t)
   end
   for i,p in motes do local a=i*2.399+t*2; local h=(i*.31+t*2)%5; p.CFrame=CFrame.new(center+Vector3.new(math.cos(a)*2.1,h,math.sin(a)*2.1)); p.Transparency=.2+fade*.8 end
  end,speed)
 elseif data.id==4 then
  local orange=Color3.fromRGB(255,135,38)
  local target=data.target
  local direction=(target-origin).Magnitude>.1 and (target-origin).Unit or Vector3.new(0,0,-1)
  local hand=character and (character:FindFirstChild('RightHand') or character:FindFirstChild('Right Arm'))
  local start=hand and hand.Position+direction*.6 or origin
  local seal=sigil(model,orange); local impactWave=ring(model,48,orange,.065)
  local anchor=part(model,'Fireball emitter',Vector3.one,CFrame.new(start),orange); anchor.Transparency=1
  local flame=flameEmitter(anchor,2.6,55); local smoke=smokeEmitter(anchor)
  local core=flameEmitter(anchor,1.2,25); core.Color=ColorSequence.new(Color3.fromRGB(255,242,195))
  local light=Instance.new('PointLight'); light.Range=20; light.Color=orange; light.Brightness=1.6; light.Parent=anchor
  local impacted=false; local released=false; local burstLight
  animate(model,1.8,function(t)
   local charge=math.clamp(t/.25,0,1)
   if t<.25 and hand and hand.Parent then start=hand.Position+direction*.6 end
   local f=math.clamp((t-.25)/.3,0,1)
   local pos=start:Lerp(target,f)
   anchor.CFrame=CFrame.lookAt(pos,pos+direction)
   seal(CFrame.lookAt(start+direction,start+direction*2),1.2+charge*.6,math.clamp((t-.25)*8,0,1),t*.9)
   if t>=.25 and not released then released=true; sound(model,start,.85) end
   if t>=.55 and not impacted then
    impacted=true; flame.Enabled=false; core.Enabled=false; smoke.Enabled=false; light.Enabled=false
    local impact=part(model,'Combustion burst',Vector3.one,CFrame.new(target),orange); impact.Transparency=1
    local fire=flameEmitter(impact,5.5,0); fire.Speed=NumberRange.new(6,12); fire.SpreadAngle=Vector2.new(180,180); fire.Lifetime=NumberRange.new(.25,.5); fire:Emit(18)
    local soot=smokeEmitter(impact); soot.Enabled=false; soot.Speed=NumberRange.new(3,8); soot:Emit(10)
    particle(model,target,orange,'sparks',30)
    burstLight=Instance.new('PointLight'); burstLight.Color=orange; burstLight.Range=24; burstLight.Brightness=3; burstLight.Parent=impact
    local s=Instance.new('Sound'); s.SoundId='rbxassetid://139148990073887'; s.Volume=.4; s.RollOffMaxDistance=100; s.RollOffMinDistance=8; s.Parent=impact; s:Play()
   end
   local age=math.max(0,t-.55)
   impactWave(CFrame.lookAt(target,target+direction),.2+7*(1-math.exp(-age*9)),t<.55 and 1 or math.clamp(age/.4,0,1),0)
   if burstLight then burstLight.Brightness=3*math.exp(-age*12) end
  end,speed)

 else model:Destroy() end
 return model
end
return Art
