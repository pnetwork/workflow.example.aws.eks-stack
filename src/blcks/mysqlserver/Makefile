.PHONY: pre-build

pre-build:
	mkdir -p template && \
	ofsm template -l python3_blcks_flask template && \
	faas-cli build --name=mysqlserver --lang=python3_blcks_flask --image=mysqlserver --handler=handler --shrinkwrap && \
	cp *.para build/mysqlserver