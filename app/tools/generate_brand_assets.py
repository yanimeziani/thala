#!/usr/bin/env python3
"""Rasterise Thala brand assets from the primary SVG logo."""

from __future__ import annotations

import pathlib
import shutil
import subprocess
from dataclasses import dataclass

try:  # pragma: no cover - availability differs per host
    from cairosvg import svg2png  # type: ignore
except Exception:  # noqa: BLE001
    svg2png = None


ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE_SVG = ROOT / "assets" / "logo.svg"
SVG_BYTES = SOURCE_SVG.read_bytes()


@dataclass(frozen=True)
class IconExport:
    size: int
    path: pathlib.Path

    def render(self) -> None:
        output_path = ROOT / self.path
        output_path.parent.mkdir(parents=True, exist_ok=True)
        rasterise_svg(str(output_path), self.size)
        print(f"→ {self.path} ({self.size}px)")


def rasterise_svg(path: str, size: int) -> None:
    if svg2png is not None:
        svg2png(  # type: ignore[operator]
            bytestring=SVG_BYTES,
            write_to=path,
            output_width=size,
            output_height=size,
        )
        return

    sips = shutil.which("sips")
    if sips:
        subprocess.run(
            [
                sips,
                "--resampleHeightWidth",
                str(size),
                str(size),
                "-s",
                "format",
                "png",
                str(SOURCE_SVG),
                "--out",
                path,
            ],
            check=True,
        )
        return

    raise SystemExit(
        "Unable to rasterise SVG. Install cairosvg or make 'sips' available."
    )


ANDROID_EXPORTS = (
    IconExport(48, pathlib.Path("android/app/src/main/res/mipmap-mdpi/ic_launcher.png")),
    IconExport(72, pathlib.Path("android/app/src/main/res/mipmap-hdpi/ic_launcher.png")),
    IconExport(96, pathlib.Path("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png")),
    IconExport(144, pathlib.Path("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png")),
    IconExport(192, pathlib.Path("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png")),
)

IOS_ICONSET_DIR = pathlib.Path("ios/Runner/Assets.xcassets/AppIcon.appiconset")
IOS_EXPORTS = (
    IconExport(1024, IOS_ICONSET_DIR / "Icon-App-1024x1024@1x.png"),
    IconExport(20, IOS_ICONSET_DIR / "Icon-App-20x20@1x.png"),
    IconExport(40, IOS_ICONSET_DIR / "Icon-App-20x20@2x.png"),
    IconExport(60, IOS_ICONSET_DIR / "Icon-App-20x20@3x.png"),
    IconExport(29, IOS_ICONSET_DIR / "Icon-App-29x29@1x.png"),
    IconExport(58, IOS_ICONSET_DIR / "Icon-App-29x29@2x.png"),
    IconExport(87, IOS_ICONSET_DIR / "Icon-App-29x29@3x.png"),
    IconExport(40, IOS_ICONSET_DIR / "Icon-App-40x40@1x.png"),
    IconExport(80, IOS_ICONSET_DIR / "Icon-App-40x40@2x.png"),
    IconExport(120, IOS_ICONSET_DIR / "Icon-App-40x40@3x.png"),
    IconExport(120, IOS_ICONSET_DIR / "Icon-App-60x60@2x.png"),
    IconExport(180, IOS_ICONSET_DIR / "Icon-App-60x60@3x.png"),
    IconExport(76, IOS_ICONSET_DIR / "Icon-App-76x76@1x.png"),
    IconExport(152, IOS_ICONSET_DIR / "Icon-App-76x76@2x.png"),
    IconExport(167, IOS_ICONSET_DIR / "Icon-App-83.5x83.5@2x.png"),
)

ADDITIONAL_EXPORTS = (
    IconExport(512, pathlib.Path("assets/images/logo.png")),
    IconExport(256, pathlib.Path("assets/images/logo@0.5x.png")),
    IconExport(128, pathlib.Path("assets/images/logo@0.25x.png")),
)


def main() -> None:
    exports = (*ANDROID_EXPORTS, *IOS_EXPORTS, *ADDITIONAL_EXPORTS)
    for export in exports:
        export.render()
    print(f"Generated {len(exports)} assets from {SOURCE_SVG.relative_to(ROOT)}.")


if __name__ == "__main__":
    main()
