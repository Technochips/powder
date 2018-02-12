function love.load()
	matter = {}
	matter[0] = {"Empty", {0, 0, 0}, 0, 0}
	matter[1] = {"Wall", {192, 192, 192}, 1, 2000}
	matter[2] = {"Sand", {231, 212, 166}, 2, 120}
	matter[3] = {"Water", {33, 50, 215}, 3, 100}
	matter[4] = {"Dust", {225, 222, 214}, 2, 80}
	matter[5] = {"Heavy liquid(?)", {109, 27, 27}, 3, 150}
	matter[6] = {"Light Wall", {121, 203, 215}, 1, 100}
	matter[7] = {"Very Light Wall", {101, 209, 225}, 1, 75}
	matter[8] = {"Salt", {230, 230, 230}, 2, 120}

	love.graphics.setBackgroundColor(matter[1][2])

	worldWidth = 100
	worldHeight = 100
	world = {}
	for x = 1, worldWidth do
		world[x] = {}
		for y = 1, worldHeight do
			--[[if y > worldHeight / 2 then
				world[x][y] = 0
			elseif y == worldHeight / 2 then
				world[x][y] = 1
			else
				world[x][y] = 3
			end]]
			world[x][y] = 0
		end
	end

	selectedElement = 2

	timermax = 0
	timer = timermax
	titletimermax = 1
	titletimer = titletimermax

	scale = 4

	cx = nil
	cy = nil

	running = true
end

function love.update(dt)
	cx = math.floor(love.mouse.getX() / scale)
	cy = math.floor(love.mouse.getY() / scale)
	if cx > 0 and cx < worldWidth and cy > 0 and cy < worldHeight then
		love.mouse.setVisible(false)
		if love.mouse.isDown(1) then
			setPixel(cx, cy, selectedElement)
		end
	else
		love.mouse.setVisible(true)
		cx = nil
		cy = nil
	end

	if running then
		timer = timer - dt
		if timer <= 0 then
			worldupdate()
			timer = timermax
		end
	end
	titletimer = titletimer - dt
	if titletimer <= 0 then
		love.window.setTitle(love.timer.getFPS())
		titletimer = titletimermax
	end
end
function worldupdate()
	local nworld = {}
	hasSwapped = {}
	for x = 1, worldWidth do
		hasSwapped[x] = {}
		for y = 1, worldHeight do
			hasSwapped[x][y] = false
		end
	end
	for x = 1, worldWidth do
		nworld[x] = {}
		for y = 1, worldHeight do
			local currentPixel = matter[getPixel(x, y, nworld)]
			local belowPixel = matter[getPixel(x, y + 1, nworld)]
			if currentPixel[3] == 2 then
				if belowPixel[3] == 0 or belowPixel[4] < currentPixel[4] then
					swap(x, y, x, y + 1, nworld)
				else
					local leftPixel = matter[getPixel(x - 1, y + 1)]
					local rightPixel = matter[getPixel(x + 1, y + 1)]
					local left = leftPixel[3] == 0 or leftPixel[4] < currentPixel[4]
					local right = rightPixel[3] == 0 or rightPixel[4] < currentPixel[4]
					if left and (not right) then
						swap(x, y, x - 1, y + 1, nworld)
					elseif right and (not left) then
						swap(x, y, x + 1, y + 1, nworld)
					elseif right and left then
						local r = love.math.random() > 0.5
						if r then
							swap(x, y, x + 1, y + 1, nworld)
						else
							swap(x, y, x - 1, y + 1, nworld)
						end
					end
				end
			elseif currentPixel[3] == 3 then
				if belowPixel[3] == 0 or belowPixel[4] < currentPixel[4] then
					swap(x, y, x, y + 1, nworld)
				else
					local leftPixel = matter[getPixel(x - 1, y + 1)]
					local rightPixel = matter[getPixel(x + 1, y + 1)]
					local left = leftPixel[3] == 0 or leftPixel[4] < currentPixel[4]
					local right = rightPixel[3] == 0 or rightPixel[4] < currentPixel[4]
					if left and (not right) then
						swap(x, y, x - 1, y + 1, nworld)
					elseif right and (not left) then
						swap(x, y, x + 1, y + 1, nworld)
					elseif right and left then
						local r = love.math.random() > 0.5
						if r then
							swap(x, y, x + 1, y + 1, nworld)
						else
							swap(x, y, x - 1, y + 1, nworld)
						end
					elseif (not left) and (not right) then
						local leftPixel = matter[getPixel(x - 1, y)]
						local rightPixel = matter[getPixel(x + 1, y)]
						local left = leftPixel[3] == 0 or leftPixel[4] < currentPixel[4]
						local right = rightPixel[3] == 0 or rightPixel[4] < currentPixel[4]
						local r = love.math.random()
						if left and (not right) then
							if r > 0.5 then
								swap(x, y, x - 1, y , nworld)
							end
						elseif (not left) and right then
							if r > 0.5 then
								swap(x, y, x + 1, y , nworld)
							end
						elseif left and right then
							if r > 1/3 and r <= (1/3) * 2 then
								swap(x, y, x - 1, y , nworld)
							elseif r > (1/3) * 2 then
								swap(x, y, x + 1, y , nworld)
							end
						end
					end
				end
			end
		end
	end
end

function swap(x1, y1, x2, y2, oworld, nworld)
	if (not hasSwapped[x1][y1]) and (not hasSwapped[x2][y2]) then
		local nw = true
		if nworld == nil then
			nworld = world
			nw = false
		end
		setPixel(x1, y1, getPixel(x2, y2, oworld), nworld)
		setPixel(x2, y2, getPixel(x1, y1, oworld), nworld)
		hasSwapped[x1][y1] = true
		hasSwapped[x2][y2] = true
	end
end

function getPixel(x, y, nworld)
	local nw = true
	if nworld == nil then
		nworld = world
		nw = false
	end
	if x > 0 and x < worldWidth and y > 0 and y < worldHeight then
		if nworld[x] == nil then
			nworld[x] = {}
		end
		if nworld[x][y] == nil then
			if nw then
				nworld[x][y] = getPixel(x, y) --recursions are scary man
			else
				nworld[x][y] = 0
			end
		end
		return nworld[x][y]
	else
		return 1
	end
end

function setPixel(x, y, i, nworld)
	local nw = true
	if nworld == nil then
		nworld = world
		nw = false
	end
	if x > 0 and x < worldWidth and y > 0 and y < worldHeight then
		nworld[x][y] = i
		return true
	end
	return false
end

function love.draw()
	love.graphics.scale(scale)
	for x = 1, worldWidth do
		for y = 1, worldHeight do
			if cx == x and cy == y then
				love.graphics.setColor(inverseColor(matter[getPixel(x, y)][2]))
			else
				love.graphics.setColor(matter[getPixel(x, y)][2])
			end
			love.graphics.rectangle("fill", x - 1, y - 1, 1, 1)
		end
	end
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(selectedElement .. ": " .. matter[selectedElement][1], 5, worldHeight + 5)
end

function love.wheelmoved(x, y)
	if y > 0 then
		selectedElement = selectedElement + 1
		if selectedElement > #matter then
			selectedElement = 0
		end
	elseif y < 0 then
		selectedElement = selectedElement - 1
		if selectedElement < 0 then
			selectedElement = #matter
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		running = not running
	end
end

function inverseColor(c)
	return {inverseByte(c[1]), inverseByte(c[2]), inverseByte(c[3])}
end
function inverseByte(b)
	return (b * -1) + 255
end