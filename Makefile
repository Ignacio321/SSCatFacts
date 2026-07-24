lint:
	bundle exec rubocop
	npm run lint

lint-fix:
	bundle exec rubocop -A
	npm run lint:fix
	npm run format

dev:
	bin/dev