import datetime
import json
import subprocess
from ignis.widgets import Widget
from ignis.utils import Utils
from ignis.app import IgnisApp
from ignis.services.audio import AudioService
from ignis.services.system_tray import SystemTrayService
from ignis.services.hyprland import HyprlandService
from ignis.services.mpris import MprisService, MprisPlayer

from custom_tray_module import (
    CustomTrayManager,
    CustomTrayItem,
    create_tray_widget
)

# Initializing services
app = IgnisApp.get_default()
audio = AudioService.get_default()
system_tray = SystemTrayService.get_default()
hyprland = HyprlandService.get_default()
mpris = MprisService.get_default()

app.apply_css(f"{Utils.get_current_dir()}/style.scss")

def get_hyprland_clients():
    """Get list of clients from Hyprland using hyprctl."""
    try:
        result = subprocess.run(
            ['hyprctl', 'clients', '-j'],
            capture_output=True,
            text=True
        )
        return json.loads(result.stdout)
    except (subprocess.SubprocessError, json.JSONDecodeError) as e:
        print(f"Error getting Hyprland clients: {e}")
        return []

def find_window_workspace(window_class: str) -> int:
    """Find the workspace ID containing a window with the specified class."""
    print(f"Looking for window with class: {window_class}")

    clients = get_hyprland_clients()
    for client in clients:
        client_class = client.get("class", "")
        print(f"Checking client: {client_class}")
        if client_class.lower() == window_class.lower():
            workspace_id = client.get("workspace", {}).get("id", None)
            if workspace_id is None:
                workspace_id = client.get("workspace")
            print(f"Found window in workspace: {workspace_id}")
            return workspace_id
    print(f"No window found for class: {window_class}")
    return None

def focus_media_player(player: MprisPlayer) -> None:
    """Focus the workspace containing the media player."""
    player_classes = {
        "spotify": "Spotify",
        "firefox": "firefox",
        "chromium": "Chromium",
        "chrome": "Google-chrome",
        "brave": "Brave-browser",
        "vlc": "vlc",
        "rhythmbox": "Rhythmbox",
        "clementine": "Clementine",
        "audacious": "Audacious",
        "zen-twilight": "zen-twilight",  # doesn't work for some reason, that's why the one below exists
        "mozilla": "zen-twilight",  # temp fix
    }

    player_name = player.identity.lower().split()[0]
    print(f"Player identity: {player.identity}")
    print(f"Looking for player: {player_name}")

    window_class = player_classes.get(player_name, player_name)
    print(f"Using window class: {window_class}")

    workspace_id = find_window_workspace(window_class)

    if workspace_id is None and player_name == "spotify":
        workspace_id = find_window_workspace("spotify")

    if workspace_id is not None:
        print(f"Switching to workspace: {workspace_id}")
        try:
            subprocess.run(['hyprctl', 'dispatch', 'workspace', str(workspace_id)])
        except subprocess.SubprocessError as e:
            print(f"Error switching workspace: {e}")
    else:
        print(f"Could not find workspace for {player_name}")

# -------------- Custom tray manager ------------- #
TRAY_CONFIG = {
    "blacklist": [
        "spotify",
        "iwgtk"
    ],
    "icon_overrides": {
        "nm-applet": "/home/arx/.config/ignis/icons/wifi.png",
        "qbittorent": "/home/arx/.config/ignis/icons/bean.png",
        "qbit": "/home/arx/.config/ignis/icons/bean.png",
        "steam": "/home/arx/.config/ignis/icons/gamepad.png",
        "vesktop": "/home/arx/.config/ignis/icons/messages.png",
        "vencord": "/home/arx/.config/ignis/icons/messages.png"
    }
}

custom_tray_manager = CustomTrayManager(
    global_icon_overrides=TRAY_CONFIG.get("icon_overrides", {})
)

# Tray items
def launch_clipboard():
    subprocess.run(['foot', '-e', 'bash', '-c', 'cliphist list | fzf --no-sort | cliphist decode | wl-copy'])

