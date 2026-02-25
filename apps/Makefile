all:
	mkdir -p generated/
	jsonnet grafana.libsonnet -S -J vendor/ -m generated/
	jsonnet ./guestbook/main.libsonnet -S -J vendor/ -m generated/
