# Exercise source and license decision matrix

| Source | Pinned version | Metadata/instructions | Media | MVP decision |
|---|---|---:|---:|---|
| Free Exercise DB | `a859101d633a01c4a1a920d6a8ce41dabba0705f` | Allowed under Unlicense | Disabled pending asset provenance review | Included |
| exercises-dataset-main | `b10290add3dfed2d0fef5704b3dc660b1f73431d` | Repository claims MIT, but the pinned tree contains only `README.md` | Disabled; third-party Gym Visual terms apply | Rejected until an immutable data file and license snapshot exist |

Decisions:

- VieGym downloads only JSON metadata from included sources.
- No image, thumbnail, GIF, or video URL is exported or imported.
- A rejected source cannot enter the processed dataset even if its README describes data that is
  not present at the pinned commit.
- Vietnamese review overlays are authored and versioned by VieGym.
