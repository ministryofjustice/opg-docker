FROM registry.service.opg.digital/opguk/base:latest

# Download and install wkhtmltopdf
RUN apt-get update && apt-get install -y gdebi && \
    wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    gdebi -n -q wkhtmltox-0.12.2.1_linux-trusty-amd64.deb

# Install dependencies for running web service
RUN pip install werkzeug executor gunicorn

ADD app.py /app.py
EXPOSE 80

ENTRYPOINT ["usr/local/bin/gunicorn"]

# Show the extended help
CMD ["-b", "0.0.0.0:80", "--log-file", "-", "app:application"]

