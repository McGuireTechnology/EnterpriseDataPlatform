FROM python:3.14-slim

WORKDIR /workspace

COPY postgres/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

CMD ["python", "--version"]
