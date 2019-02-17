import os
import sys

APP_ROOT = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../')
sys.path.append(APP_ROOT)

from tasks.celery_app import celery_app
