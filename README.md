# Time to strap in, and get some cool stuff done.

This repo contains what you need to root your car, except for the USB stick. This is tested on my own Ioniq 5 2024 EU, 5W.XXX.S5W_L.001.001.260128, NE_E.EUR.S5W_L.001.001.260128 but I believe this should work for more cars.

The poc.sh script that is provided does nothing, until you put a payload in it.

Do whatever you want with this, just don't forget to give credit where credit is due.

# Get started

- Format a USB stick as FAT or exFAT
- Write a Busybox ash valid script or commands in the payload section of poc.sh that does what you want
- Run encrypt_ter.py, pointing it at poc.sh, with Python:
```
python3 encrypt_ter.py poc.sh
```
- VarUpgrade is created, and can now be moved to your USB stick
- On the car, the actions are:
1. Open the engineering menu
2. Press "nav" or "map", or "media" button or whatever to **close** the menu again (and kill the process)
3. Plug USB in to your car's data USB port
4. Wait for a while (5-10 seconds??) and your payload will be executed

> It can be a little fiddly. Sometimes you don't need to do this and you plug it straight in and instant execute, sometimes you gotta do the dance. Sometimes you see the real engineering menu instead of the paylaod one, sometimes the screen goes blank after you see the engineering menu. It is what it is.

# Why is this possible

- Plugging in a stick auto-starts the updater. The mount signal (`com.lge.car.automount.UsbMount`) is accepted from any sender, and nothing asks the user.
- With no normal update present, it processes a fallback file, `VarUpgrade`.
- The updater reads the signature *type* from the file itself. Type `TE2` is verified for real; type `TER` is accepted after only parsing the key. (This is in theory also possible for an entire update, but I haven't tested that.)
- The payload is AES-128-CBC with no integrity check.
- The result is written to `/tmp/app/bin/AppEngineerMode` and launched by AppLauncher, which skips its signature check on this path. It runs as uid 0 with full capabilities.
- Unplugging deletes the `/tmp` file, but root can rewrite the read-only `/app` partition (no dm-verity, no module signing).

Scripts and binaries should both work.

## Disclaimer

> [!WARNING]
> This project is intended for research and educational purposes only.
> Modifying vehicle software or firmware may void warranties, violate
> regulations, or render a device inoperable. Proceed only if you fully
> understand the risks.
