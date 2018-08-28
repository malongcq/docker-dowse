FROM dowse:latest

### https://aws.amazon.com/blogs/compute/creating-a-simple-fetch-and-run-aws-batch-job/
### use aws blog fetch and run approach to run scripts in s3
### may change to more complex aws codedeploy appspec format:
### https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html

COPY fetch_and_run.sh /workspace/fetch_and_run.sh

ENTRYPOINT ["/workspace/fetch_and_run.sh"]

