
# ---- Base Stage ----
FROM node:20-slim AS base
WORKDIR /usr/src/app

# ---- Dependencies Stage ----
# First, install dependencies and generate the Prisma Client.
FROM base AS deps
COPY prisma ./prisma/
COPY package.json package-lock.json ./
RUN npm ci --only=production


# ---- Builder Stage ----
# Use the dependencies from the previous stage to build the app.
FROM base AS builder
COPY . .
COPY --from=deps /usr/src/app/node_modules ./node_modules
RUN npm install 
RUN npx prisma generate
RUN npm run build

# ---- Production Stage ----
# Create the final, small image.
FROM base AS production
ENV NODE_ENV=production

# Copy the built application from the builder stage.
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/generated ./generated
# Copy the prisma schema and the production node_modules.
# Critically, this includes the generated Prisma client.
COPY --from=builder /usr/src/app/prisma ./prisma
COPY --from=builder /usr/src/app/node_modules ./node_modules

EXPOSE 4000

# This command runs the application.
CMD ["node", "dist/main.js"]

