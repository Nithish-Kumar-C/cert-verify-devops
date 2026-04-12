FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN apt-get update && apt-get install -y gcc default-libmysqlclient-dev pkg-config && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --upgrade pip setuptools==68.0.0
RUN pip install -r requirements.txt
RUN pip install web3==6.15.1
COPY . .
EXPOSE 8000
CMD ["gunicorn", "cert_verify.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]