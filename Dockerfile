FROM smizy/scikit-learn:0.19.1-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="smizy/pytorch" \
    org.label-schema.url="https://gitlab.com/smizy" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-url="https://github.com.com/smizy/docker-pytorch"

ENV PYTORCH_VERSION      $VERSION
ENV TORCHVISION_VERSION  0.2.0
ENV TORCHTEXT_VERSION    0.2.1

RUN set -x \
    && apk update \
    # - pytorch build dependencies
    && apk --no-cache add \
        libgomp \
        py3-cffi \
    && apk --no-cache add --virtual .builddeps \
        bash \
        build-base \
        cmake \
        # freetype-dev \
        git \
        # jpeg-dev \
        linux-headers \
        openblas-dev \
        python3-dev \
        # zlib-dev \
    && pip3 install pyyaml \
    # - pytorch src
    && git clone --recursive -b v${PYTORCH_VERSION} --single-branch --depth 1 https://github.com/pytorch/pytorch /tmp/pytorch \
    && cd /tmp/pytorch \
    # - build 
    && python setup.py install \
    && cd /tmp \
    # - pillow build dependency
    && apk --no-cache add \
        lcms2 \
        libjpeg-turbo \
        libwebp \
        openjpeg \
        py3-olefile \
        tiff \
    && apk --no-cache add --virtual .builddeps.1 \
        freetype-dev \
        lcms2-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        openjpeg-dev \
        tiff-dev \
    && pip3 install torchvision==${TORCHVISION_VERSION} \
    && pip3 install torchtext==${TORCHTEXT_VERSION} \
    # - cleanup
    && find /usr/lib/python3.6 -name __pycache__ | xargs rm -r \
    && apk del \
        .builddeps \
        .builddeps.1 \
    && rm -rf \
        /root/.[acpw]* \
        /tmp/pytorch