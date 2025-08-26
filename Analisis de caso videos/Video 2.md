#  Capítulo 14 – Máquinas Virtuales (Parte 2)

## 1. Virtualización con contenedores
- Docker popularizó la virtualización ligera mediante **contenedores**.  
- Antes se necesitaban muchas máquinas virtuales; ahora se puede crear **una sola VM** y dentro de ella desplegar **cientos de servicios con contenedores**.  
- **Linux Containers (LXC/LXD)** existían antes, pero Docker lo hizo **más amigable y accesible**.  

---

## 2. Retos del software de virtualización
- **Complejidad de diseño:** la virtualización lleva décadas desarrollándose.  
- **Procesador (CPU):**  
  - En hipervisores tipo 2 (ej. VirtualBox), el SO anfitrión es quien gestiona el CPU.  
  - En hipervisores tipo 1 (ej. VMware, KVM), el hipervisor es quien gestiona directamente los procesadores.  
- Estrategias de gestión:  
  - **Emulación:** el hipervisor crea un procesador virtual → más lento (ej. Android Emulator).  
  - **Coordinación directa:** el hipervisor asigna tiempos de CPU a las VMs sin emular.  
- Conceptos clave:  
  - **pCPU (procesador físico)**  
  - **vCPU (procesador virtual)**  

---

## 3. Buenas prácticas en configuración de CPU
- Evitar asignar más procesadores virtuales de los necesarios.  
- Mala práctica: duplicar procesadores al migrar de físico a virtual.  
- Recomendación: **empezar con pocos vCPUs** (1 o 2) y aumentar si es necesario.  
- Entre más vCPUs se configuren, más difícil será para el hipervisor encontrar recursos libres.  

---

## 4. Administración de memoria
El hipervisor también gestiona la **RAM**, aplicando distintas estrategias:

### Estrategias de optimización
1. **Memory Sharing (páginas compartidas):**  
   - Si varias VMs usan el mismo sistema operativo y programas, en lugar de duplicar en RAM, se crean **enlaces a las mismas páginas de memoria**.  

2. **Thin Provisioning (aprovisionamiento fino):**  
   - Se configura una VM con cierta cantidad de memoria/almacenamiento, pero **solo se asigna lo que realmente va usando**.  

3. **Ballooning:**  
   - El hipervisor puede **reclamar memoria no usada** de una VM y reasignarla a otra.  

4. **Memory Overcommit (sobre cuota):**  
   - Configurar más memoria RAM y procesadores virtuales que los físicos disponibles.  
   - Funciona mientras no todas las VMs demanden su máximo a la vez.  
   - Riesgo: si todas requieren su cuota máxima simultáneamente, se producen errores.  
   - Ejemplo comparativo: como un banco que presta más dinero del que realmente tiene, confiando en que no todos retirarán al mismo tiempo.  

---

## Lo que se quiere decir
- Los **contenedores** complementan a las máquinas virtuales como una alternativa ligera.  
- El **hipervisor** debe administrar eficientemente CPU y RAM, aplicando estrategias de asignación y optimización.  
- La **configuración responsable de recursos** (evitar exceso de vCPUs o RAM asignada) es clave para la estabilidad y el rendimiento de los sistemas virtualizados.
