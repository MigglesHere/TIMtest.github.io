pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- main
function _init()
  cls()  
  ts = 0  
  state = "start"
  init_game() 
  init_pickups()   
end

function _update() 
  if state == "start" then
    update_start()
  elseif state == "game" then
    update_game()
    updateparts()
    update_pickups()
  end 
  
end

function _draw() 
  if state == "start" then
    draw_start()
  elseif state == "game" then
    draw_map()
    draw_player()
    draw_pickups()
  end 
  
  if false then
    rect(box.x,box.y,
         box.x2,box.y2,8)
  end  
end

-->8
-- movement and updates
function init_game()
  pl = {}
  pl.x = 60
  pl.y = 60
  pl.ox = 60
  pl.oy = 60
  pl.w = 8
  pl.h = 8
  pl.s = 1
  pl.tle = 0
  pl.hp = 3
  t = 0
  
  part={}
  
  mob = {}
  addmob(0,2,6)
  addmob(0,21,10)
  addmob(1,30,10)
  
  gridx = 0
  gridy = 0
  
  cx = 0
  cy = 0
  
  dash_timer = 0
  dash_cooldown = 10
  
  box = {}
  box.x = 32
  box.y = 32
  box.x2 = 88
  box.y2 = 88
end

function update_start()
  if btnp(❎) then
    state = "game"
  end  
end

function update_game()
  if dash_timer > 0 then
    dash_timer -= 1
  end   
  pl.s = 3
  t += 1
  pl.ox = pl.x
  pl.oy = pl.y
  gridx = flr(pl.x/8)
  gridy = flr(pl.y/8)  
  pl.tle = mget(gridx,gridy)
  
  
  --player movement
  if btn(➡️) then
    pl.x += 1  
    pl.s = 1       
    if btn(❎)  then
      pl.x += 2  
      spawntrail(pl.x-2,pl.y+4)       
    end    
  elseif btn(⬅️) then
    pl.x -= 1
    pl.s = 2
    if btn(❎)  then
      pl.x -= 2  
      spawntrail(pl.x+2,pl.y+4)    
    end
  end
  
  if btn(⬆️) then
    pl.y -= 1
    pl.s = 4
    if btn(❎) then
      pl.y -= 2
      spawntrail(pl.x+4,pl.y+2)
    end    
  elseif btn(⬇️) then
    pl.y += 1
    pl.s = 3
    if btn(❎) then
      pl.y += 2
      spawntrail(pl.x+4,pl.y-2)
    end     
  end  
  
  --collision detection
  if map_collide(pl.x,pl.y,
                 pl.w,pl.h) then
     bump()
  end  
  
  --camera movement
  if pl.x < box.x then
    pl.x = box.x
    if btn(❎)  then
      cx -= 4
     
    end
    cx -= 2
  elseif pl.x > box.x2 then
    pl.x = box.x2
    if btn(❎)  then
      cx += 4
    
    end
    cx += 2
  end
  
  if cx <= 0 then
    cx = 0
    box.x = 0
  elseif cx >= 896 then
    cx = 896    
    box.x2 = 127
  else 
    box.x = 32
    box.x2 = 88 
  end
  
  if pl.y < box.y then
    pl.y = box.y
    if btn(❎)  then
      cy -= 4
      
    end
    cy -= 1
  elseif pl.y > box.y2 then
    pl.y = box.y2
    if btn(❎)  then 
      cy += 4
      
    end
    cy += 1
  end
  
  if cy <= 0 then
    cy = 0
    box.y = 0
  elseif cy >= 896 then
    cy = 896
    box.y2 = 127
  else 
    box.y = 32
    box.y2 = 88
  end

end

function game_over()

end


-->8
--collision and draw
function draw_map()
  cls()
  camera(cx,cy)
  map(mx,my)
  camera(0,0)
  
  for m in all(mob) do
    drawspr(getframe(m.ani),m.x*8,m.y*8,20,false)
  end
end

function draw_player()
  drawpart()
  spr(pl.s, pl.x, pl.y)
end

function draw_start()

  //cls()
  while (ts<60) do
    if (ts>30) then
    spr(69,71,48)
    spr(70,79,48)
    spr(85,71,56)
    spr(86,79,56)
    elseif (ts>15) then
    spr(67,55,36)
    spr(68,63,36)
    spr(83,55,44)
    spr(84,63,44)
    else
    spr(65,39,24)
    spr(66,47,24)
    spr(81,39,32)
    spr(82,47,32)
    end
    
    if (ts>45) then
      print("press ❎ to start!",35,80,7,8)    
    end
    
    flip() 
    ts+=1
  end
end


