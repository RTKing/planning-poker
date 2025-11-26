# Builder: Installs dependencies and creates the runtime bundle
FROM node:20-alpine AS builder
WORKDIR /app

# Enable yarn and install dependencies
RUN corepack enable
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy source and default env (uses emulator-friendly values)
COPY . .
COPY .env.example .env
ENV VITE_USE_FIRESTORE_EMULATOR=true
RUN yarn build

# Runtime: Serves the built app and starts the Firestore emulator
FROM node:20-alpine
RUN apk add --no-cache openjdk17
RUN npm install -g firebase-tools serve

WORKDIR /app
COPY --from=builder /app/build /app/build
COPY firebase-emulators /app/firebase-emulators
COPY firebase.json /app/firebase.json

EXPOSE 8080
EXPOSE 4000
EXPOSE 3000

CMD ["sh", "-c", "firebase emulators:start --only firestore --project demo & npx serve -s build -l 3000"]
