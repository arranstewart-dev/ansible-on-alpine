
default:
	echo pass

NAME=phlummox/ansible

IMAGE_VERSION=0.1
TAG=$(IMAGE_VERSION)

MOUNT=-v ~/dev:/home/dev -v $$PWD:/opt/docker-dir

print_tag:
	@echo $(TAG)

print_img:
	@echo $(NAME)

# BUILD_DATE=`date -u +'%Y-%m-%dT%H:%M:%SZ'`

docker-build:
	docker build -f Dockerfile \
			--target builder \
			--cache-from=$(NAME):$(TAG) \
			--cache-from=$(NAME):latest \
			--cache-from=$(NAME):$(TAG)-builder \
			--tag $(NAME):$(TAG)-builder .
	set -ex; \
	export GIT_REF=`git rev-parse HEAD`; \
	export GIT_COMMIT_DATE="`git show -s --format=%ci $$GIT_REF`" ; \
	docker build -f Dockerfile \
			--build-arg GIT_REF=$$GIT_REF \
			--build-arg GIT_COMMIT_DATE="$$GIT_COMMIT_DATE" \
			--build-arg VERSION=$(IMAGE_VERSION) \
			--target production \
			--cache-from=$(NAME):latest \
			--cache-from=$(NAME):$(TAG)-builder \
			--cache-from=$(NAME):$(TAG) \
			--tag $(NAME):$(TAG) .
	echo "docker build commands all done, now tagging"
	docker tag $(NAME):$(TAG) $(NAME):latest

REMOVE_AFTER=--rm

docker-run:
	docker -D run -it $(REMOVE_AFTER) --net=host \
	    $(MEMORY) $(CPU) $(SECURITY) $(MOUNT)     \
	      --name ansible-on-alpine $(NAME):$(TAG)

