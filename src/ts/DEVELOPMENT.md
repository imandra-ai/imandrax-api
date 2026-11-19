# Developing the TypeScript client

```sh
make -C src/ts check              # typecheck
make -C src/ts test               # unit tests, offline
make -C src/ts test-integration   # against the server; needs IMANDRAX_API_KEY (or IMANDRA_UNI_KEY)
make -C src/ts build              # build dist/
make -C src/ts docs               # API reference as Markdown, in docs/api
npm run docs:serve                # in src/ts: the reference as HTML, served locally
npm run docs:dev                  # in src/ts: same, rebuilt and reloaded on change
make gents                        # from the repo root: regenerate lib/raw
```

The integration tests are in `test/integration`; they also run each file in `examples/`. Each `ts` block in `README.md` is a copy of a file in `examples/`, which `npm test` checks. The twine tests read their fixtures from `src/py/tests/twine/test_data`.
