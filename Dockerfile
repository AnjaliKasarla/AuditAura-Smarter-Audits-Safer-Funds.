# ---------- Build Stage ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy only dependency files first
COPY package.json package-lock.json ./

# Use npm ci (faster + deterministic)
RUN npm ci --no-audit --no-fund

# Copy rest of the source
COPY . .

# Build Vite app
RUN npm run build

# ---------- Production Stage ----------
FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

