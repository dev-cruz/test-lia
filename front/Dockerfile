FROM node:22.12.0
RUN apt-get update -qq && apt-get install -y build-essential
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .