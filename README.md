# Python Template

Template project for a Python application.

Learn more about Python on [python.org](https://www.python.org/).


## Getting started

### Development

Use this command to run the application locally for development:

```sh
docker compose watch
# or: docker compose up -d
```

Using `watch`, you'll benefit from file changes watching for sync & rebuild.

Use [DockerC](https://github.com/matiboux/dockerc) for shortened commands: `dockerc - @w`.

### Production

Use this command to run the application locally for production:

```sh
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
# or: docker compose -f docker-compose.yml up -d
```

Use [DockerC](https://github.com/matiboux/dockerc) for shortened commands: `dockerc prod`.


## License

Copyright (c) 2025 [Matiboux](https://github.com/matiboux) ([matiboux.me](https://matiboux.me))

Licensed under the [MIT No Attribution License (MIT-0)](https://opensource.org/license/MIT-0). You can see a copy in the [LICENSE](LICENSE) file.
