
all : emacs-badge-module.so
CC=clang -framework AppKit

debug: CFLAGS += -DDEBUG -g
debug: emacs-badge-module.so

emacs-badge-module.so : emacs-badge-module.m
	$(CC) -shared $(CFLAGS) $(LDFLAGS) -o $@ $^

clean :
	$(RM) emacs-badge-module.so

.PHONY : clean all
