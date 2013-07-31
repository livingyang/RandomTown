fs = require "fs"
spawn = require('child_process').spawn

MazeGenerator = require("../../lib/MazeGenerator.coffee").MazeGenerator

info = JSON.parse fs.readFileSync("config.json")

data = {}
for i in [0...info.Role_Count]
	generator = new MazeGenerator(info.Maze_Size[0], info.Maze_Size[1])
	generator.createBlocks info.Block_Percent
	connectGridArray = generator.getConnectGridArray()
	maxGridCount = 0
	maxGridCount = gridArray.length for gridArray in connectGridArray when maxGridCount < gridArray.length
	
	if data[maxGridCount]? then data[maxGridCount]++ else data[maxGridCount] = 1

result = []
result.push k, ",", v, "\n" for k, v of data
fs.writeFileSync "income.csv", "Income,People\n#{result.join('')}"

httpServer = spawn "python", ["-m", "SimpleHTTPServer"]
httpServer.stdout.on('data', (data) ->
  console.log('stdout: ' + data);
)
spawn "open", ["http://localhost:8000/"]