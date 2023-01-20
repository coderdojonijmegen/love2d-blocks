---
title: "Löve2d - Blocks"
date: 2023-01-20T22:07:09+01:00
draft: false
toc: true
headercolor: "teal-background"
taal: Löve2D
---

We gaan met 2D game framework Löve2D een spel met vallende blokken maken.

<!--more-->

![voorbeeld van het spel](imgs/1.png)

## De regels

![voorbeeld van de stukken](imgs/2.png)

Er zijn 7 verschillende stuk. Elk stuk bestaat uit 4 kleinere blokken.

Stukken vallen vanaf boven het speelveld. De speler kan het stuk verplaatsen naar links en rechts en het stuk
ronddraaien. Als een stuk is geland, valt er een volgend stuk.

Boven het speelveld wordt de vorm van het volgende stuk dat gaat vallen getoond.

![voorbeeld van de vorm van het volgende stuk](imgs/3.png)

Als er een volledig gesloten rij van blokken is gevormd van links naar rechts op het speelveld, verdwijnt het
en schuiven alle blokken erboven 1 rij naar beneden.

Het spel eindigt als een nieuw stuk direct op een al liggend stuk terecht zou komen.

### Controls

| **toets**   | **actie**               |
|-------------|-------------------------|
| pijl links  | beweeg links            |
| pijl rechts | beweeg rechts           |
| z           | draai tegen de klok in  |
| x           | draai met de klok mee   |
| c           | val op liggende blokken |

## Overzicht

Een rooster bevat de blokken die al zijn gevallen. Een vak in het rooster kan leeg zijn of gevuld met een
blok van een bepaalde kleur.

Tekst `' '` (spatie) is een leeg vak zonder blok en `'i'`, `'j'`, `'l'`, `'o'`, `'s'`, `'t'` en `'z'` zijn vakken met
een blok met verschillende kleuren.

![voorbeeld het rooster met daarin de blokken](imgs/4.png)

Alle verschillende stukken worden in het rooster opgeslagen met de hoe ze gedraaid waren toen ze vielen.

![voorbeeld van gedraaide stukken](imgs/5.png)


The currently falling piece is stored as a number representing which type of piece it is, a number representing which rotation variation it is at, and numbers representing its X and Y position in the playing area.

A new piece is created at the top of the screen, unless it would overlap an inert block, in which case the game is over.

The player can move the piece left and right, unless this new position would overlap an inert block or be outside the playing area.

After an amount of time has passed, the piece moves down, unless this new position would overlap an inert block or be outside the playing area, in which case it has come to rest.

When one of the rotate buttons is pressed, the piece changes its rotation variation, unless this variation would overlap an inert block or be outside the playing area.

When the drop button is pressed, the piece moves down until the next position would overlap an inert block or be outside the playing area, at which point it has come to rest.

When a piece comes to rest, the blocks of the piece are added to the inert blocks, and the next piece is created.

A sequence of one of each of the seven pieces in a random order is created, and the next piece is taken from this sequence. Once all of the pieces have been taken, a new random sequence is created.

## Programmeren

### Het rooster tekenen

Voor ieder blok in het speelveld wordt een vierkant getekend. 

De volledige code tot op dit punt:

```lua
function love.draw()
    for y = 1, 18 do
        for x = 1, 10 do
            local blockSize = 20
            local blockDrawSize = blockSize - 1
            love.graphics.rectangle(
                'fill',
                (x - 1) * blockSize,
                (y - 1) * blockSize,
                blockDrawSize,
                blockDrawSize
            )
        end
    end
end
```
![het rooster](imgs/6.png)

### Het rooster inkleuren

De achtergrondkleur en de kleur van een leeg vak worden ingesteld.

De volledige code tot op dit punt:

```lua
function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)
end

function love.draw()
    for y = 1, 18 do
        for x = 1, 10 do
            love.graphics.setColor(.87, .87, .87)
            local blockSize = 20
            local blockDrawSize = blockSize - 1
            love.graphics.rectangle(
                'fill',
                (x - 1) * blockSize,
                (y - 1) * blockSize,
                blockDrawSize,
                blockDrawSize
            )
        end
    end
end
```
![het ingekleurde rooster](imgs/7.png)

