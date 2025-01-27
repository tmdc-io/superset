FROM apache/superset:4.1.1

COPY trino-0.328.9-py3-none-any.whl /app/whl/

RUN pip install /app/whl/trino-0.328.9-py3-none-any.whl