--add particle
function addpart(_x,_y,_type,_maxage,_col)  
  local _p = {}
  _p.x = _x
  _p.y = _y
  _p.tpe = _type
  _p.mage = _maxage
  _p.age = 0
  _p.col = _col
  add(part,_p) 
end

--spawn dash trail
function spawntrail(_x,_y)
  local _ang = rnd()
  local _ox = sin(_ang)*4*0.6
  local _oy = cos(_ang)*4*0.6
  addpart(_x+_ox,_y+_oy,0,10+rnd(10),8)
end

function updateparts()
  local _p
  for i=#part,1,-1 do 
    _p = part[i] 
    _p.age += 1
    if _p.age > _p.mage then
      del(part,part[i])
    else
    
    end
  end
end

function drawpart()
  for i=1,#part do
    _p = part[i]
    if _p.tpe == 0 then
      pset(_p.x,_p.y,10)
    end 
  end
end

function bump()  
  if pl.x > pl.ox then
    pl.x = pl.ox - 0.9999
  elseif pl.x < pl.ox then
    pl.x = pl.ox + 0.9999
  end 
     
  if pl.y > pl.oy then
    pl.y = pl.oy - 0.9999
  elseif pl.y < pl.oy then
    pl.y = pl.oy + 0.9999
  end  
end

function map_collide(x,y,
                     w,h)
  x += cx 
  y += cy
  
  s1 = mget(x / 8, y / 8)
  s2 = mget((x+w-1) /8, y / 8)            
  s3 = mget(x / 8,(y+w-1) /8)
  s4 = mget((x+w-1) /8,(y+w-1) /8)
            
  if fget(s1,3) then                      
    return true
  elseif fget(s2,3) then
    return true
  elseif fget(s3,3) then
    return true
  elseif fget(s4,3) then
    return true
  end
    
  return false
end

function item_collide(tle,x,y)
  if tle == 23 or tle == 24 then
    --health
    mset(x,y,8)
  elseif tle == 39 or tle == 40 then
    --damageboost
    mset(x,y,8)
  end  
end

function cooldown()
  
  if dash_cooldown > 0 then 
    return true
  end
  
  return false
end
-->8
--pickups
function init_pickups()

  pu = {}
  add(pu, {s=23, x = 2, y=2})
  add(pu, {s=24, x = 12, y=9})
  add(pu, {s=39, x = 2, y=12})
  add(pu, {s=40, x = 13, y=8})
end

function update_pickups()
   
   px = pl.x + cx
   py = pl.y + cy
   
   for p in all(pu) do 
     if aabb_collide(
       px, py, pl.w, pl.h,
       p.x*8,p.y*8,8 ,8) then
       del(pu,p)
     end
   end

end

function draw_pickups()
  camera(cx,cy)
  for p in all(pu) do 
    spr(p.s,p.x*8,p.y*8)
  end
  camera(0,0)
end

function aabb_collide(
              x1, y1, w1, h1,
              x2, y2, w2, h2)
              
  if x1 < x2 + w2 and
     x1 + w1 > x2 and
     y1 < y2 + h2 and
     y1 + h1 > y2 then
   return true
  end
  
 return false
end
-->8
--mobs
function addmob(typ,mobx,moby)
  local m = {
    x = mobx,
    y = moby,
    ani = {17,18,19,20}
  }  
  local s = {
    x = mobx,
    y = moby,
    ani = {49,50,51,52}
  }
  if typ == 0 then  
    add(mob,m) 
  else
    add(mob,s) 
  end
end

function getframe(ani)
  return ani[flr(t/8)%4+1]
end

function drawspr(_spr,_x,_y,_c)   
   camera(cx,cy)
   spr(_spr,_x,_y)
   camera(0,0)
end

function mobwalk(mob,dx,dy)
  mob.x += dx
  mob.y += dy

end