### Storing inert blocks
The grid for the inert blocks is created and every block is set to ' ' (a string containing the space character), representing an empty block.

The width and height of the grid in blocks is reused from drawing the blocks, so they are made into variables.

Full code at this point

```lua
function love.load()
    -- etc.

    gridXCount = 10
    gridYCount = 18

    inert = {}
    for y = 1, gridYCount do
        inert[y] = {}
        for x = 1, gridXCount do
            inert[y][x] = ' '
        end
    end
end

function love.draw()
    for y = 1, gridYCount do
        for x = 1, gridXCount do
            -- etc.
        end
    end
end
```

### Setting block color
When blocks are drawn, the color is set based on what type the block is.

To test this, some blocks in the inert grid are set to different types.

Full code at this point

```lua
function love.load()
    -- etc.

    -- Temporary
    inert[18][1] = 'i'
    inert[17][2] = 'j'
    inert[16][3] = 'l'
    inert[15][4] = 'o'
    inert[14][5] = 's'
    inert[13][6] = 't'
    inert[12][7] = 'z'
end

function love.draw()
    for y = 1, gridYCount do
        for x = 1, gridXCount do
            local colors = {
                [' '] = {.87, .87, .87},
                i = {.47, .76, .94},
                j = {.93, .91, .42},
                l = {.49, .85, .76},
                o = {.92, .69, .47},
                s = {.83, .54, .93},
                t = {.97, .58, .77},
                z = {.66, .83, .46},
            }
            local block = inert[y][x]
            local color = colors[block]
            love.graphics.setColor(color)

            local blockSize = 20
            local blockDrawSize = blockSize - 1
            love.graphics.rectangle(
                'fill',
                (x - 1) * blockSize,
                (y - 1) * blockSize,
                blockDrawSize,
                blockDrawSize
            )
        end
    end
end
```
![het rooster met blokken in de verschillende kleuren](imgs/8.png)

### Storing the piece structures
Each rotation of a piece structure is stored as a 4 by 4 grid of strings.

```lua
{
    {' ', ' ', ' ', ' '},
    {'i', 'i', 'i', 'i'},
    {' ', ' ', ' ', ' '},
    {' ', ' ', ' ', ' '},
}
```
Each piece structure is stored as a table of piece rotations.

```lua
{
    {
        {' ', ' ', ' ', ' '},
        {'i', 'i', 'i', 'i'},
        {' ', ' ', ' ', ' '},
        {' ', ' ', ' ', ' '},
    },
    {
        {' ', 'i', ' ', ' '},
        {' ', 'i', ' ', ' '},
        {' ', 'i', ' ', ' '},
        {' ', 'i', ' ', ' '},
    },
}
```

All of piece structures are stored in a table.

```lua
pieceStructures = {
    {
        {
            {' ', ' ', ' ', ' '},
            {'i', 'i', 'i', 'i'},
            {' ', ' ', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 'i', ' ', ' '},
            {' ', 'i', ' ', ' '},
            {' ', 'i', ' ', ' '},
            {' ', 'i', ' ', ' '},
        },
    },
    {
        {
            {' ', ' ', ' ', ' '},
            {' ', 'o', 'o', ' '},
            {' ', 'o', 'o', ' '},
            {' ', ' ', ' ', ' '},
        },
    },
    {
        {
            {' ', ' ', ' ', ' '},
            {'j', 'j', 'j', ' '},
            {' ', ' ', 'j', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 'j', ' ', ' '},
            {' ', 'j', ' ', ' '},
            {'j', 'j', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {'j', ' ', ' ', ' '},
            {'j', 'j', 'j', ' '},
            {' ', ' ', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 'j', 'j', ' '},
            {' ', 'j', ' ', ' '},
            {' ', 'j', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
    },
    {
        {
            {' ', ' ', ' ', ' '},
            {'l', 'l', 'l', ' '},
            {'l', ' ', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 'l', ' ', ' '},
            {' ', 'l', ' ', ' '},
            {' ', 'l', 'l', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', ' ', 'l', ' '},
            {'l', 'l', 'l', ' '},
            {' ', ' ', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {'l', 'l', ' ', ' '},
            {' ', 'l', ' ', ' '},
            {' ', 'l', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
    },
    {
        {
            {' ', ' ', ' ', ' '},
            {'t', 't', 't', ' '},
            {' ', 't', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 't', ' ', ' '},
            {' ', 't', 't', ' '},
            {' ', 't', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 't', ' ', ' '},
            {'t', 't', 't', ' '},
            {' ', ' ', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 't', ' ', ' '},
            {'t', 't', ' ', ' '},
            {' ', 't', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
    },
    {
        {
            {' ', ' ', ' ', ' '},
            {' ', 's', 's', ' '},
            {'s', 's', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {'s', ' ', ' ', ' '},
            {'s', 's', ' ', ' '},
            {' ', 's', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
    },
    {
        {
            {' ', ' ', ' ', ' '},
            {'z', 'z', ' ', ' '},
            {' ', 'z', 'z', ' '},
            {' ', ' ', ' ', ' '},
        },
        {
            {' ', 'z', ' ', ' '},
            {'z', 'z', ' ', ' '},
            {'z', ' ', ' ', ' '},
            {' ', ' ', ' ', ' '},
        },
    },
}
```

