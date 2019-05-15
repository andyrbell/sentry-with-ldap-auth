FROM sentry:9.1

WORKDIR /usr/src/sentry

RUN apt-get update \
 && apt-get install -y \
    libsasl2-dev \
    python-dev \
    libldap2-dev \
    libssl-dev \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN pip install sentry-ldap-auth

# Add WORKDIR to PYTHONPATH so local python files don't need to be installed
ENV PYTHONPATH /usr/src/sentry
ONBUILD COPY . /usr/src/sentry

# Hook for installing additional plugins
ONBUILD RUN if [ -s requirements.txt ]; then pip install -r requirements.txt; fi

# Hook for installing a local app as an addon
ONBUILD RUN if [ -s setup.py ]; then pip install -e .; fi

# Hook for staging in custom configs
ONBUILD RUN if [ -s sentry.conf.py ]; then cp sentry.conf.py $SENTRY_CONF/; fi \
	&& if [ -s config.yml ]; then cp config.yml $SENTRY_CONF/; fi