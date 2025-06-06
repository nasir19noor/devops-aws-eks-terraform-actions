aws eks list-access-entries --cluster-name nasir-cluster-al2 --region ap-southeast-1
aws eks create-access-entry \
  --cluster-name nasir-cluster-al2 \
  --region ap-southeast-1 \
  --principal-arn arn:aws:iam::593793047751:user/nasir
aws eks associate-access-policy \
  --cluster-name nasir-cluster-al2 \
  --region ap-southeast-1 \
  --principal-arn arn:aws:iam::593793047751:user/nasir \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster
aws eks list-access-entries --cluster-name nasir-cluster-al2 --region ap-southeast-1
aws eks list-associated-access-policies \
  --cluster-name nasir-cluster-al2 \
  --region ap-southeast-1 \
  --principal-arn arn:aws:iam::593793047751:user/nasir  