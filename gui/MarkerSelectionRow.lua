local StdUi = LibStub("StdUi")

local MARKER_DIMENSION = 32
local MARKER_PADDING = 2
local FRAME_PADDING = 2

local width = (8 * MARKER_DIMENSION) + (7 * MARKER_PADDING) + (2 * FRAME_PADDING)
local height = MARKER_DIMENSION + (2 * FRAME_PADDING)

StdUi:RegisterWidget("MarkerSelectionRow", function(self, parent, value)
    local frame = StdUi:Frame(parent, width, height)
    self:InitWidget(frame);
    self:SetObjSize(frame, width, height);

    frame.value = value

    local skull = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 8)
    frame.skull = skull
    StdUi:GlueTop(skull, frame, 2, -2, "LEFT")

    local cross = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 7)
    frame.cross = cross
    StdUi:GlueRight(cross, skull, 2, 0)

    local square = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 6)
    frame.square = square
    StdUi:GlueRight(square, cross, 2, 0)

    local moon = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 5)
    frame.moon = moon
    StdUi:GlueRight(moon, square, 2, 0)

    local triangle = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 4)
    frame.triangle = triangle
    StdUi:GlueRight(triangle, moon, 2, 0)

    local diamond = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 3)
    frame.diamond = diamond
    StdUi:GlueRight(diamond, triangle, 2, 0)

    local circle = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 2)
    frame.circle = circle
    StdUi:GlueRight(circle, diamond, 2, 0)

    local star = StdUi:MarkerIcon(frame, MARKER_DIMENSION, MARKER_DIMENSION, 1)
    frame.star = star
    StdUi:GlueRight(star, circle, 2, 0)

    local lut = {
        star,
        circle,
        diamond,
        triangle,
        moon,
        square,
        cross,
        skull
    }

    function frame:Selected(marker)
        parent:Selected(frame, marker)
    end

    function frame:Deselect(marker)
        local markerIcon = lut[marker]
        if markerIcon then
            markerIcon:Deselected()
        end
    end

    function frame:Select(marker)
        local markerIcon = lut[marker]
        if markerIcon then
            markerIcon:Selected()
        end
    end

    function frame:DeselectAll()
        for _, markerIcon in ipairs(lut) do
            if markerIcon then
                markerIcon:Deselected()
            end
        end
    end

    function frame:GetValue()
        return frame.value
    end

    function frame:IsSelected(marker)
        local markerIcon = lut[marker]
        if markerIcon then
            return markerIcon:IsSelected()
        end

        return false
    end

    return frame
end)