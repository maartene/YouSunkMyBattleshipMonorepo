
FROM node:18-alpine
WORKDIR /app

# Install production dependencies
COPY package.json .
RUN npm install --only=production

# Copy app and expose port
COPY server.js .
ENV PORT=8080
EXPOSE 8080

CMD ["node", "server.js"]

