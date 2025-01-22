push = require 'push'

class = require 'class'

require 'Ball'

require 'Paddle'

WINDOW_WIDTH = 1280/2
WINDOW_HEIGHT = 720/2

VIRTUAL_WIDTH = 320
VIRTUAL_HEIGHT = 180

PADDLE_SPEED = 400


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')
    math.randomseed(os.time())
    smallfont = love.graphics.newFont('font.ttf', 8)
    love.graphics.setFont(smallfont)
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true,
   })

   sounds = {
       ['SCORE']=love.audio.newSource('Sounds/score.wav', 'static'),
       ['Paddle_HIT']=love.audio.newSource('Sounds/paddle_hit.wav', 'static'),
       ['Wall_HIT']=love.audio.newSource('Sounds/wall_hit.wav', 'static')
   }
   
   ball = Ball(VIRTUAL_WIDTH/2 -2, VIRTUAL_HEIGHT/2 -2, 4,4)

   score_Player1 = 0
   score_Player2 = 9

   servingPlayer = 1

   player1= Paddle(10, 30 , 5, 25)
   player2= Paddle(VIRTUAL_WIDTH -15, VIRTUAL_HEIGHT-30, 5, 25)
   CPU = 'Disabled'
   Offset_value = 0
   gameState = 'start'
end    
function love.resize(w, h)
    push:resize(w, h)
end
function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50,50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = - math.random(140, 200)
        end   
    end
    --collision
    if gameState =='play' then
        if ball:Collide(player1) then
            ball.dx= -ball.dx * 1.03
            ball.x = player1.x + 5
            if ball.dy < 0  then
                ball.dy = - math.random(30,150)
            else
                ball.dy = math.random(30,150)
            end
            sounds['Paddle_HIT']:play()
        end
        if ball:Collide(player2) then
            ball.dx= -ball.dx * 1.03
            ball.x = player2.x - 4
            Offset_value = math.random(-20 , 20)
            if ball.dy < 0  then
                ball.dy = -math.random(30,150)
            else
                ball.dy = math.random(30,150)
            end
            sounds['Paddle_HIT']:play()
        end
        if ball.y < 0 then
            ball.y=0
            ball.dy = -ball.dy
            sounds['Wall_HIT']:play()
        end
        if ball.y > VIRTUAL_HEIGHT-4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy 
            sounds['Wall_HIT']:play()
        end
        --score
        if ball.x < 0  then  
            servingPlayer = 2   
            score_Player2 = score_Player2 + 1
            sounds['SCORE']:play()

            if score_Player2 == 10 then
                
                winningPlayer = 2
                gameState = 'done'
            else                
                ball:reset()
                if CPU == "Enabled" then
                    gameState = 'serve'
                else
                    gameState = 'serve'
                end    
            end
        end
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 1
            score_Player1 = score_Player1 + 1 
            sounds['SCORE']:play()

            if score_Player1 == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                ball:reset()
                gameState = 'serve'  
            end         
        end
    end

    if gameState == 'play'  then
        ball:update(dt)
    end
    --player 1 movement
    if love.keyboard.isDown('w')then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s')then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    --player 2 movement
    if CPU == "Disabled"then

        if love.keyboard.isDown('up')then
          player2.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('down')then
          player2.dy = PADDLE_SPEED
         else
             player2.dy = 0
        end
    end
     --CPU movement   
    if CPU == "Enabled" then
        --if ball.x > VIRTUAL_WIDTH/3 then
            player2.y = ball.y - 25/2 - Offset_value
            if player2.y < 0 then
                player2.y =0 
            elseif player2.y > VIRTUAL_HEIGHT - 25 then
                player2.y = VIRTUAL_HEIGHT - 25
            end
        --end
    end  
        player1:update(dt)
        player2:update(dt)
    end


function love.keypressed(key)
    if key=='escape'then
        love.event.quit()
    end
    if gameState == 'start' then
        
        if key == '2'then
            CPU = 'Enabled'
        elseif key == '1' then
            CPU = 'Disabled'
        end
    end


    if key == 'return' then
        
        if gameState == 'start'then
            gameState = 'serve'
        elseif gameState == 'serve' then
            Offset_value = math.random(-5 , 5)
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            
            ball:reset()

            score_Player1 = 0
            score_Player2 = 0
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1                
            end
        end
    end   
end

function love.draw()
    push:apply('start')
    
    love.graphics.clear(0.1,0.1,0.1,1)
    love.graphics.setFont(smallfont)
    love.graphics.printf(tostring(gameState),0, 0, VIRTUAL_WIDTH, 'center')

    if gameState == 'start'then
        love.graphics.printf('Press ENTER to Start',0,10,VIRTUAL_WIDTH,'center')
        if CPU == "Enabled"then
            love.graphics.printf('CPU is Player 2',0,20,VIRTUAL_WIDTH,'center')
        else
            love.graphics.printf('press 2 to Enable CPU',0,20,VIRTUAL_WIDTH,'center')
        end
    elseif gameState == 'serve' then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Player'..tostring(servingPlayer).."'s Serve",0,10,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press ENTER',0,20,VIRTUAL_WIDTH,'center')
    elseif gameState == 'play' then
        love.graphics.printf('play state',0,20,VIRTUAL_WIDTH,'center')
       -- love.graphics.printf(tostring(ball.x),10, 10, VIRTUAL_WIDTH, 'left')
    elseif gameState == 'done' then
        love.graphics.setFont(smallfont)
        if winningPlayer == 2 and CPU =='Enabled' then
            love.graphics.printf("CPU Win's",0,10,VIRTUAL_WIDTH,'center')
        else 
            love.graphics.printf('Player'..tostring(winningPlayer).."Win's",0,10,VIRTUAL_WIDTH,'center')
        end
        love.graphics.printf('Press ENTER',0,20,VIRTUAL_WIDTH,'center')        
    end

    --Paddle
    player1:render()
    player2:render()
   
    --Ball
    ball:render()

    displayScore()
    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(1,1,1,0.2)
    fontFPS=love.graphics.newFont('font.ttf', 10)
    love.graphics.setFont(fontFPS)
    love.graphics.print('FPS:' ..tostring(love.timer.getFPS()),10,10)
    --love.graphics.print('FPS:' ..tostring(Offset_value),10,10)
end

function displayScore()
    scorefont = love.graphics.newFont('font.ttf', 15)
    love.graphics.setFont(scorefont)
    love.graphics.print(tostring(score_Player1), VIRTUAL_WIDTH/3,VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(score_Player2), VIRTUAL_WIDTH - VIRTUAL_WIDTH/3  , VIRTUAL_HEIGHT/3)
end