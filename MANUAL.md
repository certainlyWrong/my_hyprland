## xdg-user-dirs

Serve para configurar os diretórios do usuário.

```bash
xdg-user-dirs-update
```

## nwg-look

Serve para configurar o tema GTK.

```bash
nwg-look
```

## qt5ct-kde

Serve para configurar o tema Qt.

```bash
qt5ct-kde
```

## qt6ct-kde

Serve para configurar o tema Qt6.

```bash
qt6ct-kde
```

## Adicionar ENVS no hyprland.conf

```
ENV = XDG_CURRENT_DESKTOP,Hyprland
ENV = XDG_SESSION_TYPE,wayland
ENV = XDG_SESSION_DESKTOP,Hyprland

ENV = GDK_BACKEND,wayland,x11,*
ENV = QT_QPA_PLATFORM,wayland
ENV = QT_QPA_PLATFORMTHEME,qt6ct

ENV = QT_AUTO_SCREEN_SCALE_FACTOR,1
ENV = QT_WAYLAND_DISABLE_WINDOW_DECORATIONS,1
```


## BROWSER

configurar as flags do navegador baseado no chromium. Preferred Ozone platform = wayland.

## DOLPHIN



https://github.com/5hubham5ingh/WallRizz