### Storing the current piece
The currently falling piece is represented by a number indicating which type it is (which will be used to index the table of piece structures), and a number indicating which rotation it is at (which will be used to index the table of rotations).

```lua
function love.load()
    -- etc.

    pieceType = 1
    pieceRotation = 1
end
```

### Drawing the piece
The piece is drawn by looping through its structure, and, unless the block is empty, drawing a square with a color determined by the block type.

Full code at this point

```lua
function love.draw()
    -- etc.

    for y = 1, 4 do
        for x = 1, 4 do
            local block = pieceStructures[pieceType][pieceRotation][y][x]
            if block ~= ' ' then
                local colors = {
                    i = {.47, .76, .94},
                    j = {.93, .91, .42},
                    l = {.49, .85, .76},
                    o = {.92, .69, .47},
                    s = {.83, .54, .93},
                    t = {.97, .58, .77},
                    z = {.66, .83, .46},
                }
                local color = colors[block]
                love.graphics.setColor(color)

                local blockSize = 20
                local blockDrawSize = blockSize - 1
                love.graphics.rectangle(
                    'fill',
                    (x - 1) * blockSize,
                    (y - 1) * blockSize,
                    blockDrawSize,
                    blockDrawSize
                )
            end
        end
    end
end
```

![het rooster](imgs/9.png)

### Simplifying code
The code for drawing an inert block and drawing a block of the falling piece is similar, so a function is made.

Full code at this point

```lua
function love.draw()
    local function drawBlock(block, x, y)
        local colors = {
            [' '] = {.87, .87, .87},
            i = {.47, .76, .94},
            j = {.93, .91, .42},
            l = {.49, .85, .76},
            o = {.92, .69, .47},
            s = {.83, .54, .93},
            t = {.97, .58, .77},
            z = {.66, .83, .46},
        }
        local color = colors[block]
        love.graphics.setColor(color)

        local blockSize = 20
        local blockDrawSize = blockSize - 1
        love.graphics.rectangle(
            'fill',
            (x - 1) * blockSize,
            (y - 1) * blockSize,
            blockDrawSize,
            blockDrawSize
        )
    end

    for y = 1, gridYCount do
        for x = 1, gridXCount do
            drawBlock(inert[y][x], x, y)
        end
    end

    for y = 1, 4 do
        for x = 1, 4 do
            local block = pieceStructures[pieceType][pieceRotation][y][x]
            if block ~= ' ' then
                drawBlock(block, x, y)
            end
        end
    end
end
```
### Rotation
When the x key is pressed, the piece's rotation number is increased by 1, rotating the piece clockwise.

If the rotation number is greater than the number of rotation positions, the rotation number is set to 1 (i.e. the first rotation position).

Likewise, when the z key is pressed, the piece rotation number is decreased by 1, rotating the piece counterclockwise.

If the rotation number is less than 1, the rotation number is set to the number of rotation positions (i.e. the last rotation position).

Full code at this point

