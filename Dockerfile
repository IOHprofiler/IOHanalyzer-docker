FROM openjdk:8-jre

LABEL maintainer "Hao Wang <h.wang@liacs.leidenuniv.nl>"

# install curl and add npm source
RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# install software dependencies
RUN apt-get update && apt-get install -y \
    r-base \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    nodejs \
    npm \
    xvfb \
    libxtst6 \
    libxss1 \
    libgconf2-4 \
    libgtk2.0-0 \
    libxml2-dev 

# install shinyProxy
RUN mkdir -p /opt/shinyproxy/
RUN wget https://www.shinyproxy.io/downloads/shinyproxy-2.2.1.jar -O /opt/shinyproxy/shinyproxy.jar

# install R package dependencies
RUN R -e "install.packages(c('Rcpp', 'magrittr', 'dplyr', 'data.table', 'ggplot2', 'plotly', 'colorspace', 'colorRamps', 'RColorBrewer', 'shiny', 'withr', 'shinydashboard', 'markdown', 'reshape2', 'shinyjs', 'colourpicker'), repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('remotes', dependencies = T, repos='http://cran.rstudio.com/')"
RUN R -e "remotes::install_github('nik01010/dashboardthemes')"
RUN R -e "remotes::install_github('IOHprofiler/IOHanalyzer', dependencies = T, force = T)"

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get update -y
RUN apt-get install -y google-chrome-stable

# install orca
RUN npm install -g electron@1.8.4 orca --unsafe-perm=true --allow-root
RUN mv /usr/bin/orca /usr/bin/orca-
RUN echo '#!/bin/bash' > /usr/bin/orca
RUN echo 'xvfb-run -a /usr/lib/node_modules/orca/bin/orca.js "$@"' >> /usr/bin/orca
RUN chmod a+x /usr/bin/orca

# copy the data set and configuration files
COPY repository /root/repository/
COPY Rprofile.site /usr/lib/R/etc/
COPY application.yml /opt/shinyproxy/application.yml

WORKDIR /opt/shinyproxy/
EXPOSE 3838

CMD ["java", "-jar", "/opt/shinyproxy/shinyproxy.jar"]
