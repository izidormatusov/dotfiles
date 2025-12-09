local wezterm = require 'wezterm'
local action = wezterm.action

local is_mac <const> = wezterm.target_triple:find("darwin") ~= nil
local is_linux <const> = wezterm.target_triple:find("linux") ~= nil

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.exit_behavior = 'CloseOnCleanExit'

-- Keep it quiet
config.audible_bell = 'Disabled'
config.use_resize_increments = false
-- config.visual_bell
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 50,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 50,
}
config.colors = {
  visual_bell = '#202020',
}

-- config.window_decorations = "NONE | RESIZE | TITLE"
config.window_decorations = "NONE | RESIZE | MACOS_FORCE_DISABLE_SHADOW"

-- config.font = wezterm.font 'Hack Nerd Font Mono'
config.font = wezterm.font 'JetBrains Mono'
-- config.color_scheme = 'Batman'
--
-- config.font = wezterm.font 'Fira Code'

config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

if is_mac then
  -- Mac needs a bigger size
  config.font_size = 13.5
else
  config.font_size = 10
end

if is_mac then
  config.default_cwd = wezterm.home_dir .. "/Downloads"
  -- This requires a login shell (-l) to load various system wide settings
  config.default_prog = { '/opt/homebrew/bin/bash', '-l' }
end

local scheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
scheme.background = "#000000"
-- This scheme has troubles with showing images from timg (CrontoSign)
config.color_schemes = {
   ["OLEDppuccin"] = scheme,
}
config.color_scheme = "OLEDppuccin"

config.color_scheme = '3024 (dark) (terminal.sexy)'

config.window_padding = {
  left = 0,
  right= 0,
  top = 0,
  bottom= 0,
}


-- config.colors = {
--   foreground = 'hsl:235 100 50',
-- }
--

-- Random theme
-- local schemes = {}
-- for name, scheme in pairs(wezterm.get_builtin_color_schemes()) do
--   table.insert(schemes, name)
-- end
-- 
-- wezterm.on('window-config-reloaded', function(window, pane)
--   -- If there are no overrides, this is our first time seeing
--   -- this window, so we can pick a random scheme.
--   if not window:get_config_overrides() then
--     -- Pick a random scheme name
--     local scheme = schemes[math.random(#schemes)]
--     window:set_config_overrides {
--       color_scheme = scheme,
--     }
--   end
-- end)


-- Disable liglatures
-- Or maybe not?
-- config.harfbuzz_features = {"calt=0", "clig=0", "liga=0"}

-- TODO: separate MacOS and Linux shortcuts
-- CMD/Super + h hides the window
config.keys = {
  {
    mods = 'CMD', key = 'a',
    action = wezterm.action.SendKey { mods = 'ALT', key = 'a' },
  },
  {
    mods = 'CMD', key = 'h',
    action = wezterm.action.SendKey { mods = 'ALT', key = 'h' },
  },
  {
    mods = 'CMD', key = 'l',
    action = wezterm.action.SendKey { mods = 'ALT', key = 'l' },
  },
  {
    mods = 'CMD', key = 'j',
    action = wezterm.action.SendKey { mods = 'ALT', key = 'j' },
  },
  {
    mods = 'CMD', key = 'k',
    action = wezterm.action.SendKey { mods = 'ALT', key = 'k' },
  },
  {
    mods = 'CMD|SHIFT', key = 'd',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = '"' },
    }
  },

  {
    mods = 'CMD', key = 'd',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = '%' },
    }
  },
  {
    mods = 'CMD|SHIFT', key = '[',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = 'p' },
    }
  },
  {
    mods = 'CMD|SHIFT', key = ']',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = 'n' },
    }
  },
  {
    mods = 'CMD|SHIFT', key = 'Enter',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = 'z' },
    }
  },
  {
    key = 'F11',
    action = action.ToggleFullScreen,
  },


  -- Linux
  {
    mods = 'ALT|SHIFT', key = 'd',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = '"' },
    }
  },
  {
    mods = 'ALT', key = 'd',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = '%' },
    }
  },
  {
    mods = 'ALT|SHIFT', key = 'Enter',
    action = wezterm.action.Multiple {
      wezterm.action.SendKey { mods = 'ALT', key = 'a' },
      wezterm.action.SendKey { key = 'z' },
    }
  },

}

config.notification_handling = "AlwaysShow"

return config
