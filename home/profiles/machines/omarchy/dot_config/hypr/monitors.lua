-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25
local omarchy_hdmi_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- DP-1 (Lenovo P32p-20) a la izquierda.
-- 3840x2160 @ 1.25 -> 3072x1728 logicos, posicion 0x0.
hl.monitor({ output = "DP-1", mode = "preferred", position = "0x0", scale = omarchy_monitor_scale })

-- HDMI-A-1 (Dell SE2419HX) vertical, base a la derecha -> transform 3 (270°), a la derecha del DP.
-- Comienza en el ancho logico del DP (3072); rotado y a escala 1 ocupa 1080x1920 logicos.
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "3072x0", scale = omarchy_hdmi_scale, transform = 3 })
