import os
import sys
from celery import Celery

APP_ROOT = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../')
sys.path.append(APP_ROOT)

from tasks.celery_config import config as CONFIG

celery_app = Celery('timemachine')
celery_app.config_from_object(CONFIG)  # 导入配置
