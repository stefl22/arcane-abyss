local Run=game:GetService('RunService')
local player=game.Players.LocalPlayer
local folder=workspace:WaitForChild('AbismoArcano'):WaitForChild('EnvironmentVFXV9')
local fixtures={}
for _,model in folder:GetChildren() do
 local lights,particles={},{}
 for _,v in model:GetDescendants() do
  if v:IsA('PointLight') then table.insert(lights,v) elseif v:IsA('ParticleEmitter') then table.insert(particles,v) end
 end
 table.insert(fixtures,{model=model,lights=lights,particles=particles,active=nil})
end
local elapsed=0
Run.Heartbeat:Connect(function(dt)
 elapsed=elapsed+dt; if elapsed<.1 then return end; elapsed=0
 local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 if not root then return end
 for i,item in fixtures do
  local distance=(item.model:GetPivot().Position-root.Position).Magnitude
  local active=distance<105 and math.abs(item.model:GetPivot().Position.Y-root.Position.Y)<45
  if item.active~=active then
   item.active=active
   for _,e in item.particles do e.Enabled=active end
   for _,l in item.lights do l.Enabled=active end
  end
  if active then for _,l in item.lights do l.Brightness=(l:GetAttribute('BaseBrightness') or 1)*(1+math.noise(os.clock()*2.5,i)*.15) end end
 end
end)
