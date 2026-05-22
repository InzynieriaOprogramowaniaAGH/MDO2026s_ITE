#include <stdio.h>
#include <hiredis/hiredis.h>

int main() {
    redisContext *c = redisConnect("redis-server", 6379);
    if (c == NULL || c->err) {
        printf("BŁĄD: Nie można połączyć się z Redisem: %s\n", c ? c->errstr : "Błąd alokacji");
        return 1;
    }
    redisReply *reply = redisCommand(c, "PING");
    printf("Wynik testu: %s\n", reply->str);
    freeReplyObject(reply);
    redisFree(c);
    return 0;
}
