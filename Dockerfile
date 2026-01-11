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

# Install resume-cli globally and theme locally
RUN npm install -g resume-cli && \
    npm install jsonresume-theme-stackoverflow

# Copy only resume.json
COPY resume.json .

# Generate HTML and PDF
RUN resume validate resume.json && \
    resume export resume.html --resume resume.json --theme stackoverflow && \
    resume export resume.pdf --resume resume.json --theme stackoverflow

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