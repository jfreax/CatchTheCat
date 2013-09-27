$ ->
  game = new Game('cat')

start = () -> 
  pop = new Population(3)
  pop.run(pop)
  
  
# Shim layer with setTimeout fallback
requestAnimFrame = ( () -> 
         return window.requestAnimationFrame       || 
                window.webkitRequestAnimationFrame || 
                window.mozRequestAnimationFrame    || 
                window.oRequestAnimationFrame      || 
                window.msRequestAnimationFrame     || 
                (callback) -> window.setTimeout(callback, 1000 / 60)
)()
