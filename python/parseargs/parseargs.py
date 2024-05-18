#!/opt/local/bin/python3
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('project')
parser.add_argument('--foo', dest='foo', required=True)

args = parser.parse_args()

print(args.foo)
print(args.project)
