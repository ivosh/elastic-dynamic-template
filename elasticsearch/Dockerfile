FROM docker.elastic.co/elasticsearch/elasticsearch:8.12.0
COPY --chown=elasticsearch:root elasticsearch.yml /usr/share/elasticsearch/config/

RUN echo "y" | bin/elasticsearch-keystore create
RUN echo "b21Qx.CPIJsTdhY" | bin/elasticsearch-keystore add --stdin "bootstrap.password"

RUN mkdir /usr/share/elasticsearch/repo

EXPOSE 9200