```lua
function love.keypressed(key)
    if key == 'x' then
        pieceRotation = pieceRotation + 1
        if pieceRotation > #pieceStructures[pieceType] then
            pieceRotation = 1
        end

    elseif key == 'z' then
        pieceRotation = pieceRotation - 1
        if pieceRotation < 1 then
            pieceRotation = #pieceStructures[pieceType]
        end
    end
end
```

![het rooster](imgs/10.png)

### Testing pieces
For testing purposes, the up and down arrows cycle through the piece types.

Full code at this point

```lua
function love.keypressed(key)
    -- etc.

    -- Temporary
    elseif key == 'down' then
        pieceType = pieceType + 1
        if pieceType > #pieceStructures then
            pieceType = 1
        end
        pieceRotation = 1

    -- Temporary
    elseif key == 'up' then
        pieceType = pieceType - 1
        if pieceType < 1 then
            pieceType = #pieceStructures
        end
        pieceRotation = 1
    end
end
```

![het rooster](imgs/11.png)

### Setting piece position
The position of the piece in the playing area is stored, and the piece is drawn at that position.

Full code at this point

```lua
function love.load()
    -- etc.

    pieceX = 3
    pieceY = 0
end

function love.draw()
    -- etc.

    for y = 1, 4 do
        for x = 1, 4 do
            local block = pieceStructures[pieceType][pieceRotation][y][x]
            if block ~= ' ' then
                drawBlock(block, x + pieceX, y + pieceY)
            end
        end
    end
end
```

![het rooster](imgs/12.png)

### Moving the piece
The left and right arrows subtract or add 1 to the piece's X position.

Full code at this point

```lua
function love.keypressed(key)
    -- etc.

    elseif key == 'left' then
        pieceX = pieceX - 1

    elseif key == 'right' then
        pieceX = pieceX + 1

    -- etc.
end
```

![het rooster](imgs/13.png)

### Timer
Pieces will fall every 0.5 seconds.

A timer variable starts at 0 and increases by dt each frame.

When the timer is at or above 0.5 it is reset to 0.

For now, 'tick' is printed every time the piece will fall.

Full code at this point

```lua
function love.load()
    -- etc.

    timer = 0
end

function love.update(dt)
    timer = timer + dt
    if timer >= 0.5 then
        timer = 0
        -- Temporary
        print('tick')
    end
end
```

### Falling
The timer is used to increase the piece's Y position every 0.5 seconds.

Full code at this point

```lua
function love.update(dt)
    timer = timer + dt
    if timer >= 0.5 then
        timer = 0
        pieceY = pieceY + 1
    end
end
```

![het rooster](imgs/14.png)

### Confining movement
To prevent the piece from moving off the left or right of the screen when it is moved or rotated, each of its blocks are checked to see if they are within the playing area before the piece is moved or rotated.

Because this checking will be done in multiple places, it will be written as a function. This function is given the position and rotation to check, and returns true or false depending on whether the piece can move or rotate.

To begin with, this function will always return true, so moving and rotating is still always possible.

The code is changed from immediately setting positions/rotations, to creating variables for the changed values, and if the checking function returns true, the actual position/rotation is set to the changed values.

Full code at this point

```lua
function love.load()
    -- etc.

    function canPieceMove(testX, testY, testRotation)
        return true
    end
end

function love.update(dt)
    timer = timer + dt
    if timer >= 0.5 then
        timer = 0

        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        end
    end
end

function love.keypressed(key)
    if key == 'x' then
        local testRotation = pieceRotation + 1
        if testRotation > #pieceStructures[pieceType] then
            testRotation = 1
        end

        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end

    elseif key == 'z' then
        local testRotation = pieceRotation - 1
        if testRotation < 1 then
            testRotation = #pieceStructures[pieceType]
        end

        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end

    elseif key == 'left' then
        local testX = pieceX - 1

        if canPieceMove(testX, pieceY, pieceRotation) then
            pieceX = testX
        end

    elseif key == 'right' then
        local testX = pieceX + 1

        if canPieceMove(testX, pieceY, pieceRotation) then
            pieceX = testX
        end
    end
end
``` 

### Checking left of playing area
If any block is not empty and its X position is less than 1 (i.e. off the left of the playing area), then the function returns false.

Full code at this point

