import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// 5175 para no chocar con portfolio (5174) ni programming-web (5173)
const port = Number(process.env.PORT) || 5175

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: { port },
})
