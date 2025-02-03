FROM public.ecr.aws/lambda/nodejs:14

COPY index.js ./
RUN npm init -y && npm install express serverless-http

CMD ["index.lambdaHandler"]
