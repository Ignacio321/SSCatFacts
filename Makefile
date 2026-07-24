lint:
	bundle exec rubocop
	npm run lint

lint-fix:
	bundle exec rubocop -A
	npm run lint:fix
	npm run format

dev:
	bin/dev

test:
	bundle exec rspec
	npm test

check: lint test