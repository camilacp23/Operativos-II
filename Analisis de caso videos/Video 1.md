#  Capítulo 14 – Máquinas Virtuales (Parte 1)

## 1. Concepto de virtualización
- Antes un servidor físico corría un solo sistema operativo y servicios (ejemplo: web + base de datos).  
- Problema que causa: si fallaba el hardware, todo el sistema quedaba inactivo por días.  
- Con la virtualización, un sistema caído puede trasladarse automáticamente a otro servidor redundante → **alta disponibilidad**.  

 Virtualización = **no depender de algo físico** para ejecutar servicios, aplicaciones o sistemas.  

**Ejemplos:**
- Máquinas virtuales.  
- Contenedores Docker.  
- Java Virtual Machine.  

---

## 2. Ventajas de la virtualización
- **Múltiples sistemas operativos** en un mismo servidor.  
- **Compatibilidad**: ejecutar software viejo en hardware nuevo, o viceversa.  
- **Facilidad de mantenimiento**: levantar un backup es más rápido que reparar un físico.  
- **Versatilidad**: mejor aprovechamiento del hardware.  
- **Consolidación**: menos servidores físicos encendidos = ahorro de energía.  
- **Agregación**: añadir recursos (CPU, RAM, disco) fácilmente.  
- **Dinámica**: mover VMs entre servidores según demanda.  
- **Mayor disponibilidad**: respaldo entre regiones.  

---

## 3. Hipervisores
El **hipervisor** es la capa de software que administra las máquinas virtuales sobre el hardware.  

### Tipos principales:
- **Tipo 1 (bare-metal):** se instala directamente en el hardware.  
  - Ej: VMware ESXi, Microsoft Hyper-V, KVM (Linux), Citrix XenServer.  
- **Tipo 2 (hosted):** se instala sobre un sistema operativo existente.  
  - Ej: VirtualBox, VMware Workstation.  

El hipervisor tipo 1 actúa como **sistema operativo especializado**.  
El hipervisor tipo 2 depende de otro **SO anfitrión**.  

---

## 4. Funciones del hipervisor
- Administrar ejecución de las VMs.  
- Emulación de dispositivos (drivers invitados ↔ hipervisor ↔ hardware).  
- Control de privilegios de procesos invitados.  
- Gestión del ciclo de vida de las VMs: creación, ejecución, snapshots, eliminación.  
- Actualizaciones y seguridad.  
- Optimización del hardware con drivers específicos.  

---

## 5. Técnicas de virtualización
- **Paravirtualización:** modifica drivers para comunicarse más rápido con el hardware → mayor rendimiento.  
- **Asistencia por hardware:** procesadores con extensiones de virtualización (Intel VT-x, AMD-V) aceleran operaciones.  

---

## 6. Conceptos clave
- **Driver vs. Controlador:**  
  - *Driver* → software en el SO que habla con el hardware.  
  - *Controlador* → chip/software que controla el dispositivo físico.  

---

**Podemos concluir que** La virtualización revolucionó la informática al permitir mayor disponibilidad, eficiencia y flexibilidad en el uso de hardware.  
Los **hipervisores** son la base tecnológica que lo hace posible.
