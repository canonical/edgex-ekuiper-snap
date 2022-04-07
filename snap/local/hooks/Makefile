HOOKS=cmd/configure/configure

tidy:
	go mod tidy

build: tidy $(HOOKS)

cmd/configure/configure:
	go build -o $@ ./cmd/configure

clean:
	rm -f $(HOOKS)