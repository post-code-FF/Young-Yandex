FROM ubuntu
RUN apt update
RUN apt install python3-pip -y
COPY requirements.txt .
RUN pip3 install --break-system-packages -r requirements.txt
COPY . /app
WORKDIR /app
CMD ["python3", "app.py"]
