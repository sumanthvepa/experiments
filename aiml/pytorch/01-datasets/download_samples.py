#--------------------------------------------------------------------
# download_samples.py: Check that pytorch has been installed correctly
#
# Copyright (C) 2024 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#--------------------------------------------------------------------

from torch.utils.data import DataLoader
from torchvision import datasets
from torchvision.transforms import ToTensor

# Example taken from:
# https://pytorch.org/tutorials/beginner/basics/quickstart_tutorial.html

# Download datasets
# Note 1: FashionMNIST is a data set of fashion images that
#  is freely available at: 
#  https://github.com/zalandoresearch/fashion-mnist
#  See also the original MNIST dataset: 
#  http://yann.lecun.com/exdb/mnist/
#  3Blue1Brown uses this data set to explain neural networks:
#  https://www.3blue1brown.com/topics/neural-networks
#         
# Note 2: It appears that the download operation is (thankfully)
#   idempotent. As specified, the methods below download sample
#   datasets to a directory called data that is created in
#   the current working directory.

# Note 3: It seems that datasets.FashionMNIST accepts 
#  tuple as a parameter. You can see this as there is
#  trailing comma in the call to datasets.FashionMMNIST

# Note 4: The datatype of training_data and test_data is 
# class torchvision.datasets.mnist.FashionMNIST
# This eventually inherits from torch.utils.data.Dataset

# Download training data from open datasets
training_data = datasets.FashionMNIST(
  root='data',
  train=True,
  download=True,
  transform=ToTensor(),)

# Does not actually print the raw data,
# but prints metadata about the dataset
print(type(training_data))
print(training_data)

# Download test_data
test_data = datasets.FashionMNIST(
  root='data',
  train=False,
  download=True,
  transform=ToTensor(),)

# Does not actualy print the raw data, 
# but prints metadata about the dataset
print(type(test_data))
print(test_data)


batch_size = 64

# Data loaders allow you to iterate over datasets
training_data_loader = DataLoader(training_data, batch_size=batch_size)
test_data_loader = DataLoader(test_data, batch_size=batch_size)

# Print the 'shape' of the first element in the test dataset
# The break ensures that only first element is considered.
for x, y in test_data_loader:
  print(f'Shape of x[N, C, H, W]: {x.shape}')
  print(f'Shape of y: {y.shape} {y.dtype}')
  break
