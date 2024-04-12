
-------------------------------------------------------------
----------[[** Smart lua editing **]]------------------------
----------[[** written by Spiken **]]------------------------
----[[** https://github.com/spik3n/Smart-lua-editing **]]----
-------------------------------------------------------------
local mq = require('mq')
local imgui = require('ImGui')

local configFile
local configFileContents = ""
local iniFileLoaded = false
local showMainGUI = true
local showFileDialog = false

local function readIniFile(filePath)
    local file = io.open(filePath, "r")
    if file then
        configFileContents = file:read("*all")
        file:close()
        iniFileLoaded = true
    else
        configFileContents = "Failed to load file."
        iniFileLoaded = false
    end
end

local function saveIniFile(filePath)
    if iniFileLoaded then
        local file = io.open(filePath, "w")
        if file then
            file:write(configFileContents)
            file:close()
        end
    end
end

local function listIniFiles(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('dir "'..directory..'" /b /a-d')
    for filename in pfile:lines() do
        if filename:match("%.ini$") then
            table.insert(t, filename)
        end
    end
    pfile:close()
    return t
end

local function drawMainGUI()
    imgui.SetNextWindowSize(600, 400, ImGuiCond.FirstUseEver)
    imgui.Begin("Smart lua editing", showMainGUI)

    if imgui.Button("Open ini file") then
        showFileDialog = true
    end

    if imgui.Button("Save and Close") then
        saveIniFile(configFile)
        configFileContents = ""
        iniFileLoaded = false
    end

    if iniFileLoaded then
        configFileContents = imgui.InputTextMultiline("##edit", configFileContents, 1024, 300)
    end

    imgui.End()
end

local function drawFileDialog()
    if showFileDialog then
        imgui.SetNextWindowSize(150, 300, ImGuiCond.FirstUseEver)
        imgui.Begin("ini files", showFileDialog)

        local files = listIniFiles(mq.configDir)
        for i, file in ipairs(files) do
            if imgui.Button(file) then
                configFile = mq.configDir .. "/" .. file
                readIniFile(configFile)
                showFileDialog = false
            end
        end
        imgui.End()
    end
end

ImGui.Register('Smart lua editing', function()
    if showMainGUI then
        drawMainGUI()
    end
    if showFileDialog then
        drawFileDialog()
    end
end)

while showMainGUI do
    mq.delay(1000)
end