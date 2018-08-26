FROM ubuntu:18.04

#---1. apt-get init.
RUN apt-get clean && apt-get update -y && apt-get upgrade -y

#---2. install tools
RUN apt-get install -y build-essential unzip unrar
RUN apt-get install -y wget curl gnupg gnupg2 openssl

#---3. postgesql, mysql
##RUN apt-get install -y libaio1 libaio-dev libssl1.0.0 libssl1.0-dev
RUN apt-get install -y postgresql-client libpq-dev
RUN apt-get install -y mysql-client libmysqlclient-dev

#---4. Oracle
#### https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
### use /opt for optional tools though they are compulsory
RUN apt-get install -y libaio1 libaio-dev
RUN mkdir /opt/ora
COPY instantclient_12_2 /opt/ora/instantclient_12_2
ARG ORACLE_HOME=/opt/ora/instantclient_12_2

#---5. MS SQL server, odbc
RUN apt-get install -y freetds-bin freetds-dev unixodbc unixodbc-dev tdsodbc

#---5. microsoft, not works at this moment, always 'login failed' but FreeTDS works, linux ODBC may be problem
### add microsoft ubuntu library for SQL server tools
### https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
### use 'ldd /opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.2.so.0.1' to check odbc lib dep. libs are exist
RUN curl -s https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl -s https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update -y
RUN apt-get install -y locales libssl1.0.0 libssl1.0-dev
RUN locale-gen en_US.UTF-8
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
ARG MSSQL_HOME=/opt/mssql-tools/bin

#---6. python & libs
RUN apt-get install -y python3 python3-pip cython3
### install python libraries via pip
RUN pip3 install --upgrade pip
RUN pip3 install boto3 awscli
RUN pip3 install pandas xlrd
RUN pip3 install SQLAlchemy
RUN pip3 install psycopg2-binary
RUN pip3 install cx_Oracle
RUN pip3 install mysql-connector-python
##RUN pip3 install pyodbc
RUN PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1 pip3 install pymssql
##RUN pip3 install pymssql

#---7. create env. vars and dirs
RUN mkdir /workspace
WORKDIR /workspace
ENV ORACLE_HOME=${ORACLE_HOME}
ENV PATH="${ORACLE_HOME}:${MSSQL_HOME}:${PATH}"
ENV LD_LIBRARY_PATH="${ORACLE_HOME}:${LD_LIBRARY_PATH}"

### later define which user to run jobs, temp. using "root" but may not be a good option
#USER nobody

### https://aws.amazon.com/blogs/compute/creating-a-simple-fetch-and-run-aws-batch-job/
### use aws blog fetch and run approach to run scripts in s3
### may change to more complex aws codedeploy appspec format: 
### https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html
#COPY fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
#ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]

