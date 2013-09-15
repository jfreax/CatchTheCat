class Game
  floorColor: "rgb(200,200,200)"

  constructor: () ->
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
          y = Math.round(e.offsetY / (@radius * 2))
          
          xoffset = @radius
          if y % 2
            xoffset = 2*@radius
            
          x = Math.round (e.offsetX + xoffset) / (@radius*2) - 1
          
          if !@fields[y*11+x]
            @makeWall x,y
            ind = new Individual(@fields)
          
            @makeCatMove()
            if ind.fitness() == 99
              @catLost()
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
    neighbours = i.neighbours(@cat)
    best_distance = 99
    best_ind = neighbours[0]
    for n in neighbours
      n.distance = 0
      distance = i.bfs([n], [n.x+n.y*11])
      if distance < best_distance
        best_distance = distance
        best_ind = n
    @setCat(best_ind.x, best_ind.y)
    @isLost()
    
    #for bla in n
    #  @makeWall(bla.x, bla.y)
    
    @isPaused = false

  isLost: () ->
    if @cat.x <= 0 or @cat.x > 11 or @cat.y <= 0 or @cat.y > 11
      @ctx.font = "bold 120px sans-serif"
      @ctx.textAlign = 'center'
      @ctx.fillText("LOST", @gamefield.width / 2, @gamefield.height / 2)
      @isPaused = true

  catLost: () ->
      @ctx.font = "bold 110px sans-serif"
      @ctx.textAlign = 'center'
      @ctx.fillText("CAT LOST", @gamefield.width / 2, @gamefield.height / 2)
      @isPaused = true