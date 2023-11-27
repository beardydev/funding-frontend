# [Choice] Ruby version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.1, 3.0, 2, 2.7, 2.6, 3-bullseye, 3.1-bullseye, 3.0-bullseye, 2-bullseye, 2.7-bullseye, 2.6-bullseye, 3-buster, 3.1-buster, 3.0-buster, 2-buster, 2.7-buster, 2.6-buster
ARG VARIANT=3.1
FROM mcr.microsoft.com/devcontainers/ruby:${VARIANT}

# Install required packages for RVM
RUN apt-get update && \
    apt-get install -y curl gpg

# Add GPG keys for RVM
RUN gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# Install RVM and Ruby 3.1.1
RUN \curl -sSL https://get.rvm.io | bash -s stable && \
    /bin/bash -c "source /usr/local/rvm/scripts/rvm && rvm install 3.1.1 && rvm use 3.1.1 --default"

# Set PATH for RVM and gems
# ENV PATH="/usr/local/rvm/gems/ruby-3.1.1/bin:$PATH"

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains 
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.app.github.dev"

# [Choice] Node.js version: lts/*, 16, 14, 12, 10
ARG NODE_VERSION="16"
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"

# Set PATH for other binaries
ENV PATH="$PATH:/workspaces/funding-frontend/.git/hooks/bin"

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install additional gems.
# RUN gem install <your-gem-names-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
