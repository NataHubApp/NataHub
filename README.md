# NataHub — Inventory Management for UMKM

Responsive React + Vite website for small business inventory management. The product branding is **NataHub**.

## Features
- Register/login UI with Supabase Auth support
- Interactive demo mode (no backend needed to preview the UI)
- Dashboard, inventory list, search and filters
- Add/edit/delete products
- Stock-in and stock-out tracking
- Low-stock and restock list
- Responsive layout and custom NataHub favicon

## Upload to GitHub
Upload the **contents of this folder** into the root of the repository `NataHub` under the `NataHubApp` owner. Do not upload the outer ZIP or a wrapper folder.

The repository should have this structure:

```text
NataHub/
├── .github/workflows/deploy.yml
├── public/natahub-icon.svg
├── src/main.jsx
├── src/styles.css
├── src/supabase.js
├── .env.example
├── index.html
├── package.json
├── supabase-schema.sql
└── vite.config.js
```

## GitHub Pages deployment
1. In repository **Settings → Pages**, set the build source to **GitHub Actions**.
2. Push/commit these files to the `main` branch.
3. Open the **Actions** tab and wait for **Deploy NataHub to GitHub Pages** to finish.
4. For repository `NataHub` owned by `NataHubApp`, the expected URL is `https://natahubapp.github.io/NataHub/`.

## Demo vs. real accounts
The demo button works without Supabase and uses temporary sample data. Real registration/login and permanent data need a Supabase project.

1. Create a project at https://supabase.com/.
2. Run `supabase-schema.sql` in Supabase SQL Editor.
3. Add repository secrets under **Settings → Secrets and variables → Actions**:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. In Supabase Authentication URL configuration, add the deployed website URL as the Site URL / allowed redirect URL.

Only use the public anon/publishable key in the frontend. **Never put a Supabase `service_role` key in this repository.**

## Run locally
Requires Node.js 20+.

```bash
npm install
npm run dev
```

For local builds, `vite.config.js` uses the GitHub Pages `/NataHub/` base path, so open the site via the Vite server root and keep the repository deployment path in mind. For hosting at a custom domain/root, change `base` to `/`.
