# Vanilla Linux environment to test the dotfiles in.
# Only installs what the bootstrap needs; everything else should come from
# the dotfiles themselves (or fail visibly).
FROM ubuntu:24.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates git make stow zsh \
  && rm -rf /var/lib/apt/lists/*

COPY run.sh /usr/local/bin/run-dotfiles

RUN useradd --create-home --shell /usr/bin/zsh tester
USER tester
WORKDIR /home/tester

ENTRYPOINT ["/usr/local/bin/run-dotfiles"]
CMD ["test"]
