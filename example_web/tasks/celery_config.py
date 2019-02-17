import os
from datetime import timedelta
from celery.schedules import crontab


class BaseConfig(object):
    # redbeat_redis_url = os.environ.get('redbeat_redis_url') \
    #                     or 'redis://localhost:6379/1'
    # redbeat_lock_timeout = 50
    # beat_max_loop_interval = 10
    # beat_scheduler = 'redbeat.RedBeatScheduler'

    # 使用rabbitmq作为消息代理
    broker_url = os.environ.get('celery_broker_url') \
                 or 'redis://localhost:6379/0'
    # result_backend = os.environ.get('celery_result_backend') \
    #                  or 'redis://localhost:6379/1'  # 任务结果存入redis
    task_serializer = 'msgpack'  # 任务序列化和反序列化使用msgpack方案
    result_serializer = 'json'  # 读取任务结果要求性能不高，使用可读性更好的JSON
    result_expires = 60 * 60 * 24  # 任务任务过期时间
    accept_content = ['json', 'msgpack']  # 指点接受的内容类型
    timezone = 'UTC'  # 设置时区
    enable_utc = True  # 开启utc
    imports = ['tasks.celery_tasks', 'tasks.celery_beats']  # 导入任务模块
    task_track_started = True  # 任务跟踪
    # worker_hijack_root_logger = True  # 禁用log root 清理

    beat_schedule = {
        'test': {
            'task': 'tasks.celery_beats.start_backup_periodical',
            'schedule': crontab('*')
        }
    }


class DevConfig(BaseConfig):
    pass


config = DevConfig()
