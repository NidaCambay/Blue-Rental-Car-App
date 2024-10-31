FROM node:16.18
WORKDIR /app
COPY ./Task-3/bluerentalcars-frontend/package.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm","start"]