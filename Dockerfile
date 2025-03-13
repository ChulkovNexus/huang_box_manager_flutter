# Environemnt to install flutter and build web
FROM debian:latest AS build-env

# install all needed stuff
RUN apt-get update
RUN apt-get install -y curl git unzip

# define variables
ARG FLUTTER_SDK=/usr/local/flutter
ARG APP=/app/

#clone flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK

ARG FLUTTER_VERSION=3.29.0

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# change dir to current flutter folder and make a checkout to the specific version
#RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

RUN flutter channel stable
RUN flutter upgrade

# Start to run Flutter commands
# doctor to see if all was installes ok
RUN flutter doctor -v

# create folder to copy source code
RUN mkdir $APP
# copy source code to folder
COPY . $APP
# stup new folder as the working directory
WORKDIR $APP

# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN flutter clean
RUN flutter pub get
RUN flutter gen-l10n
RUN flutter pub run build_runner build --delete-conflicting-outputs
RUN flutter build web --target=lib/entry_points/prod_main.dart --release

#RUN flutter build web

# Этап сервинга
FROM nginx:alpine

# Копируем собранный фронт в nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Удаляем дефолтный конфиг и пишем свой для SPA
RUN rm /etc/nginx/conf.d/default.conf && \
    cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF
# Открываем порт для доступа
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
