# Database Migration and Validation Workflow

This project uses Prisma, MySQL, SonarQube, and a Python-based ETL process to perform schema migration, data transformation, and post-migration validation.

## Prerequisites

Make sure the following tools are installed:

* Docker
* Node.js and npm
* MySQL
* Python 3
* Prisma CLI
* SonarScanner

---

# 1. Start SonarQube

Run SonarQube locally using Docker:

```bash
docker run -d \
  --name sonarqube \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -p 9000:9000 \
  sonarqube:latest
```

Access SonarQube at:

```text
http://localhost:9000
```

---

# 2. Run SonarScanner

Execute static code analysis:

```bash
sonar-scanner
```

Make sure a valid `sonar-project.properties` file exists in the project root.

---

# 3. Set Up Prisma

Install Prisma as a development dependency:

```bash
npm install prisma --save-dev
```

Initialize Prisma:

```bash
npx prisma init
```

Run the migration:

```bash
npx prisma migrate dev --name sre
```

Import the refactored SQL schema:

```bash
mysql -u root -p sre < part_f_refactoring.sql
```

---

# 4. Run the Python ETL Process

Install the required MySQL connector:

```bash
pip install mysql-connector-python
```

Execute the ETL script:

```bash
python migration_etl.py
```

---

# 5. Run Post-Migration Validation

Execute the validation script to verify migrated data and schema integrity:

```bash
mysql -u root -p sre < part_g_validation.sql
```

---

# Project Workflow Summary

1. Start SonarQube
2. Run static analysis using SonarScanner
3. Configure Prisma and apply migrations
4. Import the refactored schema
5. Execute ETL migration scripts
6. Run post-migration validation checks
