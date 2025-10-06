### To start an agent:
```bash
    docker run -e AZP_URL="<Azure DevOps instance>" -e AZP_TOKEN="<Personal Access Token>" -e AZP_POOL="<Agent Pool Name>" -e AZP_AGENT_NAME="Docker Agent - Linux" --name "azp-agent-linux" azp-agent:linux
```

or just run the `./start_local_agent.sh` in the terminal

My Azure DevOps organization: `https://dev.azure.com/alakaganaguathoork/`

### Notes:
`docker compose up -d` will start a default agent.