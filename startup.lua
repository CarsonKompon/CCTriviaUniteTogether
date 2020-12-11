os.loadAPI("bigfont")
os.loadAPI("json")

local modem = peripheral.find("modem")
local monitor = peripheral.wrap("right")
local speaker = peripheral.find("speaker")

local podiumNames = {
    "monitor_5", "monitor_4", "monitor_6", "monitor_7"
}

local podiums = {
    peripheral.wrap(podiumNames[1]),
    peripheral.wrap(podiumNames[2]),
    peripheral.wrap(podiumNames[3]),
    peripheral.wrap(podiumNames[4])
}

monitor.setTextScale(0.5)
term.redirect(monitor)

local MONITOR_WIDTH, MONITOR_HEIGHT = term.getSize()
local screenCenterX = math.ceil(MONITOR_WIDTH/2)
local screenCenterY = math.ceil(MONITOR_HEIGHT/2)
local currTerm = term.current()
local window = window.create(currTerm,1,1,MONITOR_WIDTH,MONITOR_HEIGHT,false)

local GAME_VERSION = "v1.0.0"

--Game vars
local GAMESTATE = 0 --0 = menu, 1 = ingame, 2 = answering, 3 = reveal, 4 = game end
local MENUSTATE = 0 --0 = main menu, 1 = how to play
local PLAYERS = {}
local SCORES = {}
local HIGHSCORE = 0
local CORRECTANSWERS = 0
local ROUND = 0
local ROUNDTIME = 0
local WAITTIME = -1
local WAITFUNCTION = function()end
local CATEGORIES = {}
local DIFFICULTIES = {}
local QUESTIONS = {}
local OPTIONS = {}
local ANSWERS = {}
local CURRENTOPTIONS = {}
local QUESTIONTEXT = " "
local DISPLAYTEXT = " "
local TEXTTIMER = 0
local SELECTEDANSWER = {0,0,0,0}
local SCORESAVE = "highscore.sav"
local READY = {false,false,false,false}
local READYTIME = 15*20
local ANSWERTIME = {0,0,0,0}
local WINNER = 1

local clickX = 0
local clickY = 0
local clicked = false
local whoClicked = "noone"

monitor.setBackgroundColor(colors.black)
monitor.clear()

local programTimer = 0

local imgLogo = paintutils.loadImage("logo.nfp")
local imgDiamond1 = paintutils.loadImage("diamond.nfp")
local imgDiamond2 = paintutils.loadImage("diamond1.nfp")
local imgDiamond3 = paintutils.loadImage("diamond2.nfp")
local imgDiamond4 = paintutils.loadImage("diamond3.nfp")

local menuDiamonds = {}
local menuDiamondTimer = 0


function load_highscore()
    local file = fs.open(SCORESAVE, "r")
    HIGHSCORE = tonumber(file.readAll())
    file.close()
end

function save_highscore()
    local file = fs.open(SCORESAVE, "w")
    file.write(tostring(HIGHSCORE))
    file.close()
end

--[[
if not fs.exists(SCORESAVE) then
    save_highscore()
else
    load_highscore()
end
]]


function draw_menu_background()
    if programTimer % 21 == 0 then
        table.insert(menuDiamonds,{i=0,y=-16,x=math.floor(math.random(-8,MONITOR_WIDTH))})
    end
    
    for ii, d in ipairs(menuDiamonds) do
        local dimg = imgDiamond1
        if menuDiamondTimer == 1 or menuDiamondTimer == 5 then dimg = imgDiamond2
        elseif menuDiamondTimer == 2 or menuDiamondTimer == 4 then dimg = imgDiamond3
        elseif menuDiamondTimer == 3 then dimg = imgDiamond4 end

        d.y = d.y + 1
        if d.y > MONITOR_HEIGHT then
            table.remove( menuDiamonds,ii )
        end
        paintutils.drawImage(dimg,d.x,d.y)
    end

    if programTimer % 4 == 0 then
        menuDiamondTimer = menuDiamondTimer + 1
        if menuDiamondTimer > 6 then menuDiamondTimer = 0 end
    end
end