clipboard_item = CustomTrayItem(
    id="custom-clipboard",
    icon_path="/home/arx/.config/ignis/icons/clipboard.png",
    tooltip="fzf clipboard",
    on_left_click=launch_clipboard,
    text=None
)
custom_tray_manager.add_item(clipboard_item)

def create_custom_tray_item(item, custom_tray_manager):
    from custom_tray_module import create_tray_item

    if any(bl in item.id.lower() for bl in TRAY_CONFIG.get("blacklist", [])):
        return None

    return create_tray_item(item, custom_tray_manager)

def create_tray_widget(system_tray, custom_tray_manager):
    box = Widget.Box(
        setup=lambda self: system_tray.connect(
            "added",
            lambda x, item: self.append(create_custom_tray_item(item, custom_tray_manager))
            if create_custom_tray_item(item, custom_tray_manager) else None
        ),
        spacing=10,
    )

    from custom_tray_module import FakeSystemTrayItem
    for custom_item in custom_tray_manager.get_all_items():
        fake_item = FakeSystemTrayItem(custom_item)
        box.append(create_custom_tray_item(fake_item, custom_tray_manager))

    return box

class WorkspaceState:
    def __init__(self):
        self.current_workspace = 1
        self.direction = "right"  # Default direction

    def update_direction(self, new_workspace):
        if new_workspace > self.current_workspace:
            self.direction = "right"
        elif new_workspace < self.current_workspace:
            self.direction = "left"
        self.current_workspace = new_workspace
        return self.direction

workspace_state = WorkspaceState()

def workspace_button(workspace_id: int) -> Widget.Button:
    current_workspaces = {w["id"]: w for w in hyprland.workspaces}
    workspace = current_workspaces.get(workspace_id)

    has_spotify = any(
        client.get("class", "").lower() == "spotify" and
        (client.get("workspace", {}).get("id", client.get("workspace")) == workspace_id)
        for client in get_hyprland_clients()
    )

    if workspace_id == hyprland.active_workspace["id"]:
        workspace_state.update_direction(workspace_id)
        icon = "ᗧ" if workspace_state.direction == "right" else "ᗤ"
        css_class = "active"
    elif workspace and any(
        client.get("workspace", {}).get("id", client.get("workspace")) == workspace_id
        for client in get_hyprland_clients()
    ):
        icon = "ᗣ"
        css_class = "has-windows"
        if has_spotify:
            css_class = "has-spotify"
    else:
        icon = "•"
        css_class = "inactive"

    def on_workspace_click(widget, id=workspace_id):
        hyprland.switch_to_workspace(id)

    widget = Widget.Button(
        css_classes=["workspace", css_class],
        on_click=on_workspace_click,
        child=Widget.Label(
            label=icon,
            css_classes=["workspace-icon"],
        ),
    )
    return widget

def scroll_workspaces(direction: str) -> None:
    current = hyprland.active_workspace["id"]
    if direction == "up":
        target = current - 1
        workspace_state.update_direction(target)
        hyprland.switch_to_workspace(target)
    else:
        target = current + 1
        if target == 11:
            return
        workspace_state.update_direction(target)
        hyprland.switch_to_workspace(target)

def workspaces() -> Widget.EventBox:
    return Widget.EventBox(
        on_scroll_up=lambda x: scroll_workspaces("up"),
        on_scroll_down=lambda x: scroll_workspaces("down"),
        css_classes=["workspaces"],
        spacing=5,
        child=hyprland.bind(
            "workspaces",
            transform=lambda value: [workspace_button(i) for i in range(1, 11)],
        ),
    )

def mpris_title(player: MprisPlayer) -> Widget.Box:
    container = Widget.Box(
        spacing=10,
        setup=lambda self: player.connect(
            "closed",
            lambda x: self.unparent(),
        ),
    )
    def on_click(widget):
        print("Media player clicked!")
        focus_media_player(player)
    button = Widget.Button(
        on_click=on_click,
        css_classes=["media-player-button"],
        child=Widget.Box(
            spacing=10,
            child=[
                Widget.Icon(image="audio-x-generic-symbolic"),
                Widget.Label(
                    ellipsize="end",
                    max_width_chars=100,
                    label=player.bind("title"),
                ),
            ],
        ),
    )
    container.append(button)
    return container

