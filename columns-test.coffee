chalk = require 'chalk'
_ = require 'underscore'
{argv} = require 'yargs'

grid = [
  #0 #1 #2 #3 #4 #5
  [0, 0, 0, 0, 0, 0] # 0
  [0, 0, 0, 0, 0, 0] # 1
  [0, 0, 0, 0, 0, 0] # 2
  [0, 0, 0, 0, 0, 0] # 3
  [0, 0, 0, 0, 0, 0] # 4
  [0, 0, 0, 0, 0, 0] # 5
  [0, 0, 0, 0, 0, 0] # 6
  [0, 0, 0, 0, 0, 0] # 7
  [0, 0, 0, 0, 0, 0] # 8
  [0, 0, 0, 0, 0, 0] # 9
  [0, 0, 0, 0, 0, 0] # 10
  [0, 0, 0, 0, 0, 0] # 11
  [0, 0, 0, 0, 0, 0] # 12
]

colours = [
  'red'
  'white' #'orange' # Should be orange
  'yellow'
  'green'
  'blue'
  'purple'
]

# Colours available to chalk are limited, the bastards.
chalkColours = [
  'bgBlack'
  'bgRed'
  'bgWhite'
  'bgYellow'
  'bgGreen'
  'bgBlue'
  'bgMagenta'
]

tick = null
gridDrawing = []
matchedMessages = {}

# Number of colours, or null for full gamut. Don't use 1 or lower or 'BOOM'.
numColours = argv.colours - 1 or (colours.length - 1)

# Add slow but acceptable array rotation. Sure there's cleverer stuff out there.
# It's technically folding/transposing, but rotate sounds better.
Array::rotate = () ->
  newArr = []
  for row, ri in @
    for col, ci in row
      if !newArr[ci]? then newArr[ci] = []
      newArr[ci][ri] = col
  return newArr

# Split array into segments.
Array::chunk = (chunkSize) ->
  array = this
  [].concat.apply [], array.map (elem, i) ->
    (if i % chunkSize then [] else [array.slice(i, i + chunkSize)])

# Rotate the array 45 degrees.
Array::rotate45 = ->
  arr = this
  # Max index of diagonal matrix.
  summax = (arr.length - 1) * (arr[0].length - 1)
  # Create empty matrix and push in the number of rows required.
  rotated = []
  for i in summax
    rotated.push []
  # Fill the new array by partitioning the original matrix.
  for j in arr[0].length
    for i in arr.length
      rotated[i + j].push arr[i][j]
  return rotated

# Apply the current column to the grid.
applyColumn = (column) ->
  willDie = false
  for i in [0..2]
    j = column.y - i - 1
    if !grid[j]?
      willDie = true
    else
      grid[j][column.x] = column.blocks[i]
  gridDrawing.push drawGrid grid
  updateGrid grid
  die() if willDie

start = () ->
  # tick = setTimeout columnTick, 0
  columnTick()

columnTick = () ->

  # @todo This may be converted to an interval or such, so just as a reminder...
  # if tick then clearInterval tick

  column =
    blocks: []
    blocksAsColours: []
    x: Math.round Math.random() * (grid[0].length - 1)
    y: 0

  # Create 3-colour array for blocks.
  for i in [0..2]
    x = column.blocks.push 1 + Math.round Math.random() * (numColours)
    column.blocksAsColours.push colours[x]
  # @todo Make asyncronous and based on a timer/actual ticks.
  _l = grid.length
  for i in [0.._l]
    if column.y >= grid.length
      # console.log 'hit bottom!'
      applyColumn column
      return columnTick()
    if grid[column.y][column.x] > 0
      # console.log 'hit another column'
      applyColumn column
      return columnTick()
    # console.log column.x, column.y
    column.y++


updateLines = (_grid, _dir) ->
  for row, rowIndex in _grid
    matches = []
    for block, blockIndex in row
      # Reset and move to next block if blank.
      if block < 1
        matches = []
        continue
      # Push block onto array if matches are blank or block matches prev.
      if !matches.length or block is matches[matches.length - 1]
        matches.push block
      else
      # Reset and push if it's a standard 'different' block.
        matches = [block]
      if matches.length >= 3
        for i in [0..2]
          _grid[rowIndex][blockIndex - i] = 0
        matchedColours = matches.map (match) ->
          return colours[match - 1]
        matchedMessages[rowIndex + '-' + blockIndex] = " > Matched #{matches.length} on #{_dir} - index #{rowIndex}/#{blockIndex} - #{matchedColours}"
  return _grid

updateGrid = (_grid) ->
  # Check horizontal...
  grid = updateLines _grid, 'x'
  # Check vertical...
  grid = (updateLines _grid.rotate(), 'y').rotate()

drawGrid = (_grid) ->
  output = []
  for row in _grid
    line = ''
    for block in row
      try
        line += chalk[chalkColours[block]]("  ")
      catch e
        console.log "Could not find chalk colour #{block}"
    output.push chalk.cyan '|' + line + '|'
  output.push chalk.cyan '*' + (new Array(grid[0].length + 1).join "^^") + '*'
  return output

die = () ->
  rows = gridDrawing.chunk 10
  output = []
  for row, rid in rows
    _tmp = []
    for game, gid in row
      if _tmp.length
        for d, i in game
          _tmp[i] += ' ' + d
      else
        _tmp = game
    output.push _tmp

  for row in output
    console.log row.join '\n'

  console.log "You died lol! Moves: #{gridDrawing.length}"
  updateGrid grid
  console.log _.values(matchedMessages).join '\n'

  # Cheap exit ;)
  process.exit 0

start()
