# From openjdk:8-jdk-buster
FROM buildpack-deps:buster-scm

ARG MAVEN_VERSION=3.6.3
ARG MAVEN_SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG MAVEN_BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ARG JAVA_URL=https://github.com/lexusag/mvn-oraclejdk/blob/main/jdk-8u241-linux-x64.tar.gz?raw=true
ARG JAVA_FILENAME=jdk-8u241-linux-x64.tar.gz

# From openjdk:8-jdk-buster
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
		fontconfig libfreetype6 \
		ca-certificates p11-kit \
	; \
	rm -rf /var/lib/apt/lists/*

# Oracle jdk and maven
RUN wget --no-verbose -O /tmp/"${JAVA_FILENAME}" "${JAVA_URL}" \
    && tar xzf /tmp/"${JAVA_FILENAME}" -C /opt/ \
    && ln -s /opt/jdk1.8.0_241 /opt/jdk \
    && ln -s /opt/maven/bin/mvn /usr/local/bin \
    && rm -f /tmp/"${JAVA_FILENAME}" \
    && mkdir -p /usr/share/maven \
    && curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
    && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV JAVA_HOME "/opt/jdk"
ENV MAVEN_HOME "/usr/share/maven"
ENV PATH $PATH:$JAVA_HOME/bin