def media() -> Widget.Box:
    MPRIS_BLACKLIST = ["zen-twilight", "mozilla"]

    media_box = Widget.Box(
        spacing=10,
        child=[
            Widget.Label(
                label="No media players",
                visible=mpris.bind("players", lambda value: len(value) == 0),
            )
        ]
    )

    def on_player_added(service, player):
        player_name = player.identity.lower().split()[0]
        if player_name not in MPRIS_BLACKLIST:
            player_widget = mpris_title(player)
            media_box.append(player_widget)

            def on_player_closed(widget):
                media_box.remove(widget)
                player.disconnect_by_func(on_player_closed)

            player.connect("closed", on_player_closed)

    connection_id = mpris.connect("player-added", on_player_added)

    def cleanup():
        while media_box.get_first_child() != media_box.get_children()[0]:
            media_box.remove(media_box.get_first_child())

        mpris.disconnect(connection_id)

    media_box.cleanup = cleanup

    return media_box

def client_title() -> Widget.Label:
    return Widget.Label(
        css_classes=["hyprland-window-title"],
        ellipsize="end",
        max_width_chars=40,
        label=hyprland.bind(
            "active_window",
            transform=lambda value: value.get("title", ""),
        ),
    )

class ClockState:
    def __init__(self):
        self.use_24h = True

    def toggle_format(self):
        self.use_24h = not self.use_24h
        return self.use_24h

    def get_current_format(self):
        return "%H:%M" if self.use_24h else "%I:%M %p"

clock_state = ClockState()

def clock() -> Widget.Button:
    def update_time(self):
        current_format = clock_state.get_current_format()
        return datetime.datetime.now().strftime(current_format)

    def on_click(widget):
        clock_state.toggle_format()
        time_poll.update()

    time_poll = Utils.Poll(1, update_time)

    return Widget.Button(
        css_classes=["clock"],
        on_click=on_click,
        child=Widget.Label(
            label=time_poll.bind("output")
        )
    )

def date() -> Widget.Button:
    def launch_calendar(widget):
        try:
            subprocess.Popen(['gnome-calendar'])
        except subprocess.SubprocessError as e:
            print(f"Error launching gnome-calendar: {e}")

    return Widget.Button(
        css_classes=["date"],
        on_click=launch_calendar,
        child=Widget.Label(
            label=Utils.Poll(
                60, lambda self: datetime.datetime.now().strftime("%Y-%m-%d")
            ).bind("output"),
        )
    )

def speaker_volume() -> Widget.Box:
    return Widget.Box(
        css_classes=["volume-display"],
        child=[
            Widget.Icon(
                image=audio.speaker.bind("icon_name"),
                style="margin-right: 5px;"
            ),
            Widget.Label(
                label=audio.speaker.bind("volume", transform=lambda value: str(value))
            ),
        ]
    )

def speaker_slider() -> Widget.Scale:
    return Widget.Scale(
        min=0,
        max=100,
        step=1,
        value=audio.speaker.bind("volume"),
        on_change=lambda x: audio.speaker.set_volume(x.value),
        css_classes=["volume-slider"],
    )

def left() -> Widget.Box:
    return Widget.Box(child=[workspaces(), client_title()], spacing=10)

def center() -> Widget.Box:
    return Widget.Box(
        child=[
            media(),
        ],
        spacing=10,
    )

def right() -> Widget.Box:
    return Widget.Box(
        child=[create_tray_widget(system_tray, custom_tray_manager),
               speaker_volume(),
               date(),
               clock()],
        spacing=10,
    )

def bar(monitor_id: int = 0) -> Widget.Window:
    return Widget.Window(
        namespace=f"ignis_bar_{monitor_id}",
        monitor=monitor_id,
        anchor=["left", "top", "right"],
        exclusivity="exclusive",
        child=Widget.CenterBox(
            css_classes=["bar"],
            start_widget=left(),
            center_widget=center(),
            end_widget=right(),
        ),
    )

# Create bar for each monitor
for i in range(Utils.get_n_monitors()):
    bar(i)
