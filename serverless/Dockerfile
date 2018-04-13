FROM alpine
MAINTAINER brian.verkley@emc.com

RUN apk --update add git python py-pip && rm -f /var/cache/apk/*
RUN pip install flask requests python-logstash
COPY honeypot.py /tmp/
EXPOSE 8080
ENTRYPOINT ["python","/tmp/honeypot.py"]