```lua
function love.load()
    -- etc.

    function canPieceMove(testX, testY, testRotation)
        for y = 1, 4 do
            for x = 1, 4 do
                if pieceStructures[pieceType][testRotation][y][x] ~= ' '
                and (testX + x) < 1 then
                    return false
                end
            end
        end

        return true
    end
end
```

### Simplifying code
The number of blocks each piece has on the X and Y axes are reused from drawing the pieces, so variables are made for them.

Full code at this point

```lua
function love.load()
    -- etc.

    pieceXCount = 4
    pieceYCount = 4

    function canPieceMove(testX, testY, testRotation)
        for y = 1, pieceYCount do
            for x = 1, pieceXCount do
                if pieceStructures[pieceType][testRotation][y][x] ~= ' '
                and (testX + x) < 1 then
                    return false
                end
            end
        end

        return true
    end
end

function love.draw()
    -- etc.

    for y = 1, pieceYCount do
        for x = 1, pieceXCount do
            local block = pieceStructures[pieceType][pieceRotation][y][x]
            if block ~= ' ' then
                drawBlock(block, x + pieceX, y + pieceY)
            end
        end
    end
end
```

### Checking right of playing area
If any block's X position is greater than the width of the playing area (i.e. off the right of the playing area), then the function also returns false.

Full code at this point

```lua
function love.load()
    -- etc.

    function canPieceMove(testX, testY, testRotation)
        for y = 1, pieceYCount do
            for x = 1, pieceXCount do
                if pieceStructures[pieceType][testRotation][y][x] ~= ' ' and (
                    (testX + x) < 1
                    or (testX + x) > gridXCount
                ) then
                    return false
                end
            end
        end

        return true
    end
end
```

### Checking bottom of playing area
If any block's Y position is greater than the height of the playing area (i.e off the bottom of the playing area), then the function also returns false.

Full code at this point

```lua
function love.load()
    -- etc.

    function canPieceMove(testX, testY, testRotation)
        for y = 1, pieceYCount do
            for x = 1, pieceXCount do
                if pieceStructures[pieceType][testRotation][y][x] ~= ' ' and (
                    (testX + x) < 1
                    or (testX + x) > gridXCount
                    or (testY + y) > gridYCount
                ) then
                    return false
                end
            end
        end

        return true
    end
end
```

### Checking inert
If there is an inert block at any block's position, then the function also returns false.

To test this, an inert block is manually set.

Full code at this point

```lua
function love.load()
    -- etc.

    function canPieceMove(testX, testY, testRotation)
        for y = 1, pieceYCount do
            for x = 1, pieceXCount do
                if pieceStructures[pieceType][testRotation][y][x] ~= ' ' and (
                    (testX + x) < 1
                    or (testX + x) > gridXCount
                    or (testY + y) > gridYCount
                    or inert[testY + y][testX + x] ~= ' '
                ) then
                    return false
                end
            end
        end

        return true
    end

    -- Temporary
    inert[8][5] = 'z'
end
```

![het rooster](imgs/15.png)

#### Simplifying code
The calculated block positions to test are reused, so they are stored in variables.

Full code at this point

```lua
function love.load()
    -- etc.

    function canPieceMove(testX, testY, testRotation)
        for y = 1, pieceYCount do
            for x = 1, pieceXCount do
                local testBlockX = testX + x
                local testBlockY = testY + y

                if pieceStructures[pieceType][testRotation][y][x] ~= ' ' and (
                    testBlockX < 1
                    or testBlockX > gridXCount
                    or testBlockY > gridYCount
                    or inert[testBlockY][testBlockX] ~= ' '
                ) then
                    return false
                end
            end
        end

        return true
    end
end
```

### Drop
When the c key is pressed, the piece's Y position is increased by 1 while that position is movable.

Full code at this point

```lua
function love.keypressed(key)
    -- etc.

    elseif key == 'c' then
        while canPieceMove(pieceX, pieceY + 1, pieceRotation) do
            pieceY = pieceY + 1
        end

    -- etc.
end
```

### Resetting piece
If the timer ticks and the piece can't move down, the piece is reset to its initial position and rotation, and (for now) its initial type.

Full code at this point

