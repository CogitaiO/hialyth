# [Linux][Flatpak] Namida startup stalls in Fontconfig on Fedora 44

## Environment
- Namida Flatpak `app.namida.Namida`: 8.4.0-beta+261021218 (commit `5e4699d7d1acdd6eed0ec1860be49ccc5e524baf8ae1fbe0cc16852d04efef1b`) and 8.6.0-beta+261108180 (commit `f69dda6b3319b9e6ec96578d11aebac8391638a1381548bb85403bbcbb3163b5`)
- Fedora 44 x86_64, kernel 7.2.15-200.fc44.x86_64, GNOME Wayland, AMD Radeon Graphics
- Flatpak 1.18.4, runtime org.gnome.Platform 51
- Host Fontconfig 2.17.0; runtime Fontconfig 2.18.3

## Observed
With normal Flatpak font configuration, Namida 8.4.0 starts but its window does not appear, and the process consumes roughly one CPU core for over a minute. Standard output was empty. Two debugger snapshots showed the main thread in `FcPatternGetString` / `FcObjectTypeLookup`, called from `libflutter_linux_gtk.so`.

## Steps to reproduce on the affected machine
1. Launch the installed Flatpak normally with `flatpak run app.namida.Namida`.
2. Wait for the first window and observe the process CPU usage.
3. On this system, the window did not appear during the observation period. A clean HOME/XDG setup was also tested, so this observation does not depend on the existing application profile.

For the reduced-font test, the following minimal `fonts.conf` was passed through `FONTCONFIG_FILE` to the sandbox, with an isolated HOME and XDG directories. This restricts font fallback and is for diagnosis only:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/usr/share/fonts</dir>
  <cachedir>/tmp/namida-font-cache</cachedir>
</fontconfig>
```

The configuration file was exposed read-only to the Flatpak for that run only. It selected 118 font records and the Namida window opened; the font set, rules and cache all differ from the default run.

This also occurred with an isolated temporary HOME and XDG data/config/cache paths. The default Flatpak font configuration reported approximately 2312 `fc-list` records in that isolated environment.

The locally supplied 8.6.0-beta Flatpak bundle was installed into a separate temporary user installation and launched with isolated HOME/XDG directories. With default Fontconfig it likewise showed no window during the short observation before termination; a debugger snapshot showed `FcPatternGetString` called by `libflutter_linux_gtk.so`. A second run using the minimal Fontconfig configuration opened a window, as confirmed by the tester.

With a minimal custom Fontconfig configuration, a private temporary cache, and 118 font records from `/usr/share/fonts`, the isolated Namida window opened. A separate custom config listing `/usr/share/fonts`, `/run/host/fonts` and `/run/host/user-fonts` with a private cache reported 1241 records and progressed to video controller initialization; the exact font set and configuration differ from the default.

An additional test attempted to copy `/etc/fonts` and replace its cache paths. It enumerated 2334 records (2259 unique file/index pairs) and stalled, but syscall tracing showed 243 successful opens of host user-font cache paths, so it was NOT a valid independent-cache test. After additionally setting `FONTCONFIG_PATH` to the copied configuration directory, the private-cache run opened the Namida window; tracing `openat`/`openat2` during startup observed 399 successful cache-file opens from the temporary cache directory and none from the host font-cache directories. These are open call counts, not unique file counts. This changed enumeration: default 2334 records, private-cache 1253, with 1102 default-only and 21 private-only file/index records. Therefore these results do not isolate cache contents from font enumeration or rule differences and cannot identify a root cause.

## Expected
The first window appears without a prolonged CPU spin regardless of installed fonts and font cache state.

## Related
- https://github.com/flatpak/flatpak/issues/6738 (Fedora/Flatpak Fontconfig cache compatibility and similar stack)
- https://github.com/flutter/flutter/issues/187085 (startup delay with many fonts)

## Privacy and caveats
No system fonts or existing caches were removed or regenerated. Matching file/index counts in the invalid initial test do not establish identical metadata or rule evaluation. The separate configuration is a diagnostic workaround, not a recommended permanent configuration: limiting fonts can break fallback for some languages and symbols.
