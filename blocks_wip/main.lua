function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)

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

    gridXCount = 10
    gridYCount = 18

    inert = {}
    for y = 1, gridYCount do
        inert[y] = {}
        for x = 1, gridXCount do
            inert[y][x] = ' '
        end
    end

    pieceType = 1
    pieceRotation = 1
    pieceX = 3
    pieceY = 0
    timer = 0
    timerLimit = 0.5

    pieceXCount = 4
    pieceYCount = 4

    function canPieceMove(testX, testY, testRotation)
        for y = 1, pieceYCount do
            for x = 1, pieceXCount do
                local testBlockX = testX + x
                local testBlockY = testY + y

                if pieceStructures[pieceType][testRotation][y][x] ~= ' ' and
                    (
                        testBlockX < 1
                        or testBlockX > gridXCount
                        or testBlockY > gridYCount
                        or inert[testBlockY][testBlockX] ~= ' '
                    )
                then
                    return false
                end
            end
        end

        return true
    end

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

    for y = 1, pieceYCount do
        for x = 1, pieceXCount do
            local block = pieceStructures[pieceType][pieceRotation][y][x]
            if block ~= ' ' then
                drawBlock(block, x + pieceX, y + pieceY)
            end
        end
    end
end

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
    elseif key == 'c' then
        while canPieceMove(pieceX, pieceY + 1, pieceRotation) do
            pieceY = pieceY + 1
            timer = timerLimit
        end
    end
end

function love.update(dt)
    timer = timer + dt
    if timer >= timerLimit then
        timer = 0
        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        else
            newPiece()
            for y = 1, pieceYCount do
                for x = 1, pieceXCount do
                    local block =
                        pieceStructures[pieceType][pieceRotation][y][x]
                    if block ~= ' ' then
                        inert[pieceY + y][pieceX + x] = block
                    end
                end
            end
            for y = 1, gridYCount do
                local complete = true
                for x = 1, gridXCount do
                    if inert[y][x] == ' ' then
                        complete = false
                        break
                    end
                end

                if complete then
                   -- tijdelijke code
                   print('Complete row: '..y)
                end
            end
        end
    end
end
