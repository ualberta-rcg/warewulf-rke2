<img src="https://www.ualberta.ca/en/toolkit/media-library/homepage-assets/ua_logo_green_rgb.png" alt="University of Alberta Logo" width="50%" />

# RKE2 Node Image for Warewulf

**Maintained by:** Rahim Khoja ([khoja1@ualberta.ca](mailto:khoja1@ualberta.ca)) & Karim Ali ([kali2@ualberta.ca](mailto:kali2@ualberta.ca))

## 🧰 Description

This repository contains a hardened **RKE2 Kubernetes node image** based on Ubuntu 24.04, built into a Docker container that is **Warewulf-compatible** and deployable on bare metal.

It's primarily used for imaging and provisioning Kubernetes-ready compute nodes using [Warewulf 4](https://warewulf.org), and is tailored for high-performance computing clusters or edge AI clusters that integrate Kubernetes and Slurm side-by-side.

The image includes essential kernel modules, container runtime, RKE2 (server mode), and CIS security hardening using the SCAP Security Guide.

The image is automatically built and pushed to Docker Hub using GitHub Actions whenever changes are pushed to the `latest` branch.

## 📦 Docker Image

**Docker Hub:** [rkhoja/warewulf-rke2\:latest](https://hub.docker.com/r/rkhoja/warewulf-rke2)

```bash
docker pull rkhoja/warewulf-rke2:latest
```

## 🏗️ What's Inside

This container includes:

* **RKE2 Kubernetes** (server mode, installed via official Rancher script)
* SSH, NFS, LVM, Ansible, smartmontools, ipmitool, sensors
* Kernel and modules pre-installed for k8s networking (iptables, CNI, auditd, etc.)
* SCAP CIS Level 2 hardening (automatically applied)
* Systemd-based boot compatible with Warewulf PXE deployments
* `changeme` root password (you should change this in production)

**RKE2 Kubernetes** ([docs](https://docs.rke2.io/)) (server mode, installed via official Rancher script)

All major Kubernetes dependencies (e.g., socat, conntrack, iptables, etc.) are preinstalled, and the RKE2 unit is enabled on boot.

## 🛠️ GitHub Actions - CI/CD Pipeline

This project includes a GitHub Actions workflow: `.github/workflows/deploy-warewulf-rke2.yml`.

### 🔄 What It Does

* Builds the Docker image from the `Dockerfile`
* Logs into Docker Hub using stored GitHub Secrets
* Pushes the image tagged as the current branch (usually `latest`)

### ✅ Setting Up GitHub Secrets

To enable pushing to your Docker Hub:

1. Go to your fork's GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Add the following:

   * `DOCKER_HUB_REPO` → your Docker Hub repo. In this case: *rkhoja/warewulf-rke2* 
   * `DOCKER_HUB_USER` → your Docker Hub username
   * `DOCKER_HUB_TOKEN` → create a [Docker Hub access token](https://hub.docker.com/settings/security)

### 🚀 Manual Trigger & Auto-Build

* Manual: Run the workflow from the **Actions** tab with **Run workflow** (enabled via `workflow_dispatch`).
* Automatic: Any push to the `latest` branch triggers the CI/CD pipeline.

* **Recommended branching model:**
  * Work and test in `main`
  * Merge or fast-forward `main` to `latest` to trigger a production build

```bash
git checkout latest
git merge main
git push origin latest
```

## 🧪 How To Use This Image with Warewulf 4

Once you have Warewulf 4 setup on your control node:

```bash
warewulf import docker rkhoja/warewulf-rke2:latest --name=rke2-node
```

Then assign the image to a compute node:

```bash
wwctl node set n00[1-4] --container=rke2-node
wwctl configure -a
```

Finally boot the nodes via PXE.

RKE2 will auto-start via systemd and begin initializing the cluster once networking is available.

## 🤝 Support

Many Bothans died to bring us this information. This project is provided as-is, but reasonable questions may be answered based on my coffee intake or mood. ;)

Feel free to open an issue or email **[khoja1@ualberta.ca](mailto:khoja1@ualberta.ca)** or **[kali2@ualberta.ca](mailto:kali2@ualberta.ca)** for U of A related deployments.

## 📜 License

This project is released under the **MIT License** - one of the most permissive open-source licenses available.

**What this means:**
- ✅ Use it for anything (personal, commercial, whatever)
- ✅ Modify it however you want
- ✅ Distribute it freely
- ✅ Include it in proprietary software

**The only requirement:** Keep the copyright notice somewhere in your project.

That's it! No other strings attached. The MIT License is trusted by major projects worldwide and removes virtually all legal barriers to using this code.

**Full license text:** [MIT License](https://opensource.org/licenses/MIT)

## 🧠 About University of Alberta Research Computing

The [Research Computing Group](https://www.ualberta.ca/en/information-services-and-technology/research-computing/index.html) supports high-performance computing, data-intensive research, and advanced infrastructure for researchers at the University of Alberta and across Canada.

We help design and operate compute environments that power innovation — from AI training clusters to national research infrastructure.
