VERSION=0.1.0
USER=bells17
REPOSITORY=terraform-diff

all: init package	

init: deq ghr
	
deq:
	go get -u github.com/golang/dep/cmd/dep

package:
	dep ensure

ghr:
	go get -u github.com/tcnksm/ghr

build:
	go build -ldflags '-X main.BuildVersion=${VERSION}' -o bin/${REPOSITORY}

install:
	go install -ldflags '-X main.BuildVersion=${VERSION}'

fmt:
	go fmt ./...

build-cross:
	GOOS=linux GOARCH=amd64 go build -ldflags '-X main.BuildVersion=${VERSION}' -o bin/${REPOSITORY}-linux-amd64
	GOOS=darwin GOARCH=amd64 go build -ldflags '-X main.BuildVersion=${VERSION}' -o bin/${REPOSITORY}-darwin-amd64

dist: build-cross
	cd bin && \
		tar cvf release/${REPOSITORY}-linux-amd64-${VERSION}.tar ${REPOSITORY}-linux-amd64 && \
		zopfli release/${REPOSITORY}-linux-amd64-${VERSION}.tar && \
		rm release/${REPOSITORY}-linux-amd64-${VERSION}.tar
	cd bin && \
		tar cvf release/${REPOSITORY}-darwin-amd64-${VERSION}.tar ${REPOSITORY}-darwin-amd64 && \
		zopfli release/${REPOSITORY}-darwin-amd64-${VERSION}.tar && \
		rm release/${REPOSITORY}-darwin-amd64-${VERSION}.tar

clean:
	rm -f bin/${REPOSITORY}*
	rm -f bin/release/${REPOSITORY}*

tag:
	git checkout master
	git tag v${VERSION}
	git push origin v${VERSION}
	git push origin master

release: clean dist
	rm -f bin/release/.gitkeep && \
		ghr -u ${USER} -r ${REPOSITORY} ${VERSION} bin/release && \
		touch bin/release/.gitkeep
