FROM registry.service.opg.digital/opguk/base

# Download and install wkhtmltopdf
RUN apt-get update && \
    apt-get install -y gdebi && \
    cd /tmp && \
    wget https://downloads.wkhtmltopdf.org/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    echo "502d2b557af49997d19edb3152a19a55  wkhtmltox-0.12.2.1_linux-trusty-amd64.deb" | md5sum -c - && \
    gdebi -n -q wkhtmltox-0.12.2.1_linux-trusty-amd64.deb

# Install dependencies for running web service
RUN pip install werkzeug executor gunicorn

ADD app.py /app.py
EXPOSE 80

ENTRYPOINT ["usr/local/bin/gunicorn"]

# Show the extended help
CMD ["-b", "0.0.0.0:80", "--log-file", "-", "app:application"]

