import os
from collections import deque
from typing import Any, Coroutine, Dict, List, Optional, Sequence, Tuple, Union

from PIL import Image
from viam.components.camera import Camera
from viam.gen.component.camera.v1.camera_pb2 import GetPropertiesResponse
from viam.media.utils import pil
from viam.media.video import CameraMimeType, NamedImage, ViamImage
from viam.proto.common import ResponseMetadata


def load_ordered_images(path: str) -> Sequence[Image.Image]:
    """Load all jpg images from the given folder path in order."""

    if os.path.isdir(path):  # if there are multiple images
        # filter out non jpg and sort list
        image_files = sorted([f for f in os.listdir(path) if f.endswith(".jpg")])
        images = [Image.open(os.path.join(path, img)) for img in image_files]
    else:
        # if there is just a single image, open it
        images = [Image.open(path)]
    return images


# for testing purposes
class FakeCamera(Camera):
    def __init__(self, name: str, img_path: str, use_ring_buffer: bool = False):
        """
        Initialize the FakeCamera with a list of images.

        :param name: The name of the camera.
        :param img_path: The path to the folder containing the images.
        :param use_ring_buffer: If True, use a ring buffer for the images.
        """
        super().__init__(name=name)
        self.count = -1
        images = load_ordered_images(img_path)

        if use_ring_buffer:
            # Use a deque as a ring buffer
            self.images = deque(images)
        else:
            # Use a simple list
            self.images = images

    async def get_image(
        self,
        mime_type: str = "",
        *,
        extra: Optional[Dict[str, Any]] = None,
        timeout: Optional[float] = None,
        **kwargs,
    ) -> ViamImage:  # automatically returns coroutine
        """
        Get the next image from the list or ring buffer.

        :param mime_type: The mime type of the image.
        :return: A ViamImage object.
        """
        self.count += 1

        if isinstance(self.images, deque):
            # Rotate the deque to get the next image and wrap around if necessary
            self.images.rotate(-1)
            image = self.images[0]
        else:
            # Access the next image in the list
            if self.count >= len(self.images):
                raise IndexError("Already read all the images passed as input")
            image = self.images[self.count]

        return pil.pil_to_viam_image(image, CameraMimeType.JPEG)

    async def get_images(
        self,
    ) -> Coroutine[Any, Any, Union[List[NamedImage], ResponseMetadata]]:
        """
        Get a list of all images (not implemented in this example).

        :return: A list of NamedImage objects or ResponseMetadata.
        """
        raise NotImplementedError

    async def get_properties(
        self, *, timeout: Optional[float] = None, **kwargs
    ) -> GetPropertiesResponse:
        """
        Get camera properties (not implemented in this example).

        :return: A GetPropertiesResponse object.
        """
        raise NotImplementedError

    async def get_point_cloud(self) -> Coroutine[Any, Any, Tuple[Union[bytes, str]]]:
        """
        Get the point cloud data (not implemented in this example).

        :return: A tuple containing the point cloud data.
        """
        raise NotImplementedError

    def get_number_of_images(self) -> int:
        """
        Get the number of images in the list or ring buffer.

        :return: The number of images.
        """
        return len(self.images)
