# Cloud-hosted website

## Deploy without Google Cloud billing

Render can host the website without attaching a Google Cloud billing account.

1. Create a GitHub repository and push this folder to it.
2. Sign in to Render at https://dashboard.render.com/
3. Choose **New > Blueprint**, connect the GitHub repository, and select this repository.
4. Render reads `render.yaml` and creates the `northstar-studio` service.
5. Enter these environment values in Render's service settings:
   - `SMTP_USER`: `joshwoods9115@gmail.com`
   - `SMTP_PASSWORD`: Gmail App Password (16 characters)
   - `CONTACT_TO`: `joshwoods9115@gmail.com`
6. Deploy the service and open the `*.onrender.com` URL it provides.

The free Render service may sleep after inactivity, then take several seconds to wake on
the first request. The laptop does not need to remain on after deployment.

This app is a dependency-free Python website that runs on Google Cloud Run. Google SMTP
is used for contact-form delivery, so the website can remain online when the development
laptop is switched off.

## Google Cloud setup

1. Install the Google Cloud CLI and authenticate:
   `gcloud auth login`
2. Enable the required APIs:
   `gcloud config set project nice-proposal-442209-n4`
   `gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com secretmanager.googleapis.com`
3. Create Gmail App Password credentials in Google Account security. Normal Gmail passwords
   do not work for SMTP.
4. Store credentials in Secret Manager (replace the placeholder values once):
   `printf %s "your-address@gmail.com" | gcloud secrets create SMTP_USER --data-file=-`
   `printf %s "your-app-password" | gcloud secrets create SMTP_PASSWORD --data-file=-`
   `printf %s "your-address@gmail.com" | gcloud secrets create CONTACT_TO --data-file=-`
5. Build and deploy:
   `gcloud builds submit --config cloudbuild.yaml`
   Then add the secrets to the Cloud Run service from the Google Cloud Console:
   Cloud Run > hostable-site > Edit & Deploy New Revision > Security > Secrets.

Or run the complete deployment as this gcloud command:

```powershell
gcloud run deploy hostable-site `
  --source . `
  --region us-central1 `
  --allow-unauthenticated `
  --set-secrets SMTP_USER=SMTP_USER:latest,SMTP_PASSWORD=SMTP_PASSWORD:latest,CONTACT_TO=CONTACT_TO:latest
```

## Gmail limitations

Google Workspace and Gmail SMTP require 2-Step Verification and an App Password. SMTP is
available on `smtp.gmail.com` port `465` with implicit TLS. The sender must be a real
Gmail or Workspace address supplied through `SMTP_USER`.

## Run locally

Copy `.env.example` to the environment variables of your terminal, then run:
`python server.py`
