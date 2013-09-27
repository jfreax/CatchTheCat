class Game
  floorColor: "rgb(200,200,200)"

  constructor: (@type) ->
    @fields = {}
    @cat = {}

    @radius = 24
    @isPaused = true

    @gamefield = document.getElementById('game')
    @ctx = @gamefield.getContext('2d')
    @initialize()
    
    
  initialize: () ->
    @ctx.fillStyle = @floorColor
    
    for x in [1..11]
      for y in [1..11]
        @drawTile(x, y)
        
    @setCat(6, 5)
    @randomWalls( Math.random() * 5 + 3 )
    
    @gamefield.addEventListener('click', (e) =>
          if @isPaused
            return
          
          if e.offsetX == undefined # for Firefox
            xpos = e.pageX-@gamefield.offsetLeft;
            ypos = e.pageY-@gamefield.offsetTop;
          else
            xpos = e.offsetX
            ypos = e.offsetY
  
          y = Math.round(ypos / (@radius * 2))
          
          xoffset = @radius
          if y % 2
            xoffset = 2*@radius
            
          x = Math.round (xpos + xoffset) / (@radius*2) - 1
          nextPos = { x: x, y: y }
          
          if !@fields[y*11+x]
            ind = new Individual(@fields)
            if @type == 'catcher'
              @makeWall x,y
              #@makeWallAi()
              @makeCatMove()
            else # cat
              for n in ind.neighbours(@cat) # fixme: silly and unefficient
                if n.x == nextPos.x and n.y == nextPos.y
                  @setCat(nextPos.x, nextPos.y)
                  @makeWallAi()
                
            console.log ind.fitness()
            if ind.fitness() == 99
              @catLost()
            @isLost()
            
            @isPaused = false
      , false)
      
      @isPaused = false
  
  randomWalls: (count) ->
    for i in [1..count]
      @makeWall(
        Math.round(Math.random()*10+1), 
        Math.round(Math.random()*10+1)
      )
      
  setCat: (x, y) ->
    if @cat.x and @cat.y
      @ctx.fillStyle = @floorColor
      @drawTile(@cat.x, @cat.y)

    @ctx.fillStyle = "rgb(200,100,100)"
    xOffset = 0.25
    if y % 2
      xOffset = -0.25
    @ctx.fillRect((x+xOffset)*@radius*2, (y-0.25)*@radius*2, @radius, @radius)
    
    @fields[@cat.y*11+@cat.x] = undefined
    @fields[y*11+x] = 'cat'
    
    @cat.x = x
    @cat.y = y
      
  drawTile: (x, y) ->
    @ctx.beginPath()
    if y % 2
      @ctx.arc(x*@radius*2, y*@radius*2, @radius-1, 0, Math.PI*2, true)
    else
      @ctx.arc(x*@radius*2+@radius, y*@radius*2, @radius-1, 0, Math.PI*2, true)
    @ctx.closePath()
    @ctx.fill()
 
  makeWall: (x, y) ->
    if @fields[y*11+x] == 'cat'
      return
  
    @fields[y*11+x] = 'wall'
    @ctx.fillStyle = "rgb(100,100,100)"
    @drawTile(x, y)
    
    @isPaused = true
    
  makeCatMove: () ->
    i = new Individual( @fields )
    best = i.nextBestMove()
    @setCat(best.x, best.y)

    @isPaused = false
    
  makeWallAi: () ->
    pop = new Population(@fields)
    best = pop.run()
    
    for pos,type of best.chromosom
      if !@fields[pos]
        if best.chromosom[pos] == 'wall'
          @makeWall( Math.floor((pos-1) % 11)+1, Math.floor((pos-1) / 11) )
        
    @isPaused = false

  isLost: () ->
    if @cat.x <= 0 or @cat.x > 11 or @cat.y <= 0 or @cat.y > 11
      @catWon()

  catWon: () ->
    if @type == 'catcher'
      @ctx.fillStyle = "rgb(200,100,100)"
      @ctx.font = "bold 120px sans-serif"
      @ctx.textAlign = 'center'
      @ctx.fillText("LOST", @gamefield.width / 2, @gamefield.height / 2)
    else
      @ctx.fillStyle = "rgb(100,200,100)"
      @ctx.font = "bold 120px sans-serif"
      @ctx.textAlign = 'center'
      @ctx.fillText("WON", @gamefield.width / 2, @gamefield.height / 2)
    @isPaused = true
      
  catLost: () ->
    if @type == 'cat'
      @ctx.fillStyle = "rgb(200,100,100)"
      @ctx.font = "bold 110px sans-serif"
      @ctx.textAlign = 'center'
      @ctx.fillText("LOST", @gamefield.width / 2, @gamefield.height / 2)
    else
      @ctx.fillStyle = "rgb(100,200,100)"
      @ctx.font = "bold 120px sans-serif"
      @ctx.textAlign = 'center'
      @ctx.fillText("WON", @gamefield.width / 2, @gamefield.height / 2)
    @isPaused = true