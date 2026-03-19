# Demo: Setting Up the Data Pipeline Stack

## Demo Overview
**Type:** Hybrid (Conceptual + Implementation)  
**Duration:** 40-50 minutes  
**Prerequisites:** Docker Desktop installed

## Learning Objectives
By the end of this demo, trainees will:
- Understand Airflow's component architecture and its role in orchestrating data pipelines
- Set up a complete local environment with Airflow, Kafka, and Spark using Docker Compose
- Access the Airflow UI, Kafka UI, and Spark Master UI
- Understand how these components work together in a real data pipeline

---

## Phase 0: The Multi-Service Stack
**Time:** 10 minutes

### Step 1: Introduce the Full Architecture
Open `diagrams/multi-service-architecture.mermaid` or draw on the whiteboard.

**Instructor Script:**
> "This week we're not just learning Airflow in isolation. We're learning how to orchestrate a complete data pipeline that includes Kafka for event streaming and Spark for distributed processing. Let me show you what we're building."

### Step 2: Explain the Pipeline Pattern
Draw or display:
```
[Kafka Producers] --> [Kafka Topics] --> [Batch Consumer] --> [Landing Zone]
                                                                    |
                                                                    v
                                          [Gold Zone] <-- [Spark ETL] <-- [Airflow DAG]
```

> "This is the pattern you'll implement in your StreamFlow project. Airflow is the orchestrator - it triggers consumers, schedules Spark jobs, and monitors the entire pipeline."

### Step 3: Service Overview
| Service | Purpose | Port |
|---------|---------|------|
| **Airflow** | Workflow orchestration | 8082 |
| **Kafka** | Event streaming / message broker | 9092 (internal), 9094 (external) |
| **Kafka UI** | Visual Kafka monitoring | 8080 |
| **Spark Master** | Distributed processing cluster | 7077 (submit), 8081 (UI) |
| **Zookeeper** | Kafka coordination | 2181 |
| **PostgreSQL** | Airflow metadata database | 5432 |

> "Each of these runs in its own Docker container, but they communicate over a shared network."

---

## Phase 1: The Concept (Airflow Architecture)
**Time:** 10 minutes

### Step 1: Zoom into Airflow Components
Open `diagrams/airflow-architecture.mermaid`

**Instructor Script:**
> "Now let's zoom in on Airflow specifically. It has several components that work together."

### Step 2: Explain Each Component

Walk through the diagram:

1. **Metadata Database (PostgreSQL)**
   > "This is Airflow's brain. It stores everything: DAG definitions, task states, connections, variables. Without it, Airflow has no memory."

2. **Webserver**
   > "This serves the UI you'll use to monitor and manage DAGs. It reads from the database to show you what's happening."

3. **Scheduler**
   > "This is the heart. It continuously checks: 'What needs to run? Are dependencies met?' It writes to the database when it schedules tasks."

4. **Executor**
   > "This actually runs your tasks. Today we'll use LocalExecutor, which runs tasks as local processes."

5. **DAGs Folder**
   > "This is where your Python DAG files live. Both the scheduler and webserver read from here."

### Step 3: Discussion Question
> "If the scheduler crashes, what happens to running tasks? What about the webserver?"

**Answer:** Running tasks may continue (executor), but no new tasks get scheduled. Webserver can still show current state.

---

## Phase 2: The Code (Docker Setup)
**Time:** 20-25 minutes

### Step 1: Review the Docker Compose File
Open `code/docker-compose.yml`

**Instructor Script:**
> "Let's look at how we translate that architecture into Docker containers. This file defines our entire data pipeline infrastructure."

Walk through key sections:
1. **Zookeeper** - Kafka's coordination service
2. **Kafka** - Message broker with internal/external listeners
3. **Kafka UI** - Browser-based Kafka monitoring
4. **Spark Master + Worker** - Distributed processing cluster
5. **PostgreSQL** - Airflow's metadata database
6. **Airflow services** - Webserver and Scheduler

### Step 2: Start the Environment

```bash
cd code/
docker compose up -d
```

**Instructor Script:**
> "The `-d` flag runs containers in the background. This will take a few minutes the first time as it downloads images."

```bash
docker compose ps
```

Show all containers becoming healthy.

### Step 3: Access All UIs

**Kafka UI:**
Open browser to `http://localhost:8080`

> "This is where you can see Kafka topics, messages, and consumer groups. We don't have any topics yet - we'll create those later."

**Spark Master:**
Open browser to `http://localhost:8081`

> "This shows your Spark cluster. Notice we have one master and one worker. When we submit jobs, you'll see them listed here."

**Airflow:**
Open browser to `http://localhost:8082`

Log in with:
- Username: `admin`
- Password: `admin`

> "This is Airflow's interface. This is where we'll spend most of our time orchestrating the other components."

### Step 4: Tour the Airflow Initial State

Point out:
- Empty DAGs list (we'll add DAGs in the next demo)
- Admin menu (Connections, Variables, Pools)
- Browse menu (DAG Runs, Task Instances)

### Step 5: Verify Components

```bash
# Check all services are running
docker compose ps

# Check Kafka is ready
docker exec streamflow-kafka kafka-topics --bootstrap-server localhost:9092 --list

# Check Airflow scheduler is running
docker compose logs airflow-scheduler | tail -20

# Check Airflow health
curl http://localhost:8082/health
```

**Instructor Script:**
> "The health endpoint tells us the database and scheduler are connected and working. We're now ready to build pipelines."

---

## Phase 3: Wrap-Up
**Time:** 5 minutes

### Key Takeaways
1. A modern data pipeline stack includes multiple components: Kafka, Spark, Airflow
2. Docker Compose simplifies local setup of complex distributed systems
3. Airflow's role is to orchestrate the other components, not to process data directly
4. Always verify all services are healthy before developing DAGs

### Preview Next Demo
> "Now that we have the full stack running, in the next demo we'll create our first DAG. Later this week, we'll make that DAG trigger Kafka consumers and Spark jobs."

---

## Troubleshooting Guide

| Issue | Solution |
|-------|----------|
| Port 8080/8081/8082 in use | Change ports in docker-compose.yml |
| Containers not starting | Run `docker compose down -v` and retry |
| Kafka not healthy | Wait 60 seconds; check Zookeeper first |
| Login fails | Wait for initialization; check logs |
| Spark worker not connecting | Verify spark-master is running first |

---

## Cleanup Commands
```bash
# Stop containers (preserves data)
docker compose down

# Remove all data (fresh start)
docker compose down -v
```

---

## Files Reference
- `diagrams/multi-service-architecture.mermaid` - Full stack visualization
- `diagrams/airflow-architecture.mermaid` - Airflow component detail
- `code/docker-compose.yml` - Complete Docker stack definition
