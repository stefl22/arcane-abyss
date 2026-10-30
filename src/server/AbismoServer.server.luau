local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')
local RunService = game:GetService('RunService')
local event = RS:WaitForChild('AbismoEvent')
local rng = Random.new()
local world = workspace:WaitForChild('AbismoArcano')
local enemies, states = {}, {}
local colors = {Color3.fromRGB(85,180,255),Color3.fromRGB(90,240,175),Color3.fromRGB(180,105,255),Color3.fromRGB(255,110,60),Color3.fromRGB(255,210,100)}
local names = {'Azure Threshold','Emerald Grotto','Violet Sepulcher','Ashen Depths','Abyssal Throne'}
local powers = {
 {name='Arcane Spear',damage=38,range=52,cd=2.2,kind='single'},
 {name='Frost Nova',damage=24,range=22,cd=5,kind='frostarea'},
 {name='Radiant Renewal',damage=35,range=0,cd=8,kind='heal'},
 {name='Flame Bolt',damage=32,range=48,cd=2.8,kind='single'},
 {name='Arcane Wave',damage=22,range=18,cd=4,kind='area'},
 {name='Aegis',damage=0,range=0,cd=12,kind='shield'},
 {name='Lightning Strike',damage=48,range=40,cd=3,kind='single'},
 {name='Blizzard',damage=22,range=22,cd=5,kind='frostarea'},
 {name='Soul Drain',damage=30,range=28,cd=4,kind='drain'},
 {name='Solar Burst',damage=55,range=25,cd=6,kind='area'},
 {name='Void Lance',damage=85,range=45,cd=5,kind='single'},
 {name='Judgment',damage=70,range=30,cd=9,kind='area'},
}
local function base(f) return Vector3.new(0,200-(f-1)*80,0) end
local function part(name,size,cf,color,material)
 local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=cf; p.Anchored=true; p.Color=color; p.Material=material or Enum.Material.Slate; p.Parent=world; return p
end
local function label(p,text)
 local gui=Instance.new('BillboardGui',p); gui.Size=UDim2.fromOffset(240,60); gui.StudsOffset=Vector3.new(0,5,0); gui.AlwaysOnTop=true
 local t=Instance.new('TextLabel',gui); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=text; t.TextColor3=Color3.new(1,1,1); t.TextStrokeTransparency=.3; t.TextSize=18; t.Font=Enum.Font.GothamBold; return t
end
local function send(p,msg)
 local s=states[p]; if s then p:SetAttribute('AbismoFloor',s.floor); p:SetAttribute('AbismoKills',s.kills); event:FireClient(p,{race=s.race,floor=s.floor,kills=s.kills,coins=s.coins,unlocked=math.min(12,math.max(4,s.floor*3)),message=msg or '',won=s.won}) end
end
local function move(p,f)
 local c=p.Character; if c then c:PivotTo(CFrame.new(base(f)+Vector3.new(0,5,29))) end
end
for f=0,5 do
 local gate=world:WaitForChild('Portal'..f)
 label(gate,f==0 and 'DESCEND TO FLOOR 1' or f<5 and ('DESCEND • defeat 3 enemies\n'..names[f]) or 'DEFEAT THE GUARDIAN')
 local prompt=Instance.new('ProximityPrompt',gate); prompt.ActionText=f<5 and 'Descend' or 'Finish expedition'; prompt.ObjectText=f==0 and 'Sanctuary of Awakening' or names[f]; prompt.MaxActivationDistance=12; prompt.HoldDuration=.4
 prompt.KeyboardKeyCode=Enum.KeyCode.F; prompt.RequiresLineOfSight=false
 prompt.Triggered:Connect(function(p)
  local s=states[p]; local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
  if not s or s.floor~=f or not root or (root.Position-gate.Position).Magnitude>16 then return end
  if f==5 then send(p,s.won and 'Expedition complete! You conquered the abyss.' or 'The guardian still stands.'); return end
  if f>0 and s.kills<3 then send(p,'Defeat 3 enemies on this floor first.'); return end
  s.floor=f+1; s.kills=0; s.shield=os.clock()+3; move(p,s.floor)
  local h=p.Character:FindFirstChildOfClass('Humanoid'); if h then h.Health=h.MaxHealth end
  send(p,'Checkpoint reached. Explore your spellbook.')
 end)