```lua
function love.update(dt)
    timer = timer + dt
    if timer >= 0.5 then
        timer = 0

        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        else
            pieceX = 3
            pieceY = 0
            pieceType = 1
            pieceRotation = 1
        end
    end
end
``` 

### Simplifying code
The piece is set to its initial state in two places, so a function is made.

Full code at this point

```lua
function love.load()
    -- etc.

    function newPiece()
        pieceX = 3
        pieceY = 0
        pieceType = 1
        pieceRotation = 1
    end

    newPiece()

    -- etc.
end

function love.update(dt)
    timer = timer + dt
    if timer >= 0.5 then
        timer = 0

        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        else
            newPiece()
        end
    end
end
```

### Creating the sequence of next pieces
The sequence of next pieces is stored as a table containing the numbers representing piece types in a random order.

Each number representing a piece type is looped through and inserted into the sequence at a random position from 1 (the first position) to 1 more than the number of piece types already in the sequence table (the last position).

To test this, a new sequence is created when the s key is pressed, and the sequence is printed.

Full code at this point

```lua
function love.load()
    -- etc.

    function newSequence()
        sequence = {}
        for pieceTypeIndex = 1, #pieceStructures do
            local position = love.math.random(#sequence + 1)
            table.insert(
                sequence,
                position,
                pieceTypeIndex
            )
        end
    end

    newSequence()
end

function love.keypressed(key)
    -- etc.

    -- Temporary
    elseif key == 's' then
        newSequence()
        print(table.concat(sequence, ', '))
    end
end
```

`3, 2, 4, 1, 7, 5, 6`

### New piece from sequence
When a new piece is created, it removes the last item from the sequence and uses it for the piece type.

When the sequence is empty, a new sequence is created.

The newPiece function is moved below the newSequence function.

Full code at this point

```lua
function love.load()
    -- etc.

    function newPiece()
        pieceX = 3
        pieceY = 0
        pieceRotation = 1
        pieceType = table.remove(sequence)

        if #sequence == 0 then
            newSequence()
        end
    end

    newPiece()
end
```
### Add to inert
When a piece has come to rest, the piece's blocks are added to the inert blocks.

The piece's blocks are looped through, and if a block isn't empty, then the inert block at this position is set to the type of the piece's block.

Full code at this point

```lua
function love.update(dt)
    timer = timer + dt
    if timer >= 0.5 then
        timer = 0

        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        else
            -- Add piece to inert
            for y = 1, pieceYCount do
                for x = 1, pieceXCount do
                    local block =
                        pieceStructures[pieceType][pieceRotation][y][x]
                    if block ~= ' ' then
                        inert[pieceY + y][pieceX + x] = block
                    end
                end
            end

            newPiece()
        end
    end
end
```

### New piece immediately after drop
When a piece is dropped, the timer is set immediately to the limit so that adding the piece to the inert pieces and creating the new piece happen immediately instead of waiting for the timer.

The timer limit is reused, so it is made into a variable.

Full code at this point

```lua
function love.load()
    -- etc.

    timer = 0
    timerLimit = 0.5

    -- etc.
end

function love.update(dt)
    timer = timer + dt
    if timer >= timerLimit then

    -- etc.
end

function love.keypressed(key)
    -- etc.

    elseif key == 'c' then
        while canPieceMove(pieceX, pieceY + 1, pieceRotation) do
            pieceY = pieceY + 1
            timer = timerLimit
        end
    end
end
```

### Finding complete rows
Each row of the inert blocks is looped through, and if none of the columns of the row contain an empty block, then the row is complete.

For now, the complete row numbers are printed out.

Full code at this point

```lua
function love.update(dt)
    timer = timer + dt
    if timer >= timerLimit then
        timer = 0

        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        else
            -- Add piece to inert
            for y = 1, pieceYCount do
                for x = 1, pieceXCount do
                    local block =
                        pieceStructures[pieceType][pieceRotation][y][x]
                    if block ~= ' ' then
                        inert[pieceY + y][pieceX + x] = block
                    end
                end
            end

            -- Find complete rows
            for y = 1, gridYCount do
                local complete = true
                for x = 1, gridXCount do
                    if inert[y][x] == ' ' then
                        complete = false
                        break
                    end
                end
                
                if complete then
                   -- Temporary
                   print('Complete row: '..y)
                end
            end

            newPiece()
        end
    end
end
```

