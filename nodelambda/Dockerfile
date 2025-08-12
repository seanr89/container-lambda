# Use the official AWS Lambda Node.js 22 image
FROM public.ecr.aws/lambda/nodejs:22

# Create a work directory
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy the function handler
COPY --chown=node:node index.js .

# Set the user to "node"
USER node

# Add a healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:8080/ || exit 1

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "index.handler" ]