if jit then jit.off() end
love.graphics.setDefaultFilter("nearest", "nearest")
math.randomseed(os.time())

ObservationTime = 0.05
NoConstrain = false
GrassWeight = 3
NoBuds = true

Superposition = 0
Grass = 1
Cross = 2
Horizontal = 3
Vertical = 4
Left_Down_L = 5
Left_Up_L = 6
Right_Down_L = 7
Right_Up_L = 8
Left_Bud = 9
Right_Bud = 10
Up_Bud = 11
Down_Bud = 12
City = 13

Images = {
	[Grass] = love.graphics.newImage("/grass.png"),
	[Cross] = love.graphics.newImage("/cross.png"),
	[Horizontal] = love.graphics.newImage("/horizontal.png"),
	[Vertical] = love.graphics.newImage("/vertical.png"),
	[Left_Down_L] = love.graphics.newImage("/left_down_l.png"),
	[Left_Up_L] = love.graphics.newImage("/left_up_l.png"),
	[Right_Down_L] = love.graphics.newImage("/right_down_l.png"),
	[Right_Up_L] = love.graphics.newImage("/right_up_l.png"),
	[Left_Bud] = love.graphics.newImage("/left_bud.png"),
	[Right_Bud] = love.graphics.newImage("/right_bud.png"),
	[Up_Bud] = love.graphics.newImage("/up_bud.png"),
	[Down_Bud] = love.graphics.newImage("/down_bud.png"),
	[City] = love.graphics.newImage("/city.png"),
}

AllowedList = {}
AllowedList.list = {}
function AllowedList.new(list)
	local tbl = {
		list = {}
	}

	if list then
		for i,v in pairs(list) do
			tbl.list[i] = {allowed = true, val = v, weight = 1}
		end
	end

	local mt = {
		__index = AllowedList
	}

	return setmetatable(tbl,mt)
end

function AllowedList:setWeight(i,n)
	if self.list[i] then
		n = n or 1
		if n < 1 then
			n = 1
		end
		self.list[i].weight = n
	end
end

function AllowedList:allow(i)
	if self.list[i] then
		self.list[i].allowed = true
	end
end

function AllowedList:disallow(i)
	if self.list[i] then
		self.list[i].allowed = false
	end
end

function AllowedList:disallowList(li)
	if li then
		for _, i in pairs(li) do
			if self.list[i] then
				self.list[i].allowed = false
			end
		end
	end
end

function AllowedList:getList()
	local tbl = {}
	for i,v in pairs(self.list) do
		if v.allowed then
			for n = 1,v.weight do
				table.insert(tbl,v.val)
			end
		end
	end

	return tbl
end

Board = {}
Board.tiles = {}
Board.x = 0
Board.y = 0
Board.ox = 1
Board.oy = 1

Tilesize = 64

function Board.new(x,y)
	x = x or 10
	y = y or 10
	local tbl = {}
	tbl.x = x
	tbl.y = y
	tbl.ox = 1
	tbl.oy = 1

	tbl.tiles = {}
	for i = 1,y do
		tbl.tiles[i] = tbl.tiles[i] or {}
		for j = 1,x do
			tbl.tiles[i][j] = Superposition
		end
	end

	local mt = {
		__index = Board
	}

	return setmetatable(tbl,mt)
end

function Board:set(x,y,c)
	self.tiles[y][x] = c or Empty
end

function Board:draw()
	for i = 1, self.y do
		for j = 1, self.x do
			local n = self.tiles[i][j]
			if n == Superposition then
				love.graphics.setColor(1,1,1)
				love.graphics.rectangle("line",j*Tilesize - 16,i*Tilesize - 24,Tilesize,Tilesize)
			else
				local img = Images[n]
				if img then
					love.graphics.draw(img,j*Tilesize - 16,i*Tilesize - 24)
					-- love.graphics.print(string.format("%d %d",j,i),j*Tilesize - 16,i*Tilesize - 24)
				end
			end
		end
	end
