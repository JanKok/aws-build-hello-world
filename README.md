# aws-build-hello-world

EC2 build pipeline for the [hello-world-example](../hello-world-example) C program. Syncs `hello.c` to a t3.micro EC2 instance, compiles it with `gcc`, and fetches the binary back to `hello-world-example/bin/hello`.

## Prerequisites

- `aws-build-hello-world`, `hello-world-example`, and `aws-build-utils` must all be checked out as siblings in the same parent directory.
- AWS CLI, SSH key pair, and other one-time setup steps are described in [aws-build-utils/SETUP-README.md](../aws-build-utils/SETUP-README.md).
- EC2 key pair named `aws-build` with the private key at the path configured in `aws-build-utils/config.sh`.

## First-time setup

```bash
./create-instance.sh
```

Resolves the latest Ubuntu 22.04 AMI, launches an EC2 instance, saves its ID to `.state/`, then stops it. Only needed once.

## Scripts

| Script | What it does |
|---|---|
| `build.sh` | Start EC2, sync source, compile, fetch binary, stop EC2 |
| `local-build.sh` | Compile `hello.c` locally with `gcc` |
| `deploy.sh` | Run the compiled binary on this machine |
| `start.sh` | Start the EC2 instance |
| `stop.sh` | Stop the EC2 instance |
| `resize-instance.sh` | Change the EC2 instance type (instance must be stopped) |
| `create-instance.sh` | One-time setup: launch the EC2 instance |

All scripts accept `--dry-run` to print what they would do without making changes.

## VS Code tasks

Open `aws-build.code-workspace` in VS Code. `Ctrl+Shift+B` runs **Build on EC2**. Other tasks are available via **Terminal → Run Task**.

## Configuration

Edit `config.sh` to change instance type, key pair name, remote paths, or local paths. `PAYLOAD_CMD` defines the build command run on EC2 and locally.
