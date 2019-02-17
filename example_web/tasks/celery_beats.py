from datetime import datetime

from tasks.celery_app import celery_app
from tasks.celery_tasks import start_backup_async

@celery_app.task
def start_backup_periodical():
    print('check backup periodical.')

    minute = datetime.now().minute

    if minute % 5 == 0:
        start_backup_async.delay()

