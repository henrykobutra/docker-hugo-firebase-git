FROM node:10.16.3-slim@sha256:d5dc8e967cf60394ed8361f20ec370b66bc7260d70bbe0ea3137dbfb573fcea9

# labels
LABEL maintainer="henrykobutra@gmail.com"

# variables
ENV HUGO_VERSION 0.53

RUN  apt-get update \
    && apk add --update --upgrade --no-cache ca-certificates git \
    && update-ca-certificates  \
     # Install latest chrome dev package, which installs the necessary libs to
     # make the bundled version of Chromium that Puppeteer installs work.
     && apt-get install -y wget --no-install-recommends \
     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
     && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
     && apt-get update \
     && apt-get install -y google-chrome-unstable --no-install-recommends \
     && rm -rf /var/lib/apt/lists/* \
     && wget --quiet https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /usr/sbin/wait-for-it.sh \
     && chmod +x /usr/sbin/wait-for-it.sh \
    # && cd /tmp\
    && wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -O hugo.tar.gz  \
    && tar xzf hugo.tar.gz  \
    && mv hugo /usr/bin/hugo  \
    # && rm -r *  \
    && apk del --purge wget  \
    && npm install -g firebase-tools --unsafe-perm

# Install Puppeteer under /node_modules so it's available system-wide
ADD package.json package-lock.json /
RUN npm install
