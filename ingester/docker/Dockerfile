# The document flattener (runbook D0). The only part of the ingester that runs in a container: reading
# xlsx, pptx and pdf needs parsers the shell scripts cannot have. python:3.12-slim is already on the host.
FROM python:3.12-slim
# Corporate TLS interception (Netskope): the macOS system keychain's certificates join the image's trust
# store so pip can verify PyPI. corp-ca.crt is written by make build from the keychain and is not committed.
COPY corp-ca.crt /usr/local/share/ca-certificates/corp-ca.crt
RUN update-ca-certificates
ENV PIP_CERT=/etc/ssl/certs/ca-certificates.crt
RUN pip install --no-cache-dir openpyxl==3.1.5 python-pptx==1.0.2 pdfplumber==0.11.4
RUN useradd --create-home flatten
USER flatten
WORKDIR /app
COPY flatten.py /app/flatten.py
ENTRYPOINT ["python", "-I", "/app/flatten.py"]
