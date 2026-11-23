if jit then jit.off() end
love.graphics.setDefaultFilter("nearest", "nearest")
math.randomseed(os.time())

Empty = 0
Blue = 1
Red = 2
Green = 3
Yellow = 4

Board = {}
Board.tiles = {}
Board.walkers = {}
Board.x = 0
Board.y = 0

Tilesize = 16

function Board.new(x,y)
	x = x or 10
	y = y or 10
	local tbl = {}
	tbl.x = x
	tbl.y = y

	tbl.tiles = {}
	for i = 1,y do
		tbl.tiles[i] = tbl.tiles[i] or {}
		for j = 1,x do
			tbl.tiles[i][j] = Empty
		end
	end

	tbl.walkers = {}

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
			if self.tiles[i][j] == Empty then
				love.graphics.setColor(1,1,1)
				love.graphics.rectangle("line",j*Tilesize,i*Tilesize,Tilesize,Tilesize)
			else
				if self.tiles[i][j] == Blue then
					love.graphics.setColor(0,0,1)
				elseif self.tiles[i][j] == Red then
					love.graphics.setColor(1,0,0)
				elseif self.tiles[i][j] == Green then
					love.graphics.setColor(0,1,0)
				elseif self.tiles[i][j] == Yellow then
					love.graphics.setColor(1,1,0)
				end
				love.graphics.rectangle("fill",j*Tilesize,i*Tilesize,Tilesize,Tilesize)
			end
		end
	end

	for _,v in pairs(self.walkers) do
		local j = v.x
		local i = v.y
		if v.color == Blue then
			love.graphics.setColor(0,0,1)
		elseif v.color == Red then
			love.graphics.setColor(1,0,0)
		elseif v.color == Green then
			love.graphics.setColor(0,1,0)
		elseif v.color == Yellow then
			love.graphics.setColor(1,1,0)
		end
		love.graphics.rectangle("fill",j*Tilesize + (Tilesize/4),i*Tilesize + (Tilesize/4),Tilesize/2,Tilesize/2)
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line",j*Tilesize + (Tilesize/4),i*Tilesize + (Tilesize/4),Tilesize/2,Tilesize/2)
	end
end

Walker = {}
Walker.color = Empty
Walker.x = 1
Walker.y = 1

function Walker.new(color,x,y,map)
	local tbl = {}
	tbl.color = color or Empty
	tbl.x = x or 1
	tbl.y = y or 1

	local mt = {
		__index = Walker
	}

	local t =  setmetatable(tbl,mt)
	if map then
		table.insert(map.walkers,t)
		if (tbl.x >= 1) and (tbl.x <= map.x) and (tbl.y >= 1) and (tbl.y <= map.y) then
			map.tiles[t.y][t.x] = tbl.color
		end
	end

	return t
end

function Walker:RandomWalk(M)
	if (self.x >= 1) and (self.x <= M.x) and (self.y >= 1) and (self.y <= M.y) then
		local n = math.random(1,5)
		if n == 1 then
			-- right
			local x = self.x + 1
			if x <= M.x and ((M.tiles[self.y][x] == Empty) or (M.tiles[self.y][x] == self.color)) then
				self.x = x
				M.tiles[self.y][self.x] = self.color
			end
		elseif n == 2 then
			-- left
			local x = self.x - 1
			if x >= 1 and ((M.tiles[self.y][x] == Empty) or (M.tiles[self.y][x] == self.color)) then
				self.x = x
				M.tiles[self.y][self.x] = self.color
			end
		elseif n == 3 then
			-- up
			local y = self.y + 1
			if y <= M.y and ((M.tiles[y][self.x] == Empty) or (M.tiles[y][self.x] == self.color)) then
				self.y = y
				M.tiles[self.y][self.x] = self.color
			end
		elseif n == 4 then
			-- down
			local y = self.y - 1
			if y >= 1 and ((M.tiles[y][self.x] == Empty) or (M.tiles[y][self.x] == self.color)) then
				self.y = y
				M.tiles[self.y][self.x] = self.color
			end
		elseif n == 5 then
			-- nothing
		end
	end
end

Map = Board.new(48,36)
Walk1 = Walker.new(Blue,1,1,Map)
Walk2 = Walker.new(Red,14,1,Map)
Walk3 = Walker.new(Green,1,10,Map)
Walk4 = Walker.new(Yellow,14,10,Map)

function love.load()
	
end

function love.update(dt)
	WalkerTimer = WalkerTimer or 0
	WalkerTimer = WalkerTimer + dt
	-- if WalkerTimer > 0.125 then
		Walk1:RandomWalk(Map)
		Walk2:RandomWalk(Map)
		Walk3:RandomWalk(Map)
		Walk4:RandomWalk(Map)
		WalkerTimer = 0
	-- end
end

function love.keypressed(key)
	if key == "return" then
		Map = Board.new(48,36)
		Walk1 = Walker.new(Blue,1,1,Map)
		Walk2 = Walker.new(Red,14,1,Map)
		Walk3 = Walker.new(Green,1,10,Map)
		Walk4 = Walker.new(Yellow,14,10,Map)
	end
end

function love.mousepressed(x,y,button)
	
end

function love.draw()
	Map:draw()
end
