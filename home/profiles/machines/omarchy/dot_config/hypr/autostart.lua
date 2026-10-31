-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- omadeck: el icono de la tecla Swap indica en qué monitor está el foco.
local function sync_swap_icon()
  hl.exec_cmd("/home/juan/.local/bin/omadeck-update-swap-icon")
end

hl.on("monitor.focused", sync_swap_icon)
hl.on("hyprland.start", sync_swap_icon)
