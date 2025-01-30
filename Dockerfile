FROM --platform=linux/amd64 node:20-alpine
LABEL org.opencontainers.image.source https://github.com/spielhoelle/GoldanGai_NFTBuilding
RUN npm install -g pnpm
# RUN apk add --no-cache openssl
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
# RUN npx prisma generate

ARG REPLICATE_API_TOKEN
ENV REPLICATE_API_TOKEN ${REPLICATE_API_TOKEN}

ARG PINATA_GROUP
ENV PINATA_GROUP ${PINATA_GROUP}

ARG PINATA_KEY_ID
ENV PINATA_KEY_ID ${PINATA_KEY_ID}

ARG PINATA_SECRET_KEY
ENV PINATA_SECRET_KEY ${PINATA_SECRET_KEY}

ARG ADDRESS_OWNER
ENV ADDRESS_OWNER ${ADDRESS_OWNER}

ARG MINTING_PRICE
ENV MINTING_PRICE ${MINTING_PRICE}

ARG CONTRACT_ADDRESS
ENV CONTRACT_ADDRESS ${CONTRACT_ADDRESS}

ARG CONTRACT_ARTIFACT
ENV CONTRACT_ARTIFACT ${CONTRACT_ARTIFACT}

RUN pnpm build
EXPOSE 3000
CMD ["pnpm", "run", "start"]
