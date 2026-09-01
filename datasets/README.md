# VieGym datasets

Runtime services must never read files under `raw/`. The supported flow is:

```text
manifest -> fetch -> raw validation -> deterministic build -> processed validation -> Spring importer
```

Exercise commands (run from the repository root):

```bash
python3 datasets/scripts/fetch_sources.py
python3 datasets/scripts/validate_raw_exercises.py
python3 datasets/scripts/build_exercise_export.py
python3 datasets/scripts/validate_exercises.py
```

External media is intentionally excluded. The current export contains 120 deterministic records;
all 120 have a Vietnamese review overlay and are `PUBLIC`. New candidates without an approved
review overlay remain `HIDDEN` by default.

Import the validated export with Spring Boot:

```bash
cd backend
./mvnw spring-boot:run \
  -Dspring-boot.run.arguments="--viegym.dataset.exercise.enabled=true --viegym.dataset.exercise.path=../datasets/exports/viegym_exercises_v1.json"
```

The importer is insert-only for an existing import key. This prevents a later external snapshot
from silently overwriting admin-curated master data.
