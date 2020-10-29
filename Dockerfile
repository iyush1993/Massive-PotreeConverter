# DockertFile for the Massive-PotreeConverter
FROM ubuntu:18.04
RUN apt-get update -y

# INSTALL compilers and build toold
RUN apt-get install -y wget git cmake build-essential gcc g++ 

RUN apt-get install -y manpages-dev libssl-dev


# INSTALL PDAL
RUN apt-get install -y libgeos-dev libproj-dev libtiff-dev libgeotiff-dev
RUN apt-get install -y libgdal-dev
WORKDIR /opt
RUN wget http://download.osgeo.org/laszip/laszip-2.1.0.tar.gz
RUN tar xvfz laszip-2.1.0.tar.gz
WORKDIR /opt/laszip-2.1.0
RUN mkdir makefiles
WORKDIR /opt/laszip-2.1.0/makefiles/
RUN cmake ..
RUN make; make install
WORKDIR /opt
RUN wget http://download.osgeo.org/pdal/PDAL-1.7.2-src.tar.gz
RUN tar xvzf PDAL-1.7.2-src.tar.gz
WORKDIR /opt/PDAL-1.7.2-src
RUN mkdir makefiles
WORKDIR /opt/PDAL-1.7.2-src/makefiles
RUN apt-get install -y libjsoncpp-dev
RUN cmake -G "Unix Makefiles" ../
RUN make ; make install

WORKDIR /opt

# INSTALL PotreeConverter

# =================================== LAStools =================================
ARG LAS_TOOLS_BRANCH=master

ADD https://api.github.com/repos/LAStools/LAStools/git/refs/heads/${LAS_TOOLS_BRANCH} version.json
RUN git clone --single-branch --branch ${LAS_TOOLS_BRANCH} https://github.com/LAStools/LAStools.git && \
    cd LAStools/LASzip && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make && \
    make install && \
    cd /tmp

# =================================== PotreeConverter ==========================
ARG POTREE_CONVERTER_BRANCH=1.6

RUN git clone --single-branch --branch ${POTREE_CONVERTER_BRANCH} https://github.com/potree/PotreeConverter.git && \
    cd PotreeConverter && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DLASZIP_INCLUDE_DIRS=/usr/local/include/laszip -DLASZIP_LIBRARY=/usr/local/lib/liblaszip.so .. && \
    make && \
    make install && \
    cd /tmp

# INSTALL LAStools
WORKDIR /opt
RUN wget http://www.cs.unc.edu/~isenburg/lastools/download/lastools.zip
# RUN apt-get update -y
RUN apt-get install -y unzip
RUN unzip lastools.zip -d LT
WORKDIR /opt/LT/LAStools/
RUN make
RUN ln -s /opt/LT/LAStools/bin/lasinfo /usr/local/sbin/lasinfo
RUN ln -s /opt/LT/LAStools/bin/lasmerge /usr/local/sbin/lasmerge


# INSTALL pycoeman
RUN apt-get install -y python-pip python-dev build-essential libfreetype6-dev libffi-dev
RUN pip install git+https://github.com/NLeSC/pycoeman

# INSTALL Massive-PotreeConverter
RUN pip install git+https://github.com/iyush1993/Massive-PotreeConverter.git

# Create 3 volumes to be used when running the script. Ideally each run must be mounted to a different physical device
VOLUME ["/data1"]
VOLUME ["/data2"]
VOLUME ["/data3"]

WORKDIR /data1