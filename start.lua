local composer = require( "composer")

local scene = composer.newScene()

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )
display.setStatusBar( display.HiddenStatusBar )

local w = display.contentWidth -- largura da tela
local h = display.contentHeight -- altura da tela

    wX = display.contentCenterX
    hY = display.contentCenterY

--grupos criados para organizar melhor
local backGroup = display.newGroup()  -- Display group for the background image<font></font>
local mainGroup = display.newGroup()  -- Display group for the nave, asteroids, lasers, etc.<font></font>
local botao = display.newGroup()    -- Display group for UI objects like the pontos

local fundo = display.newImageRect( backGroup, "img/fundo.png", 736, 1376 )
	fundo.x = wX 
	fundo.y = hY

local start = display.newImageRect( "img/start.png", 308, 144 )
	start.x = wX 
	start.y = hY + 400

--COLOCANDO TEXTOS PERSONALIZADOS NO JOGO
local logo = display.newImageRect( "img/logo.png",593 ,224 )
--local logo = display.newText("Space Magic", wX, hY, "font/Turtles", 100 )--SO COLOCAR FONTE QUE QUER NA PASTA ONDE ESTA O JOGO E CHAMAR ELA.
	logo.x = wX 
	logo.y = hY - 100
--	logo:setFillColor(0.68, 0.15, 1,04)



-- função para mudar de tela, e ir para o jogo 	
function iniciar(  )
   	composer.gotoScene("jogo", {  time = 1000, effect = "crossFade" })
end	
--function pontosAltos(  )
 --   composer.gotoScene( "pontosaltos", {effect = "fade", time = 1000})
--end

start:addEventListener("tap", iniciar)
--start:addEventListener("tap", pontosAltos)
return scene