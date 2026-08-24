This OpenTofu project manages the `moc-services` EKS cluster and the associated AWS infrastructure.

## Accessing the cluster

In order to add cluster credentials to your local `kubeconfig` file:

```sh
aws eks update-kubeconfig --name moc-services --region us-east-1
```

You can also see this command in the output of `tofu output`.

## Manually updating public_access_cidrs

If you need access to the public API endpoint and you are blocked by the current configuration of `public_access_cidrs`, you will not be able to run this tofu configuration. Instead, you can manually update the value:

```sh
aws eks update-cluster-config \
  --name moc-services \
  --resources-vpc-config '{"publicAccessCidrs":["<your-cidr>"]}'
```

Note that this command, as given, will *replace* the `publicAccessCidrs` value. You should include any existing values, which you can obtain with:

```sh
aws eks describe-cluster --name moc-services \
  --query 'cluster.resourcesVpcConfig.publicAccessCidrs'
```
