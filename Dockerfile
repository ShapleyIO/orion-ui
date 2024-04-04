FROM node:lts-bookworm as base

RUN mkdir ~/.ssh
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts \
    git config --global url."git@github.com".insteadOf "https://github.com"

ENV PROJECT shapley-iam-ui
WORKDIR /src/github.com/ShapleyIO/$PROJECT
RUN git config --global --add safe.directory /src/github.com/ShapleyIO/$PROJECT

FROM base as builder
COPY . .
RUN npm run build

FROM nginx:stable-alpine as iam-ui
COPY --from=builder /src/github.com/ShapleyIO/shapley-iam-ui/dist /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]