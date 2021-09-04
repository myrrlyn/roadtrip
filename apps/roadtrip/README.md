# Roadtrip

This is the core application; it currently exists primarily to serve the web
front-end, but may be extended for other clients in the future.

## Data Model

- `Vehicle` is the base model.
- `Measurement` records a timestamp, odometer reading, and possible
  miscellaneous data (`Refuel`, `Maintenance`)
