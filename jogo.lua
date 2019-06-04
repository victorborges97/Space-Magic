local composer = require( "composer")

local scene = composer.newScene()

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Semeia o gerador de números aleatórios
math.randomseed( os.time() )
display.setStatusBar( display.HiddenStatusBar )

local w = display.contentWidth -- largura da tela
local h = display.contentHeight -- altura da tela

    wX = display.contentCenterX
    hY = display.contentCenterY

--grupos criados para organizar melhor
local backGroup = display.newGroup()  -- Exibir grupo para a imagem de fundo
local mainGroup = display.newGroup()  -- Mostrar grupo para a nave, asteróides, lasers, etc.
local uiGroup = display.newGroup()    -- Exibir grupo para objetos da interface do usuário, como os pontos

local fundo = display.newImageRect( backGroup, "img/fundo.png", 736, 1376 )
	fundo.x = wX 
	fundo.y = hY

-- difiçoes de variaveis
local vidas = 3
local pontos = 0
local died = false

local inimigosTable = {}
local nave2
local gameLoopTimer
local vidasText
local pontosText

-- Carregando a nave e alinhando
local nave = display.newImage( mainGroup, "img/nave2.png", 0, 0 )
	nave.x = wX
	nave.y = h - 150
	nave:scale( 0.3, 0.3)
	physics.addBody (nave, { radius=30, isSensor=true } )
	nave.myName = "nave"

--exibir na tela os pontos e as vidas
vidasText = display.newText( uiGroup, "Vidas: " .. vidas, 160, 140, "font/Turtles", 36 )
pontosText = display.newText( uiGroup, "Pontos: " .. pontos, 175, 100, "font/Turtles", 36 )
vidasText:setFillColor(0.7, 0.7, 0.9)
pontosText:setFillColor(0.7, 0.7, 0.9)

--função para atualizar os TEXTOS (vidas e pontos)
local function atualizarTexto()
    vidasText.text = "Vidas: " .. vidas
    pontosText.text = "Pontos: " .. pontos
end

--função para manipular eventos de toque / arrastar da nave
local function dragNave( event )
 
	local nave = event.target
	local phase = event.phase

	if ( "began" == phase ) then
        -- Definir o foco de toque na nave
        display.currentStage:setFocus( nave )
        -- Armazenar posição inicial de deslocamento
        nave.touchOffsetX = event.x - nave.x
        --nave.touchOffsetY = event.y - nave.y -- nessa habilitamos o movimento para qualquer lugar da tela x e y

        elseif ( "moved" == phase ) then
        -- Move the nave to the new touch position
        nave.x = event.x - nave.touchOffsetX
        --nave.y = event.y - nave.touchOffsetY -- nessa habilitamos o movimento para qualquer lugar da tela x e y
		
		elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Solte o foco de toque na nave
        display.currentStage:setFocus( nil )
    
    	return true  --Impede a propagação de toques para objetos subjacentes
	end
end 
nave:addEventListener( "touch", dragNave )

--disparos 
local function fireLaser()
 
    local laser = display.newImage( mainGroup, "img/laser.png", 26, 200 )
    physics.addBody( laser, "dynamic", { isSensor=true } )
    laser.isBullet = true
    laser.myName = "laser"

    laser.x = nave.x
    laser.y = nave.y
    laser:toBack()
    laser:scale( 0.5, 0.5)
    transition.to( laser, { y=-40, time=1000, 
        onComplete = function() display.remove( laser ) end
    } )
end

nave:addEventListener( "tap", fireLaser )


local function novoinimigo()
   
    local inimigof = display.newImage( "img/inimigof.png" )
    	
    	inimigof:scale( 0.07, 0.07)
        physics.addBody( inimigof, "dynamic", { radius=40, bounce=0.8 } )
        inimigof.myName = "inimigof"

    local whereFrom = math.random( 3 )

        if ( whereFrom == 1 ) then
            -- Do lado da Esquerda
            inimigof.x = -60 -- para fazer a saida da nave inimiga do lado esquerdo da tela.
            inimigof.y = math.random( 350 )   --random para selecionar um numero aleatorio entre 0 e 350 
            inimigof:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )--ele simplesmente define o movimento do objeto em uma direção constante e consistente.
               
        elseif ( whereFrom == 2 ) then
            -- Do lado de cima
            inimigof.x = math.random( display.contentWidth )
            inimigof.y = -60
            inimigof:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
        
        elseif ( whereFrom == 3 ) then
            -- Do lado direito
            inimigof.x = display.contentWidth + 60
            inimigof.y = math.random( 350 )
            inimigof:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
        end

end


local function gameLoop()
 
    -- Create new asteroid
    novoinimigo()
    -- Remove asteroids which have drifted off screen
    for i = #inimigosTable, 1, -1 do
        local thisInimigos = inimigosTable[i]
 
        if ( thisInimigos.x < -100 or
             thisInimigos.x > display.contentWidth + 100 or
             thisInimigos.y < -100 or
             thisInimigos.y > display.contentHeight + 100 )
        then
            display.remove( thisInimigos )
            table.remove( inimigosTable, i )
        end
    end
end

gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 0 )


--função para a restauração da nave depois de morre(colidir)
local function restoreNave2()
 
    nave.isBodyActive = false --remove a nave da simulação física para que ela deixe de interagir com outros 
    nave.x = wX
    nave.y = h - 150
 
    -- Fade in the nave
    transition.to( nave, { alpha=1, time=4000,
        onComplete = function()
            nave.isBodyActive = true
            died = false
                local function endGame()
                    composer.gotoScene( "start", { time=800, effect="crossFade" } )
                end
        end
    } )
end



--chamando a função de colidir
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2
        if ( ( obj1.myName == "laser" and obj2.myName == "inimigof" ) or
             ( obj1.myName == "inimigof" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and inimigof
            display.remove( obj1 )
            display.remove( obj2 )

            for i = #inimigosTable, 1, -1 do
                if ( inimigosTable[i] == obj1 or inimigosTable[i] == obj2 ) then
                    table.remove( inimigosTable, i )
                    break
                end
            end
            -- Increase pontos
            pontos = pontos + 100
            pontosText.text = "Pontos: " .. pontos

        elseif ( ( obj1.myName == "nave" and obj2.myName == "inimigof" ) or
                 ( obj1.myName == "inimigof" and obj2.myName == "nave" ) )
        then
            if ( died == false ) then
                died = true

                -- Update vidas
                vidas = vidas - 1
                vidasText.text = "Vidas: " .. vidas

                if ( vidas == 0 ) then
                    display.remove( nave )
                else
                    nave.alpha = 0
                    timer.performWithDelay( 1000, restoreNave2 )
                end
            end

        end
    end
end

Runtime:addEventListener( "collision", onCollision )




return scene