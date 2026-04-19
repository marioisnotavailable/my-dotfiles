Name = "wallpapers"
NamePretty = "Wallpapers"
HideFromProviderlist = true
Cache = false

function SetWallpaper(value)
	local home = os.getenv("HOME") or ""
	local script_path = home .. "/.config/niri/set-wallpaper.sh"
	os.execute(script_path .. " '" .. value .. "' &")
end

function GetEntries()
	local entries = {}
	local home = os.getenv("HOME") or ""
	local wallpapers_dir = home .. "/.local/share/dotfiles/current/theme/backgrounds"

	local handle = io.popen(
		"find '"
			.. wallpapers_dir
			.. "' -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \\) | sort"
	)

	if handle then
		for line in handle:lines() do
			local filename = line:match("([^/]+)$")

			if filename then
				table.insert(entries, {
					Text = filename:gsub("%.[^.]+$", ""),
					Value = line,
					Preview = line,
					PreviewType = "file",
					Actions = {
						apply = "lua:SetWallpaper",
					},
				})
			end
		end
		handle:close()
	end

	return entries
end
