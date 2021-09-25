prefix=/usr/local
confdir=/etc
systemd_dir=${DESTDIR}${confdir}/systemd/system
nginx_dir=${DESTDIR}${confdir}/nginx
bindir=${DESTDIR}${prefix}/bin

MAX_SIZE 	?= 52428800 # default 50mb
CC			?= gcc
CFLAGS		:= -O2 -DMG_MAX_RECV_BUF_SIZE=${MAX_SIZE} ${CFLAGS}

BIN			:= trance

SOURCE	:= main.c mongoose.c
OBJ		:= mongoose.o main.o
DEPS	:= mongoose.h index.h
LIBS	:= -lcrypt

all: $(BIN)

clean:
	rm -f $(OBJ)

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

install-nginx:
	@install -Dm644 doc/trance.nginx ${nginx_dir}/sites-available/trance

install-systemd:
	@install -Dm644 doc/trance.service ${systemd_dir}/trance.service
	@install -Dm644 doc/trance.conf ${DESTDIR}/${confdir}/trance.conf

install-bin:
	@install -Dm755 ${BIN} ${bindir}/${BIN}

install: install-bin install-nginx install-systemd
