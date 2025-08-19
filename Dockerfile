#################
#  Base layer   #
#################
FROM alpine:edge AS runtime-base

# Install runtime dependencies
RUN apk add --no-cache bash curl jq

WORKDIR /app

#################
#  Test image   #
#################
FROM node:24-alpine AS test-env

# Install dependencies needed for testing the script
RUN apk add --no-cache bash curl jq

WORKDIR /app

# Install all Node dependencies
COPY package.json /app/
COPY package-lock.json /app/
RUN npm ci

# Copy source code
COPY . /app/

# Perform tests when running this test-env container
CMD ["npm", "test"]

#################
# Runtime image #
#################
FROM runtime-base AS runtime

COPY ./src/gitlab-fetches.sh .

ENTRYPOINT ["./gitlab-fetches.sh"]
CMD ["--help"]
