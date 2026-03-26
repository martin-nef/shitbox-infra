I'm setting up an infrastructure-as-code repo for hosting containerised apps on a home server (Lenovo ThinkCentre). Here's the full context:

## Architecture decisions (already made)

- **Ubuntu Server** as the base OS, with an autoinstall config for reproducible installs
- **Ansible** to provision the host (install Docker, playit.gg agent) and deploy apps
- **Docker Compose** for each app — the host is a dumb Docker runner, nothing more
- **playit.gg** tunnels traffic from a rented domain to the server — no firewall/ingress/port-forwarding config needed on our side
- **Ansible Vault** for secrets — encrypted in git, templated to `.env` files on the host at deploy time
- The Ansible role for apps should be generic: it loops over a list of apps, each with a docker-compose.yml and optional .env.j2 template. It pulls images, injects secrets, and runs `docker compose up`.

## Repo structure

```
infra/
  .gitignore
  README.md
  autoinstall/
    README.md          # instructions for building a bootable USB
    user-data          # cloud-init autoinstall config
    meta-data          # empty, required by cloud-init
  ansible/
    ansible.cfg
    inventory.yml      # target host IP/user
    playbook.yml       # runs base + apps roles
    requirements.yml   # ansible-galaxy deps (community.docker)
    group_vars/
      all/
        vars.yml       # non-secret config: app list, image refs, playit version
        vault.yml      # secrets (to be encrypted with ansible-vault)
    roles/
      base/
        tasks/main.yml     # install Docker, playit.gg agent, unattended-upgrades
        handlers/main.yml  # restart playit handler
      apps/
        tasks/main.yml         # loop over apps list
        tasks/deploy_app.yml   # per-app: copy compose, template .env, pull, up
        handlers/main.yml      # placeholder
  apps/
    myapp/
      docker-compose.yml   # web (rails) + db (postgres) services
      .env.j2              # Jinja2 template referencing vault_ vars
```

## What I need you to do

Please scaffold this entire repo in the current directory. Create every file listed above with working content. Specific things to get right:

1. **deploy_app.yml** — Don't use `notify` with dynamic handler names (that doesn't work in Ansible). Instead, register `changed` results from the copy/template tasks and use a conditional restart task at the end.

2. **The .env.j2 template** — Should set RAILS_ENV, SECRET_KEY_BASE, DATABASE_URL for the web container, and POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB for the db container. Extract the PG password from the DATABASE_URL vault var cleanly.

3. **docker-compose.yml** — Rails web service on port 3000, Postgres 16 with a healthcheck, a named volume for pgdata.

4. **autoinstall/user-data** — LVM storage layout, a `deploy` user, SSH-only auth (no password login), placeholder for SSH public key.

5. **Base role** — Install Docker from the official apt repo (with GPG key), download playit.gg binary from GitHub releases, create a systemd unit for it that reads a secret file, enable unattended-upgrades.

6. **vault.yml** — Include placeholder values with CHANGEME markers. Don't actually encrypt it (I'll do that myself).

7. **README.md** — Quick-start instructions covering: install ansible, create vault, run playbook, redeploy a single app, add a new app.

After creating the files, show me the tree and tell me the 3-4 things I need to manually fill in (SSH key, vault secrets, inventory IP, image reference) before I can run the playbook.
