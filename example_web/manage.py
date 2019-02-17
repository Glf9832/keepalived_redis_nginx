import os
import sys
from flask import Flask, jsonify

APP_ROOT = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../')
sys.path.append(APP_ROOT)

from tasks.celery_tasks import start_backup_async

app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>test page.</h1>'

@app.route('/json')
def index_json():
    return jsonify({'hello': 'world'})

@app.route('/task/start')
def start_backup():
    task = start_backup_async.delay()
    return jsonify({'task_id': task.id})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
