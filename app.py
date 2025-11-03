from flask import Flask, request, Response
from json import dumps
from platform import python_version as pv, system, release, version
from datetime import datetime
from sys import platform

app = Flask(__name__)

@app.route("/")
def collect_data():
    ip = request.remote_addr
    python_version = pv()
    time = datetime.now().strftime("%H:%M:%S")
    message = "Вторая домашка готова!"
    data =  {
        "ip":ip,
        "python_version":python_version,
        "time":time,
        "message":message
    }
    hard_data = {
        "operating_system":f"{system()},{release()}",
        "some_text": ["devops","linux","yandex"]
    }
    combined = {
        "soft_data":data,
        "hard_data":hard_data
    }

    json_data = dumps(combined, ensure_ascii=False)
    return Response(json_data, content_type="application/json; charset=utf-8")



if __name__ == '__main__':
    app.run(debug=True,host="0.0.0.0",port=5000)
