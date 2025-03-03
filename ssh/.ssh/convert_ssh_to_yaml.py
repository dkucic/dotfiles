import yaml
import re

# Input SSH Config file (INI-like format)
ssh_config_file = "config"
yaml_output_file = "ssh_config.yaml"

def parse_ssh_config(file_path):
    """Parses an SSH config file and extracts host details into a list of dictionaries."""
    hosts = []
    current_host = {}

    with open(file_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue  # Skip empty lines and comments

            match = re.match(r"^Host\s+(.+)", line, re.IGNORECASE)
            if match:
                if current_host:
                    hosts.append(current_host)  # Save the previous host
                current_host = {"Name": match.group(1)}  # Preserve case
            elif current_host:
                key_value = line.split(None, 1)  # Split by first space
                if len(key_value) == 2:
                    key, value = key_value
                    current_host[key] = value  # Keep original case

    if current_host:
        hosts.append(current_host)  # Add last host

    return hosts

def convert_to_yaml(hosts, output_file):
    """Converts parsed SSH host data to a YAML file with preserved case."""
    yaml_data = {"Hosts": hosts}
    with open(output_file, "w") as yaml_file:
        yaml.dump(yaml_data, yaml_file, default_flow_style=False, sort_keys=False)

# Process the SSH config file and save as YAML
hosts_data = parse_ssh_config(ssh_config_file)
convert_to_yaml(hosts_data, yaml_output_file)

print(f"YAML configuration saved to {yaml_output_file}")

