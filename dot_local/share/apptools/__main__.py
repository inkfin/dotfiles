import os
import sys
from pathlib import Path

_here = Path(__file__).resolve().parent
_share = _here.parent
if str(_share) not in sys.path:
    sys.path.insert(0, str(_share))

from apptools.cli import main  # noqa: E402

raise SystemExit(main())
