all:
	mkdir -p generated/
	jsonnet grafana.libsonnet -S -J vendor/ -m generated/
	jsonnet ./guestbook/redis.libsonnet -S -J vendor/ -m generated/
