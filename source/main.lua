import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/object"

local gfx <const> = playdate.graphics
local font = gfx.font.new('font/Mini Sans 2X') -- DEMO
assert(font)
local fontHeight = font:getHeight()
local paragraphs = {}

local function loadGame()
	gfx.setFont(font) -- DEMO
	local book = playdate.file.open('books/trial.txt')
	assert(book)
	local lines = {}
	while true do
		local line = book:readline()
		if line == nil then break
		elseif line == "" and next(lines) then
			table.insert(paragraphs, table.concat(lines, " "))
			lines = {}
		elseif line ~= "" then
			table.insert(lines, line)
		end
	end
end

local currentParagraph = 1
local currentTop = 0
local topLine = 0
local bottomLine = 0
local images = {}

local function getInput()
	local delta = 0
	if playdate.buttonIsPressed(playdate.kButtonDown) then
		delta += 4
	end
	if playdate.buttonIsPressed(playdate.kButtonUp) then
		delta -= 4
	end
	local ticks = playdate.getCrankTicks(fontHeight * 10)
	if ticks then
		delta += ticks
	end

	currentTop = math.max(0, currentTop + delta)
end

local function createImages()
	while bottomLine < currentTop + 240 do
		local text = paragraphs[currentParagraph]
		currentParagraph += 1
		print(text)
		local image = gfx.imageWithText(text, 390, 20000)
		assert(image)
		local width, height = image:getSize()
		table.insert(images, {image = image, y = bottomLine})
		bottomLine += height + fontHeight
	end
end

local function drawGame()
	createImages()
	gfx.clear()
	for i, image in pairs(images) do
		image.image:draw(5, image.y - currentTop)
	end
end

loadGame()

function playdate.update()
	getInput()
	drawGame()
end