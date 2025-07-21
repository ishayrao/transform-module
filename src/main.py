import asyncio
from viam.module.module import Module
import src.models.gpu_transform as gpu_transform
import src.transform_pipeline as transform_pipeline

if __name__ == "__main__":
    asyncio.run(Module.run_from_registry())
