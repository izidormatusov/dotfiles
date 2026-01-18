# How to update QMK firmware on GMMK Pro

## Create layout

Go to https://config.qmk.fm/ and select `gmmk/pro/rev1/ansi`

Modify the layout. Save the `keymap.json` so that you can load it up again.

When you're happy, click `Compile` in top right corner and wait until the
animation finishes baking potato. Afterwards click the `Firmware` button and
download `.hex` file.

## Flashing

Get the QMK toolbox (homebrew page says that the cask is deprecated):

```shell
brew install --cask qmk-toolbox
```

Open QMK toolbox and select the downloaded `.bin` file. Keep the processor to
the default version (`ATmega32U4`).

Put the keyboard into the boot mode.

 - Default Glorious Core firmware: Unplug the keyboard. Press and hold
   <kbd>Space</kbd> + <kbd>B</kbd> and with the other hand plug the cable.
 - QMK layout has <kbd>FN</kbd> + <kbd>|</kbd> (the one under backspace).

You should see something like this in the output:

```
STM32 DFU device connected: STMicroelectronics STM32  BOOTLOADER
```

Press `Flash` and keep the keyboard plugged in until `Flash complete` appears.

MacOS might ask you couple times if you want to allow a new device to plug in.

To disable RGB, press <kbd>FN</kbd> + <kbd>1</kbd>. (unless you remap it that)

## References

 - [Glorious: Step-By-Step Guide To Configuring Your GMMK PRO Using QMK](https://www.gloriousgaming.com/en-eu/blogs/resources/step-by-step-guide-to-configuring-your-gmmk-pro-using-qmk)
 - [QMK Tutorial](https://docs.qmk.fm/newbs)
