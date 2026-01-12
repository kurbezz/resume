FROM node:20-alpine AS builder

WORKDIR /app

# Install Chromium and required dependencies for PDF generation
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Create a wrapper script for Chromium that adds required flags
RUN echo '#!/bin/sh' > /usr/local/bin/chromium-wrapper && \
    echo 'exec /usr/bin/chromium-browser --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu "$@"' >> /usr/local/bin/chromium-wrapper && \
    chmod +x /usr/local/bin/chromium-wrapper

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/local/bin/chromium-wrapper

# Install resume-cli globally
RUN npm install -g resume-cli

# Install the theme
RUN npm install @jsonresume/jsonresume-theme-consultant-polished

# Install Babel and dependencies for transpiling JSX
RUN npm install --save-dev \
    @babel/core \
    @babel/cli \
    @babel/preset-react \
    @babel/preset-env \
    @babel/plugin-transform-runtime \
    @babel/runtime

# Install React and styled-components (required by the theme)
RUN npm install react react-dom styled-components

# Create babel config with automatic JSX runtime
RUN echo '{ \
  "presets": [ \
    ["@babel/preset-env", { "targets": { "node": "current" } }], \
    ["@babel/preset-react", { "runtime": "automatic" }] \
  ], \
  "plugins": [ \
    ["@babel/plugin-transform-runtime", { "regenerator": true }] \
  ] \
}' > babel.config.json

# Transpile the theme in-place with proper React support
RUN npx babel node_modules/@jsonresume/jsonresume-theme-consultant-polished/src \
    --out-dir node_modules/@jsonresume/jsonresume-theme-consultant-polished/src \
    --config-file ./babel.config.json

# Copy only resume.json
COPY resume.json .

# Generate HTML and PDF using the transpiled theme
RUN resume validate resume.json && \
    resume export resume.html --resume resume.json --theme @jsonresume/jsonresume-theme-consultant-polished && \
    (resume export resume.pdf --resume resume.json --theme @jsonresume/jsonresume-theme-consultant-polished || echo "PDF generation failed, creating placeholder") && \
    if [ ! -f resume.pdf ]; then touch resume.pdf; fi

# Production stage with nginx
FROM nginx:alpine

# Copy generated files to nginx html directory
COPY --from=builder /app/resume.html /usr/share/nginx/html/index.html
COPY --from=builder /app/resume.pdf /usr/share/nginx/html/resume.pdf
COPY --from=builder /app/resume.json /usr/share/nginx/html/resume.json

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]