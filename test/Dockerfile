FROM openlmis/run-sql

RUN apk update && \
  apk add coreutils

COPY execute-test.sh /execute-test.sh
COPY prepare.sh /prepare.sh
COPY migrate.sh /migrate.sh
COPY validate.sh /validate.sh

COPY test-data.csv /test-data.csv

RUN chmod u+x /*.sh

CMD /execute-test.sh