__gfx__
000000000055000000005500000550000005500000000000000000005555d6550000000000000000000000000000000000000000000000000000000000000000
000000000599900000099950009995000055550000000000000000005555d6550000000000000000000000000000000000000000000000000000000000000000
00700700091910000001919000191900005555000000000000000000ddddd6dd0000000000000000000000000000000000000000000000000000000000000000
0007700004fff550055fff4000fff400005555000000000000000000666666660000000000000000000000000000000000000000000000000000000000000000
000770004222265005622224045555400422224000000000000000005556dddd0000500000000000000000000000000000000000000000000000000000000000
00700700f55657500575655f0f5665f00f5665f000000000000000005556d5550000000000000000000000000000000000000000000000000000000000000000
00000000022225000052222000255200002222000000000000000000ddd655550000000000000000000000000000000000000000000000000000000000000000
00000000040040000004004000400400004004000000000000000000666666660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007770000777777000000000000000000000000000000000000000000000000000000000
000000000000000000bbb00000000000000000000000000000000000070007007000000706666600066666000000000000000000000000000000000000000000
0000000000bbb0000b0bbb0000bbb000000000000000000000000000070007007000000700606000006060000000000000000000000000000000000000000000
000000000b0bbb000b0bbb000b0bbb000bbbbbb00000000000000000007770000777777006000600068886000000000000000000000000000000000000000000
00000000b0bbbbb00bbbbb00b0bbbbb0b00bbbbb0000000000000000078887007788887760700060687888600000000000000000000000000000000000000000
00000000bbbbbbb00bbbbb00bbbbbbb0bbbbbbbb0000000000000000788888707888888767888860678888600000000000000000000000000000000000000000
000000000bbbbb0000bbb0000bbbbb000bbbbbb00000000000000000788888707788887768888860688888600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000077777000777777006666600066666000000000000000000000000000000000000000000
00000000007700000077000000770000007700000000000000000000007770000777777000000000000000000000000000000000000000000000000000000000
00000000070707000707070007070700070707000000000000000000070007007000000706666600066666000000000000000000000000000000000000000000
00000000077777000777770007777700077777000000000000000000070007007000000700606000006060000000000000000000000000000000000000000000
0000000077000700070007007700070077000700000000000000000000777000077777700600060006aaa6000000000000000000000000000000000000000000
0000000070777070707770707077707570777070000000000000000007aaa70077aaaa77607000606a7aaa600000000000000000000000000000000000000000
000000000700075007000705070007000700075000000000000000007aaaaa707aaaaaa767aaaa6067aaaa600000000000000000000000000000000000000000
000000000777770077777700077777000777770000000000000000007aaaaa7077aaaa776aaaaa606aaaaa600000000000000000000000000000000000000000
00000000070007000700070007000700070007000000000000000000077777000777777006666600066666000000000000000000000000000000000000000000
00000000007777000077770000777700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700777777007777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770770777707707770077007770770770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700770077007700770077007700770070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777077077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777777707707777077077777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070770700707707007077070070770700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777777777776000777777777777600077760000077760000000000000000000000000000000000000000000000000000000000000000000000000
000000000007888888888760007bbbbbbbbbb760007cc760007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000007888888888760007bbbbbbbbbb760007ccc7607ccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000007888888888760007bbbbbbbbbb760007cccc77cccc760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777788877776000777bbbbbb77760007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888766660000077bbbb776660007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb766000007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb760000007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb760000007cc7cccc7cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb760000007cc77cc77cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000077bbbb776660007cc707767cc760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000788876000000777bbbbbb77760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000007bbbbbbbbbb760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000007bbbbbbbbbb760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000007bbbbbbbbbb760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000777776000000777777777777600077770000777760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000877880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008880000878880000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000087888000888880008788800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000878888800888880087888880088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888800888880088888880877888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888800888880088888880888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888000088800008888800088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000c77cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ccc0000c7ccc0000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c7ccc000ccccc000c7ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c7ccccc00ccccc00c7ccccc00cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccc00ccccc00ccccccc0c77ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccc00ccccc00ccccccc0cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ccccc0000ccc0000ccccc000cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070707080808080807070707070707070707070808080808070707070707070707070707070707070707070707070707070707080808080808070707070
70707070707070808080707070707070707070707070808080808070707070707070707070808080808070707070707070707070707080808080707070707070
70808080808080808080808080808070708080808080808080808080808080707080808080808080708080808080807070808080808080808080808080808070
70808080808080808080708080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080708080808080807070808080808080808080808080808070
70808080808080808080708080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080708080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080708080808080807070808080807080808080708080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808070808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808070707070708080808080807070808080707080808080707080808070
70808080808080808080808070707070708080808080808080808080808080707080808080808080808070707070707070808080808080707080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080707080808080808070
70707070707080808080808080808080808080808080707070708080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808080808080808080707070708080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808080808080808080707070708080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080707080808080707080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080707080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080708080808080807080808070
70707070708080808080808080808070708080808080808080808080808080707080808070808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808070808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808070808080808080808080807070808080808080808080808080808070
70707070707080808080807070707070707070707070808080808070707070707070707070708080808080707070707070707070707080808080807070707070
70707070707080808080807070707070707070707070808080808070707070707070707070708080808080707070707070707070707080808080807070707070
70707070707080808080807070707070707070707070808080808070707070707070707070708080808080707070707070707070707080808080807070707070
70707070707080808080807070707070707070707070808080808070707070707070707070708080808080707070707070707070707080808080807070707070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080807080808080808080808070708080707080808080808070708080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808070708080808070708080807070808080808080808080808080808070
70707070707080808080808080808070708080708080808080808080708080707080808080808080808080808080807070808080707080808080807070808070
70808080807080808080708080808070708080808080808080808080808080707080808070808080808080708080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080708070808080708070808070
70808080808070707070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080708070808070808070
70808080808070707070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080807080808070808070
70808080808070707070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080808080808070808070
70808080807080808080708080808080808080807070708080707070808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080808080808070808070
70808080808080808080808080808070708080808080708080708080808080707080808070808080808080708080807070808080707080808080707080808070
70808080808080808070808080808070708080807070708080707070808080707080808070808080808080708080807070808080708080808080808070808070
70808080808080808080808080808070708080808080708080708080808080707080808070708080808070708080807070808080708080808080807080808070
70808080808080808070808080808070708080708080808080808080708080707080807080808080808080807080807070808080708080808080808070808070
70808080808080808080808080808070708080808080708080708080808080707080808080808080808080808080807070808080708080808080807080808070
70808080808080808070808080808070708080708080808080808080708080707080708080808080808080808070807070808080808080808080808080808070
70808080808080808080808080808070708080808080707070708080808080707080808080808080808080808080807070808080708080808080807080808070
70808080808080808070808080808070707070708080808080808080707070707070808080808080808080808080707070808080808080808080808080808070
70707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
70707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
__gff__
0000000000000008000000000000000000000000000000040400000000000000000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707
0708080808080808080808070808080707080808080808070808080808080807070808080707070707070707080808070708080808080808080808080808080707080808080807080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0708080808080808080808070808080707080808080808070808080808080807070808080807070707070708080808070708080808080808080808080808080707080808080807080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0708080808080808080808070808080707080808080808070808080808080807070808080807070707070708080808070708080808080808080808080808080707080808080807080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0707070707070808080808070808080707080807070707070707070808070707070808080807070707070708080808070708080807080808080808070808080707080808080807080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0708080808080808080808070808080707080808080808070808080808070807070808080808080808080808080808070708080808080808080808080808080707080808080807080808080808080807070808080808080808080808080808070708080808080807070808080808080707080808080808080808080808080807
0708080808080808070707070808080707080808080808070808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080707080808080808070708080808080807070808080808080707080808080808080808080808080807
0708080808080808080808080808080808080808080808070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070707070808080808080808080808080807070808080808080808080808080808070808080808080807
0708080808080808080808080808080808080808080808070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080807070707070708080808080808080808070707070707080808080808080808080808070707070707070707
0707070707070708080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707070707070707080808080808080808080807070808080808080808080808080808080808080808080807
0708080808070708080808080808080707080808080808080808080808080808080808080808080808080808080808080808080807080808080808070808080808080808080808080808080808080808080808080808080808080808080808080808080808080807070808080808080808080808080808080808080808080807
0708080808070708080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080808080808080808080808080808080808070708080808080807070808080808080707080808080808080808080808080807
0708080808070708080707080807070707070707070708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080708080808070707080808080708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808070707070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080708080808070707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808070707070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0707070707070808080707070707070707070707070707080808070707070707070707070708080808080807070707070707070707070708080807070707070707070707070707080807070707070707070707070707080808080807070707070707070707070708080807070707070707070707070707080808070707070707
0707070707070808080707070707070707070707070707080808070707070707070707070708080808080807070707070707070707070708080807070707070707070707070707080807070707070707070707070707080808080807070707070707070707070708080807070707070707070707070707080808070707070707
0708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808070708080808080807070808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808070708080808080807070808070708080808080708080708080808080707080808080808080808080808080807
0708080808080808080808080707070707080808080808080807070707070707070808080808080808080808080808070708080808080808080807070808080707080808080808080808080808080807070808080808080808080808080808070708080808070808080807080808080707080808080707070707070808080807
0708080808080808080808080808080707080808080808080808080808080807080808080808080808080808080808080808080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080807080808080808070808080707080808080808070708080808080807
0708080808080808080808080808080808080808080808080808080808080808080808080808070707070808080808080808080808080808080808080808080808080808080807070707080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070708080808080807
0707070707070808080808080808080808080808080808080808080808080808080808080707070707070707080808080808080808080808080808080808080808080808080807070707080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070708080808080807
0708080807070808080808080808080808080808080808080808080808080808080808080808070707070808080808080808080808080808080808080808080808080808080807070707080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070708080808080807
0708080807070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080807080808080808070808080707080808080808070708080808080807
0708080807070808080808080808080707080808070708080808080808080808080808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808070708080808080807070808070708080808070808080807080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808070708080808080807070808070708080808080708080708080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0707070707070808080808070707070707070707070708080808080707070707070707070707070707070707070707070707070707070808080808080707070707070707070707080808070707070707070707070707080808080807070707070707070707080808080807070707070707070707070708080808070707070707
