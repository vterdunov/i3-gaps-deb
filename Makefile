debian:
	docker build -t i3-gaps:build .
	rm -rf build-result
	CID=$(shell docker run --rm -d i3-gaps:build sleep 10); \
	docker cp $$CID:/build-result/ . ; \
	docker kill $$CID
