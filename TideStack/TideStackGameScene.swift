// TideStackGameScene.swift
// Main game scene with all TideStack mechanics

import SpriteKit
import AVFoundation

class TideStackGameScene: SKScene {
    
    // MARK: - Constants
    let blockHeight: CGFloat = 34
    let initialBlockWidth: CGFloat = 120
    let minOverlap: CGFloat = 8
    let perfectThreshold: CGFloat = 18
    let autoDropSeconds: Double = 5.0
    let bounceLeft: CGFloat = 10
    let bounceRight: CGFloat = 350
    
    let colors: [UIColor] = [
        UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0),   // #FF6B6B
        UIColor(red: 1.0, green: 0.62, blue: 0.26, alpha: 1.0),   // #FF9F43
        UIColor(red: 1.0, green: 0.88, blue: 0.40, alpha: 1.0),   // #FFE066
        UIColor(red: 0.33, green: 0.94, blue: 0.77, alpha: 1.0),  // #55EFC4
        UIColor(red: 0.45, green: 0.73, blue: 1.0, alpha: 1.0),   // #74B9FF
        UIColor(red: 0.64, green: 0.61, blue: 1.0, alpha: 1.0),   // #A29BFE
        UIColor(red: 0.99, green: 0.47, blue: 0.66, alpha: 1.0),  // #FD79A8
        UIColor(red: 0.0, green: 0.81, blue: 0.79, alpha: 1.0),   // #00CEC9
        UIColor(red: 0.99, green: 0.80, blue: 0.43, alpha: 1.0),  // #FDCB6E
        UIColor(red: 0.42, green: 0.36, blue: 0.90, alpha: 1.0)   // #6C5CE7
    ]
    
    // MARK: - Game State
    enum GameState {
        case idle, playing, dead
    }
    
    var gameState: GameState = .idle
    var score: Int = 0
    var combo: Int = 0
    var blocks: [SKShapeNode] = []
    var movingBlock: SKShapeNode?
    var movingBlockDirection: CGFloat = 1
    var movingBlockSpeed: CGFloat = 2.8
    
    var tideY: CGFloat = 700
    var tideSpeed: CGFloat = 0.4
    var tideNode: SKShapeNode?
    var tideBackNode: SKShapeNode?
    var tideFoamNode: SKShapeNode?
    
    var particles: [SKNode] = []
    var comboTexts: [SKLabelNode] = []
    var clouds: [SKSpriteNode] = []
    
    var autoDropTimer: Double = 5.0
    var lastUpdateTime: TimeInterval = 0
    
    // MARK: - UI Nodes
    var scoreLabel: SKLabelNode!
    var tideBarBackground: SKShapeNode!
    var tideBarFill: SKShapeNode!
    var tideLabel: SKLabelNode!
    var startScreen: SKNode!
    var gameOverScreen: SKNode!
    
    // MARK: - Demo Mode
    var demoBlocks: [SKShapeNode] = []
    var demoMovingBlock: SKShapeNode?
    var demoMovingDirection: CGFloat = 1
    var demoTideY: CGFloat = 840
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.04, green: 0.09, blue: 0.16, alpha: 1.0)
        
        setupClouds()
        setupUI()
        setupStartScreen()
        setupGameOverScreen()
        
        initDemo()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        // Score display
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.fontSize = 44
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 60)
        scoreLabel.zPosition = 100
        scoreLabel.isHidden = true
        addChild(scoreLabel)
        
        // Tide bar background
        let barWidth: CGFloat = 210
        let barHeight: CGFloat = 10
        tideBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 5)
        tideBarBackground.fillColor = UIColor(white: 1.0, alpha: 0.12)
        tideBarBackground.strokeColor = UIColor(white: 1.0, alpha: 0.2)
        tideBarBackground.lineWidth = 1.5
        tideBarBackground.position = CGPoint(x: size.width / 2, y: 30)
        tideBarBackground.zPosition = 100
        tideBarBackground.isHidden = true
        addChild(tideBarBackground)
        
        // Tide bar fill
        tideBarFill = SKShapeNode(rectOf: CGSize(width: barWidth * 0.2, height: barHeight - 2), cornerRadius: 4)
        tideBarFill.fillColor = UIColor(red: 0.0, green: 0.9, blue: 1.0, alpha: 1.0)
        tideBarFill.strokeColor = .clear
        tideBarFill.position = CGPoint(x: -barWidth / 2 + barWidth * 0.1, y: 0)
        tideBarFill.zPosition = 101
        tideBarBackground.addChild(tideBarFill)
        
        // Tide label
        tideLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        tideLabel.fontSize = 9
        tideLabel.fontColor = UIColor(white: 1.0, alpha: 0.35)
        tideLabel.text = "TIDE LEVEL"
        tideLabel.position = CGPoint(x: size.width / 2, y: 45)
        tideLabel.zPosition = 100
        tideLabel.isHidden = true
        addChild(tideLabel)
    }
    
    func setupStartScreen() {
        startScreen = SKNode()
        startScreen.zPosition = 200
        
        // Background gradient effect
        let skyGradient = SKSpriteNode(color: UIColor(red: 0.04, green: 0.16, blue: 0.28, alpha: 1.0), size: size)
        skyGradient.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startScreen.addChild(skyGradient)
        
        // Stars
        for i in 0..<40 {
            let star = SKShapeNode(circleOfRadius: i % 3 == 0 ? 1.5 : 0.8)
            star.fillColor = .white
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.55...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...0.7)
            startScreen.addChild(star)
            
            // Twinkle animation
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.6 + Double.random(in: 0...0.5))
            let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.6 + Double.random(in: 0...0.5))
            star.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))
        }
        
        // Moon
        let moon = SKShapeNode(circleOfRadius: 18)
        moon.fillColor = UIColor(red: 0.91, green: 0.96, blue: 1.0, alpha: 1.0)
        moon.position = CGPoint(x: size.width * 0.82, y: size.height - 70)
        moon.glowWidth = 25
        startScreen.addChild(moon)
        
        // Logo
        let logoTitle = SKLabelNode(fontNamed: "Helvetica-Bold")
        logoTitle.fontSize = 48
        logoTitle.fontColor = .white
        logoTitle.text = "TideStack"
        logoTitle.position = CGPoint(x: size.width / 2, y: size.height - 160)
        startScreen.addChild(logoTitle)
        
        let logoSubtitle = SKLabelNode(fontNamed: "Helvetica")
        logoSubtitle.fontSize = 13
        logoSubtitle.fontColor = UIColor(red: 0.63, green: 0.94, blue: 1.0, alpha: 0.8)
        logoSubtitle.text = "~ ride the tide ~"
        logoSubtitle.position = CGPoint(x: size.width / 2, y: size.height - 185)
        startScreen.addChild(logoSubtitle)
        
        // Tagline
        let tagline = SKLabelNode(fontNamed: "Helvetica-Bold")
        tagline.fontSize = 15
        tagline.fontColor = UIColor(white: 1.0, alpha: 0.75)
        tagline.text = "Stack blocks before the tide catches up!"
        tagline.position = CGPoint(x: size.width / 2, y: 280)
        startScreen.addChild(tagline)
        
        // Tips
        let tips = ["Tap to place", "Perfect = full width", "5 sec auto-drop"]
        for (i, tip) in tips.enumerated() {
            let tipLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            tipLabel.fontSize = 11
            tipLabel.fontColor = UIColor(white: 1.0, alpha: 0.8)
            tipLabel.text = tip
            tipLabel.position = CGPoint(x: size.width / 2, y: 240 - CGFloat(i * 25))
            startScreen.addChild(tipLabel)
        }
        
        // Play button
        let playButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 30)
        playButton.fillColor = UIColor(red: 0.0, green: 0.9, blue: 1.0, alpha: 1.0)
        playButton.position = CGPoint(x: size.width / 2, y: 120)
        playButton.name = "playButton"
        startScreen.addChild(playButton)
        
        let playLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        playLabel.fontSize = 30
        playLabel.fontColor = .white
        playLabel.text = "PLAY"
        playLabel.position = CGPoint(x: 0, y: -10)
        playLabel.name = "playButton"
        playButton.addChild(playLabel)
        
        addChild(startScreen)
    }
    
    func setupGameOverScreen() {
        gameOverScreen = SKNode()
        gameOverScreen.zPosition = 200
        gameOverScreen.isHidden = true
        
        // Background
        let bg = SKSpriteNode(color: UIColor(red: 0.04, green: 0.12, blue: 0.24, alpha: 0.95), size: size)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverScreen.addChild(bg)
        
        // Wave icon
        let waveIcon = SKLabelNode(fontNamed: "AppleColorEmoji")
        waveIcon.fontSize = 70
        waveIcon.text = "🌊"
        waveIcon.position = CGPoint(x: size.width / 2, y: size.height - 150)
        gameOverScreen.addChild(waveIcon)
        
        // Title
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.fontSize = 32
        title.fontColor = .white
        title.text = "Tide Got You!"
        title.position = CGPoint(x: size.width / 2, y: size.height - 240)
        gameOverScreen.addChild(title)
        
        // Score label
        let scoreLabelTitle = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabelTitle.fontSize = 12
        scoreLabelTitle.fontColor = UIColor(red: 0.63, green: 0.86, blue: 1.0, alpha: 0.7)
        scoreLabelTitle.text = "YOUR SCORE"
        scoreLabelTitle.position = CGPoint(x: size.width / 2, y: size.height - 300)
        gameOverScreen.addChild(scoreLabelTitle)
        
        // Final score
        let finalScoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        finalScoreLabel.fontSize = 72
        finalScoreLabel.fontColor = .white
        finalScoreLabel.text = "0"
        finalScoreLabel.name = "finalScore"
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 360)
        gameOverScreen.addChild(finalScoreLabel)
        
        // Restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: 200, height: 55), cornerRadius: 27)
        restartButton.fillColor = UIColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0)
        restartButton.position = CGPoint(x: size.width / 2, y: 150)
        restartButton.name = "restartButton"
        gameOverScreen.addChild(restartButton)
        
        let restartLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.text = "Try Again"
        restartLabel.position = CGPoint(x: 0, y: -8)
        restartLabel.name = "restartButton"
        restartButton.addChild(restartLabel)
        
        // Hint
        let hint = SKLabelNode(fontNamed: "Helvetica-Bold")
        hint.fontSize = 13
        hint.fontColor = UIColor(white: 1.0, alpha: 0.4)
        hint.text = "Perfect stacks keep your width — combo for bonus!"
        hint.position = CGPoint(x: size.width / 2, y: 80)
        gameOverScreen.addChild(hint)
        
        addChild(gameOverScreen)
    }
    
    func setupClouds() {
        let cloudPositions = [
            (x: 30, y: size.height - 55, scale: 1.1),
            (x: 190, y: size.height - 35, scale: 0.85),
            (x: 295, y: size.height - 75, scale: 1.0)
        ]
        
        for pos in cloudPositions {
            let cloud = createCloud()
            cloud.position = CGPoint(x: pos.x, y: pos.y)
            cloud.setScale(pos.scale)
            cloud.alpha = 0.88
            addChild(cloud)
            clouds.append(cloud)
        }
    }
    
    func createCloud() -> SKSpriteNode {
        let cloudNode = SKNode()
        
        let circles = [
            (x: 0, y: 0, r: 25),
            (x: 30, y: -5, r: 20),
            (x: -25, y: 5, r: 18),
            (x: 15, y: 10, r: 18)
        ]
        
        for circle in circles {
            let c = SKShapeNode(circleOfRadius: CGFloat(circle.r))
            c.fillColor = .white
            c.position = CGPoint(x: circle.x, y: circle.y)
            cloudNode.addChild(c)
        }
        
        // Convert to sprite for better performance
        let texture = view?.texture(from: cloudNode) ?? SKTexture()
        return SKSpriteNode(texture: texture)
    }
    
    // MARK: - Demo Mode
    func initDemo() {
        demoBlocks.forEach { $0.removeFromParent() }
        demoBlocks.removeAll()
        demoMovingBlock?.removeFromParent()
        
        let baseX = (size.width - initialBlockWidth) / 2
        for i in 0..<5 {
            let block = createBlock(
                x: baseX + CGFloat.random(in: -5...5),
                y: 100 + CGFloat(i) * blockHeight,
                width: max(60, initialBlockWidth - CGFloat(i) * 4),
                color: colors[i % colors.count]
            )
            demoBlocks.append(block)
            addChild(block)
        }
        
        spawnDemoMovingBlock()
    }
    
    func spawnDemoMovingBlock() {
        let topBlock = demoBlocks.last!
        let width = max(60, topBlock.frame.width)
        let startLeft = demoBlocks.count % 2 == 0
        
        demoMovingBlock = createBlock(
            x: startLeft ? bounceLeft : bounceRight - width,
            y: topBlock.position.y + blockHeight,
            width: width,
            color: colors.randomElement()!
        )
        demoMovingDirection = startLeft ? 1 : -1
        demoMovingBlock?.alpha = 0.7
        addChild(demoMovingBlock!)
    }
    
    // MARK: - Game Logic
    func initGame() {
        // Clear existing blocks
        blocks.forEach { $0.removeFromParent() }
        blocks.removeAll()
        movingBlock?.removeFromParent()
        particles.forEach { $0.removeFromParent() }
        particles.removeAll()
        comboTexts.forEach { $0.removeFromParent() }
        comboTexts.removeAll()
        
        // Reset state
        score = 0
        combo = 0
        tideY = size.height + 40
        tideSpeed = 0.4
        autoDropTimer = autoDropSeconds
        
        // Create base block
        let baseBlock = createBlock(
            x: (size.width - initialBlockWidth) / 2,
            y: 100,
            width: initialBlockWidth,
            color: UIColor(red: 0.63, green: 0.83, blue: 0.41, alpha: 1.0)
        )
        blocks.append(baseBlock)
        addChild(baseBlock)
        
        spawnMovingBlock()
        updateScoreDisplay()
        
        // Show UI
        scoreLabel.isHidden = false
        tideBarBackground.isHidden = false
        tideLabel.isHidden = false
        
        // Setup tide
        setupTide()
    }
    
    func setupTide() {
        tideNode?.removeFromParent()
        tideBackNode?.removeFromParent()
        tideFoamNode?.removeFromParent()
        
        // Back wave
        tideBackNode = SKShapeNode()
        tideBackNode?.fillColor = UIColor(red: 0.0, green: 0.39, blue: 0.78, alpha: 0.5)
        tideBackNode?.zPosition = 50
        addChild(tideBackNode!)
        
        // Main wave
        tideNode = SKShapeNode()
        tideNode?.fillColor = UIColor(red: 0.12, green: 0.63, blue: 0.94, alpha: 0.82)
        tideNode?.zPosition = 51
        addChild(tideNode!)
        
        // Foam
        tideFoamNode = SKShapeNode()
        tideFoamNode?.fillColor = UIColor(red: 0.71, green: 0.92, blue: 1.0, alpha: 0.45)
        tideFoamNode?.zPosition = 52
        addChild(tideFoamNode!)
    }
    
    func createBlock(x: CGFloat, y: CGFloat, width: CGFloat, color: UIColor) -> SKShapeNode {
        let block = SKShapeNode(rectOf: CGSize(width: width, height: blockHeight), cornerRadius: 10)
        block.fillColor = color
        block.strokeColor = UIColor(white: 0.0, alpha: 0.15)
        block.lineWidth = 1.5
        block.position = CGPoint(x: x + width / 2, y: y + blockHeight / 2)
        
        // Add highlight gradient effect
        let highlight = SKShapeNode(rectOf: CGSize(width: width - 4, height: blockHeight / 2), cornerRadius: 8)
        highlight.fillColor = UIColor(white: 1.0, alpha: 0.3)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: blockHeight / 4)
        block.addChild(highlight)
        
        return block
    }
    
    func spawnMovingBlock() {
        let topBlock = blocks.last!
        let blockWidth = max(40, topBlock.frame.width)
        movingBlockSpeed = min(2.8 + CGFloat(score) * 0.05, 7)
        let startLeft = blocks.count % 2 == 0
        
        movingBlock = createBlock(
            x: startLeft ? bounceLeft : bounceRight - blockWidth,
            y: topBlock.position.y + blockHeight - blockHeight / 2,
            width: blockWidth,
            color: colors.randomElement()!
        )
        movingBlockDirection = startLeft ? 1 : -1
        
        // Add glow effect for moving block
        movingBlock?.strokeColor = UIColor(white: 1.0, alpha: 0.9)
        movingBlock?.lineWidth = 2.5
        
        addChild(movingBlock!)
        autoDropTimer = autoDropSeconds
    }
    
    func dropBlock() {
        guard let moving = movingBlock else { return }
        let topBlock = blocks.last!
        
        let movingLeft = moving.position.x - moving.frame.width / 2
        let movingRight = moving.position.x + moving.frame.width / 2
        let topLeft = topBlock.position.x - topBlock.frame.width / 2
        let topRight = topBlock.position.x + topBlock.frame.width / 2
        
        let overlapLeft = max(movingLeft, topLeft)
        let overlapRight = min(movingRight, topRight)
        let overlap = overlapRight - overlapLeft
        
        if overlap <= 0 {
            killPlayer()
            return
        }
        
        let isPerfect = abs(movingLeft - topLeft) <= perfectThreshold
        
        if isPerfect {
            combo += 1
            spawnPerfectParticles(at: topBlock.position)
            showComboText(combo)
            SoundManager.shared.playPerfectSound()
            if combo >= 3 {
                SoundManager.shared.playComboSound()
            }
            
            // Keep full width
            let newBlock = createBlock(
                x: topLeft,
                y: topBlock.position.y + blockHeight / 2,
                width: topBlock.frame.width,
                color: moving.fillColor
            )
            blocks.append(newBlock)
            addChild(newBlock)
            
            score += 1 + combo / 3
        } else {
            combo = 0
            let newWidth = max(overlap, minOverlap)
            spawnChipParticles(at: CGPoint(x: movingLeft > topLeft ? movingRight : movingLeft, y: moving.position.y), color: moving.fillColor)
            SoundManager.shared.playDropSound()
            
            let newBlock = createBlock(
                x: overlapLeft,
                y: topBlock.position.y + blockHeight / 2,
                width: newWidth,
                color: moving.fillColor
            )
            blocks.append(newBlock)
            addChild(newBlock)
            
            score += 1
        }
        
        moving.removeFromParent()
        movingBlock = nil
        
        updateScoreDisplay()
        tideSpeed += 0.025
        
        // Check if tide caught up
        if tideY < topBlock.position.y + blockHeight {
            killPlayer()
            return
        }
        
        spawnMovingBlock()
    }
    
    func killPlayer() {
        gameState = .dead
        movingBlock?.removeFromParent()
        movingBlock = nil
        SoundManager.shared.playGameOverSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            self.showGameOver()
        }
    }
    
    func showGameOver() {
        if let finalScoreLabel = gameOverScreen.childNode(withName: "//finalScore") as? SKLabelNode {
            finalScoreLabel.text = "\(score)"
        }
        gameOverScreen.isHidden = false
        scoreLabel.isHidden = true
        tideBarBackground.isHidden = true
        tideLabel.isHidden = true
    }
    
    func updateScoreDisplay() {
        scoreLabel.text = "\(score)"
    }
    
    // MARK: - Particles & Effects
    func spawnPerfectParticles(at position: CGPoint) {
        for i in 0..<14 {
            let angle = (CGFloat.pi * 2 / 14) * CGFloat(i)
            let speed = CGFloat.random(in: 2...5)
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            particle.fillColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            particle.position = position
            particle.zPosition = 60
            
            let vx = cos(angle) * speed
            let vy = sin(angle) * speed
            
            addChild(particle)
            particles.append(particle)
            
            let move = SKAction.moveBy(x: vx * 30, y: vy * 30, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            particle.run(SKAction.sequence([SKAction.group([move, fade]), remove]))
        }
    }
    
    func spawnChipParticles(at position: CGPoint, color: UIColor) {
        for _ in 0..<7 {
            let size = CGFloat.random(in: 5...10)
            let particle = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 2)
            particle.fillColor = color
            particle.position = position
            particle.zPosition = 60
            
            let vx = CGFloat.random(in: -3...3)
            let vy = CGFloat.random(in: -5...-1)
            
            addChild(particle)
            particles.append(particle)
            
            let move = SKAction.moveBy(x: vx * 20, y: vy * 20, duration: 0.4)
            let fade = SKAction.fadeOut(withDuration: 0.4)
            let remove = SKAction.removeFromParent()
            particle.run(SKAction.sequence([SKAction.group([move, fade]), remove]))
        }
    }
    
    func showComboText(_ combo: Int) {
        let text: String
        if combo >= 5 {
            text = "INSANE!"
        } else if combo >= 3 {
            text = "COMBO x\(combo)"
        } else {
            text = "PERFECT!"
        }
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 22
        label.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        label.text = text
        label.position = CGPoint(x: size.width / 2, y: blocks.last!.position.y + 50)
        label.zPosition = 70
        addChild(label)
        comboTexts.append(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 0.8)
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([SKAction.group([moveUp, fade]), remove]))
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let dt = min(currentTime - lastUpdateTime, 0.1)
        lastUpdateTime = currentTime
        
        // Update clouds
        for cloud in clouds {
            cloud.position.x += 0.18 * cloud.xScale * 60 * CGFloat(dt)
            if cloud.position.x > size.width + 80 {
                cloud.position.x = -80
            }
        }
        
        if gameState == .idle {
            updateDemo(dt)
            return
        }
        
        if gameState != .playing {
            return
        }
        
        // Update moving block
        if let moving = movingBlock {
            moving.position.x += movingBlockDirection * movingBlockSpeed * 60 * CGFloat(dt)
            
            let movingLeft = moving.position.x - moving.frame.width / 2
            let movingRight = moving.position.x + moving.frame.width / 2
            
            if movingBlockDirection == 1 && movingRight >= bounceRight {
                moving.position.x = bounceRight - moving.frame.width / 2
                movingBlockDirection = -1
            }
            if movingBlockDirection == -1 && movingLeft <= bounceLeft {
                moving.position.x = bounceLeft + moving.frame.width / 2
                movingBlockDirection = 1
            }
            
            // Update auto-drop timer
            autoDropTimer -= dt
            if autoDropTimer <= 0 {
                dropBlock()
                return
            }
        }
        
        // Update tide
        tideY -= tideSpeed * 60 * CGFloat(dt)
        
        let topBlock = blocks.last!
        if tideY < topBlock.position.y + blockHeight {
            killPlayer()
            return
        }
        
        // Update tide bar
        let gap = topBlock.position.y + blockHeight - tideY
        let dangerPct = max(0, min(1, 1 - gap / (size.height * 0.5)))
        let barWidth: CGFloat = 210
        tideBarFill.xScale = dangerPct * 5 // Scale from 20% to 100%
        
        // Update tide wave shape
        updateTideWave()
    }
    
    func updateDemo(_ dt: TimeInterval) {
        if let demoMoving = demoMovingBlock {
            demoMoving.position.x += demoMovingDirection * 3.2 * 60 * CGFloat(dt)
            
            let movingLeft = demoMoving.position.x - demoMoving.frame.width / 2
            let movingRight = demoMoving.position.x + demoMoving.frame.width / 2
            
            if demoMovingDirection == 1 && movingRight >= bounceRight {
                demoMoving.position.x = bounceRight - demoMoving.frame.width / 2
                demoMovingDirection = -1
            }
            if demoMovingDirection == -1 && movingLeft <= bounceLeft {
                demoMoving.position.x = bounceLeft + demoMoving.frame.width / 2
                demoMovingDirection = 1
            }
        }
        
        demoTideY -= 0.15 * 60 * CGFloat(dt)
        if demoTideY < size.height - 50 {
            demoTideY = size.height + 200
        }
    }
    
    func updateTideWave() {
        let time = CACurrentMediaTime()
        
        // Create wave path
        func createWavePath(amplitude: CGFloat, frequency: CGFloat, phase: CGFloat, yOffset: CGFloat) -> CGPath {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: yOffset))
            
            for x in stride(from: 0, to: Int(size.width) + 5, by: 5) {
                let y = yOffset + sin(CGFloat(x) / frequency + CGFloat(time) / phase) * amplitude
                path.addLine(to: CGPoint(x: CGFloat(x), y: y))
            }
            
            path.addLine(to: CGPoint(x: size.width, y: -100))
            path.addLine(to: CGPoint(x: 0, y: -100))
            path.closeSubpath()
            return path
        }
        
        tideBackNode?.path = createWavePath(amplitude: 7, frequency: 40, phase: 0.6, yOffset: tideY + 4)
        tideNode?.path = createWavePath(amplitude: 6, frequency: 30, phase: 0.4, yOffset: tideY)
        tideFoamNode?.path = createWavePath(amplitude: 5, frequency: 22, phase: 0.28, yOffset: tideY - 7)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "playButton" {
                startGame()
                return
            }
            if node.name == "restartButton" {
                restartGame()
                return
            }
        }
        
        if gameState == .playing {
            dropBlock()
        }
    }
    
    func startGame() {
        startScreen.isHidden = true
        gameState = .playing
        initGame()
    }
    
    func restartGame() {
        gameOverScreen.isHidden = true
        scoreLabel.isHidden = false
        tideBarBackground.isHidden = false
        tideLabel.isHidden = false
        gameState = .playing
        initGame()
    }
}
