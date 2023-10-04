.PHONY: container-image
container-image:
	docker build -t amostutorial .

PHONY: run
run:
	docker run -it -p 8080:8080/tcp --rm amostutorial

.PHONY:
build-binary-nix:
	nix build

# does not work - no crosscompilation
.PHONY: build-container-nix
build-container-nix:
	nix build .#dockerImage

.PHONY: develop
develop:
	nix develop

build-container-nix-inside:
	docker build -t amostutorial-nix . -f Dockerfile.flake
