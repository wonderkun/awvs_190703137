FROM ubuntu:latest

RUN mkdir /data
WORKDIR /data

RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo apt-utils net-tools && rm -rf /var/lib/apt/lists/*
RUN apt-get update && sudo apt-get install libxdamage1 libgtk-3-0 libasound2 libnss3 libxss1 libx11-xcb1 -y
RUN apt-get update -y && \
    apt-get install -y cron && \
    touch /var/log/cron.log

## ubuntu systemctl: command not found
# RUN apt-get install --reinstall systemd

COPY ./crontab_del.sh .
RUN chmod u+x crontab_del.sh
RUN sh -c 'echo "0 0 * * * bash /data/crontab_del.sh" | crontab -'

COPY ./acunetix_trial.sh .
RUN chmod u+x acunetix_trial.sh
RUN sh -c '/bin/echo -e "\nyes\nubuntu\nadmin@test.com\nTest123...\nTest123...\n"| ./acunetix_trial.sh'

# del sh
RUN rm acunetix_trial.sh

WORKDIR /home/acunetix/.acunetix_trial/v_190703137/scanner
COPY ./patch_awvs .
COPY ./wvsc .
USER root
RUN chmod u+x ./patch_awvs
CMD chmod u+x /home/acunetix/.acunetix_trial/start.sh
USER acunetix
CMD /home/acunetix/.acunetix_trial/start.sh
