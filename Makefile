VERSION ?= gaps-next

.PHONY: deb
deb:
	docker build -t i3-gaps:build --build-arg=VERSION=$(VERSION) ./
	rm -rf dist
	CID=$$(docker run --rm -d i3-gaps:build sleep 10) && \
	docker cp $$CID:/dist/ . && \
	docker kill $$CID
