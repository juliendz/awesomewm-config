-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
--Vicious library
local vicious = require("vicious")
-- Bashets library
-- local bashets = require("bashets") 
-- bashets.set_script_path("/dev/shm/bashets/")
-- bashets.set_script_path("/home/julien/.config/awesome/bashets/")
-- bashets.set_temporary_path("/dev/shm/tmp/")
-- Xdb menu
xdg_menu = require("archmenu")

--For debugging
--local inspect = require('inspect')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
editor = "gvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1:web", "2:dev", "3:console", "4:fm", "5:music", "6:misc" }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Applications", xdgmenu },
                                    { "Firefox", "firefox" },
                                    { "Eclipse", "eclipse" },
                                    { "Terminator", terminal },
                                    { "Nemo", "nemo" },
                                    { "KSysGuard", "ksysguard" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
app_folders = { "/usr/share/applications/", "~/.local/share/applications/" }
-- }}}

-- {{{ Wibox
-- Create a textclock widget
clock_icon = wibox.widget.imagebox()
clock_icon:set_image(beautiful.clock)
mytextclock = awful.widget.textclock()



-- spacer
spacer = wibox.widget.textbox()
spacer:set_text("   ")

-- Create a wibox for each screen and add it
topwibox = {}
botwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
                                        
-- separator
separator_icon = wibox.widget.imagebox()
separator_icon:set_image(beautiful.separator_icon)
                                          
--wifi signal widget
--[==[
 wifi_signal_widget = wibox.widget.textbox("?%")
 wifi_signal_icon = wibox.widget.imagebox()
 wifi_signal_icon:set_image(beautiful.wireless_signal)
 function wifiInfo()
     local spacer = ""
     local wifiStrength = awful.util.pread("awk 'NR==3 {printf \"%.1f%%\\n\",($3/70)*100}' /proc/net/wireless")
     if wifiStrength == "" then
         wifi_signal_widget:set_text("n/a")
     else
         wifi_signal_widget:set_text(spacer .. wifiStrength)
     end
 end
 wifiInfo()
 wifi_timer = timer({timeout=20})
 wifi_timer:connect_signal("timeout",wifiInfo)
 wifi_timer:start()
--]==]
 
 -- Memory widget
memory_icon = wibox.widget.imagebox()
memory_icon:set_image(beautiful.memory_icon)
memwidget = wibox.widget.textbox()
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$2MB", 15)

-- CPU widget
cpuwidget = wibox.widget.textbox()
cpu_icon = wibox.widget.imagebox()
cpu_icon:set_image(beautiful.cpu_icon)
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%", 5)


--Data in/out widget
 bytes_in_widget = wibox.widget.textbox("?%")
 bytes_in_icon = wibox.widget.imagebox()
 bytes_in_icon:set_image(beautiful.bytes_in_icon)
 
 bytes_out_widget = wibox.widget.textbox("?%")
 bytes_out_icon = wibox.widget.imagebox()
 bytes_out_icon:set_image(beautiful.bytes_out_icon)
 
 function bytes_info()
     local spacer = " "
     local bytes_in = awful.util.pread("awk 'NR==5 {printf \"%.1f\\n\", ($2/1024)/1024}' /proc/net/dev")
     local bytes_out = awful.util.pread("awk 'NR==5 {printf \"%.1f\\n\", ($10/1024)/1024}' /proc/net/dev")
     bytes_in_widget:set_text(spacer .. bytes_in)
     bytes_out_widget:set_text(spacer .. bytes_out)
 end
 bytes_info()
 bytes_info_timer = timer({timeout=30})
 bytes_info_timer:connect_signal("timeout",bytes_info)
 bytes_info_timer:start()
 
 --CPU  temp widget
 cpu_temp_icon = wibox.widget.imagebox()
 cpu_temp_icon:set_image(beautiful.cpu_temp_icon)
 --cpu_num_widget = wibox.widget.textbox("CPU[1/2] ")
 cpu_1_widget = wibox.widget.textbox()
 cpu_2_widget = wibox.widget.textbox()
 
 function cpu_temp_info()
     local cpu1 = awful.util.pread("sensors | grep 'Core 0' | awk 'NR==1 {printf \"%.f\", $3}'")
     local cpu2 = awful.util.pread("sensors | grep 'Core 1' | awk 'NR==1 {printf \"%.f\", $3}'")
     cpu_1_widget:set_text(cpu1 .. "/")
     cpu_2_widget:set_text(cpu2)
 end
 cpu_temp_info()
 cpu_temp_info_timer = timer({timeout=10})
 cpu_temp_info_timer:connect_signal("timeout", cpu_temp_info)
 cpu_temp_info_timer:start()
 
--Internet check bashet
--[==[
net_check_icon = wibox.widget.imagebox()
net_check_icon:set_image(beautiful.net_icon)
net_icon = wibox.widget.imagebox()
net_icon:set_image(beautiful.check_icon)

function net_bashets_callback(retval)  
    --naughty.notify({text=inspect.inspect(retval)})
    if retval[1] == "0" then                                 
        net_icon:set_image(beautiful.check_icon)
    else
        net_icon:set_image(beautiful.cross_icon)
    end                                                   
end
--]==]
 
--bashets.register("net-check.sh", {widget = net_check_widget, callback = net_bashets_callback, format = "$1", update_time = "20", async = true, file_update_time = "20"}) 
--bashets.register("net-check.sh", {callback = net_bashets_callback, update_time = "21", async = true, file_update_time = "20"}) 
 
--Start all bashets
--bashets.start()
 

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    topwibox[s] = awful.wibox({ position = "top", screen = s, height = 25 })

    -- Widgets that are aligned to the left
    local top_left_layout = wibox.layout.fixed.horizontal()
    top_left_layout:add(mylauncher)
    top_left_layout:add(mypromptbox[s])
    top_left_layout:add(mytaglist[s])
    top_left_layout:add(spacer)
    
    -- Widgets that are aligned to the middle
    local top_mid_layout = wibox.layout.fixed.horizontal()
    top_mid_layout:add(mytasklist[s])
    
    -- Widgets that are aligned to the right
    local top_right_layout = wibox.layout.fixed.horizontal()
    top_right_layout:add(spacer)
    top_right_layout:add(cpu_icon)
    top_right_layout:add(cpuwidget)
    top_right_layout:add(separator_icon)
    top_right_layout:add(memory_icon)
    top_right_layout:add(memwidget)
    top_right_layout:add(separator_icon)
    top_right_layout:add(cpu_temp_icon)
    top_right_layout:add(cpu_1_widget)
    top_right_layout:add(cpu_2_widget)
    top_right_layout:add(separator_icon)
    top_right_layout:add(bytes_in_icon)
    top_right_layout:add(bytes_in_widget)
    top_right_layout:add(bytes_out_icon)
    top_right_layout:add(bytes_out_widget)
    top_right_layout:add(separator_icon)

    -- Systray
    if s == 1 then top_right_layout:add(wibox.widget.systray()) end
    -- Clock widget
    top_right_layout:add(mytextclock)
    -- Layout indicator box
    top_right_layout:add(mylayoutbox[s])
    
    -- Now bring it all together (with the tasklist in the middle)
    local top_layout = wibox.layout.align.horizontal()
    top_layout:set_left(top_left_layout)
    top_layout:set_middle(top_mid_layout)
    top_layout:set_right(top_right_layout)

    topwibox[s]:set_widget(top_layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Mod1"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end




clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))
    
-- 
root.keys(globalkeys)
-- }}}


-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 1 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][1], maximized_vertical = true } },
    { rule = { class = "Qbittorrent" },
      properties = { tag = tags[1][6] } },
    { rule = { class = "Dolphin" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Eclipse" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Kget" },
      properties = { tag = tags[1][6] } },
    { rule = { instance = "plugin-container" },
      properties = { floating = true, fullscreen = true } }, 
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
  
    --Make sure client windows are not maximized
    c.maximized_horizontal = false
    c.maximized_vertical   = false
    
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c, {size = 16}):set_widget(layout)
        
    end
end)


client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--set different layout for different tags
local screen = mouse.screen
local floating_layout_tags = {1, 4, 5, 6}
for flt=1, 4 do
    local tag = awful.tag.gettags(screen)[floating_layout_tags[flt]]
    awful.layout.set(layouts[12], tag)
end

--Auto start apps
-- awful.util.spawn_with_shell("firefox")
-- awful.util.spawn_with_shell("orage")
-- awful.util.spawn_with_shell(terminal)
-- awful.util.spawn_with_shell("nm-applet")
