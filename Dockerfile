FROM openjdk:11
ADD target/gateway-0.0.1-RELEASE.jar eos-gateway-api.jar
CMD ["java","-jar","eos-gateway-api.jar"]