# Análisis de caso: Plataforma Web con Docker, HAProxy y CI/CD

**Objetivo**: Diseñar y ejecutar una plataforma web basada en contenedores Docker, balanceo de carga con HAProxy y automatización CI/CD. Además, simular y analizar el comportamiento de una aplicación web básica (Java “Hola mundo”), incluyendo pruebas de carga con Apache JMeter, aspectos de seguridad (HTTPS) y alta disponibilidad (simulación de fallas y opción Docker Swarm).

> Todo esta pensado para el **paso a paso en la terminal de Ubuntu**. No requiere JDK ni Maven instalados en el host, porque todo se compila y ejecuta dentro de contenedores.

---

## 0) Requisitos en Ubuntu

```bash
# Actualiza paquetes
sudo apt update

# Herramientas básicas
sudo apt install -y git curl openssl

# Docker Engine y Compose Plugin (paquetes de Ubuntu)
sudo apt install -y docker.io docker-compose-plugin

# Agrega tu usuario al grupo docker (desloguea y vuelve a entrar para aplicar)
sudo usermod -aG docker "$USER"
# cierra sesión y vuelve a entrar, o:
newgrp docker

# Verifica instalación
docker version
docker compose version
```

> Si prefieres instalar Docker desde el repositorio oficial, consulta la documentación oficial de Docker.

---

## 1) Obtener el proyecto

Opción A (descargaste este paquete .zip): descomprímelo, entra a la carpeta y revisa el contenido.




---

## 2) Generar certificado HTTPS (autofirmado)

Para lab, usaremos un certificado **autofirmado** en HAProxy. Luego podrás reemplazarlo por Let’s Encrypt si tienes un dominio.

```bash
chmod +x scripts/gen_self_signed.sh
./scripts/gen_self_signed.sh
ls -l haproxy/certs/selfsigned.pem
```

---

## 3) Construir y levantar la plataforma con Docker Compose

```bash
# Levanta las dos instancias de la app Java y el HAProxy
docker compose up -d --build

# Ver estado
docker compose ps
```

Pruebas rápidas:
```bash
# HTTP (redirige a HTTPS)
curl -I http://localhost

# HTTPS (ignora la validación del certificado autofirmado)
curl -k https://localhost/

# Comprobar healthcheck del backend a través de HAProxy (debería responder 200/OK)
curl -k https://localhost/health
```

---

## 4) Simulación de falla y alta disponibilidad (a nivel de balanceo)

```bash
# Detén una instancia (app1) para simular caída
docker compose stop app1

# El servicio debe seguir respondiendo vía HAProxy (sirve app2)
curl -k https://localhost/

# Vuelve a levantar la instancia
docker compose start app1
```

**Análisis**: explica cómo HAProxy marca como *DOWN* la instancia no disponible (health checks) y continúa enviando tráfico a la instancia saludable.

---

## 5) Pruebas de carga con Apache JMeter (modo headless)

 Instalar JMeter en Ubuntu
```bash
sudo apt install -y jmeter
jmeter -n -t tests/jmeter/helloworld.jmx -l tests/jmeter/results.jtl -e -o tests/jmeter/report

```

Abre el reporte HTML generado (carpeta `tests/jmeter/report`) con tu navegador.

> Ajusta en el `.jmx` el número de hilos (usuarios), ramp-up y duración para observar cómo se reparte la carga entre instancias.

---

## 6) Seguridad

- **HTTPS obligatorio**: todo HTTP se redirige a HTTPS.
- **Certificado**: en lab usamos autofirmado (`haproxy/certs/selfsigned.pem`). En producción usa **Let’s Encrypt** u otra CA.
- **Rate limiting**: se ejemplifica limitación de peticiones por IP en HAProxy.
- **Cortafuegos (UFW)**:
  ```bash
  sudo ufw allow OpenSSH
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  sudo ufw enable
  sudo ufw status
  ```

---

## 7) CI/CD con GitHub Actions

El flujo `ci-cd.yml` compila la imagen Docker y la publica en **GitHub Container Registry (GHCR)**. Opcionalmente, se muestra una etapa de despliegue por SSH a un servidor (requiere secretos).

Pasos:
1. Crea un repositorio en GitHub y sube este proyecto.
2. En **Settings → Actions → General**, deja habilitado el uso del `GITHUB_TOKEN` para publicar en **ghcr.io**.
3. (Opcional) Configura secretos para despliegue: `SSH_HOST`, `SSH_USER`, `SSH_KEY`.
4. Haz `git push` a `main` y revisa la pestaña **Actions**.

---

## 8) (Opcional) Docker Swarm para orquestación

Para observar **escalado horizontal** con orquestador:
```bash
# Inicializa un Swarm en el nodo actual
docker swarm init

# Despliega la pila (ajusta owner/imagen si corresponde)
docker stack deploy -c swarm-stack.yml webplat

# Verifica
docker stack services webplat
docker service ls
```

> En Swarm, HAProxy puede descubrir por DNS los contenedores/servicios y balancearlos. Mantén HAProxy en un nodo manager o usa réplicas con una VIP o un LB externo.

Para retirar:
```bash
docker stack rm webplat
docker swarm leave --force
```

---

## 9) Qué entregar (sugerido)

## 10) Git: preparar y subir a tu repo

```bash
git init
git add .
git commit -m "Plataforma Docker + HAProxy + CI/CD (caso de estudio)"
git branch -M main
git remote add origin <URL_DE_TU_REPO>
git push -u origin main
```