# Etapa de compilación
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app
COPY app/src/HelloServer.java ./
RUN javac HelloServer.java

# Etapa de ejecución
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/HelloServer.class ./
EXPOSE 8080
ENV PORT=8080
CMD ["java","HelloServer"]
