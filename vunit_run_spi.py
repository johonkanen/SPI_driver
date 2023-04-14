#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

SPI = VU.add_library("SPI")
SPI.add_source_files(ROOT / "clock_divider_pkg.vhd")
SPI.add_source_files(ROOT / "testbenches/clock_divider_tb.vhd")

VU.main()
