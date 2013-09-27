class Population

  constructor: (@world) ->
    @best = -1
    @best_fitness = -1
    @individuals = []
    
    @populate()
  
  populate: () ->
    for x in [1..11]
      for y in [1..11]
        num = x + y*11
        if !@world[num]
          newWorld = @clone(@world)
          newWorld[num] = 'wall'
          ind = new Individual(newWorld)
          ind.parent = ind
          @individuals.push ind

    for i in @individuals
      for x in [1..11]
        for y in [1..11]
          num = x + y*11
          ind = new Individual @clone(i.chromosom)
          
          #catMove = ind.nextBestMove()
          #ind.moveCat(catMove.x, catMove.y)
         
          if !i.chromosom[num]
            ind.chromosom[num] = 'wall'
            
            ind.parent = i
            @individuals.push ind

  run: () ->
    for i in @individuals
      fitness = i.fitness()
      
      if fitness > @best_fitness or (fitness == @best_fitness and i.parent == i)
        @best_fitness = fitness
        console.log "Best: " + @best_fitness
        @best = i

    return @best.parent
    
  clone: (obj) ->
    return obj  if obj is null or typeof (obj) isnt "object"
    temp = new obj.constructor()
    for key of obj
      temp[key] = @clone(obj[key])
    temp