end
local function spawnEnemy(f,index,boss)
 local pos=base(f)+Vector3.new((index-2)*16,6,-8)
 local p=part(boss and 'Abyssal Guardian' or 'Stalker',boss and Vector3.new(9,11,9) or Vector3.new(4,5,4),CFrame.new(pos),colors[f],Enum.Material.Neon)
 p.Shape=Enum.PartType.Ball; p.CanCollide=false
 local hp=boss and 700 or 50+f*25
 local e={part=p,floor=f,hp=hp,max=hp,boss=boss,origin=pos,frozen=0,hits={},attack=0}
 p:SetAttribute('HP',hp); p:SetAttribute('EnemyFloor',f); e.label=label(p,p.Name..' • '..hp); enemies[p]=e
end
local returnGate=world:WaitForChild('ReturnHub')
label(returnGate,'RETURN TO SANCTUARY')
local back=Instance.new('ProximityPrompt',returnGate); back.ActionText='Return'; back.ObjectText='Sanctuary'; back.KeyboardKeyCode=Enum.KeyCode.F; back.MaxActivationDistance=10; back.HoldDuration=.4; back.RequiresLineOfSight=false
back.Triggered:Connect(function(p)
 local s=states[p]; local c=p.Character; local r=c and c:FindFirstChild('HumanoidRootPart'); local h=c and c:FindFirstChildOfClass('Humanoid')
 if not s or s.floor~=1 or not r or not h or h.Health<=0 or (r.Position-returnGate.Position).Magnitude>14 then return end
 s.floor=0; s.kills=0; move(p,0); h.Health=h.MaxHealth; send(p,'You returned to the sanctuary.')
end)
for f=1,5 do for i=1,3 do spawnEnemy(f,i,false) end end
spawnEnemy(5,2,true)
local function roll()
 local r=rng:NextInteger(1,1000)
 if r<=450 then return 'Human' elseif r<=730 then return 'Elf' elseif r<=900 then return 'Dwarf' elseif r<=980 then return 'Draconic' elseif r<=995 then return 'Demon' else return 'God' end
end
local function joined(p)
 if states[p] then return end
 states[p]={race=roll(),floor=0,kills=0,coins=0,cooldowns={},last=0,shield=0,dodgeUntil=0,dodgeNext=0,won=false}
 local function character(c)
  local h=c:WaitForChild('Humanoid'); c:WaitForChild('HumanoidRootPart')
  local s=states[p]; if not s then return end
  s.shield=os.clock()+3; s.sprinting=false; p:SetAttribute('Sprinting',false)
  h.MaxHealth=s.race=='Dwarf' and 140 or 110; h.Health=h.MaxHealth; h.WalkSpeed=s.race=='Elf' and 22 or 18
  move(p,s.floor); send(p,'You awakened as '..s.race..'. Mouse: look · Click: punch · Shift: dodge')
 end
 p.CharacterAdded:Connect(character); if p.Character then task.spawn(character,p.Character) end
end
Players.PlayerAdded:Connect(joined); for _,p in ipairs(Players:GetPlayers()) do joined(p) end
Players.PlayerRemoving:Connect(function(p) states[p]=nil; for _,e in pairs(enemies) do e.hits[p]=nil end end)
local function effect(pos,radius,color)
 local p=part('Magia',Vector3.new(radius*2,radius*2,radius*2),CFrame.new(pos),color,Enum.Material.Neon); p.Shape=Enum.PartType.Ball; p.CanCollide=false; p.Transparency=.75; Debris:AddItem(p,.22)
