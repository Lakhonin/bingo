## Overview
1 декабря, в 23:59 по московскому времени мы запускаем наш новый сервис - API хранилища истории сессий нашего онлайн кинотеатра «Фильмопоиск». Дату запуска сдвинуть нельзя, наш PR уже активно продвигает этот запуск. От тебя потребуется развернуть продуктовую инсталляцию этого сервиса.
Наш подрядчик "Horns&Hooves Soft inc" пишет для нас этот новый сервис. Неделю назад подрядчик провёл демонстрационную презентацию. На ней он показал почти корректно работающее приложение, и презентовал HTTP эндпоинт, который отвечает на **GET /ping** кодом **200**, если приложение работает корректно и кодом **500**, если нет.
Мы попросили внести небольшие изменения: нужно, чтобы запрос **GET /long_dummy** в 75% случаев работал быстрее секунды, при этом нас устроит закешированный ответ не старше минуты. На презентации он работал дольше. Кроме того, подрядчик сообщил, что потребуется внести некоторые технологические изменения для повышения удобства эксплуатации, а так же починить несколько некритичных багов для повышения стабильности в работе.
https://storage.yandexcloud.net/final-homework/bingo – вот ссылка на этот бинарник.
Твоя задача развернуть отказоустойчивую инсталляцию приложения из имеющегося бинарника до даты запуска продукта. Планируется стабильная нагрузка в **60 RPS**, пиковая в **120 RPS**.
## Requirements
- [x] Отказоустойчивость: сервис должен быть развернут на двух нодах, отказ любой из них должен быть незаметен пользователю. Допускается просадка по RPS до стабильного значения в момент отказа любой из нод. При живости обеих нод, инсталяция обязана выдерживать пиковую нагрузку. Так же нужно обеспечить восстановление работоспособности любой отказавшей ноды быстрее, чем  за минуту.
- [x] Сервис должен переживать пиковую нагрузку в 120 RPS в течение 1 минуты, стабильную в 60 RPS
- [x] Запросы POST /operation {"operation": <operation_id: integer>} должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за 400 миллисекунд в 90% случаев при 120 RPS, гарантируя не более 1% ошибок.
Запросы GET /db_dummy должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за 400 миллисекунд в 90% случаев при 120 RPS, гарантируя не более 1% ошибок.
- [x] Запросы GET /api/movie/{id} должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за 400 миллисекунд в 90%  случаев при 120 RPS, гарантируя не более 1% ошибок.
- [x] Запросы GET /api/customer/{id} должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за 400 миллисекунд в 90% случаев при 120 RPS, гарантируя не более 1% ошибок.
- [x] Запросы GET /api/session/{id} должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за 400 миллисекунд в 90%  случаев при 120 RPS, гарантируя не более 1% ошибок.
- [x] Запросы GET /api/movie должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя не более 1% ошибок. Требований по времени ответа нет, планируем делать не более одного такого запроса одновременно.
- [x] Запросы GET /api/customer должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя не более 1% ошибок. Требований по времени ответа нет, планируем делать не более одного такого запроса одновременно.
- [x] Запросы GET /api/session должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя не более 5% ошибок. Требований по времени  ответа нет, планируем делать не более одного такого запроса одновременно.
- [x] Запросы POST /api/session должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя не более 1% ошибок. Требований по  времени ответа и RPS нет.
- [x] Запросы DELETE /api/session/{id} должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя не более 1% ошибок. Требований по  времени ответа и RPS нет.
- [ ] Задача со звёздочкой: сделать так, чтобы сервис работал на отдельном домене по https протоколу, и по http без редиректа на https  (допускается самоподписанный сертификат).
- [ ] Задача со звёздочкой: сделать http3.
- [ ] Задача со звёздочкой: сделать так, чтобы запросы GET /long_dummy возвращали ответ не старше 1 минуты и отвечали быстрее, чем за 1 секунду в 75% случаев.
- [ ] Задача со звёздочкой: желательно обеспечить наблюдаемость приложения: графики RPS и ошибок по каждому эндпоинту.
- [x] Задача со звёздочкой: автоматизировать развёртывание при помощи devops инструментов, с которыми вы успели познакомиться ранее.

## Usage 
При запуске приложение выводит сообщение "Hello world"
Пробую ключ --help (-h) выводит дополнительную информацию:

```bash
$ ./bingo -h

Usage:
   [flags]
   [command]

Available Commands:
  completion           Generate the autocompletion script for the specified shell
  help                 Help about any command
  prepare_db           prepare_db
  print_current_config print_current_config
  print_default_config print_default_config
  run_server           run_server
  version              version
  
Flags:
  -h, --help   help for this command

Use " [command] --help" for more information about a command.
```
Необходимо запустить приложение с ключом **run_server**.

```bash
$ ./bingo print_current_config

panic: failed to read config data
        /home/vgbadaev/go/pkg/mod/github.com/spf13/cobra@v1.7.0/command.go:992
        /build/cmd/bingo/main.go:22 +0x85
```
Запускаю через strace:
```bash
$ strace ./bingo print_current_config
```
Обращение к несуществующему файлу:
```bash
openat(AT_FDCWD, "/opt/bingo/config.yaml", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
```
Как он должен выглядеть помогает команда:
```bash
$ ./bingo print_default_config

student_email: test@example.com
postgres_cluster:
  hosts:
  - address: localhost
    port: 5432
  user: postgres
  password: postgres
  db_name: postgres
  ssl_mode: disable
  use_closest_node: false
```
Создаем тестовую БД

