FROM nginx:alpine

# Usuniecie domyslnej konfiguracji nginxa
RUN rm /etc/nginx/conf.d/default.conf

# Skopiowanie unikalnej konfiguracji
COPY custom.conf /etc/nginx/conf.d/

# Skopiowanie strony HTML
COPY index.html /usr/share/nginx/html/

# Expose portu
EXPOSE 8888