# (rm -fv $KIRA_INFRA/docker/validator/Dockerfile) && nano $KIRA_INFRA/docker/validator/Dockerfile
FROM localhost:5000/tools-image:latest

ARG BUILD_HASH
ARG BRANCH
ARG CHECKOUT
ARG REPO

ENV SEKAI="${GOPATH}/src/github.com/kiracore/sekai"
ENV SEKAID_BIN="${GOBIN}/sekaid"
ENV SEKAICLI_BIN="${GOBIN}/sekaicli"

RUN echo "Build hash: ${BUILD_HASH}"

RUN ${SELF_SCRIPTS}/git-pull-v0.0.1.sh "${REPO}" "${BRANCH}" "${CHECKOUT}" "${SEKAI}"
RUN cd ${SEKAI} && make install
RUN sekaid version --long

ADD ./scripts ${SELF_SCRIPTS}
ADD ./configs ${SELF_CONFIGS}
ADD ./container ${SELF_CONTAINER}

RUN chmod 777 -R ${SELF_HOME}

ARG DEBIAN_FRONTEND=noninteractive
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive ${BUILD_SCRIPT}

RUN printenv

HEALTHCHECK --interval=60s --timeout=600s --start-period=300s --retries=3 CMD ${HEALTHCHECK_SCRIPT} $>> ${SELF_LOGS}/healthcheck_script_output.txt

CMD ["sh", "-c", "/bin/bash ${START_SCRIPT}"]

