-- Add extra spacing after file icon for Iosevka support
function Folder:icon(file)
	local icon = file:icon()
	return icon and ui.Span(" " .. icon.text .. "  "):style(icon.style) or ui.Span("")
end
