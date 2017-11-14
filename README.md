## `ceylon-config`

A Ceylon Library for managing configuration from several sources, including
* config files
* env variables 
* java system-properties

This library inspired by [The Twelve-Factor App](https://github.com/yogthos/config) 
and [yogthos/config](https://github.com/yogthos/config) project.

Configuration is resolved in next order:

1. config `json/toml` file in current dir 
2. profile `json/toml` file
3. Environment variables
4. custom config file `json/toml`, specified by cmd parameter `--config` 
5. cmd parameters
6. java-system properties

Each next level overrides definitions from earlier levels.

`toml` files has more higher priority than `json`.

## Install

Add dependency to your `module.ceylon` file

```ceylon
import ru.qdzo.ceylon.config "0.0.1";
```

## Usage

Library looks for the config file in current dir and *profiles* dirs. 
After that it loads system environment variables, cmd parameters, 
system properties and merges them in one `HashMap<String,String> env` object.

### Use Configuration file

Create `config.json` file in project root.

```json
{
  "database": {
    "host": "localhost",
    "port": 5144
  }
}
```

Use `env` object to obtain variables.

```ceylon
import ru.qdzo.ceylon.config { env }

shared void run() {
    assert(exists dbHost = env["database.host"]);
    assert(is Integer dbPort = Integer.parse(env["database.port"]));
    value connection = connectDb(dbHost, dbPort);
    ...
}
```

### Use system environment variables or cmd parameters

You can override config variables by specifying system environment variables or cmd parameters

Set environment before application start-up

```bash
export DATABASE_HOST=192.168.0.10
export DATABASE_HOST=4000
```

Or set cmd parameters with `ceylon run` command

```bash
ceylon run app.module --database-host 192.168.0.10 -database.port=4000
```

Also you can specify custom config file 

```bash
ceylon run app.module --config=my/custom/config.toml
```

### Mulitple configurations

Setting up mutliple configurations is done by *profiles* dirs. 

> Ceylon doesn't force us to use any kind of configuration for different dev environments - we have full freedom in this place.

Profile dir is a dir that placed in path `{project_root}/config/{profile-name}`. 

You need to create `config` dir in project root and then create `dev`, `test` `stage` (whatever...) dirs nested in `config` dir.

In each of these dirs create config file: `config.json` or `config.toml`.

You must get such paths in project root:

* `config/dev/config.json`
* `config/test/config.toml`
* `config/test/config.json`

To specify profile config you must set environment variable `PROFILE` to needed profile.

```bash 
export PROFILE=dev
```

**NOTE**: all variables that gathered from different sources are transformed to one format:
* all chars lowercased
* hyphen (`-`) and underscore (`_`) replaced with dot (`.`)

This gives you some advantages:
* a freedom to specify variables according standards (uppercased with upderscore in *env*, lowercased with dot in *java-properties*)
* to use variables without fear to forget they format.

> The library prints warnings when it formats variables, so be attentive

### Caveats: 

`ceylon-config` doesn't support arrays in json: it converts them to string. 
This is made to exclude ugly and buggy variable-names folowed by index - `foo.1, foo.2.name`. 
> Because position is matter in sequence.


## Advanced

You can create custom config loader by extending `Loader` class and registering it in the system.

Implementing loader

```ceylon
shared object mySecretLoader extends Loader() {
    load => HashMap { sanitize("PASSWORD")->"SeCrEt" };
}
```

You need to apply `sanitize` function for key, to bring it to common format (see above).

Registering loader

```
registerLoader(mySecretLoader);
```

*NOTE*: custom loaders have lowest priority.

## Licence

Distributed under the Apache License, Version 2.0.
