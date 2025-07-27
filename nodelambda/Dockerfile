
# Use the official AWS Lambda Node.js 22 image
FROM public.ecr.aws/lambda/nodejs:22

# Copy the function handler
COPY index.js ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "index.handler" ]
