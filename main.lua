local G = love.graphics
local KB = love.keyboard
local collisions = require("utils/collisions")

local player = {}
local background = nil

local canPlayerShoot = true
local playerShotDelay = 0.2
local playerCurrentShot = playerShotDelay
local playerShotImage
local playerProjectiles = {}

local isPlayerAlive = true;

local enemies = {}
local enemySpawnDelay = 1
local currentEnemy = enemySpawnDelay
local enemyImage
local enemyMargin = 0

local points = 0

local function playerInit()
    player.image = G.newImage("assets/images/Nave.png")
    playerShotImage = G.newImage("assets/images/projetil.png")

    player.x = (G.getWidth() - player.image:getWidth()) / 2
    player.y = (G.getHeight() - player.image:getHeight()) / 2

    player.speed = 300
end

local function enemyInit()
    enemyImage = G.newImage("assets/images/Nave-Inimiga.png")
    enemyMargin = enemyImage:getWidth() / 2
end

function love.load()
    enemyInit()
    playerInit()
    background = G.newImage("assets/images/Espaco.png")
end

function love.draw()
    G.draw(background, 0, 0)
    if isPlayerAlive then
        G.draw(player.image, player.x, player.y)
    else
        G.print("Fostes de vasco.")
    end
    for i in ipairs(playerProjectiles) do
        G.draw(playerShotImage, playerProjectiles[i].x, playerProjectiles[i].y)
    end

    for i in ipairs(enemies) do
        G.draw(enemyImage, enemies[i].x, enemies[i].y)
    end
end

function love.update(dt)
    if KB.isDown("r") and not isPlayerAlive then
        Reset()
    end
    if KB.isDown('escape') then
        love.event.quit()
    end

    if KB.isDown("left", 'a') then
        if player.x > 0 then
            player.x = player.x - player.speed * dt
        else
            player.x = 0
        end
    elseif KB.isDown("right", 'd') then
        if player.x < (G.getWidth() - player.image:getWidth()) then
            player.x = player.x + player.speed * dt
        end
    end

    playerCurrentShot = playerCurrentShot - (1 * dt)

    if playerCurrentShot < 0 then
        canPlayerShoot = true
    end

    if KB.isDown("space", "lctrl", "rctrl") and canPlayerShoot and isPlayerAlive then
        local newProjectile = { x = player.x + (player.image:getWidth() / 2), y = player.y }
        table.insert(playerProjectiles, newProjectile)
        canPlayerShoot = false
        playerCurrentShot = playerShotDelay
    end

    for i, projectile in ipairs(playerProjectiles) do
        projectile.y = projectile.y - (300 * dt)

        if projectile.y < 0 then
            table.remove(projectile, i)
        end
    end

    currentEnemy = currentEnemy - (1 * dt)

    if currentEnemy < 0 then
        currentEnemy = enemySpawnDelay

        math.randomseed(os.time())

        local randomXPostion = math.random(10 + enemyMargin, G.getWidth() - (10 - enemyMargin))
        local newEnemy = { x = randomXPostion, y = -10 }
        table.insert(enemies, newEnemy)
    end

    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (200 * dt)

        if enemy.y > G.getHeight() then
            table.remove(enemies, i)
        end
    end

    for i, enemy in ipairs(enemies) do
        for j, projectile in ipairs(playerProjectiles) do
            if collisions.checkCollision(
                    enemy.x, enemy.y, enemyImage:getWidth(), enemyImage:getHeight(),
                    projectile.x, projectile.y, playerShotImage:getWidth(), playerShotImage:getHeight()
                ) then
                table.remove(playerProjectiles, j)
                table.remove(enemies, i)
                points = points + 10;
            end

            if collisions.checkCollision(
                    enemy.x, enemy.y, enemyImage:getWidth(), enemyImage:getHeight(),
                    player.x, player.y, player.image:getWidth(), player.image:getHeight()
                ) then
                table.remove(enemies, i)
                isPlayerAlive = false
            end
        end
    end
end

function Reset()
    playerProjectiles = {}
    enemies = {}
    currentEnemy = enemySpawnDelay
    playerCurrentShot = playerShotDelay

    player.x = (G.getWidth() - player.image:getWidth()) / 2
    player.y = (G.getHeight() - player.image:getHeight()) / 2

    points = 0
    isPlayerAlive = true
end
