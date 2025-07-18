# Module gpu-transform-camera 

## Model isha-org:gpu-transform-camera:gpu-transform

Module to redirect transforms from cameras on the vision service to use GPU CUDA instead of CPU to improve processing speed and efficiency.

<pre>
├── Makefile
├── module.tar.gz
├── reload.sh
├── run.sh
├── meta.json
├── README.md
├── requirements.txt
├── setup.sh
|-- build.sh
├── src
│   ├── __init__.py
│   ├── camera_module.py
│   ├── config.py
│   ├── transform_pipeline.py
│   └── utils
│       ├── __init__.py
│       └── gpu_utils.py
└── tests
    └── test_transform_pipeline.py
</pre>

Run tests through pytest with:
<pre> pytest tests/ -v </pre>


---

## Features

- GPU-accelerated transforms: Uses CUDA to speed up image processing from camera feeds.
- Modular pipeline: Easily extend or modify transform steps.
- Test suite: Includes integration and unit tests for reliability.

---

## Installation

> Note:  
> The current `requirements.txt` does not yet support JetPack 6.  
> Make sure your environment matches the dependencies listed in `requirements.txt`.

```sh
pip install -r requirements.txt
```

---

## Usage

You can run the main pipeline or integrate the module into your own code.

Example:
```python
from src.transform_pipeline import GPUTransformPipeline

config = [
    {
        "type": "resize",
        "attributes": {
            "width_px": 224,
            "height_px": 224
        }
    },
    {
        "type": "normalize",
        "attributes": {
            "mean": [0.485, 0.456, 0.406],
            "std": [0.229, 0.224, 0.225]
        }
    }
]

pipeline = GPUTransformPipeline(config)
```

Or run scripts directly:
```sh
python src/main.py
```

---

## Running Tests

Tests are located in `src/tests/`.  
To run all tests:
```sh
pytest src/tests/ -v
```

---

## Transform Pipeline Configuration

The transform pipeline is configured with a list of transform steps. Each step is a dictionary with a `type` and an `attributes` dictionary.

### Supported Transform Types and Attributes

| Transform Type | Attribute Name(s)         | Type      | Required | Description                                      |
|:--------------:|:-------------------------|:----------|:---------|:-------------------------------------------------|
| resize         | width_px, height_px       | int       | Yes      | Output width and height in pixels                |
| normalize      | mean, std                 | list      | Yes      | Mean and std lists for normalization             |
| grayscale      | *(none)*                  |           | -        | Converts image to grayscale                      |
| rotate         | angle_degs                | int/float | Yes      | Angle in degrees to rotate the image             |
| crop           | x_min_px, y_min_px, x_max_px, y_max_px, overlay_crop_box | float, float, float, float, bool | Yes, Yes, Yes, Yes, No | Crop box coordinates and optional overlay flag    |

### Example Configuration

```json
[
  {
    "type": "resize",
    "attributes": {
      "width_px": 224,
      "height_px": 224
    }
  },
  {
    "type": "normalize",
    "attributes": {
      "mean": [0.485, 0.456, 0.406],
      "std": [0.229, 0.224, 0.225]
    }
  },
  {
    "type": "rotate",
    "attributes": {
      "angle_degs": 90
    }
  },
  {
    "type": "crop",
    "attributes": {
      "x_min_px": 10.0,
      "y_min_px": 20.0,
      "x_max_px": 200.0,
      "y_max_px": 220.0,
      "overlay_crop_box": false
    }
  },
  {
    "type": "grayscale",
    "attributes": {}
  },
  {
    "type": "to_tensor",
    "attributes": {}
  }
]
```

---
## Makefile Commands

You can use the provided Makefile to build and clean the module:

| Command             | Description                                                        |
|---------------------|--------------------------------------------------------------------|
| `make module`       | Builds the module and creates `module.tar.gz` for deployment.      |
| `make clean_module` | Removes build artifacts, including `module.tar.gz`.                |

**Example usage:**
```sh
make module        # Build the module
make clean_module  
```
```

## Notes

- CUDA and compatible GPU required for acceleration.
- For JetPack 6 support, dependencies may need to be updated in `requirements.txt`.

---
