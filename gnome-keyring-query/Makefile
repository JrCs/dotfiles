#
# Packages required: glib2-devel libgnome-keyring-devel
#

all: gnome-keyring-query

gnome-keyring-query: gnome-keyring-query.c
	gcc `pkg-config --cflags --libs gnome-keyring-1 glib-2.0` -o gnome-keyring-query gnome-keyring-query.c

clean:
	@rm -f gnome-keyring-query
