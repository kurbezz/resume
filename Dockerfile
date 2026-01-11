FROM node:20-alpine AS builder

WORKDIR /app

# Install resume-cli globally
RUN npm install -g resume-cli

# Copy only resume.json
COPY resume.json .

# Generate HTML and PDF
RUN resume validate resume.json && \
    resume export resume.html --resume resume.json && \
    resume export resume.pdf --resume resume.json || true

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