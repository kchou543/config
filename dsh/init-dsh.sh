docker run -d \
  --name dsh \
  --restart unless-stopped \
  --network host \
  -e DSH_HOME=/root/.dsh \
  -e NPM_CONFIG_PREFIX=/root/.npm-global \
  -e PATH=/root/.npm-global/bin:$PATH \
  -v ./dsh-data:/root/.dsh \
  -v ./dsh-workspace:/workspace \
  -v ./dsh-npm-global:/root/.npm-global \
  -w /workspace \
  node:24-slim \
  sh -c "command -v dsh >/dev/null 2>&1 || npm install -g @deepseek-ai/dsh && exec dsh web --no-open"
