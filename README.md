# GCP DM Templates for NebulaGraph

This repository contains the templates for deploying Nebula Graph on GCP using [Google Cloud Deployment Manager](https://cloud.google.com/deployment-manager/).

## Environment Setup
At first, you will need a GCP account, then you can open in google cloud console here.

[![Open in Google Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/kqzh/nebula-dm.git)

Now, you need a copy of this repo. Run the commands:
```shell
git clone https://github.com/kqzh/nebula-dm.git
cd nebula-dm
```

## Creating a Deployment

Set which project you want to deploy in.
```shell
gcloud config set project <your-gcp-project>
```

This repo contains two config plans. You can deploy with any of them using command below.
```shell
gcloud deployment-manager deployments create <your-deployment-name> --config parameters.standard.yaml
```
The command then passes the cluster configuration to GCP and builds your NebulaGraph Cluster automatically.

## Deleting a Deployment
To delete your deployment you can either run the command below or use the GUI in the [Google Cloud Console](https://console.cloud.google.com/dm/deployments).
```shell
gcloud deployment-manager deployments delete <your-deployment-name>
```