```hcl 
## terraform/main.tf
resource "yandex_mdb_postgresql_cluster" "pg" {
  folder_id = yandex_resourcemanager_folder.folder.id
  name                = "bingopg"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.network.id
  security_group_ids  = [ yandex_vpc_security_group.pgsql-sg.id ]
  deletion_protection = false

  config {
    version = 16
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = "20"
    }
  }

  host {
    zone      = "ru-central1-a"
    name      = "pg-host-a"
    subnet_id = yandex_vpc_subnet.subnet.id
  }
}
```

Пробую запустить приложение с ключом prepare_db
```bash
$ strace ./bingo prepare_db
```

Ждём какое-то время, по окончании смотрим, что за данные:

```bash
bingo=# \dt
             List of relations
 Schema |       Name        | Type  | Owner
--------+-------------------+-------+-------
 public | customers         | table | bingo
 public | movies            | table | bingo
 public | schema_migrations | table | bingo
 public | sessions          | table | bingo
(4 rows)

bingo=# select count(*) from sessions;
  count
---------
 5000000
(1 row)

bingo=# \d sessions;
                                         Table "public.sessions"
   Column    |            Type             | Collation | Nullable |               Default
-------------+-----------------------------+-----------+----------+--------------------------------------
 id          | bigint                      |           | not null | nextval('sessions_id_seq'::regclass)
 start_time  | timestamp without time zone |           | not null |
 customer_id | integer                     |           | not null |
 movie_id    | integer                     |           | not null |
```
Видим много данных и отсутствие индексов 
Пробуем запустить с ключем **run_server**
```bash
$  ./bingo run_server 
error
```
Пробуем запустить с strace 
```bash
$ strace ./bingo run_server

openat(AT_FDCWD, "/opt/bongo/logs/3a956b711f/main.log", O_WRONLY|O_CREAT|O_APPEND|O_CLOEXEC, 0666) = -1 ENOENT (No such file or directory)
```

Делаем необходимые директории 

```bash
mkdir -p /opt/bongo/logs/3a956b711f/
chown -R bingoservice:bingousers /opt/bongo
```

Снова пробую запустить с ключем **run_server**

```bash
$ ./bingo run_server

My congratulations.
You were able to start the server.
Here's a secret code that confirms that you did it.
--------------------------------------------------
code:         yoohoo_server_launched
--------------------------------------------------
```

На каком порту сидит приложение.
```bash
$ sudo netstat -lntup

tcp6       0      0 :::27352                 :::*                    LISTEN      16842/./bingo
```
## Building
Приложение bingo собирается в docker-контайтере с помощью gitlab ci/cd.
```docker
FROM alpine:3.15.0
WORKDIR /app 
RUN addgroup --system bingousers \
    mkdir -p /app/.postgresql \
    && wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
    --output-document /app/.postgresql/root.crt \
    && adduser -S -s /bin/false -G bingousers bingoservice -D -H \
    && apk add --no-cache postgresql-client curl \
    && curl -O https://storage.yandexcloud.net/final-homework/bingo \
    && mkdir -p /opt/bongo/logs/3a956b711f/ && chown -R bingoservice:bingousers /opt/bongo \
    && chown -R bingo:bingo /app \
    && chmod 0600 /bin/.postgresql/root.crt
USER bingoservice
EXPOSE 27352
ENTRYPOINT ["/opt/bingo/bingo", "run_server"]

```
Используем kaniko
```bash
##.gitlab-ci.yml
- /kaniko/executor --cache-repo=$CI_REGISTRY_IMAGE/bingo/cache --cache=true --context "${CI_PROJECT_DIR}/bingo" --dockerfile "${CI_PROJECT_DIR}dockerfile" --destination "$CI_REGISTRY_IMAGE/bingo:$CI_COMMIT_SHA" --registry-mirror mirror.gcr.io --registry-mirror index.docker.io
```
## Troubleshooting
Смотрим что приложение пишет в лог:

```bash
$ awk -F "," '{print $4}' /opt/bongo/logs/3a956b711f/main.log
```
```bash
>"msg":"Started updating nodes."
>"msg":"Node is alive."
>"msg":"Started updating nodes."
>"msg":"Notified all waiters."
```

Смотрим в лог 
```bash
$ tcpdump -i wlp2s0 -s 65535 -w bingo.dmp
```
Находим что приложение лезет на днс гугл'а, пробую блокировать 8.8.8.8
```bash
$ ip route add blackhole 8.8.8.8/32
```
Запускаем приложение, стартует и отдает третий код:
```bash
google_dns_is_not_http.
```
Ускоряем выполнение запросов в БД
```sql
CREATE INDEX movieid_idx ON movies (id);
CREATE INDEX customerid_idx ON customers (id);
CREATE INDEX sessionid_idx ON sessions (id);
```

## Release Notes
Can be found in [RELEASE_NOTES](RELEASE_NOTES.md).

## Authors
* Aleksandr Lakhonin - [lakhonin](https://github.com/lakhonin)

## Contributing
Please, follow [Contributing](CONTRIBUTING.md) page.

## Code of Conduct
Please, follow [Code of Conduct](CODE_OF_CONDUCT.md) page.

## License
This project is MIT License - see the [LICENSE](LICENSE) file for details