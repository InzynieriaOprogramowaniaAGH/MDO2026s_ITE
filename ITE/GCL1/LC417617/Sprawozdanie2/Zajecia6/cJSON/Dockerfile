FROM alpine:3.19 AS base
RUN apk add --no-cache libgcc

FROM base AS build
RUN apk add --no-cache gcc g++ make cmake
WORKDIR /app
COPY . .
RUN mkdir build && cd build && cmake .. -DENABLE_CJSON_TEST=On && make

FROM build AS test
WORKDIR /app/build
RUN ctest --output-on-failure

FROM base AS deploy
WORKDIR /app
COPY --from=build /app/build/cJSON_test /app/cJSON_test
COPY --from=build /app/build/libcjson.* /usr/lib/
CMD ["./cJSON_test"]