--Draw Main Menu
function draw_menu()
    window.clear()
    
    draw_menu_background()

    window.setTextColor(colors.black)
    window.setBackgroundColor(colors.cyan)

    window.setCursorPos(1,1)
    window.write(GAME_VERSION)

    --MAIN MENU SCREEN
    if MENUSTATE ~= 1 then

        if #PLAYERS < 1 then
            paintutils.drawImage(imgLogo,screenCenterX-22,11)
            window.setBackgroundColor(colors.cyan)
            window.setTextColor(colors.orange)
            local txt = "Together"
            bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 25)
        else
            paintutils.drawImage(imgLogo,screenCenterX-22,1)

            window.setBackgroundColor(colors.cyan)
            window.setTextColor(colors.orange)
            local txt = "Together"
            bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 15)

            window.setTextColor(colors.black)
            txt = "Game starting in " .. math.ceil(READYTIME/20) .. "s"
            if READYTIME == 0 then txt = "Starting Game" end
            bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 24)

            txt = tostring(#PLAYERS) .. "/4 Players"
            bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 30)
        end

    --HOW TO PLAY SCREEN
    else
        window.setBackgroundColor(colors.cyan)

        --Tutorial text
        local txt = ""

        window.setTextColor(colors.black)
        txt = "Trivia Unite consists of 10 rounds. Each round, you must answer either a Multiple Choice or True/False question."
        window.setCursorPos(screenCenterX-#txt/2+1, 20)
        window.write(txt)

        txt = "You gain points for each question you correctly answer. The quicker you answer, the more points you get."
        window.setCursorPos(screenCenterX-#txt/2, 22)
        window.write(txt)

        txt = "To select an answer, right click the answer button."
        window.setCursorPos(screenCenterX-#txt/2+1, 26)
        window.write(txt)

        txt = "At the end of the game, you can see how many you answered correctly, and compare your score to the current highscore!"
        window.setCursorPos(screenCenterX-#txt/2+1, 28)
        window.write(txt)

        window.setTextColor(colors.gray)
        txt = "Made by @CarsonKompon"
        window.setCursorPos(screenCenterX-#txt/2+1, 34)
        window.write(txt)

        txt = "Questions provided by OpenTDB"
        window.setCursorPos(screenCenterX-#txt/2+1, 36)
        window.write(txt)

        --Back Button
        window.setTextColor(colors.black)
        paintutils.drawFilledBox(1, MONITOR_HEIGHT-5,15,MONITOR_HEIGHT,colors.red)
        bigfont.writeOn(term, 1, "Back", 2, MONITOR_HEIGHT-3)

        paintutils.drawImage(imgLogo,screenCenterX-21,1)
    end
end

--Draw Game GUI
function draw_game_gui()
    

    window.setTextColor(colors.black)

    local yyy = 2
    for v=1,4 do
        if has_value(PLAYERS, v) then
            window.setCursorPos(1,yyy)
            window.write("Player " .. tostring(v) .. ": " .. tostring(SCORES[v]))
            yyy = yyy + 3
        end
    end

    local txt = tostring(ROUND) .. "/10" 
    bigfont.writeOn(term, 1, txt,  MONITOR_WIDTH-(#txt*3), 2)

    window.setTextColor(colors.black)
    if ROUNDTIME < (30*20)-5 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[1] == ANSWERS[ROUND] then drawcol = colors.green end
        paintutils.drawFilledBox(screenCenterX-25,14,screenCenterX+25,18, drawcol)
        local txt = "A. " .. unescape(CURRENTOPTIONS[1])
        window.setCursorPos(screenCenterX-(#txt/2), 16)
        window.write(txt)
    end
    if ROUNDTIME < (30*20)-10 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[2] == ANSWERS[ROUND] then drawcol = colors.green end
        paintutils.drawFilledBox(screenCenterX-25,20,screenCenterX+25,24, drawcol)
        local txt = "B. " .. unescape(CURRENTOPTIONS[2])
        window.setCursorPos(screenCenterX-(#txt/2), 22)
        window.write(txt)
    end
    if ROUNDTIME < (30*20)-15 and #OPTIONS[ROUND] > 1 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[3] == ANSWERS[ROUND] then drawcol = colors.green end
        paintutils.drawFilledBox(screenCenterX-25,26,screenCenterX+25,30, drawcol)
        local txt = "C. " .. unescape(CURRENTOPTIONS[3])
        window.setCursorPos(screenCenterX-(#txt/2), 28)
        window.write(txt)
    end
    if ROUNDTIME < (30*20)-20 and #OPTIONS[ROUND] > 1 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[4] == ANSWERS[ROUND] then drawcol = colors.green end
        paintutils.drawFilledBox(screenCenterX-25,32,screenCenterX+25,36, drawcol)
        local txt = "D. " .. unescape(CURRENTOPTIONS[4])
        window.setCursorPos(screenCenterX-(#txt/2), 34)
        window.write(txt)
    end

    window.setTextColor(colors.black)

    --Quit Button
    --[[
    local quittxt = "Quit"
    paintutils.drawFilledBox(MONITOR_WIDTH-15, MONITOR_HEIGHT-5,MONITOR_WIDTH,MONITOR_HEIGHT,colors.red)
    bigfont.writeOn(term, 1, quittxt, MONITOR_WIDTH-(#quittxt*3), MONITOR_HEIGHT-3)
    ]]

    window.setBackgroundColor(colors.cyan)
    
    --Print Category
    if ROUNDTIME < (30*20) then
        window.setCursorPos(1,MONITOR_HEIGHT)
        window.write(unescape(CATEGORIES[ROUND]))

        local diftext = "Difficulty: " .. string.sub(DIFFICULTIES[ROUND],1,1):upper() .. string.sub(DIFFICULTIES[ROUND],2)
        window.setCursorPos(MONITOR_WIDTH-#diftext, MONITOR_HEIGHT)
        window.write(diftext)
    end

    --Print timer
    if ROUNDTIME <= 10*20 then window.setTextColor(colors.red) end
    txt = tostring(math.ceil(ROUNDTIME/20))
    bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 3)

end

function draw_game()
    term.redirect(window)

    paintutils.drawFilledBox(1,1,MONITOR_WIDTH,MONITOR_HEIGHT,colors.cyan)

    --Draw Main Menu
    if GAMESTATE == 0 then
       draw_menu()
    
    -- Draw Game End
    elseif GAMESTATE == 4 then
        window.clear()

        draw_menu_background()

        window.setBackgroundColor(colors.cyan)
        window.setTextColor(colors.orange)
        local txt = "PLAYER " .. tostring(WINNER) .. " WINS"
        bigfont.writeOn(term, 2, txt, screenCenterX-(#txt*4.5)+2, 6)

        window.setTextColor(colors.black)

        local yyy = 19
        for v=1,4 do
            if has_value(PLAYERS, v) then
                local tx = "Player " .. tostring(v) .. ": " .. tostring(SCORES[v])
                bigfont.writeOn(term, 1, tx, screenCenterX-(#txt*1.5), yyy)
                yyy = yyy + 4
            end
        end


        --[[
        window.setTextColor(colors.black)
        txt = "Correct Answers: " .. tostring(CORRECTANSWERS) .. "/10"
        bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 18)

        --txt = "Score: " .. tostring(SCORE)
        --bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 24)

        window.setTextColor(colors.gray)
        txt = "High Score: " .. tostring(HIGHSCORE)
        bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 34)
        ]]

        window.setTextColor(colors.black)

    -- Draw Game
    else
        
        window.clear()

        --Draw the current question
        local txt1 = DISPLAYTEXT
        local txt2 = ""
        if #txt1 > 75 then
            txt2 = string.sub(txt1, 76, #txt1)
            txt1 = string.sub(txt1, 1, 75)
            if string.sub(txt1,#txt1,#txt1) ~= " " and string.sub(txt2,1,1) ~= " " then txt1 = txt1 .. "-" end
        end
        window.setTextColor(colors.black)
        window.setCursorPos(screenCenterX-(#txt1/2), 8)
        window.write(txt1)
        window.setCursorPos(screenCenterX-(#txt2/2), 10)
        window.write(txt2)

        draw_game_gui()

    end
    term.redirect(currTerm)
    window.setVisible(true)
    window.setVisible(false)
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function unescape(url)
    return string.gsub(url, "%%(%x%x)", function(x)
        return string.char(tonumber(x, 16))
    end)
end








--PODIUM CODE

function update_podiums()
    for i=1,4 do
        podium = podiums[i]

            if clicked and whoClicked == podiumNames[i] then

                if has_value(PLAYERS, i) then

                    if GAMESTATE == 2 and ANSWERTIME[i] == 0 then
                        if clickX >= 2 and clickY >= 3 and clickX <= 6 and clickY <= 5 then
                            select_answer(1, i)
                        elseif clickX >= 10 and clickY >= 3 and clickX <= 14 and clickY <= 5 then
                            select_answer(2, i)
                        elseif clickX >= 2 and clickY >= 7 and clickX <= 6 and clickY <= 9 and #CURRENTOPTIONS > 2 then
                            select_answer(3, i)
                        elseif clickX >= 10 and clickY >= 7 and clickX <= 14 and clickY <= 9 and #CURRENTOPTIONS > 2 then
                            select_answer(4, i)
                        end
                    end
                    
                else
                    if GAMESTATE == 0 then
                        if not READY[i] then
                            READY[i] = true
                            table.insert(PLAYERS, i)
                            if #PLAYERS == 4 then READYTIME = 1 end
                        end
                    end
                end
                
                clicked = false
            end

        --paintutils.drawFilledBox(2,8,3,11,colors.green)

    end
end

--Draw podium screens
function draw_podiums()
    for i=1,4 do
        podium = podiums[i]
        term.redirect(podium)

        podium.setTextScale(0.5)
        podium.clear()

        if GAMESTATE < 1 then
            paintutils.drawFilledBox(1,1,15,10,colors.black)


            podium.setBackgroundColor(colors.black)
            podium.setTextColor(colors.white)

            
            local btncol = colors.red
            if READY[i] then
                btncol = colors.green
                local txt = "READY"
                podium.setCursorPos(8-math.floor(#txt/2), 1)
                podium.write(txt)
            end

            paintutils.drawFilledBox(3,3,13,8,btncol)

        elseif GAMESTATE > 1 then

            paintutils.drawFilledBox(1,1,15,10,colors.black)

            if has_value(PLAYERS, i) then

                podium.setBackgroundColor(colors.black)
                podium.setTextColor(colors.white)

                podium.setCursorPos(1,1)
                podium.write(tostring(SCORES[i]))

                podium.setTextColor(colors.black)

                --A
                local drawcol = colors.red
                if GAMESTATE == 2 or CURRENTOPTIONS[1] == ANSWERS[ROUND] then drawcol = colors.green end
                if GAMESTATE == 2 and SELECTEDANSWER[i] == 1 then drawcol = colors.white end
                paintutils.drawFilledBox(2,3,6,5,drawcol)
                podium.setCursorPos(2+2,3+1)
                podium.write("A")

                --B
                drawcol = colors.red
                if GAMESTATE == 2 or CURRENTOPTIONS[2] == ANSWERS[ROUND] then drawcol = colors.green end
                if GAMESTATE == 2 and SELECTEDANSWER[i] == 2 then drawcol = colors.white end
                paintutils.drawFilledBox(10,3,14,5,drawcol)
                podium.setCursorPos(10+2,3+1)
                podium.write("B")

                if #CURRENTOPTIONS > 2 then

                    --C
                    drawcol = colors.red
                    if GAMESTATE == 2 or CURRENTOPTIONS[3] == ANSWERS[ROUND] then drawcol = colors.green end
                    if GAMESTATE == 2 and SELECTEDANSWER[i] == 3 then drawcol = colors.white end
                    paintutils.drawFilledBox(2,7,6,9,drawcol)
                    podium.setCursorPos(2+2,7+1)
                    podium.write("C")

                    --D
                    drawcol = colors.red
                    if GAMESTATE == 2 or CURRENTOPTIONS[4] == ANSWERS[ROUND] then drawcol = colors.green end
                    if GAMESTATE == 2 and SELECTEDANSWER[i] == 4 then drawcol = colors.white end
                    paintutils.drawFilledBox(10,7,14,9,drawcol)
                    podium.setCursorPos(10+2,7+1)
                    podium.write("D")

                end

            else

            end

        end

        --paintutils.drawFilledBox(2,8,3,11,colors.green)

    end

    term.redirect(currTerm)
end





-------------------------------------------------------------------------------------------










--Start New Game
function start_game()

    WINNER = 1

    SCORES = {0,0,0,0}
    CORRECTANSWERS = 0
    ROUND = 0

    CATEGORIES = {}
    DIFFICULTIES = {}
    QUESTIONS = {}
    OPTIONS = {}
    ANSWERS = {}
    CURRENTOPTIONS = {}

    local hget = http.get("https://opentdb.com/api.php?amount=10&encode=url3986").readAll()
    local obj = json.decode(hget)

    for i, v in pairs(obj.results) do
        table.insert(QUESTIONS, v.question)
        table.insert(OPTIONS, v.incorrect_answers)
        table.insert(ANSWERS, v.correct_answer)
        table.insert(CATEGORIES, v.category)
        table.insert(DIFFICULTIES, v.difficulty)
    end

    start_round()

end

--Round Start
function start_round()
    ROUND = ROUND + 1
    ROUNDTIME = 30*20
    GAMESTATE = 2
    TEXTTIMER = 0
    SELECTEDANSWER = {0,0,0,0}
    ANSWERTIME = {0,0,0,0}

    if ROUND > 10 then
       end_game()
    else
        QUESTIONTEXT = QUESTIONS[ROUND]
        DISPLAYTEXT = ""

        CURRENTOPTIONS = {}

        if #OPTIONS[ROUND] == 1 then
            table.insert(CURRENTOPTIONS, "True")
            table.insert(CURRENTOPTIONS, "False")
        else
        local offset = math.floor(math.random(0,#OPTIONS[ROUND]+0.99))
            for i = 1,#OPTIONS[ROUND]+1 do
                local v = offset + i
                while v > #OPTIONS[ROUND]+1 do v = v - (#OPTIONS[ROUND]+1) end
                if v == #OPTIONS[ROUND]+1 then
                    table.insert(CURRENTOPTIONS, ANSWERS[ROUND])
                else
                    table.insert(CURRENTOPTIONS, OPTIONS[ROUND][v])
                end
            end
        end
    end
end

--Game End
function end_game()

    local winam = 0
    WINNER = 1

    for j=1,4 do
        if SCORES[j] > winam then
            winam = SCORES[j]
            WINNER = j
        end
    end
    
    ROUND = 10
    GAMESTATE = 4

    --TODO: Highscore
    --[[
    if SCORE > HIGHSCORE then
        HIGHSCORE = SCORE
        save_highscore()
    end
    ]]

    menuDiamonds = {}

    WAITTIME = 12 * 20
    WAITFUNCTION = function ()
        GAMESTATE = 0
        MENUSTATE = 0
        SCORES = {0,0,0,0}
        READY = {false,false,false,false}
        ROUND = 0
        ROUNDTIME = 0
        READYTIME = 15*20
        PLAYERS = {}
    end
end

--Select Answer
function select_answer(num, player)
    SELECTEDANSWER[player] = num
    ANSWERTIME[player] = ROUNDTIME
    
    local remaining = #PLAYERS
    for j=1,4 do
        if SELECTEDANSWER[j] ~= 0 then
            remaining = remaining - 1
        end
    end

    if remaining == 0 then
        GAMESTATE = 3

        for j=1,4 do
            if SELECTEDANSWER[j] > 0 then
                if CURRENTOPTIONS[SELECTEDANSWER[j]] == ANSWERS[ROUND] then
                SCORES[j] = SCORES[j] + math.ceil(1000*((ANSWERTIME[j]+(30*20))/(60*20)))
                end
            end
        end

        WAITTIME = 20 * 4
        WAITFUNCTION = start_round
    end

    --[[
    if num > 0 then
        if ANSWERS[ROUND] == CURRENTOPTIONS[num] then
            SCORES[player] = SCORES[player] + math.ceil(1000*((ROUNDTIME+(30*20))/(60*20)))
            CORRECTANSWERS = CORRECTANSWERS + 1
            speaker.playSound("minecraft:entity.player.levelup", 0.5)
        else
            speaker.playSound("minecraft:entity.witch.ambient", 0.5)
        end
    else
        speaker.playSound("minecraft:entity.witch.ambient", 0.5)
    end

    WAITTIME = 20 * 4
    WAITFUNCTION = start_round
    ]]

end

--Update Game
function update_game()
    programTimer = programTimer + 1
    
    --Mouse clicked events
    if clicked and whoClicked == "right" then

        --MAIN MENU STATE
        if GAMESTATE == 0 then
            --Main Menu
            if MENUSTATE == 0 then

            --How To Play Menu
            elseif MENUSTATE == 1 then
                --Back Button
                if clickX >= 1 and clickY >= MONITOR_HEIGHT-5 and clickX <= 15 and clickY <= MONITOR_HEIGHT then
                    MENUSTATE = 0
                    speaker.playSound("minecraft:ui.button.click")
                end
            end
        
        --GAME STATE
        elseif GAMESTATE == 2 then
            --[[
            if clickX >= screenCenterX-25 and clickY >= 14 and clickX <= screenCenterX+25 and clickY <= 18 then
                select_answer(1)
            elseif clickX >= screenCenterX-25 and clickY >= 20 and clickX <= screenCenterX+25 and clickY <= 24 then
                select_answer(2)
            elseif clickX >= screenCenterX-25 and clickY >= 26 and clickX <= screenCenterX+25 and clickY <= 30 then
                select_answer(3)
            elseif clickX >= screenCenterX-25 and clickY >= 32 and clickX <= screenCenterX+25 and clickY <= 36 then
                select_answer(4)
            end
            ]]
        end
        clicked = false
    end

    if WAITTIME > 0 then
        WAITTIME = WAITTIME - 1
        if WAITTIME == 0 then
            WAITTIME = -1
            WAITFUNCTION()
        end
    end

    if GAMESTATE == 0 then
        --Start Game Button
        if #PLAYERS > 0 then
            if READYTIME > 0 then
                READYTIME = READYTIME - 1

                if READYTIME == 0 then
                    speaker.playSound("minecraft:ui.toast.challenge_complete")
                    MENUSTATE = 2
                    WAITTIME = 80
                    WAITFUNCTION = function()
                        MENUSTATE = 0
                        ROUND = 0
                        ROUNDTIME = 30 * 20
                        GAMESTATE = 1

                        DISPLAYTEXT = ""

                        WAITTIME = 20
                        WAITFUNCTION = start_game
                    end
                end
            end
        end
    elseif GAMESTATE == 2 then
        --Round Timer
        if ROUNDTIME > 0 then

            --Type the question
            local txttocopy = unescape(QUESTIONTEXT)
            if #DISPLAYTEXT < #txttocopy then
                speaker.playSound("minecraft:block.note.snare", 0.2, math.random(1,2))
                DISPLAYTEXT = DISPLAYTEXT .. string.sub(txttocopy,#DISPLAYTEXT+1,#DISPLAYTEXT+1)
            end

            ROUNDTIME = ROUNDTIME - 1

            if ROUNDTIME == 0 then
                for v=1,4 do
                    if ANSWERTIME[v] == 0 and has_value(PLAYERS, v) then
                        select_answer(-1,v)
                    end
                end
            end

            if ROUNDTIME % 20 == 0 then
                local sndpitch = 0.5
                if math.floor(ROUNDTIME / 20) % 2 == 0 then sndpitch = 0.625 end
                if ROUNDTIME <= 10*20 then sndpitch = sndpitch * 1.5 end
                speaker.playSound("minecraft:block.comparator.click", 0.18, sndpitch)
            end
        end
    end

end

--MAIN GAME
function main_game()
    update_game()
    draw_game()
    update_podiums()
    draw_podiums()

    os.sleep()
end

--Get mouse input
function get_input()
    event, side, xClick, yClick = os.pullEvent("monitor_touch")

    whoClicked = side
    clicked = true
    clickX = xClick
    clickY = yClick
end

while true do
    
    parallel.waitForAny(get_input, main_game)

end

--[[

monitor.setTextColor(colors.orange)
monitor.setCursorPos(10,1)
monitor.write("TRIVIA UNITE")
]]
