#!/usr/bin/env python3

import os
import subprocess
from dataclasses import dataclass
from typing import Iterable


INCH = 25.4
INCH_5_8 = 5/8 * INCH
INCH_7_16 = 7/16 * INCH
OUTPUT_DIR = 'dist'


def find_openscad(*locations: Iterable[str]) -> str:
    for loc in locations:
        try:
            subprocess.run([loc, '--version'], check=True)
            print(f'Found OpenSCAD at {loc}')
            return loc
        except:
            pass
    raise FileNotFoundError("OpenSCAD not found")

def dq(s: str, q : str = '\'') -> str:
    "Wrap a string in exta quotes."
    return f'{q}{s}{q}'


def cyan(s: str) -> str:
    "Wrap a string to be output to shell in cyan color codes"
    return f'\033[96m{s}\033[0m'


OPENSCAD = os.environ.get('OPENSCAD_LOCATION') or find_openscad('openscad', '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD')


@dataclass
class Configuration:
    name: str
    part: str
    nodes_per_arm: int
    dowel_size: float  # mm
    s_slop: float


_ = 1  # Use this to indicate a parameter doesn't matter for a certain configuration


configurations = [
    Configuration("test-block", "test block", _, _, 0.15),
    Configuration("leg-top-nodes-4", "top", 4, _, 0.15),
    Configuration("leg-middle-nodes-4", "middle", 4, _, 0.15),
    Configuration("leg-bottom-nodes-4", "bottom", 4, _, 0.15),
    Configuration("leg-top-nodes-3", "top", 3, _, 0.15),
    Configuration("leg-middle-nodes-3", "middle", 3, _, 0.15),
    Configuration("leg-bottom-nodes-3", "bottom", 3, _, 0.15),
    Configuration("leg-top-nodes-2", "top", 2, _, 0.15),
    Configuration("leg-middle-nodes-2", "middle", 2, _, 0.15),
    Configuration("leg-bottom-nodes-2", "bottom", 2, _, 0.15),
    Configuration("mount-5_8-in", "mount", _, INCH_5_8, 0.15),
    Configuration("mount-7_16-in", "mount", _, INCH_7_16, 0.15),
]


for c in configurations:
    command = ' '.join([
        OPENSCAD,
        '-o', f'{OUTPUT_DIR}/{c.name}.stl',
        '-D', dq(f'part="{c.part}"'),
        '-D', dq(f'nodes_per_arm={c.nodes_per_arm}'),
        '-D', dq(f'dowel_size={c.dowel_size}'),
        '-D', dq(f'$slop={c.s_slop}'),
        'all.scad',
    ])
    print(cyan("=" * os.get_terminal_size().columns))
    print(cyan(f'Processing: {c.name}'))
    print(cyan("=" * os.get_terminal_size().columns))
    subprocess.run(command, shell=True, check=True)
