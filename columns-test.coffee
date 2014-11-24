chalk = require 'chalk'

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
  'orange'
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

# Add slow but acceptable array rotation. Sure there's cleverer stuff out there.
Array::rotate = () ->
  newArr = []
  for row, ri in @
    for col, ci in row
      if !newArr[ci]? then newArr[ci] = []
      newArr[ci][ri] = col
  return newArr

Array::chunk = (chunkSize) ->
  array = this
  [].concat.apply [], array.map (elem, i) ->
    (if i % chunkSize then [] else [array.slice(i, i + chunkSize)])

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
  die() if willDie

start = () ->
  # tick = setTimeout columnTick, 0
  columnTick()

columnTick = () ->

  # @todo This may be converted to an interval or such, so just as a reminder...
  # if tick then clearInterval tick

  column =
    blocks: []
    x: Math.round Math.random() * (grid[0].length - 1)
    y: 0

  # Create 3-colour array for blocks.
  for i in [0..2]
    column.blocks.push 1 + Math.round Math.random() * (colours.length - 1)

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


checkLines = (_grid, _dir) ->
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
        console.log " > Matched #{matches.length} on #{_dir} - index #{rowIndex}", matches

checkGrid = (_grid) ->
  # Check horizontal...
  checkLines _grid, 'x'
  # Check vertical...
  checkLines _grid.rotate(), 'y'

drawGrid = (_grid) ->
  output = []
  for row in _grid
    line = ''
    for block in row
      line += chalk[chalkColours[block]]("  ")
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
  checkGrid grid

  # Cheap exit ;)
  process.exit 0

start()
