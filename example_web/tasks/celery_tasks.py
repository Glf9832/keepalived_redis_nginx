from tasks.celery_app import celery_app


@celery_app.task
def start_backup_async():
    print('start backup.')
    return 'start backup successful.'
