function timer_checkpoint(label, type, reset)
    G.PREV_GARB = G.PREV_GARB or 0
    if not G.F_ENABLE_PERF_OVERLAY then return end
    G.check = G.check or {
      draw = {
        checkpoint_list = {},
        checkpoints = 0,
        last_time = 0,
      },
      update = {
        checkpoint_list = {},
        checkpoints = 0,
        last_time = 0,
      }
    }
    local cp = G.check[type]
    if reset then 
      cp.last_time = love.timer.getTime()
      cp.checkpoints = 0
      return
    end
  end
  
  function remove_nils(t)
    local ans = {}
    for _,v in pairs(t) do
      ans[ #ans+1 ] = v
    end
    return ans
  end
  
  function EMPTY(t)
    if not t then return {} end 
    for k, v in pairs(t) do
      t[k] = nil
    end
    return t
  end
  
  function reset_drawhash()
    G.DRAW_HASH = EMPTY(G.DRAW_HASH)
  end
  
  function add_to_drawhash(obj)
    if obj then 
      G.DRAW_HASH[#G.DRAW_HASH+1] = obj
    end
  end
  
  function nuGC(time_budget, memory_ceiling, disable_otherwise)
      time_budget = time_budget or 3e-4
      memory_ceiling = memory_ceiling or 300
      local max_steps = 1000
      local steps = 0
      local start_time = love.timer.getTime()
      while
          love.timer.getTime() - start_time < time_budget and
          steps < max_steps
      do
          collectgarbage("step", 1)
          steps = steps + 1
      end
      --safety net
      if collectgarbage("count") / 1024 > memory_ceiling then
          collectgarbage("collect")
      end
      --don't collect gc outside this margin
      if disable_otherwise then
          collectgarbage("stop")
      end
  end
  
  function update_canvas_juice(dt)
    G.JIGGLE_VIBRATION = G.ROOM.jiggle or 0
    if not G.SETTINGS.screenshake or (type(G.SETTINGS.screenshake) ~= 'number') then
        G.SETTINGS.screenshake = G.SETTINGS.reduced_motion and 0 or 50
    end
    local shake_amt = (G.SETTINGS.reduced_motion and 0 or 1)*math.max(0,G.SETTINGS.screenshake-30)/100
    shake_amt = (G.SETTINGS.reduced_motion and 0 or 1)*G.SETTINGS.screenshake/100*3
    if shake_amt < 0.05 then shake_amt = 0 end
  
    G.ROOM.jiggle = (G.ROOM.jiggle or 0)*(1-5*dt)*(shake_amt > 0.05 and 1 or 0)
    G.ROOM.T.r = (0.001*math.sin(0.3*G.TIMERS.REAL)+ 0.002*(G.ROOM.jiggle)*math.sin(39.913*G.TIMERS.REAL))*shake_amt
    
  end
  
  