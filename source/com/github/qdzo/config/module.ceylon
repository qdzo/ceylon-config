"""
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
   import com.github.qdzo.config "0.1.3";
   ```

   ## Usage

   Library looks for the config file in current dir and *profiles* dirs.
   After that it loads system environment variables, cmd parameters,
   system properties and merges them in one `HashMap<String,String>` that accessible as `env` top-level object.

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
   import com.github.qdzo.config { env }

   shared void run() {
       String dbHost = env.getString("database.host");            // asserts value existence
       Integer dbPort = env.getInteger("database.port");          // asserts existence and try parse-integer
       String? dbUser = env.getStringOrNull("database.user");     // optional parameter
       String? dbPass = env["database.password"];                 // env satisfies Map<String,String>

       value connection = connectDb(dbHost, dbPort, dbUser, dbPass);
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

   > Ceylon doesn't force us to use any kind of configuration for different dev environments.

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
   * all chars lower-cased
   * hyphen (`-`) and underscore (`_`) replaced with dot (`.`)

   This gives you some advantages:
   * a freedom to specify variables according standards (upper-cased with underscore in *env*, lower-cased with dot in *java-properties*)
   * to use variables without fear to forget they format.

   > The library prints warnings when it formats variables, so be attentive

   ### Caveats:

   `ceylon-config` doesn't support arrays in json: it converts them to string.
   This is made to exclude ugly and buggy variable-names followed by index - `foo.1, foo.2.name`.
   > Because position is matter in sequence.


   ## Advanced

   ### Using env in non-`run` method

   If you want to use `env` variables somewhere in the project and you want to be sure that variable present at application startup,
   you would annotate your method with `requiredEnv` annotation and call `checkEnvRequirements` in run method.

   ```ceylon
   requiredEnv("web.host", "web.port") // method required some envirnment variables
   shared startServer() {
       String host = env.getString("web.host");
       Integer port = env.getInteger("web.port");
       value server = newServer({});
       server.start(SocketAddress(host, port));
   }


   shared void run() {
       checkEnvRequirements(`module`); // search for `requredEnv` annotaion in current-module and check env existence
       ...
       Thread.sleep(10_000)
       serverStart();
   }
   ```


   ### Using annotations to setup config-Classes and instantiate them

   It's convenient to use some class as configuration.
   You may to annotate fields of that class with `envVar("varname")` annotation
   and then get instantce of that class with specified parameters from the environment variables.

   Example:

   ```ceylon
   class Config(
       envVar("server.host")
       shared String host,

       envVar("server.port")
       shared Integer port,

       envVar("server.user")
       shared String user = "test-user",

       envVar("server.pass")
       shared String pass = "secret",
   ) {}

   shared void run() {
       value conf = configure<Config>();
       value connection = connectDb(conf.host, conf.port, conf.user, conf.pass);
       ...
   }
   ```

   Rules to create such config class:

   * Fields must be *one* of the basic types (`Boolean`, `Integer`, `Float`, `String`, `Date`, `Time`, `DateTime`) or sequence/iterable of them.
   * Fields with default values are treated as `optional` fields, and may not have value in environment.
   * If some variable is not exists in the environment then `EnvironmentVariableNotFoundException` will be thrown while `configure<Type>`.

"""

native("jvm")
//module com.github.qdzo.config "0.1.4-SNAPSHOT" {
module com.github.qdzo.config "0.2.0" {
    import java.base "8";
    import ceylon.interop.java "1.3.3";
    import ceylon.file "1.3.3";
    import ceylon.json "1.3.3";
    import ceylon.toml "1.3.3";
    shared import ceylon.time "1.3.3";
    import ceylon.logging "1.3.3";
}
