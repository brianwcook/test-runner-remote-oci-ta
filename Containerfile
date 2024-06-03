FROM quay.io/redhat-appstudio/multi-platform-runner:01c7670e81d5120347cf0ad13372742489985e5f@sha256:246adeaaba600e207131d63a7f706cffdcdc37d8f600c56187123ec62823ff44
COPY remote-post.sh /remote-post.sh
COPY remote-pre.sh /remote-pre.sh
RUN chmod +x /remote-pre.sh && chmod +x remote-post.sh