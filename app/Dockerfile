FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY server.js .
USER 10001
EXPOSE 3000
CMD ["node", "server.js"]
