# SSH Configuration Management

## Generating SSH Config
To generate `~/.ssh/config` from the Jinja2 template:
```sh
# Preprocess YAML file by expanding environment variables with envsubst
( envsubst < ssh_config.yaml > j2preprocessed-data.yaml )
# Render Jinja2 template using the preprocessed YAML file
j2 ssh_config.j2 j2preprocessed-data.yaml > ~/.ssh/config
chmod 600 ~/.ssh/config
```

- _ssh_config.j2_ - jinja2 template for ssh config.
- _convert_ssh_to_yaml.py_ - helper script that renders existing config file _~/.ssh/config_ to yaml for jinja2 templating.

> **📝 NOTE:**  
> The templating command syntax differs depending on whether you're using  
> **`j2cli` (j2)** or Python’s Jinja2 directly. However, the **jinja2 template remains the same**.




