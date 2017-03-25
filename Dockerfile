FROM phusion/baseimage:0.9.19

MAINTAINER David Coppit <david@coppit.org>

ENV DEBIAN_FRONTEND noninteractive

# Speed up APT
RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
  && echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

# Auto-accept Oracle JDK license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# Filebot needs Java 8
RUN add-apt-repository ppa:webupd8team/java \
  && apt-get update \
  && apt-get install -y oracle-java8-installer

# Create dir to keep things tidy. Make sure it's readable by $USER_ID
RUN mkdir /files
RUN chmod a+rwX /files

# Use of inotify inspired by inkubux/filebot-inotifywatch
RUN set -x \
#  && apt-get update \
  # libchromaprint-tools for fpcalc, used to compute AcoustID fingerprints for MP3s
  && apt-get install -y inotify-tools mediainfo libchromaprint-tools \
  && wget -O /files/filebot.deb 'https://app.filebot.net/download.php?type=deb&arch=amd64&version=4.7.8‘ \
  && dpkg -i /files/filebot.deb && rm /files/filebot.deb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/media", "/config"]

# Rev-locking this to ensure reproducible builds
RUN wget -O /files/runas.sh \
  'https://raw.githubusercontent.com/coppit/docker-inotify-command/7be05137c367a7bbff6b7980aa14e8af0c24eca6/runas.sh'
RUN chmod +x /files/runas.sh
RUN wget -O /files/monitor.sh \
  'https://raw.githubusercontent.com/coppit/docker-inotify-command/934be986851265789979dde2e220d81cfd352850/monitor.sh'
RUN chmod +x /files/monitor.sh

# Add scripts. Make sure start.sh, pre-run.sh, and filebot.sh are executable by $USER_ID
ADD pre-run.sh /files/pre-run.sh
RUN chmod a+x /files/pre-run.sh
ADD start.sh /files/start.sh
RUN chmod a+x /files/start.sh
ADD filebot.sh /files/filebot.sh
RUN chmod a+wx /files/filebot.sh
ADD filebot.conf /files/filebot.conf
RUN chmod a+w /files/filebot.conf

ENV USER_ID 99
ENV GROUP_ID 100
ENV UMASK 0000

# Set the locale, to help filebot deal with files that have non-ASCII characters
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD /files/start.sh
