{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"glue:GetCrawler",
				"glue:GetTables",
				"glue:StartCrawler",
				"glue:UpdateTable",
				"glue:GetTable"
			],
			"Resource": [
				"*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:ReplicateObject",
				"s3:PutObject",
				"s3:GetObject",
				"s3:GetObjectAttributes",
				"s3:ListBucket",
				"s3:DeleteObject",
				"s3:GetBucketLocation",
				"s3:ListMultipartUploadParts"
			],
			"Resource": [
				"*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"athena:ListDatabases",
				"athena:ListDataCatalogs",
				"athena:GetTable",
				"athena:GetTableMetadata",
				"athena:GetTables",
				"athena:RunQuery"
			],
			"Resource": [
				"*"
			]
		}
	]
}