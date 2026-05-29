FROM python:3.12-slim

WORKDIR /workspace/dbt

RUN pip install --no-cache-dir "dbt-postgres>=1.10,<1.11"

CMD ["dbt", "--version"]
