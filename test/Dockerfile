# Vanilla Linux environment to test the dotfiles in.
# Only installs what the bootstrap needs; everything else should come from
# the dotfiles themselves (or fail visibly).
FROM ubuntu:24.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates git locales make stow sudo zsh \
  && rm -rf /var/lib/apt/lists/* \
  # .shell_env sets LANG=en_US.UTF-8, as present on a desktop install
  && locale-gen en_US.UTF-8

COPY run.sh /usr/local/bin/run-dotfiles

# Regular user with sudo, like on a desktop install (passwordless for tests)
RUN useradd --create-home --shell /usr/bin/zsh --groups sudo tester \
  && echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester
USER tester
WORKDIR /home/tester

ENTRYPOINT ["/usr/local/bin/run-dotfiles"]
CMD ["test"]
