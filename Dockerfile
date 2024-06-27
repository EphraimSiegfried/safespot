FROM ubuntu:20.04
RUN apt-get update && apt-get install -y sudo bash zsh

COPY . /safespot
WORKDIR /safespot
SHELL ["/bin/zsh", "-c"]
RUN /bin/zsh ./setup.sh

EXPOSE 22

# Start SSHD
CMD ["bash"]
