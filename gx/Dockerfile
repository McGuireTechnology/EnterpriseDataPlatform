FROM python:3.12-slim

WORKDIR /workspace/gx

RUN pip install --no-cache-dir "great_expectations[postgresql]>=1.17,<1.18" "psycopg[binary]>=3.2,<4"

CMD ["great_expectations", "--version"]
