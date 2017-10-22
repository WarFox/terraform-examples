resource "aws_iam_user" "user_one" {
  name = "test-user-one"
}

resource "aws_iam_user" "user_two" {
  name = "test-user-two"
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_membership" "developers" {
  name = "tf-developers-group-membership"

  users = [
    "${aws_iam_user.user_one.name}",
    "${aws_iam_user.user_two.name}"
  ]

  group = "${aws_iam_group.developers.name}"
}

resource "aws_iam_access_key" "lb" {
  user = "${aws_iam_user.user_one.name}"
}

resource "aws_iam_user_policy" "lb_ro" {
  name = "lb_ro_policy"
  user = "${aws_iam_user.user_one.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

output "secret" {
  value = "${aws_iam_access_key.lb.encrypted_secret}"
}
