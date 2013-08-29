fs = require "fs"
exec = require("child_process").exec

dirDistSrc = "./dist/src"
dirDistSpec = "./dist/spec"

onBuildAllFileDone = -> console.log "onBuildAllFileDone"
buildingFileCount = 0
buildFile = (filePath, distDir) ->
	++buildingFileCount
	exec "coffee -o #{distDir} -c #{filePath}", (error, stdout, stderr) ->
	    if error?
	    	console.log('stdout: ' + stdout)
    		console.log('stderr: ' + stderr)
    		console.log('exec error: ' + error)
    	--buildingFileCount
    	if buildingFileCount is 0
    		onBuildAllFileDone?()
    	

# build src file
srcFiles = [
	"../../lib/MazeGenerator.coffee"
	"../../lib/RandomTown.coffee"
]

srcFiles.forEach (srcFile) ->
	buildFile srcFile, dirDistSrc

# build spec file
specFiles = []
fs.readdirSync("spec").forEach (filename) ->
	specFiles.push "spec/#{filename}" if filename.match ".coffee"

specFiles.forEach (specFile) ->
	buildFile specFile, dirDistSpec

# make Runner html file
getScriptTag = (scriptPath) ->
	"<script type=\"text/javascript\" src=\"#{scriptPath}\"></script>"

getDirScriptTags = (dirPath) ->
	result = ""
	fs.readdirSync(dirPath).forEach (filename) ->
		filePath = "#{dirPath}/#{filename}"
		result += "#{getScriptTag(filePath)}\n" if filePath.match(".js")
	result

runHtml = fs.readFileSync("RunnerTemplate.html").toString()
runHtml = runHtml.replace "<!-- src -->", getDirScriptTags(dirDistSrc)
runHtml = runHtml.replace "<!-- spec -->", getDirScriptTags(dirDistSpec)

runHtmlFilename = "SpecRunner.html"

onBuildAllFileDone = ->
	fs.writeFile runHtmlFilename, runHtml, (error) ->
		exec "open #{runHtmlFilename}", (error, stdout, stderr) ->
			if error?
				console.log('stdout: ' + stdout)
				console.log('stderr: ' + stderr)
				console.log('exec error: ' + error)
