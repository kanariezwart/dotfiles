# Vanilla Linux environment to test the dotfiles in.
# Only installs what the bootstrap needs; everything else should come from
# the dotfiles themselves (or fail visibly).
FROM ubuntu:24.04

# The ubuntu image is minimized: dpkg skips /usr/share/doc and man pages,
# where e.g. fzf's zsh key bindings live. Install packages fully, as on a
# regular install.
RUN rm /etc/dpkg/dpkg.cfg.d/excludes \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates git make stow sudo zsh \
  && rm -rf /var/lib/apt/lists/*

COPY run.sh /usr/local/bin/run-dotfiles

# Regular user with sudo, like on a desktop install (passwordless for tests)
RUN useradd --create-home --shell /usr/bin/zsh --groups sudo tester \
  && echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester
USER tester
WORKDIR /home/tester

ENTRYPOINT ["/usr/local/bin/run-dotfiles"]
CMD ["test"]