end
event.OnServerEvent:Connect(function(p,action,id)
 local s=states[p]; if not s then return end
 if action=='sprint' then
  if type(id)~='boolean' then return end
  if s.sprinting==id then return end
  s.sprinting=id; p:SetAttribute('Sprinting',id)
  local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
  if h and h.Health>0 then h.WalkSpeed=(s.race=='Elf' and 22 or 18)*(id and 1.4 or 1) end
  return
 end
 local now=os.clock(); if now-s.last<.1 then return end; s.last=now
 if action=='sync' then send(p,s.floor==0 and 'Practice your powers, then enter the portal to floor 1.' or 'Defeat 3 enemies to continue.'); return end
 if action=='dodge' then
  local c=p.Character; local root=c and c:FindFirstChild('HumanoidRootPart'); local h=c and c:FindFirstChildOfClass('Humanoid')
  if not root or not h or h.Health<=0 or now<s.dodgeNext then return end
  local direction=typeof(id)=='Vector3' and id or root.CFrame.LookVector
  if direction.X~=direction.X or direction.Z~=direction.Z or math.abs(direction.X)>2 or math.abs(direction.Z)>2 then return end
  direction=Vector3.new(direction.X,0,direction.Z)
  if direction.Magnitude<.1 then direction=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z) end
  if direction.Magnitude<.1 then return end
  direction=direction.Unit; s.dodgeNext=now+2.5; s.dodgeUntil=now+.35
  p:SetAttribute('DodgeUntil',s.dodgeUntil)
  event:FireClient(p,{cooldown='dodge',duration=2.5})
  event:FireAllClients({vfx=true,caster=p,origin=root.Position,target=root.Position+direction*15,id=0,kind='dodge'})
  task.spawn(function()
   local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={c}; params.RespectCanCollide=true
   pcall(function() root:SetNetworkOwner(nil) end)
   for _=1,8 do
    if not root.Parent or h.Health<=0 then break end
    local step=direction*1.8; local hit=workspace:Blockcast(root.CFrame,Vector3.new(2,3,2),step,params)
    if hit then break end
    root.CFrame=root.CFrame+step; root.AssemblyLinearVelocity=Vector3.zero; task.wait(.025)
   end
   if root.Parent then pcall(function() root:SetNetworkOwnershipAuto() end) end
  end)
  return
 end
 local aim
 if action=='cast' and type(id)=='table' then
  aim=id.aim; id=id.id
  if typeof(aim)~='Vector3' or aim.X~=aim.X or aim.Y~=aim.Y or aim.Z~=aim.Z or aim.Magnitude<.9 or aim.Magnitude>1.1 then return end
  aim=aim.Unit
 end
 local basic=action=='basic'
 if not basic and (action~='cast' or type(id)~='number' or id%1~=0 or id<1 or id>math.min(12,math.max(4,s.floor*3))) then return end
 if basic then id=0 end
 local spell=id==0 and {name='Punch',damage=12,range=7,cd=.42,kind='punch'} or powers[id]; local c=p.Character; local root=c and c:FindFirstChild('HumanoidRootPart'); local h=c and c:FindFirstChildOfClass('Humanoid')
 if not root or not h or h.Health<=0 or math.abs(root.Position.Y-base(s.floor).Y)>35 then return end
 if now<(s.cooldowns[id] or 0) then return end
 local combo=0
 if basic then
  combo=(now-(s.lastPunch or 0)<1.15) and ((s.combo or 0)%3+1) or 1
  s.combo=combo; s.lastPunch=now; spell.damage=combo==3 and 20 or 12
 end
 local targets={}
 local castDirection=aim or root.CFrame.LookVector
 local sight=RaycastParams.new(); sight.FilterType=Enum.RaycastFilterType.Exclude; sight.FilterDescendantsInstances={c}; sight.RespectCanCollide=true
 for _,e in pairs(enemies) do
  local delta=e.part.Position-root.Position
  if e.floor==s.floor and delta.Magnitude<=spell.range then
   local isArea=spell.kind=='area' or spell.kind=='frostarea'
   if (isArea or delta.Magnitude<1 or (basic and root.CFrame.LookVector or castDirection):Dot(delta.Unit)>(basic and .35 or .96)) and not workspace:Raycast(root.Position,delta,sight) then table.insert(targets,e) end
  end
 end
 table.sort(targets,function(a,b) return (a.part.Position-root.Position).Magnitude<(b.part.Position-root.Position).Magnitude end)
 s.cooldowns[id]=now+spell.cd; event:FireClient(p,{cooldown=id,duration=spell.cd})
 local castOrigin=root.Position+Vector3.new(0,1,0)
 local target=targets[1] and targets[1].part.Position or castOrigin+castDirection*math.max(18,spell.range)
 local obstacle=workspace:Raycast(castOrigin,target-castOrigin,sight)
 if obstacle then target=obstacle.Position+obstacle.Normal*.05 end
 event:FireAllClients({vfx=true,caster=p,origin=root.Position+Vector3.new(0,1,0),target=target,id=id,kind=spell.kind,combo=combo,hit=#targets>0})
 if #targets==0 and not basic and spell.kind~='heal' and spell.kind~='shield' then send(p,'Cast: '..spell.name..'. No target in range.'); end
 if spell.kind=='heal' then h.Health=math.min(h.MaxHealth,h.Health+spell.damage); return end
 if spell.kind=='shield' then s.shield=now+5; effect(root.Position,6,Color3.fromRGB(130,200,255)); return end
 local area=spell.kind=='area' or spell.kind=='frostarea'
 -- Align damage with the fist contact or spear impact, and recheck the target.
 if basic or id==1 or id==4 or id==2 then task.wait(basic and .14 or id==1 and .65 or id==4 and .55 or .2) end
 if not states[p] or not root.Parent or h.Health<=0 then return end
 now=os.clock()
 for i,e in ipairs(targets) do
  if i>1 and not area then break end
  if not e.part.Parent or enemies[e.part]~=e or states[p].floor~=e.floor then continue end
  if (e.part.Position-root.Position).Magnitude>spell.range+2 then continue end
  if (id==1 or id==4) and (e.part.Position-target).Magnitude>6 then continue end
  if workspace:Raycast(root.Position,e.part.Position-root.Position,sight) then continue end
  if basic then
   local delta=e.part.Position-root.Position
   if delta.Magnitude>0 and root.CFrame.LookVector:Dot(delta.Unit)<.2 then continue end
   if combo==3 then
    local push=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)*4
    if not workspace:Raycast(e.part.Position,push,sight) then e.part.Position=e.part.Position+push end
    e.frozen=now+.4
   end
  end
  local dmg=spell.damage*((s.race=='Draconic' or s.race=='God') and 1.1 or 1)
  e.hp=e.hp-dmg; e.hits[p]=now; e.part:SetAttribute('HP',e.hp)
  if spell.kind=='freeze' or spell.kind=='frostarea' then e.frozen=now+3 end
  if spell.kind=='drain' or s.race=='Demon' then h.Health=math.min(h.MaxHealth,h.Health+dmg*.15) end
  event:FireAllClients({damage=math.ceil(dmg),position=e.part.Position})
  e.label.Text=e.part.Name..' • '..math.max(0,math.ceil(e.hp))
  if e.hp<=0 then
   enemies[e.part]=nil; e.part:Destroy()
   for player,hitTime in pairs(e.hits) do
    local st=states[player]
    if st and st.floor==e.floor and now-hitTime<30 then st.kills=st.kills+1; st.coins=st.coins+(e.boss and 250 or 15*e.floor); if e.boss then st.won=true end; send(player,e.boss and 'Victory! You defeated the Abyssal Guardian.' or '+ Aether fragments') end
   end
   task.delay(e.boss and 35 or 12,function() spawnEnemy(e.floor,rng:NextInteger(1,3),e.boss) end)
  end
 end
end)
local accumulator=0
RunService.Heartbeat:Connect(function(dt)
 accumulator=accumulator+dt; if accumulator<.1 then return end; local step=math.min(accumulator,.3); accumulator=0
 local now=os.clock()
 for _,e in pairs(enemies) do
  local nearest,dist,targetPlayer=nil,26,nil
  for p,s in pairs(states) do
   local c=p.Character; local root=c and c:FindFirstChild('HumanoidRootPart'); local h=c and c:FindFirstChildOfClass('Humanoid')
   if s.floor==e.floor and root and h and h.Health>0 then local d=(root.Position-e.part.Position).Magnitude; if d<dist then nearest=root; dist=d; targetPlayer=p end end
  end
  if nearest then
   local delta=Vector3.new(nearest.Position.X,e.part.Position.Y,nearest.Position.Z)-e.part.Position
   local reach=e.boss and 9 or 5
   if delta.Magnitude>reach and now>e.frozen then e.part.Position=e.part.Position+delta.Unit*math.min(delta.Magnitude-reach,(e.boss and 7 or 9+e.floor)*step) end
   if dist<reach+2 and now>e.attack then
    e.attack=now+1.2; local s=states[targetPlayer]; local h=nearest.Parent:FindFirstChildOfClass('Humanoid')
    if h and now>s.shield and now>s.dodgeUntil then h:TakeDamage(e.boss and 25 or 5+e.floor*2) end
   end
  end
 end
end)
-- Kill plane configured in Studio, not by a runtime script.
game:GetService('Lighting').ClockTime=0
game:GetService('Lighting').Ambient=Color3.fromRGB(75,80,110)
game:GetService('Lighting').Brightness=1

