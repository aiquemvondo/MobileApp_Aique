from datetime import date
from itertools import count

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field

app = FastAPI(title="Vehicle Manufacturer Management API", version="1.0.0")

# ---------------------------------------------------------------------------
# In-memory "database"
# ---------------------------------------------------------------------------
manufacturers: dict[int, dict] = {}
vehicles: dict[int, dict] = {}
_manufacturer_ids = count(1)
_vehicle_ids = count(1)

MAX_YEAR = date.today().year + 1


# ---------------------------------------------------------------------------
# Pydantic models
# ---------------------------------------------------------------------------
class ManufacturerCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100, examples=["Toyota"])
    country: str = Field(min_length=1, max_length=100, examples=["Japan"])


class ManufacturerPatch(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    country: str | None = Field(default=None, min_length=1, max_length=100)


class Manufacturer(ManufacturerCreate):
    id: int


class VehicleCreate(BaseModel):
    manufacturer_id: int = Field(gt=0, examples=[1])
    model: str = Field(min_length=1, max_length=100, examples=["Corolla"])
    year: int = Field(ge=1886, le=MAX_YEAR, examples=[2024])
    price: float = Field(gt=0, examples=[22999.99])


class VehiclePatch(BaseModel):
    manufacturer_id: int | None = Field(default=None, gt=0)
    model: str | None = Field(default=None, min_length=1, max_length=100)
    year: int | None = Field(default=None, ge=1886, le=MAX_YEAR)
    price: float | None = Field(default=None, gt=0)


class Vehicle(VehicleCreate):
    id: int


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def get_manufacturer_or_404(manufacturer_id: int) -> dict:
    if manufacturer_id not in manufacturers:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            f"Manufacturer {manufacturer_id} not found",
        )
    return manufacturers[manufacturer_id]


def get_vehicle_or_404(vehicle_id: int) -> dict:
    if vehicle_id not in vehicles:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND, f"Vehicle {vehicle_id} not found"
        )
    return vehicles[vehicle_id]


# ---------------------------------------------------------------------------
# Manufacturers
# ---------------------------------------------------------------------------
@app.post(
    "/manufacturers",
    response_model=Manufacturer,
    status_code=status.HTTP_201_CREATED,
    tags=["Manufacturers"],
)
def create_manufacturer(payload: ManufacturerCreate):
    new_id = next(_manufacturer_ids)
    manufacturers[new_id] = {"id": new_id, **payload.model_dump()}
    return manufacturers[new_id]


@app.get("/manufacturers", response_model=list[Manufacturer], tags=["Manufacturers"])
def list_manufacturers():
    return list(manufacturers.values())


@app.get(
    "/manufacturers/{manufacturer_id}",
    response_model=Manufacturer,
    tags=["Manufacturers"],
)
def get_manufacturer(manufacturer_id: int):
    return get_manufacturer_or_404(manufacturer_id)


@app.put(
    "/manufacturers/{manufacturer_id}",
    response_model=Manufacturer,
    tags=["Manufacturers"],
)
def replace_manufacturer(manufacturer_id: int, payload: ManufacturerCreate):
    get_manufacturer_or_404(manufacturer_id)
    manufacturers[manufacturer_id] = {"id": manufacturer_id, **payload.model_dump()}
    return manufacturers[manufacturer_id]


@app.patch(
    "/manufacturers/{manufacturer_id}",
    response_model=Manufacturer,
    tags=["Manufacturers"],
)
def update_manufacturer(manufacturer_id: int, payload: ManufacturerPatch):
    record = get_manufacturer_or_404(manufacturer_id)
    record.update(payload.model_dump(exclude_unset=True, exclude_none=True))
    return record


@app.delete(
    "/manufacturers/{manufacturer_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["Manufacturers"],
)
def delete_manufacturer(manufacturer_id: int):
    get_manufacturer_or_404(manufacturer_id)
    del manufacturers[manufacturer_id]
    # Cascade delete: remove all vehicles belonging to this manufacturer
    for vid in [v["id"] for v in vehicles.values() if v["manufacturer_id"] == manufacturer_id]:
        del vehicles[vid]


@app.get(
    "/manufacturers/{manufacturer_id}/vehicles",
    response_model=list[Vehicle],
    tags=["Manufacturers"],
)
def list_manufacturer_vehicles(manufacturer_id: int):
    get_manufacturer_or_404(manufacturer_id)
    return [v for v in vehicles.values() if v["manufacturer_id"] == manufacturer_id]


# ---------------------------------------------------------------------------
# Vehicles
# ---------------------------------------------------------------------------
@app.post(
    "/vehicles",
    response_model=Vehicle,
    status_code=status.HTTP_201_CREATED,
    tags=["Vehicles"],
)
def create_vehicle(payload: VehicleCreate):
    get_manufacturer_or_404(payload.manufacturer_id)
    new_id = next(_vehicle_ids)
    vehicles[new_id] = {"id": new_id, **payload.model_dump()}
    return vehicles[new_id]


@app.get("/vehicles", response_model=list[Vehicle], tags=["Vehicles"])
def list_vehicles():
    return list(vehicles.values())


@app.get("/vehicles/{vehicle_id}", response_model=Vehicle, tags=["Vehicles"])
def get_vehicle(vehicle_id: int):
    return get_vehicle_or_404(vehicle_id)


@app.put("/vehicles/{vehicle_id}", response_model=Vehicle, tags=["Vehicles"])
def replace_vehicle(vehicle_id: int, payload: VehicleCreate):
    get_vehicle_or_404(vehicle_id)
    get_manufacturer_or_404(payload.manufacturer_id)
    vehicles[vehicle_id] = {"id": vehicle_id, **payload.model_dump()}
    return vehicles[vehicle_id]


@app.patch("/vehicles/{vehicle_id}", response_model=Vehicle, tags=["Vehicles"])
def update_vehicle(vehicle_id: int, payload: VehiclePatch):
    record = get_vehicle_or_404(vehicle_id)
    changes = payload.model_dump(exclude_unset=True, exclude_none=True)
    if "manufacturer_id" in changes:
        get_manufacturer_or_404(changes["manufacturer_id"])
    record.update(changes)
    return record


@app.delete(
    "/vehicles/{vehicle_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["Vehicles"],
)
def delete_vehicle(vehicle_id: int):
    get_vehicle_or_404(vehicle_id)
    del vehicles[vehicle_id]