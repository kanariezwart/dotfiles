# SSH and GPG on a new machine

What the dotfiles set up for SSH (logins, GitHub) and GPG (signed commits),
and what you do by hand. The keys themselves never live in this repo.

## SSH

### Done by `make setup` (`make ssh`)

- `~/.ssh` (mode 700)
- `~/.ssh/config.local`: a template for your host definitions (mode 600)
- `Include config.local` at the top of `~/.ssh/config`
- At the end of `~/.ssh/config`:
  ```
  Host *
    AddKeysToAgent yes
    UseKeychain yes      # macOS only
  ```
  Keys are added to the agent the first time ssh uses them, so you type the
  passphrase once instead of at every connection.

### The agent

| | macOS | Linux |
|---|---|---|
| Agent | built into macOS (launchd), one per login session | started by the ssh-agent plugin in `.zshrc`, shared by all shells |
| Passphrase | asked once, then kept in the Keychain | asked on first use, kept until the agent stops (logout) |
| Package | part of macOS | `openssh-client` (`make linux`) |

No keys are added at shell startup: a passphrase prompt would clash with the
instant prompt.

### By hand

1. Copy your key pair into `~/.ssh` (`chmod 600` on the private key), or
   create one:
   ```zsh
   ssh-keygen -t ed25519 -C "you@example.com"
   ```
2. Add the public key (`~/.ssh/id_ed25519.pub`) to
   [GitHub](https://github.com/settings/keys) and any servers.
3. Put your hosts in `~/.ssh/config.local`.
4. Optionally switch this repo to SSH:
   ```zsh
   git -C ~/Projects/system/dotfiles remote set-url origin git@github.com:kanariezwart/dotfiles.git
   ```

### Check

```zsh
ssh -T git@github.com   # "Hi <user>! You've successfully authenticated"
ssh-add -l              # the key is listed after its first use
```

## GPG (signed commits)

### Done by the dotfiles

- `.gitconfig` signs every commit (`commit.gpgsign = true`, `gpg.program = gpg`)
- macOS: `gnupg` and `pinentry-mac` from the Brewfile (`make brew`)
- `.zshrc` exports `GPG_TTY`, so a terminal pinentry (Linux) can ask for the
  passphrase

### By hand

1. **Linux: install gnupg.** It isn't in `install/apt.txt`; desktop Ubuntu
   usually ships it, minimal images (servers, containers) don't:
   ```zsh
   sudo apt-get install gnupg
   ```
2. **Import your secret key**, exported on the old machine:
   ```zsh
   # old machine
   gpg --list-secret-keys --keyid-format long
   gpg --export-secret-keys --armor <KEYID> > secret.asc
   gpg --export-ownertrust > ownertrust.txt
   # new machine
   gpg --import secret.asc
   gpg --import-ownertrust ownertrust.txt
   ```
   Move these files over securely and delete them afterwards. Or create a new
   key with `gpg --full-generate-key` and add its public key
   (`gpg --armor --export <KEYID>`) to
   [GitHub](https://github.com/settings/keys).
3. **Create `~/.gitconfig.local`** with the email and key that go with it:
   ```ini
   [user]
     email = your@email.com
     signingkey = <KEYID>

   [github]
     user = your-username
   ```
   Until this exists, every commit fails: signing is on, but there is no key.
4. **macOS: create `~/.gnupg/gpg-agent.conf`**, so gpg asks for the
   passphrase in a Mac dialog that can save it in the Keychain:
   ```
   # Apple Silicon: /opt/homebrew/bin/pinentry-mac
   pinentry-program /usr/local/bin/pinentry-mac
   default-cache-ttl 14400
   max-cache-ttl 86400
   ```
   Then `gpgconf --reload gpg-agent`. Without it, gpg asks in the terminal.
   On Linux no config is needed.

### Check

```zsh
echo test | gpg --clearsign > /dev/null && echo "signing works"
# a signed commit in a throwaway repo
cd "$(mktemp -d)" && git init -q && git commit --allow-empty -qm test && git log --show-signature -1
```
