FROM node:11.5-alpine

# labels
LABEL maintainer="henrykobutra@gmail.com"

# variables
ENV HUGO_VERSION 0.53

# Install puppeteer so it's available in the container.

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
    
RUN npm i puppeteer \
    # Add user so we don't need --no-sandbox.
    # same layer as npm install to keep re-chowned files from using up several hundred MBs more space
    && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /node_modules

# Run everything after as non-privileged user.
USER pptruser

CMD ["google-chrome-unstable"]

# install hugo
RUN set -x && \
  apk add --update --upgrade --no-cache wget ca-certificates git && \
  # make sure we have up-to-date certificates
  update-ca-certificates && \
  cd /tmp &&\
  wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -O hugo.tar.gz && \
  tar xzf hugo.tar.gz && \
  mv hugo /usr/bin/hugo && \
  rm -r * && \
  # don't delete ca-certificates pacakge here since it remove all certs too
  apk del --purge wget && \
  # install firebase-cli
  # use --unsafe-perm to solve the issue: https://github.com/firebase/firebase-tools/issues/372
  npm install -g firebase-tools --unsafe-perm
