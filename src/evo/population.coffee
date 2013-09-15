class Population
  faceID: 0
  best: -1
  individuals: []

  constructor: (@count) ->
    @populate()
  
  populate: () ->
    for num in [1..@count]
      @individuals.push new Individual()
    return

  evolve: (self) ->
    for i in self.individuals
      i.mutate()

  run: (self) ->
    for i in self.individuals
      fitting = i.fitting()
      
      if fitting < self.best || self.best == 99
        self.best = fitting
        console.log fitting

    self.evolve( self )
    setTimeout( self.run, 10, self )
