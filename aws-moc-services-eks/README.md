This OpenTofu project manages the `moc-services` EKS cluster and the associated AWS infrastructure.

## Requirements

Applying and destroying this configuration requires the `aws` and `kubectl`
CLIs on your `PATH`. `kubectl` is used by the destroy-time load balancer cleanup
described below.

## Destroying the cluster

The AWS Load Balancer Controller creates AWS load balancers (and ENIs in the VPC
subnets) in response to Kubernetes Ingresses and `type: LoadBalancer` Services.
Those load balancers are not tracked in state, so if the controller were
uninstalled with them still present, their ENIs would be orphaned and block VPC
deletion.

To avoid this, `tofu destroy` runs `scripts/cleanup-load-balancers.sh` before the
controller is uninstalled. The script deletes all Ingresses and `type:
LoadBalancer` Services and waits (up to `TIMEOUT`, default 10 minutes) for the
controller to remove the backing AWS load balancers. If cleanup does not
complete in time the destroy fails with the controller still installed, so you
can resolve the problem and re-run `tofu destroy`.

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
