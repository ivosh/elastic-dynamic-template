FROM docker.elastic.co/kibana/kibana:8.12.0

# Disable legacy OpenSSL providers.
RUN /usr/bin/sed -z \
    's/## enable OpenSSL 3 legacy provider\n--openssl-legacy-provider/## disable OpenSSL 3 legacy provider\n#--openssl-legacy-provider/' \
    -i /usr/share/kibana/config/node.options

COPY --chown=kibana:root kibana.yml /usr/share/kibana/config/

EXPOSE 5601

