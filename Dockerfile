FROM node:20-alpine AS builder

WORKDIR /app

# Set environment variables to skip Puppeteer download
ENV PUPPETEER_SKIP_DOWNLOAD=true

# Install resume-cli globally and theme locally
RUN npm install -g resume-cli && \
    npm install jsonresume-theme-stackoverflow

# Copy only resume.json
COPY resume.json .

# Generate HTML
RUN resume validate resume.json && \
    resume export resume.html --resume resume.json --theme stackoverflow

# Production stage with nginx
FROM nginx:alpine

# Copy generated files to nginx html directory
COPY --from=builder /app/resume.html /usr/share/nginx/html/index.html
COPY --from=builder /app/resume.json /usr/share/nginx/html/resume.json

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]