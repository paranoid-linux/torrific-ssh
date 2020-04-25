FROM alpine


RUN apk update
RUN apk add --no-cache bash openssh tor


WORKDIR /git/hub/paranoid-linux/torrific-ssh
COPY . ./


ENTRYPOINT ["bash"]
CMD ["./torrific-ssh-server.sh"]
