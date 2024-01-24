import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "string_helpers"

local gfx <const> = playdate.graphics
local margin <const> = 5

local deadzone <const> = 15
local maxLinesPerSec <const> = 6

local font = gfx.font.new('font/Mini Sans 2X') -- DEMO
assert(font)
local fontHeight = font:getHeight()

local currentTop = 0

local lines = {}

local function loadGame()
	local savedState = playdate.datastore.read("state")
	if savedState ~= nil and savedState.currentTop ~= nil then
		currentTop = savedState.currentTop
	end

	gfx.setFont(font) -- DEMO
	local book = playdate.file.open('books/trial.txt')
	assert(book)
	local paragraph = {}
	while true do
		local line = book:readline()
		if (line == nil or line == "") and next(paragraph) then
			paragraph_ = table.concat(paragraph, " ")
			fitScreen(lines, paragraph_, font, 400 - 2*margin)
			table.insert(lines, "\n")
			paragraph = {}
		elseif line ~= "" then
			table.insert(paragraph, line)
		end

        if line == nil then
            break
        end
	end
end

local function getInput(elapsedTime)
	local delta = 0
	if playdate.buttonIsPressed(playdate.kButtonDown) then
		delta += fontHeight
	end
	if playdate.buttonIsPressed(playdate.kButtonUp) then
		delta -= fontHeight
	end
	local crankPosition = playdate.getCrankPosition()
	if crankPosition then
		local divisor = 180 - 2 * deadzone
		if crankPosition > deadzone and crankPosition < 180 - deadzone then
			delta += (crankPosition / divisor) * maxLinesPerSec * fontHeight
		elseif crankPosition < 360 - deadzone and crankPosition > 180 + deadzone then
			delta -= ((360 - crankPosition) / divisor) * maxLinesPerSec  * fontHeight
		end
	end

	currentTop = math.max(0, currentTop + delta * elapsedTime)
end

local function getLines(topLineIdx, bottomLineIdx)
    return {table.unpack(lines, topLineIdx, bottomLineIdx)}
end

local function getImages(currentTop)
    local topLineIdx = math.floor(currentTop/fontHeight)
    local bottomLineIdx = math.ceil((currentTop + 240)/fontHeight)

    local lines = getLines(topLineIdx, bottomLineIdx)
    local y = - (currentTop % fontHeight)
	local images = {}
	for _, line in pairs(lines) do
		if line == "\n" then
			y += fontHeight
		else
			local image = gfx.imageWithText(line, 400 - 2 * margin)
			assert(image)
			local width, height = image:getSize()
			table.insert(images, {image = image, y = y})
			y += height
		end
	end

	return images
end

local function drawScreen(images)
	gfx.clear()
	for _, image in pairs(images) do
		image.image:draw(margin, image.y)
	end
end

loadGame()

function playdate.update()
	local elapsedTime = playdate.getElapsedTime()
	getInput(elapsedTime)
	local images = getImages(currentTop)
	drawScreen(images)
	playdate.resetElapsedTime()
end

local function saveState()
	local state = {currentTop = currentTop}
	playdate.datastore.write(state, "state")
end

function playdate.gameWillTerminate()
	saveState()
end

function playdate.deviceWillSleep()
	saveState()
end