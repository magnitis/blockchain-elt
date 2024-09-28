build:
	npx tsc -p indexer

run-only:
	node indexer/build/index.js

cleanup-db:
	-rm db/user_files/*.jsonl

run: build cleanup-db run-only
