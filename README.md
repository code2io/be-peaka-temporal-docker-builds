# Docker custom temporal image build

1. Run `make` to install submodules.
2. Change woking directory to `temporal/`
3. Checkout to desired version.
4. Go back to root directory.
5. Run `make amd64-bins` and (or) `make arm64-bins`
6. Update the user id and group in server.Dockerfile, e.g., 1000810000.
7. Build the image with `server.Dockerfile` file adding the same user id and version of temporal in the tag. E.g:
 ```sh
 docker buildx build . -t code2io/temporal-server:1.22.4-1000810000 -f server.Dockerfile --push --platform linux/amd64,linux/arm64
 ```
 