end

function Board:Observe()
	local x = self.ox
	local y = self.oy
	if (x >= 1) and (x <= self.x) and (y >= 1) and (y <= self.y) then
		if self.tiles[y][x] == Superposition then
			local up, down, left, right
			-- if (y + 1) <= self.y then
			-- 	down = self.tiles[y + 1][x]
			-- 	if down == Superposition then
			-- 		down = nil
			-- 	end
			-- end

			if (y - 1) >= 1 then
				up = self.tiles[y - 1][x]
				if up == Superposition then
					up = nil
				end
			end

			-- if (x + 1) <= self.x then
			-- 	right = self.tiles[y][x + 1]
			-- 	if right == Superposition then
			-- 		right = nil
			-- 	end
			-- end

			if (x - 1) >= 1 then
				left = self.tiles[y][x - 1]
				if left == Superposition then
					left = nil
				end
			end

			local allowed
			if NoBuds then
				allowed = AllowedList.new({[Grass] = Grass,[Cross] = Cross,[Horizontal] = Horizontal,
												[Vertical] = Vertical,[Left_Down_L] = Left_Down_L,[Left_Up_L] = Left_Up_L,
												[Right_Down_L] = Right_Down_L,[Right_Up_L] = Right_Up_L,[City] = City}
				)
			else
				allowed = AllowedList.new({[Grass] = Grass,[Cross] = Cross,[Horizontal] = Horizontal,
											[Vertical] = Vertical,[Left_Down_L] = Left_Down_L,[Left_Up_L] = Left_Up_L,
											[Right_Down_L] = Right_Down_L,[Right_Up_L] = Right_Up_L,[Left_Bud] = Left_Bud,
											[Right_Bud] = Right_Bud,[Up_Bud] = Up_Bud,[Down_Bud] = Down_Bud,[City] = City}
				)
			end

			allowed:setWeight(Grass,GrassWeight)

			if ((up) or (down) or (left) or (right)) and (not NoConstrain) then
				if (up == Grass) then
					allowed:disallowList({Cross,Vertical,Left_Up_L,Right_Up_L,Down_Bud})
				end

				if (up == Cross) or (up == Vertical) then
					allowed:disallowList({Grass,Horizontal,Left_Down_L,Right_Down_L,Left_Bud,Right_Bud,Up_Bud,City})
				end

				if (up == Horizontal) then
					allowed:disallowList({Cross,Vertical,Left_Up_L,Right_Up_L,Down_Bud})
				end

				if (up == Left_Down_L) then
					allowed:disallowList({Grass,Horizontal,Right_Down_L,Left_Down_L,Left_Bud,Right_Bud,Up_Bud,City})
				end

				if (up == Left_Up_L) then
					allowed:disallowList({Cross,Vertical,Horizontal,Right_Up_L,Left_Up_L,Down_Bud})
				end

				if (up == Right_Down_L) then
					allowed:disallowList({Grass,Horizontal,Left_Down_L,Right_Down_L,Left_Bud,Right_Bud,Up_Bud,City})
				end

				if (up == Right_Up_L) then
					allowed:disallowList({Cross,Vertical,Horizontal,Left_Up_L,Right_Up_L,Down_Bud})
				end

				if (up == Left_Bud) then
					allowed:disallowList({Cross,Vertical,Left_Up_L,Right_Up_L,Down_Bud})
				end

				if (up == Right_Bud) then
					allowed:disallowList({Cross,Vertical,Left_Up_L,Right_Up_L,Down_Bud})
				end

				if (up == Up_Bud) then
					allowed:disallowList({Grass,Horizontal,Left_Down_L,Right_Down_L,Left_Bud,Right_Bud,Up_Bud,City})
				end

				if (up == Down_Bud) then
					allowed:disallowList({Cross,Vertical,Horizontal,Left_Up_L,Right_Up_L,Down_Bud})
				end

				if (up == City) then
					allowed:disallowList({Cross,Vertical,Left_Up_L,Right_Up_L,Down_Bud})
				end

				if (left == Grass) then
					allowed:disallowList({Left_Down_L,Left_Up_L,Left_Bud,Horizontal,Cross})
				end

				if (left == Cross) then
					allowed:disallowList({Grass,Vertical,Right_Down_L,Right_Up_L,Right_Bud,Up_Bud,Down_Bud,City})
				end

				if (left == Vertical) then
					allowed:disallowList({Cross,Horizontal,Left_Down_L,Left_Up_L,Left_Bud})
				end

				if (left == Horizontal) then
					allowed:disallowList({City,Vertical,Down_Bud,Grass,Right_Bud,Right_Down_L,Right_Up_L})
				end

				if (left == Left_Down_L) then
					allowed:disallowList({Cross,Horizontal,Left_Bud,Left_Down_L,Left_Up_L})
				end

				if (left == Left_Up_L) then
					allowed:disallowList({Cross,Horizontal,Left_Bud,Left_Down_L,Left_Up_L})
				end

				if (left == Right_Down_L) then
					allowed:disallowList({Grass,Vertical,City,Down_Bud,Up_Bud,Right_Bud,Right_Down_L,Right_Up_L})
				end

				if (left == Right_Up_L) then
					allowed:disallowList({Grass,Vertical,City,Down_Bud,Up_Bud,Right_Bud,Right_Down_L,Right_Up_L})
				end

				if (left == Left_Bud) then
					allowed:disallowList({Cross,Horizontal,Left_Bud,Left_Down_L,Left_Up_L})
				end

				if (left == Right_Bud) then
					allowed:disallowList({Grass,Vertical,City,Down_Bud,Up_Bud,Right_Bud,Right_Down_L,Right_Up_L})
				end

				if (left == Up_Bud) then
					allowed:disallowList({Cross,Horizontal,Left_Down_L,Left_Up_L,Left_Bud})
				end

				if (left == Down_Bud) then
					allowed:disallowList({Cross,Horizontal,Left_Down_L,Left_Up_L,Left_Bud})
				end

				if (left == City) then
					allowed:disallowList({Cross,Horizontal,Left_Down_L,Left_Up_L,Left_Bud})
				end
			end

			allowed = allowed:getList()
			self.tiles[y][x] = allowed[math.random(1,#allowed)] or Superposition
		end
	end

	self.ox = self.ox + 1
	if(self.ox > self.x) then
		self.ox = 1
		self.oy = self.oy + 1
		if(self.oy > self.y) then
			self.oy = 1
		end
	end
end

function IncreaseObserveTime()
	ObservationTime = math.min(5,ObservationTime + 0.01)
end

function DecreaseObserveTime()
	ObservationTime = math.max(0,ObservationTime - 0.01)
end

function ToggleConstrain()
	NoConstrain = not NoConstrain
end

function DecreaseGrassWeight()
	GrassWeight = math.max(1,GrassWeight - 1)
end

function IncreaseGrassWeight()
	GrassWeight = GrassWeight + 1
end

function ToggleBuds()
	NoBuds = not NoBuds
end

function ResetMap()
	Map = Board.new(11,8)
end

ResetMap()

Otr_f = 0
Oti_f = 0
Oc_f = 0
Gwr_f = 0
Gwi_f = 0
B_f = 0
R_f = 0

function TintFocus(t)
	if t <= 0 then
		love.graphics.setColor(1,1,1)
	else
		local T = math.min(t,0.25)/0.25
		local c = 1*(1 - T) + 0.7*T
		love.graphics.setColor(c,c,c)
	end
end

function Inside(x,y,lx,ly,w,h)
	return (x >= lx) and (x <= lx + w) and (y >= ly) and (y <= ly + h)
end

function love.load()
	
end

function love.update(dt)
	ObservationTimer = ObservationTimer or 0
	ObservationTimer = ObservationTimer + dt
	if ObservationTimer > ObservationTime then
		Map:Observe()
		ObservationTimer = 0
	end

	local x, y = love.mouse.getPosition()
	if Inside(x,y,200,570,25,25) then
		Otr_f = Otr_f + dt
	else
		Otr_f = 0
	end

	if Inside(x,y,230,570,25,25) then
		Oti_f = Oti_f + dt
	else
		Oti_f = 0
	end

	if Inside(x,y,450,570,25,25) then
		Oc_f = Oc_f + dt
	else
		Oc_f = 0
	end

	if Inside(x,y,200,645,25,25) then
		Gwr_f = Gwr_f + dt
	else
		Gwr_f = 0
	end

	if Inside(x,y,230,645,25,25) then
		Gwi_f = Gwi_f + dt
	else
		Gwi_f = 0
	end

	if Inside(x,y,450,645,25,25) then
		B_f = B_f + dt
	else
		B_f = 0
	end

	if Inside(x,y,600,600,25,25) then
		R_f = R_f + dt
	else
		R_f = 0
	end
end

function love.keypressed(key)
	if key == "return" or key == "r" then
		ResetMap()
	end

	if key == "-" then
		DecreaseObserveTime()
	end

	if key == "=" then
		IncreaseObserveTime()
	end

	if key == "," then
		DecreaseGrassWeight()
	end

	if key == "." then
		IncreaseGrassWeight()
	end

	if key == "c" then
		ToggleConstrain()
	end

	if key == "b" then
		ToggleBuds()
	end
end

function love.mousepressed(x,y,button)
	if Otr_f > 0 then
		DecreaseObserveTime()
	end

	if Oti_f > 0 then
		IncreaseObserveTime()
	end

	if Oc_f > 0 then
		ToggleConstrain()
	end

	if Gwr_f > 0 then
		DecreaseGrassWeight()
	end

	if Gwi_f > 0 then
		IncreaseGrassWeight()
	end

	if B_f > 0 then
		ToggleBuds()
	end

	if R_f > 0 then
		ResetMap()
	end
end

function love.draw()
	Map:draw()

	love.graphics.print("Observe Time: "..string.format("%.02f",ObservationTime).." +/-",50,575)
	love.graphics.print("Constrain (c): "..tostring(not NoConstrain),300,575)
	love.graphics.print("Reset (enter/return)",550,575)
	love.graphics.print("Grass Weight: "..string.format("%d",GrassWeight),50,650)
	love.graphics.print("Road Buds (b): "..tostring(not NoBuds),300,650)

	TintFocus(Otr_f)
	love.graphics.rectangle("fill",200,570,25,25)
	love.graphics.print({{0,0,0},"-"},200 + 8,575)

	TintFocus(Oti_f)
	love.graphics.rectangle("fill",230,570,25,25)
	love.graphics.print({{0,0,0},"+"},230 + 8,575)

	TintFocus(Oc_f)
	love.graphics.rectangle("fill",450,570,25,25)
	love.graphics.print({{0,0,0},"C"},450 + 8,575)

	TintFocus(B_f)
	love.graphics.rectangle("fill",450,645,25,25)
	love.graphics.print({{0,0,0},"B"},450 + 8,650)

	TintFocus(R_f)
	love.graphics.rectangle("fill",600,600,25,25)
	love.graphics.print({{0,0,0},"R"},600 + 8,605)

	TintFocus(Gwr_f)
	love.graphics.rectangle("fill",200,645,25,25)
	love.graphics.print({{0,0,0},"<"},200 + 8,650)

	TintFocus(Gwi_f)
	love.graphics.rectangle("fill",230,645,25,25)
	love.graphics.print({{0,0,0},">"},230 + 8,650)

	love.graphics.setColor(1,1,1)
end
