FROM osrf/ros:melodic-desktop-full

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
${NVIDIA_VISIBLE_DEVICES:-all}

ENV NVIDIA_DRIVER_CAPABILITIES \
${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    build-essential \
    curl \
    wget \
    git \
    lsb-release \
    gnupg2 \
    vim \
    libgoogle-glog-dev \
    libgflags-dev \
    libatlas-base-dev \
    libeigen3-dev \
    libsuitesparse-dev \
    libglew-dev \
    libpython3.8-dev \
    ffmpeg \
    libavcodec-dev \
    libavutil-dev \
    libavformat-dev \
    libswscale-dev \
    libavdevice-dev \
    libdc1394-22-dev \
    libraw1394-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    libopenexr-dev

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py

RUN python get-pip.py

RUN pip install opencv-python==4.2.0.32

RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0.tar.gz \
    && tar -zxvf cmake-3.16.0.tar.gz \
    && cd cmake-3.16.0 \
    && ./bootstrap \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf cmake-3.16.0 cmake-3.16.0.tar.gz

WORKDIR /root/catkin_ws

RUN /bin/bash -c "wget https://github.com/ceres-solver/ceres-solver/archive/refs/tags/1.14.0.tar.gz; \
    tar zxf 1.14.0.tar.gz; \
    cd ceres-solver-1.14.0; \
    mkdir build; \
    cd build; \
    cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF; \
    make; \
    sudo make install"

RUN /bin/bash -c "wget https://github.com/stevenlovegrove/Pangolin/archive/refs/tags/v0.8.tar.gz; \
    tar zxf v0.8.tar.gz; \
    cd Pangolin-0.8; \
    mkdir build; \
    cd build; \
    cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF; \
    cmake build; \
    sudo make install"

RUN /bin/bash -c "cd ~/catkin_ws; \
    git clone https://github.com/Giannis-Alamanos/ORB-LINE-SLAM.git; \
    export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:~/catkin_ws/ORB-LINE-SLAM/Examples/ROS; \
    cd ORB-LINE-SLAM; \
    sed -i 's/++11/++14/g' CMakeLists.txt; \
    chmod +x build.sh; \
    chmod +x build_ros.sh; \
    bash ./build.sh"
    

RUN /bin/bash -c "source /opt/ros/melodic/setup.bash"

# Do Following Lines in container.

# export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:~/catkin_ws/ORB-LINE-SLAM/Examples/ROS; \
# cd ~/catkin_ws/ORB-LINE-SLAM/Examples/ROS/ORB_SLAM3; \
# sed -i 's/++11/++14/g' CMakeLists.txt; \
# cd ../../../; \
# bash ./build_ros.sh"

ENTRYPOINT ["/bin/bash"]