### Removing complete rows
If the row is complete, the rows from the complete row to the row second from the top are looped through.

Each block in the row is looped through and set to the value of the block above it. Because there is nothing above the top row it doesn't need to be looped through.

The top row is then set to all empty blocks.

Full code at this point

```lua
function love.update(dt)
    -- etc.

            -- Find complete rows
            for y = 1, gridYCount do
                local complete = true
                for x = 1, gridXCount do
                    if inert[y][x] == ' ' then
                        complete = false
                        break
                    end
                end

                if complete then
                    for removeY = y, 2, -1 do
                        for removeX = 1, gridXCount do
                            inert[removeY][removeX] =
                            inert[removeY - 1][removeX]
                        end
                    end

                    for removeX = 1, gridXCount do
                        inert[1][removeX] = ' '
                    end
                end
            end

             -- etc.
end
```

### Game over
If a newly created piece is in an unmovable position, then the game is over.

For now, love.load is called to reset the game to its initial state.

Full code at this point

```lua
function love.update(dt)
    -- etc.

            newPiece()

            if not canPieceMove(pieceX, pieceY, pieceRotation) then
                love.load()
            end
        end
    end
end
```

### Offsetting the playing area
The playing area is drawn 2 blocks from the left of the screen and 5 blocks from the top of the screen.

Full code at this point

```lua
function love.draw()
    -- etc.

    local offsetX = 2
    local offsetY = 5

    for y = 1, gridYCount do
        for x = 1, gridXCount do
            drawBlock(inert[y][x], x + offsetX, y + offsetY)
        end
    end

    for y = 1, pieceYCount do
        for x = 1, pieceXCount do
            local block = pieceStructures[pieceType][pieceRotation][y][x]
            if block ~= ' ' then
                drawBlock(block, x + pieceX + offsetX, y + pieceY + offsetY)
            end
        end
    end
end
``` 

![het rooster](imgs/16.png)

### Drawing the upcoming piece
The last piece of the sequence (i.e. the next piece to fall) is drawn at its first rotation position. It is offset 5 blocks from the left and 1 block from the top.

Full code at this point

```lua
function love.draw()
    -- etc.

    local function drawBlock(block, x, y)
        local colors = {
            [' '] = {.87, .87, .87},
            i = {.47, .76, .94},
            j = {.93, .91, .42},
            l = {.49, .85, .76},
            o = {.92, .69, .47},
            s = {.83, .54, .93},
            t = {.97, .58, .77},
            z = {.66, .83, .46},
            preview = {.75, .75, .75},
        }

        -- etc.
    end

    -- etc.

    for y = 1, pieceYCount do
        for x = 1, pieceXCount do
            local block = pieceStructures[sequence[#sequence]][1][y][x]
            if block ~= ' ' then
                drawBlock('preview', x + 5, y + 1)
            end
        end
    end
end
```

![het rooster](imgs/17.png)

### Resetting the game
When the game is over, only some of the variables need to be reset, so a function is made.

Full code at this point

```lua
function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)

    pieceStructures = {
        -- etc.
    }

    gridXCount = 10
    gridYCount = 18

    pieceYCount = 4
    pieceXCount = 4

    timerLimit = 0.5

    function canPieceMove(testX, testY, testRotation)
        -- etc.
    end

    function newSequence()
        -- etc.
    end

    function newPiece()
        -- etc.
    end

    function reset()
        inert = {}
        for y = 1, gridYCount do
            inert[y] = {}
            for x = 1, gridXCount do
                inert[y][x] = ' '
            end
        end

        newSequence()
        newPiece()

        timer = 0
    end

    reset()
end

function love.update(dt)
             -- etc.

            if not canPieceMove(pieceX, pieceY, pieceRotation) then
                reset()
            end
        end
    end
end
```

## Bron

Deze instructie is een vertaling van de Engelstalige tutorial
[Blocks: A tutorial for Lua and LÖVE 11](https://simplegametutorials.github.io/love/blocks/) van 
simple.game.tutorials@gmail.com.

{{< licentie rel="http://creativecommons.org/licenses/by-nc-sa/4.0/">}}
