class Individual

  constructor: (@chromosom) ->
    
  fitness: () ->
    cat = {}
    for pos,type of @chromosom
      if type == 'cat'
        cat.x = Math.floor(pos % 11)
        cat.y = Math.floor(pos / 11)
        cat.distance = 0
        break
    
    visited = [cat.y*11+cat.x]
    return @bfs([cat], visited)
    
  bfs: (list, visited) ->
    next = []
    for l in list
      for n in @neighbours(l)
        if n.x <= 0 or n.x > 11 or n.y <= 0 or n.y > 11
          return l.distance
        else if n.x + n.y*11 not in visited
          visited.push(n.x + n.y*11)
          n.distance = l.distance + 1
          next.push(n)
          
    if next.length == 0
      return 99
    return @bfs(next, visited)

    
  neighbours: (l) ->
    neighs = []
    x = l.x
    y = l.y
    
    if !@chromosom[(x-1) + (y)*11]
      neighs.push({ x: l.x-1, y: l.y})
    if !@chromosom[(x+1) + (y)*11]
      neighs.push({ x: l.x+1, y: l.y})
    if !@chromosom[(x) + (y+1)*11]
      neighs.push({ x: l.x, y: l.y+1})
    if !@chromosom[(x) + (y-1)*11]
      neighs.push({ x: l.x, y: l.y-1})
    if l.y % 2
      if !@chromosom[(x-1) + (y+1)*11]
        neighs.push({ x: l.x-1, y: l.y+1})
      if !@chromosom[(x-1) + (y-1)*11]
        neighs.push({ x: l.x-1, y: l.y-1})
    else
      if !@chromosom[(x+1) + (y+1)*11]
        neighs.push({ x: l.x+1, y: l.y+1})
      if !@chromosom[(x+1) + (y-1)*11]
        neighs.push({ x: l.x+1, y: l.y-1})
        
    return neighs
    
  mutate: () ->
    return 0