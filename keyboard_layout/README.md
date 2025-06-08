# Keyboard modifications

I like to write on a single keyboard layout in the languages that are dear to
me: English, (Swiss) German, Slovak, Czech. The modification adds the additional
letters with diacritics like ľščťžýýáüöß.

## MacOS

The keyboard layout `izidor_keyboard.bundle` is edited using
[Ukelele](https://software.sil.org/ukelele/).

The layout is then deployed to `~/Library/Keyboard Layouts/`. It is generally
not recommended to edit the file directly at the location as the OS might go
wrong.

Super short tutorial on how to edit layout:

 - press the key with modifiers that you want
 - double click on the highlighted button
 - paste the character to output

Alternatively:

 - right click on the key and select `Edit key`
 - put the output that you want and select the modifiers on top right (e.g.
   Option + Shift)

Alternatively you can create *Dead key state* to generate items without
permanently consuming keys.

You can find the manual on your computer at
<file:///Applications/Ukelele.app/Contents/Resources/Ukelele%20Manual.pdf>

## Linux

The keyboard mapping is in file `izidor`. The file needs to be moved to
`/usr/share/X11/xkb/symbols/izidor` and set as

```shell
sudo cp izidor /usr/share/X11/xkb/symbols/izidor
setxkbmap izidor
```

To make it permanent:

```shell
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'izidor')]"
```

Theoretically one can store the keymap under `~/.config/xkb/symbols/` or
`~/.xkb/` though I did not managed to get it working.

References:

 - [Custom Keyboard Layouts with xkb](https://codeaffen.org/2023/09/16/custom-keyboard-layouts-with-xkb/)
 - [Creating a custom xkb layout](https://niklasfasching.de/posts/custom-keyboard-layout/)
 - [A simple, humble but comprehensive guide to XKB for linux](https://medium.com/@damko/a-simple-humble-but-comprehensive-guide-to-xkb-for-linux-6f1ad5e13450)
