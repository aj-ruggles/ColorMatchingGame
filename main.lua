-- Austin Ruggles 371 
-- This is my own work ;)


local numOfTilesX = 1000		-- num of x tiles
local numOfTilesY = 1000		-- num of y tiles


-- total num of tiles
--
--	this should be an even num to avoid parity 
--		errors in random color match.
--
local numOfTiles  = numOfTilesX * numOfTilesY 


--size of the title bar
local titleBar = 45


--Breakdown the entire screen to find the size of each tile
local xx = (display.contentWidth)/numOfTilesX
local yy = (display.contentHeight-titleBar)/numOfTilesY


-- setup a score system
--
--	Simple scoring system.
--   --Added pairs left amount to titlebar
--
local score = 0
local pairsL = numOfTiles/2
local scoreText = display.newText( "score:"..score, display.contentWidth/3, titleBar/2, Helvetica, 40 )
local pairsText = display.newText( "pairs:"..pairsL, display.contentWidth-display.contentWidth/3, titleBar/2, Helvetica, 40 )
local function updateScore( amount )

	score = amount + score
	scoreText.text = string.format( "score:%d", score )

end

local function updatePairs( )

	pairsL = pairsL - 1
	pairsText.text = string.format( "pairs:%d", pairsL )

end


-- setup random color gen
--
--	
--
math.randomseed( os.time() )	-- seed numbers


-- assuming we want "pairs" of colors
--
--	ToDo: fix .. 
--		if numOfTiles/2 is odd 
--          we might end up with 
--			odd number of paired colors.
--
local numOfColors = math.ceil( numOfTiles/2 )



-- return an array of evenly distributed floats
-- 
--	these will be used to create the colors
--		one array per "RGB"
-- the index will match the triplet.
--
local function colorArray( )

	local colorIndex = {}
	local tmpArray 	= {}

	for i=1, numOfColors do

	 	colorIndex[i] = i

	end

	local cnt = 1
	while table.getn( colorIndex ) > 0 do

		idx = math.random(1, table.getn( colorIndex ))
		tmpArray[cnt] = colorIndex[idx]/numOfColors
		table.remove(colorIndex, idx)
		cnt = cnt + 1

	end

	return tmpArray

end


-- initialize the RGB triplet
local r = colorArray()
local g = colorArray()
local b = colorArray()



-- create a table of colors,
--  with the number each can be used.
local colors = {}

for i=1, numOfColors do
	colors[i] = { r[i], g[i], b[i], 2 }
end


--
--
--
--
-- simple transitions to add some pizazz!!!
local function bounceDown( target )

	transition.to( target, {time = 150, xScale = .8, yScale = .8})

end

local function bounceUp( target )

	transition.to( target, {time = 200, xScale = 1, yScale = 1})

end

local function bounceOut( target )
	--after this transition remove object
	transition.to( target, {time = 800, xScale = 6, yScale = 6, onComplete=function(obj) obj:removeSelf(); obj = nil end})

end

local function fadeOut( target )
	--start bounce out 
	transition.fadeOut( target, {time = 500, transition=easing.outCubic, onStart=bounceOut} )

end 


local check = 1 	-- check to see if we just matched and restart prevTarget
local prevTarget	-- keep the last known target

local function mark( event )

	if check == 1 then
		-- prevTarget dose not exist so set a new one.
		check = 0
		prevTarget = event.target

	end

	if not event.target.marked then
		-- mark the current target
		event.target.marked = true
		bounceDown( event.target )

	else
		-- if marked then unmark it.
		event.target.marked = false
		bounceUp( event.target )
		check = 1

	end

	if event.target.marked and (prevTarget ~= event.target) then

		if event.target.color == prevTarget.color then
			-- if colors match than remove them
			fadeOut(event.target)
			fadeOut(prevTarget)
			--print(" match ")
			updateScore( 5 )
			updatePairs( )
			check = 1

		else
			-- colors don't match unmark prev, mark new.
			prevTarget.marked = false
			bounceUp(prevTarget)
			bounceDown(event.target)
			updateScore( -5 )
			--print(" mis-match ")

		end
	end

	prevTarget = event.target

end


for i=1,numOfTilesX do 			-- rows

	for j=1,numOfTilesY do  	-- columns


		-- create new tiles
		local mb = display.newRect( xx*i-xx/2, yy*j-yy/2+titleBar, xx, yy )


		-- find random color and set the tile color
		idx = math.random( 1, table.getn( colors ) )
		mb:setFillColor( colors[idx][1], colors[idx][2], colors[idx][3] )

		-- create unique color identifier as string.
		mb.color = colors[idx][1]..colors[idx][2]..colors[idx][3]
		mb.marked = false	--set the marked variable to false as default

		if colors[idx][4] > 1 then 
			-- if color selected remove 1 color pair
			colors[idx][4] = colors[idx][4] - 1

		else
			-- when both color pairs selected remove from the list of available colors
			table.remove(colors, idx)

		end



		-- event listener for tap
		mb:addEventListener( "tap", mark )

	end
end