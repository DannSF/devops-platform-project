FROM node:22-slim

WORKDIR /app

COPY app/package.json app/pnpm-lock.yaml ./

RUN corepack enable && pnpm install --frozen-lockfile --prod

COPY --chown=node:node app/ .

USER node

EXPOSE 3000

CMD [ "node", "server.js" ]


