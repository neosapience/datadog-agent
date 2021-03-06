name := neosapience/datadog-agent
tag := 7.20.2-cu10.1

build:
	docker build . -t ${name}:${tag} -f docker/Dockerfile

sh:
	docker run --rm -it ${name}:${tag} bash

push:
	docker push ${name}:${tag}

ls:
	docker image ls ${name}
