import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: 'build',
  },
  optimizeDeps: {
    include: ['@fortawesome/fontawesome-svg-core'], // Include Font Awesome in the optimization step.
  },
});

