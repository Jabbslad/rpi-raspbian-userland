FROM jsurf/rpi-raspbian

RUN [ "cross-build-start" ]

# Install cron / deps to build raspberry pi userland tools from source
RUN apt-get update && apt-get install -y \
      build-essential \
      cmake \
      git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Get latest userland tools and build. Clean up unused stuff at the end
RUN cd \
    && git clone --depth 1 https://github.com/raspberrypi/userland.git \
    && cd userland \
    && ./buildme \
    && rm -rf ..\userland \
    && rm -rf /opt/vc/include \
    && rm -rf /opt/vc/src

# Remove the dependencies needed to build userland tools    
RUN apt-get purge -y \
      build-essential \
      cmake \
      git \
    && apt-get -y --purge autoremove

# Tell linux where to find .so files for the stuff we just built
RUN echo "/opt/vc/lib" > /etc/ld.so.conf.d/00-vcms.conf \
    && ldconfig

# Run without the having to specify the full path
ENV PATH /opt/vc/bin:/opt/vc/lib:$PATH

RUN [ "cross-build-end" ]
