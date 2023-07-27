# Steps

1. Run terraform.

   `terraform apply`

2. To export Kubernetes context you can use aws eks ... command; just replace region and name of the cluster.

   `> aws eks --region us-east-1 update-kubeconfig --name demo`

3. To check connection to EKS cluster run the following command:

    `> kubectl get svc`

4. Next is to create a pod to test IAM roles for service accounts. First, we are going to omit annotations to bind the service account with the role. The way it works, you create a service account and use it in your pod spec. It can be anything, deployment, statefulset, or some jobs. It is aws-test.yaml

5. Then you need to apply it using kubectl apply -f <folder/file> command.

    `> kubectl apply -f aws-test.yml`

6. check if it can list S3 bucket in our account

    `> kubectl exec aws-cli -- aws s3api list-buckets`
