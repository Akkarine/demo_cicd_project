import sys
from src.core.utils import get_bool_from_env

DEBUG = get_bool_from_env('DEBUG', False)
TEST = 'test' in sys.argv or 'testserver' in sys.argv

if TEST:
    from .test import *
elif DEBUG:
    from .debug import *
else:
    from .production import *
