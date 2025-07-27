# Use official NGINX image
FROM nginx:alpine

# Copy your static files to NGINX's default public directory
COPY www /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX (already default CMD in base image)
