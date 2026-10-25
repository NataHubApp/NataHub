import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// GitHub Pages project site for https://NataHubApp.github.io/NataHub/
export default defineConfig({
  plugins: [react()],
  base: '/NataHub/',
});
