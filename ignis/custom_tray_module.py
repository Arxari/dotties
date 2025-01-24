import subprocess
from dataclasses import dataclass
from typing import Optional, Callable, Dict
from ignis.widgets import Widget
from ignis.services.system_tray import SystemTrayItem

@dataclass
class CustomTrayItem:
    """
    Attributes:
        id (str): Unique identifier for the tray item
        icon_path (Optional[str]): Path to the icon image, can be None
        tooltip (str): Tooltip text for the tray item
        on_left_click (Optional[Callable]): Function to call on left click
        on_right_click (Optional[Callable]): Function to call on right click
        text (Optional[str]): Text to display if no icon is provided
    """
    id: str
    icon_path: Optional[str]
    tooltip: str
    on_left_click: Optional[Callable] = None
    on_right_click: Optional[Callable] = None
    text: Optional[str] = None

class CustomTrayManager:
    def __init__(self, global_icon_overrides: Optional[Dict[str, str]] = None):
        """
        Initialize the custom tray manager.

        Args:
            global_icon_overrides (Optional[Dict[str, str]]): A dictionary of global icon overrides
            where keys are app ids and values are icon paths.
        """
        self._custom_items = {}
        self._global_icon_overrides = global_icon_overrides or {}

    def add_item(self, item: CustomTrayItem):
        """
        Args:
            item (CustomTrayItem): The custom tray item to add
        """
        self._custom_items[item.id] = item

    def get_item(self, id: str) -> Optional[CustomTrayItem]:
        """
        Retrieve a custom tray item by its ID.

        Args:
            id (str): The ID of the tray item to retrieve

        Returns:
            Optional[CustomTrayItem]: The tray item if found, None otherwise
        """
        return self._custom_items.get(id)

    def get_all_items(self):
        """
        Returns:
            List of CustomTrayItem: All registered custom tray items
        """
        return list(self._custom_items.values())

    def get_icon_override(self, item_id: str) -> Optional[str]:
        """
        Get the icon override for a given item ID.

        Args:
            item_id (str): The ID of the item

        Returns:
            Optional[str]: The override icon path if it exists
        """
        return self._global_icon_overrides.get(item_id)

class FakeSystemTrayItem:
    """
    A wrapper class to make CustomTrayItem compatible with SystemTrayItem interface.
    """
    def __init__(self, custom_item: CustomTrayItem):
        """
        Args:
            custom_item (CustomTrayItem): The custom tray item to wrap
        """
        self.id = custom_item.id
        self.icon = custom_item.icon_path
        self.tooltip = custom_item.tooltip
        self.menu = None
        self._custom_item = custom_item

    def bind(self, prop):
        """
        Args:
            prop (str): The property to bind

        Returns:
            The value of the requested property
        """
        if prop == "icon":
            return self.icon
        elif prop == "tooltip":
            return self.tooltip
        return None

    def connect(self, *args):
        """
        Placeholder method to match SystemTrayItem interface.
        """
        pass

def create_tray_item(item: SystemTrayItem, custom_tray_manager: CustomTrayManager) -> Optional[Widget.Button]:
    """
    Args:
        item (SystemTrayItem): The system tray item
        custom_tray_manager (CustomTrayManager): The custom tray manager

    Returns:
        Optional[Widget.Button]: A widget representing the tray item, or None
    """
    custom_item = custom_tray_manager.get_item(item.id)
    if custom_item:
        if not custom_item.icon_path:
            return Widget.Button(
                child=Widget.Box(
                    child=[
                        Widget.Label(
                            label=custom_item.text or custom_item.id,
                            css_classes=["custom-tray-text"]
                        )
                    ]
                ),
                tooltip_text=custom_item.tooltip,
                on_click=lambda x: custom_item.on_left_click() if custom_item.on_left_click else None,
                on_right_click=lambda x: custom_item.on_right_click() if custom_item.on_right_click else None,
                css_classes=["tray-item", "custom-tray-item"],
            )

        return Widget.Button(
            child=Widget.Box(
                child=[
                    Widget.Icon(image=custom_item.icon_path, pixel_size=24)
                ]
            ),
            tooltip_text=custom_item.tooltip,
            on_click=lambda x: custom_item.on_left_click() if custom_item.on_left_click else None,
            on_right_click=lambda x: custom_item.on_right_click() if custom_item.on_right_click else None,
            css_classes=["tray-item", "custom-tray-item"],
        )

    # Blacklist
    if "spotify" in item.id.lower() or "iwgtk" in item.id.lower():
        return None

    menu = item.menu.copy() if item.menu else None

    # Default icon overrides
    icon_override = custom_tray_manager.get_icon_override(item.id.lower())

    if icon_override:
        icon_widget = Widget.Icon(image=icon_override, pixel_size=24)
    elif "nm-applet" in item.id.lower():
        icon_widget = Widget.Icon(image="/home/arx/.config/ignis/icons/wifi-dark.svg", pixel_size=24)
    elif "qbittorent" in item.id.lower() or "qbit" in item.id.lower():
        icon_widget = Widget.Icon(image="/home/arx/.config/ignis/icons/bean.png", pixel_size=24)
    elif "steam" in item.id.lower() or "steam" in item.id.lower():
        icon_widget = Widget.Icon(image="/home/arx/.config/ignis/icons/gamepad.png", pixel_size=24)
    elif "vesktop" in item.id.lower() or "vencord" in item.id.lower():
        icon_widget = Widget.Icon(image="/home/arx/.config/ignis/icons/messages.png", pixel_size=24)
    else:
        icon_widget = Widget.Icon(image=item.bind("icon"), pixel_size=24)

    return Widget.Button(
        child=Widget.Box(
            child=[
                icon_widget,
                menu,
            ]
        ),
        setup=lambda self: item.connect("removed", lambda x: self.unparent()),
        tooltip_text=item.bind("tooltip"),
        on_click=lambda x: menu.popup() if menu else None,
        on_right_click=lambda x: menu.popup() if menu else None,
        css_classes=["tray-item"],
    )

def create_tray_widget(system_tray, custom_tray_manager: CustomTrayManager):
    """
    Args:
        system_tray: The system tray service
        custom_tray_manager (CustomTrayManager): The custom tray manager

    Returns:
        Widget.Box: A box containing tray items
    """
    box = Widget.Box(
        setup=lambda self: system_tray.connect(
            "added",
            lambda x, item: self.append(create_tray_item(item, custom_tray_manager))
            if create_tray_item(item, custom_tray_manager) else None
        ),
        spacing=10,
    )

    for custom_item in custom_tray_manager.get_all_items():
        fake_item = FakeSystemTrayItem(custom_item)
        box.append(create_tray_item(fake_item, custom_tray_manager))

    return box

def example_usage():
    """
    Example function showing how to use the CustomTrayManager.
    """
    icon_overrides = {
        "nm-applet": "/path/to/custom/wifi-icon.png"
    }
    custom_tray_manager = CustomTrayManager(global_icon_overrides=icon_overrides)

    def launch_clipboard():
        subprocess.run(['foot', '-e', 'bash', '-c', 'cliphist list | fzf --no-sort | cliphist decode | wl-copy'])

    clipboard_item = CustomTrayItem(
        id="custom-clipboard",
        icon_path="/home/arx/.config/ignis/icons/clipboard.png",
        tooltip="fzf clipboard",
        on_left_click=launch_clipboard
    )

    custom_tray_manager.add_item(clipboard_item)

    # When setting up your bar/widget, you would use:
    # tray_widget = create_tray_widget(system_tray, custom_tray_manager)
