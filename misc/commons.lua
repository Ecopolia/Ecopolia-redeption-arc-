function hex(hex)
    if #hex <= 6 then hex = hex.."FF" end
    local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
    local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
    return color
  end

function stripTags(text)
  return text:gsub("%[.-%]", "")
end

function transitionOut()
  G.TRANSITION = 1
  Timer.tween(2, G, {TRANSITION = 0}, 'in-out-cubic', function()
      G.TRANSITION = 0
  end)
end

function transitionIn()
  G.TRANSITION = 0
  Timer.tween(2, G, {TRANSITION = 1}, 'in-out-cubic', function()
      G.TRANSITION = 1
  end)
end