.PHONY: container-image
container-image:
	docker build -t amostutorial .

PHONY: run
run:
	docker run -it -p 8080:8080/tcp --rm amostutorial
